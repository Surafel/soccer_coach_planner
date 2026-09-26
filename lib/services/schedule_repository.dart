import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule.dart';

const _schedulesKey = 'schedules_v3';

class ScheduleRepository {
  Map<String, Schedule> _schedules = {};
  SharedPreferences? _prefs;

  Schedule scheduleFor(String rosterId) => _schedules[rosterId] ?? Schedule.empty();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_schedulesKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _schedules = data.map(
      (rosterId, json) => MapEntry(rosterId, Schedule.fromJson(json as Map<String, dynamic>)),
    );
  }

  Future<void> assignSession(String rosterId, String date, String? sessionId) async {
    final updated = scheduleFor(rosterId).copyWithAssignment(date, sessionId);
    _schedules = {..._schedules, rosterId: updated};
    await _persist();
  }

  Future<void> deleteRoster(String rosterId) async {
    _schedules = {..._schedules}..remove(rosterId);
    await _persist();
  }

  /// Clears any date, on any roster, currently assigned to [sessionId] (e.g.
  /// after that session is deleted) so no schedule ever points at a
  /// dangling id.
  Future<void> clearSession(String sessionId) async {
    _schedules = _schedules.map((rosterId, schedule) {
      var updated = schedule;
      for (final date in schedule.assignments.keys.toList()) {
        if (updated.sessionIdFor(date) == sessionId) {
          updated = updated.copyWithAssignment(date, null);
        }
      }
      return MapEntry(rosterId, updated);
    });
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _schedulesKey,
      jsonEncode(_schedules.map((rosterId, schedule) => MapEntry(rosterId, schedule.toJson()))),
    );
  }
}
