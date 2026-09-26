import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weekly_schedule.dart';

const _scheduleKey = 'weekly_schedule_v1';

class ScheduleRepository {
  WeeklySchedule _schedule = WeeklySchedule.empty();
  SharedPreferences? _prefs;

  WeeklySchedule get schedule => _schedule;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_scheduleKey);
    if (raw != null) {
      _schedule =
          WeeklySchedule.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  Future<void> assignSession(DayOfWeek day, String? sessionId) async {
    _schedule = _schedule.copyWithAssignment(day, sessionId);
    await _persist();
  }

  /// Clears any day currently assigned to [sessionId] (e.g. after that
  /// session is deleted) so the schedule never points at a dangling id.
  Future<void> clearSession(String sessionId) async {
    var updated = _schedule;
    for (final day in DayOfWeek.values) {
      if (updated.sessionIdFor(day) == sessionId) {
        updated = updated.copyWithAssignment(day, null);
      }
    }
    _schedule = updated;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_scheduleKey, jsonEncode(_schedule.toJson()));
  }
}
