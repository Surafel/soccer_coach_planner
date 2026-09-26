import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roster.dart';
import '../models/weekly_schedule.dart';

const _schedulesKey = 'weekly_schedules_v2';
// Pre-multi-roster storage: a single WeeklySchedule with no roster key at
// all. Migrated into the legacy roster's slot the first time this loads.
const _legacyScheduleKey = 'weekly_schedule_v1';

class ScheduleRepository {
  Map<String, WeeklySchedule> _schedules = {};
  SharedPreferences? _prefs;

  WeeklySchedule scheduleFor(String rosterId) =>
      _schedules[rosterId] ?? WeeklySchedule.empty();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_schedulesKey);
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _schedules = data.map(
        (rosterId, json) =>
            MapEntry(rosterId, WeeklySchedule.fromJson(json as Map<String, dynamic>)),
      );
      return;
    }
    final legacyRaw = prefs.getString(_legacyScheduleKey);
    if (legacyRaw != null) {
      _schedules = {
        legacyRosterId: WeeklySchedule.fromJson(jsonDecode(legacyRaw) as Map<String, dynamic>),
      };
      await _persist();
    }
  }

  Future<void> assignSession(String rosterId, DayOfWeek day, String? sessionId) async {
    final updated = scheduleFor(rosterId).copyWithAssignment(day, sessionId);
    _schedules = {..._schedules, rosterId: updated};
    await _persist();
  }

  Future<void> deleteRoster(String rosterId) async {
    _schedules = {..._schedules}..remove(rosterId);
    await _persist();
  }

  /// Clears any day, on any roster, currently assigned to [sessionId] (e.g.
  /// after that session is deleted) so no schedule ever points at a
  /// dangling id.
  Future<void> clearSession(String sessionId) async {
    _schedules = _schedules.map((rosterId, schedule) {
      var updated = schedule;
      for (final day in DayOfWeek.values) {
        if (updated.sessionIdFor(day) == sessionId) {
          updated = updated.copyWithAssignment(day, null);
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
