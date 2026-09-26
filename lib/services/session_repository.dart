import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';

const _sessionsKey = 'sessions_v1';

class SessionRepository {
  List<Session> _sessions = [];
  SharedPreferences? _prefs;

  List<Session> get sessions => List.unmodifiable(_sessions);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_sessionsKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _sessions =
        data.map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
  }

  Session? byId(String id) {
    for (final s in _sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> saveSession(Session session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
    await _persist();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionsKey,
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
  }
}
