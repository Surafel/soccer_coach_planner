import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

const _rosterKey = 'roster_v1';

class RosterRepository {
  List<Player> _players = [];
  SharedPreferences? _prefs;

  List<Player> get players => List.unmodifiable(_players);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_rosterKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _players =
        data.map((e) => Player.fromJson(e as Map<String, dynamic>)).toList();
  }

  Player? byId(String id) {
    for (final p in _players) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> savePlayer(Player player) async {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index >= 0) {
      _players[index] = player;
    } else {
      _players.add(player);
    }
    await _persist();
  }

  Future<void> deletePlayer(String id) async {
    _players.removeWhere((p) => p.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _rosterKey,
      jsonEncode(_players.map((p) => p.toJson()).toList()),
    );
  }
}
