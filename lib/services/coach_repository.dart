import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach.dart';

const _coachesKey = 'coaches_v1';

class CoachRepository {
  List<Coach> _coaches = [];
  SharedPreferences? _prefs;

  List<Coach> get coaches => List.unmodifiable(_coaches);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_coachesKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _coaches =
        data.map((e) => Coach.fromJson(e as Map<String, dynamic>)).toList();
  }

  Coach? byId(String id) {
    for (final c in _coaches) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<String> namesFor(Iterable<String> ids) => [
        for (final id in ids)
          if (byId(id) != null) byId(id)!.name,
      ];

  Future<void> saveCoach(Coach coach) async {
    final index = _coaches.indexWhere((c) => c.id == coach.id);
    if (index >= 0) {
      _coaches[index] = coach;
    } else {
      _coaches.add(coach);
    }
    await _persist();
  }

  Future<void> deleteCoach(String id) async {
    _coaches.removeWhere((c) => c.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _coachesKey,
      jsonEncode(_coaches.map((c) => c.toJson()).toList()),
    );
  }
}
