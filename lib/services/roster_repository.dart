import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roster.dart';

const _rostersKey = 'rosters_v1';

class RosterRepository {
  List<Roster> _rosters = [];
  SharedPreferences? _prefs;

  List<Roster> get rosters => List.unmodifiable(_rosters);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_rostersKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _rosters =
        data.map((e) => Roster.fromJson(e as Map<String, dynamic>)).toList();
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
    await _persist();
  }

  Future<void> deleteRoster(String id) async {
    _rosters.removeWhere((r) => r.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _rostersKey,
      jsonEncode(_rosters.map((r) => r.toJson()).toList()),
    );
  }
}
