import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_store.dart';

typedef StoredItem = MapEntry<String, Map<String, dynamic>>;

/// Field each stored item carries so a collection comes back in the order
/// its items were first added, wherever it's stored.
const _seqField = '_seq';

/// Base for the repositories: keeps one collection in [store], in order,
/// and picks up other devices' changes while the app is open.
///
/// Subclasses say how their data maps to items ([toItems] / [fromItems])
/// and how to read the format earlier versions saved on the device
/// ([readLegacy]), which is moved into [store] the first time it loads.
abstract class StoredRepository {
  final String collection;
  final DataStore store;

  StoredRepository(this.collection, DataStore? store) : store = store ?? LocalDataStore();

  /// Each item's position, assigned once when it's first saved and never
  /// changed, so deleting or editing an item doesn't rewrite the others.
  final _seq = <String, int>{};
  StreamSubscription<Items>? _changes;

  /// The repository's data as items, in display order.
  @protected
  List<StoredItem> toItems();

  /// Replaces the repository's data with [items], given in display order.
  @protected
  void fromItems(List<StoredItem> items);

  /// This collection as an earlier version stored it on the device, or null
  /// if there's none.
  @protected
  List<StoredItem>? readLegacy(SharedPreferences prefs) => null;

  /// True when the last [load] found nothing ever saved — not even an
  /// empty collection — so a repository can seed starter content.
  @protected
  bool loadedNothing = false;

  Future<void> load() async {
    await _changes?.cancel();
    final items = await store.load(collection);
    loadedNothing = false;
    if (items != null) {
      _apply(items);
    } else {
      final legacy = store is LocalDataStore
          ? readLegacy(await SharedPreferences.getInstance())
          : null;
      if (legacy != null) {
        fromItems(legacy);
        await persist(); // move it into the new format
      } else {
        _seq.clear();
        fromItems(const []);
        loadedNothing = true;
      }
    }
    _changes = store.changes(collection).listen(_apply);
  }

  void _apply(Items items) {
    int seqOf(StoredItem e) => (e.value[_seqField] as num?)?.toInt() ?? 1 << 52;
    final entries = items.entries.toList()
      ..sort((a, b) {
        final bySeq = seqOf(a).compareTo(seqOf(b));
        return bySeq != 0 ? bySeq : a.key.compareTo(b.key);
      });
    _seq
      ..clear()
      ..addAll({for (final e in entries) e.key: seqOf(e)});
    fromItems([
      for (final e in entries) StoredItem(e.key, Map.of(e.value)..remove(_seqField)),
    ]);
  }

  /// Saves the repository's current data to [store].
  @protected
  Future<void> persist() {
    final items = toItems();
    final ids = {for (final e in items) e.key};
    _seq.removeWhere((id, _) => !ids.contains(id));
    var next = _seq.values.fold(0, max) + 1;
    return store.saveAll(collection, {
      for (final e in items) e.key: {...e.value, _seqField: _seq[e.key] ??= next++},
    });
  }
}

/// Reads a JSON value an earlier version saved under [key], or null.
Object? readLegacyJson(SharedPreferences prefs, String key) {
  final raw = prefs.getString(key);
  return raw == null ? null : jsonDecode(raw);
}

/// Id for an item keyed by two values, e.g. a roster and a date.
String pairId(String a, String b) => '${a}__$b';
