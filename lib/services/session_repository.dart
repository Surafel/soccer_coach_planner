import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class SessionRepository extends StoredRepository {
  SessionRepository({DataStore? store}) : super('sessions', store);

  List<Session> _sessions = [];

  List<Session> get sessions => List.unmodifiable(_sessions);

  @override
  List<StoredItem> toItems() => [for (final s in _sessions) StoredItem(s.id, s.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _sessions = [for (final e in items) Session.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'sessions_v1') as List?;
    return data
        ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
        .map((s) => StoredItem(s.id, s.toJson()))
        .toList();
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
    await persist();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await persist();
  }
}
