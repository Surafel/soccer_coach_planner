import 'package:shared_preferences/shared_preferences.dart';

import '../models/roster.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class RosterRepository extends StoredRepository {
  RosterRepository({DataStore? store}) : super('rosters', store);

  List<Roster> _rosters = [];

  List<Roster> get rosters => List.unmodifiable(_rosters);

  @override
  List<StoredItem> toItems() => [for (final r in _rosters) StoredItem(r.id, r.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _rosters = [for (final e in items) Roster.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'rosters_v1') as List?;
    return data
        ?.map((e) => Roster.fromJson(e as Map<String, dynamic>))
        .map((r) => StoredItem(r.id, r.toJson()))
        .toList();
  }

  Roster? byId(String id) {
    for (final r in _rosters) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> saveRoster(Roster roster) async {
    final index = _rosters.indexWhere((r) => r.id == roster.id);
    if (index >= 0) {
      _rosters[index] = roster;
    } else {
      _rosters.add(roster);
    }
    await persist();
  }

  Future<void> deleteRoster(String id) async {
    _rosters.removeWhere((r) => r.id == id);
    await persist();
  }
}
