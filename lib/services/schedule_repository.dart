import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule.dart';
import 'data_store.dart';
import 'stored_repository.dart';

/// Stored as one item per roster and date, so coaches scheduling different
/// dates at the same time don't overwrite each other.
class ScheduleRepository extends StoredRepository {
  ScheduleRepository({DataStore? store}) : super('schedules', store);

  Map<String, Schedule> _schedules = {};

  Schedule scheduleFor(String rosterId) => _schedules[rosterId] ?? Schedule.empty();

  @override
  List<StoredItem> toItems() => [
        for (final roster in _schedules.entries)
          for (final a in roster.value.assignments.entries)
            StoredItem(pairId(roster.key, a.key), {
              'rosterId': roster.key,
              'date': a.key,
              'sessionId': a.value,
            }),
      ];

  @override
  void fromItems(List<StoredItem> items) {
    final byRoster = <String, Map<String, String>>{};
    for (final e in items) {
      (byRoster[e.value['rosterId'] as String] ??= {})[e.value['date'] as String] =
          e.value['sessionId'] as String;
    }
    _schedules = byRoster.map((rosterId, dates) => MapEntry(rosterId, Schedule(dates)));
  }

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'schedules_v3') as Map<String, dynamic>?;
    if (data == null) return null;
    _schedules = data.map(
      (rosterId, json) => MapEntry(rosterId, Schedule.fromJson(json as Map<String, dynamic>)),
    );
    return toItems();
  }

  Future<void> assignSession(String rosterId, String date, String? sessionId) async {
    final updated = scheduleFor(rosterId).copyWithAssignment(date, sessionId);
    _schedules = {..._schedules, rosterId: updated};
    await persist();
  }

  Future<void> deleteRoster(String rosterId) async {
    _schedules = {..._schedules}..remove(rosterId);
    await persist();
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
    await persist();
  }
}
