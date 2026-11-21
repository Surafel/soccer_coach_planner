import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One collection's contents: item id -> that item's JSON.
typedef Items = Map<String, Map<String, dynamic>>;

/// Where the repositories keep their data: on this device only
/// ([LocalDataStore]) or in the club's shared database ([SyncedDataStore]).
///
/// Data is grouped into named collections of items, each with a stable id,
/// so a shared store can save and merge each item on its own — two coaches
/// editing different drills, players or dates never overwrite each other.
///
/// Notifies listeners when another device changes the data, after the
/// affected repositories have already been updated through [changes].
abstract class DataStore extends ChangeNotifier {
  /// The collection's items, or null if nothing has ever been saved to it.
  Future<Items?> load(String collection);

  /// Makes [items] the collection's complete contents.
  Future<void> saveAll(String collection, Items items);

  /// The collection's complete contents each time another device changes
  /// it. Never emits for this device's own [saveAll] calls.
  Stream<Items> changes(String collection);
}

/// JSON with map keys sorted, so the same data always encodes to the same
/// string no matter what order a database returns its fields in.
String canonicalJson(Object? value) => jsonEncode(_sortKeys(value));

Object? _sortKeys(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    return {for (final k in keys) k: _sortKeys(value[k])};
  }
  if (value is List) return value.map(_sortKeys).toList();
  return value;
}

/// Keeps each collection as one JSON value in [SharedPreferences] (browser
/// storage on the web) — the app's original, offline-only behaviour.
class LocalDataStore extends DataStore {
  static const _keyPrefix = 'store_v2.';

  @override
  Future<Items?> load(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$collection');
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map((id, json) => MapEntry(id, json as Map<String, dynamic>));
  }

  @override
  Future<void> saveAll(String collection, Items items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$collection', jsonEncode(items));
  }

  /// Nothing else writes to this device's storage.
  @override
  Stream<Items> changes(String collection) => const Stream.empty();
}

/// The shared database as [SyncedDataStore] needs it. [FirestoreRemote] is
/// the real implementation; tests use an in-memory one.
abstract class RemoteCollections {
  /// The collection's complete contents now, then again on every change —
  /// including this device's own writes.
  Stream<Items> watch(String collection);

  /// Saves each item in [changes]; a null value deletes that item.
  Future<void> write(String collection, Map<String, Map<String, dynamic>?> changes);
}

/// A [DataStore] backed by the club's shared database. Saving writes only
/// the items that actually changed, and other devices' changes arrive
/// through [changes] while the app is open.
class SyncedDataStore extends DataStore {
  final RemoteCollections remote;

  SyncedDataStore(this.remote);

  /// The last contents seen or written, per collection, as canonical JSON —
  /// used to work out what changed on save and to ignore echoes of this
  /// device's own writes.
  final _known = <String, Map<String, String>>{};
  final _subscriptions = <String, StreamSubscription<Items>>{};
  final _controllers = <String, StreamController<Items>>{};

  StreamController<Items> _controllerFor(String collection) => _controllers.putIfAbsent(
        collection,
        // Synchronous, so repositories are updated before listeners rebuild.
        () => StreamController<Items>.broadcast(sync: true),
      );

  @override
  Future<Items?> load(String collection) async {
    final first = Completer<Items>();
    await _subscriptions.remove(collection)?.cancel();
    _subscriptions[collection] = remote.watch(collection).listen(
      (items) {
        final encoded = {for (final e in items.entries) e.key: canonicalJson(e.value)};
        if (!first.isCompleted) {
          _known[collection] = encoded;
          first.complete(items);
          return;
        }
        if (mapEquals(encoded, _known[collection])) return; // our own write
        _known[collection] = encoded;
        _controllerFor(collection).add(items);
        notifyListeners();
      },
      onError: (Object error, StackTrace stack) {
        if (!first.isCompleted) first.completeError(error, stack);
      },
    );
    final items = await first.future;
    return items.isEmpty ? null : items;
  }

  @override
  Future<void> saveAll(String collection, Items items) async {
    final known = _known[collection] ?? const {};
    final encoded = {for (final e in items.entries) e.key: canonicalJson(e.value)};
    final changes = <String, Map<String, dynamic>?>{
      for (final e in items.entries)
        if (known[e.key] != encoded[e.key]) e.key: e.value,
      for (final id in known.keys)
        if (!items.containsKey(id)) id: null,
    };
    _known[collection] = encoded;
    if (changes.isEmpty) return;
    await remote.write(collection, changes);
  }

  @override
  Stream<Items> changes(String collection) => _controllerFor(collection).stream;

  @override
  void dispose() {
    for (final s in _subscriptions.values) {
      s.cancel();
    }
    for (final c in _controllers.values) {
      c.close();
    }
    super.dispose();
  }
}
