import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach_assignment.dart';

const _assignmentsKey = 'coach_assignments_v1';

class CoachAssignmentRepository {
  List<CoachAssignment> _records = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_assignmentsKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _records = data
        .map((e) => CoachAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<String> forRosterAndDate(String rosterId, String date) {
    for (final r in _records) {
      if (r.rosterId == rosterId && r.date == date) return r.coachIds;
    }
    return const [];
  }

  Future<void> saveAssignment(String rosterId, String date, List<String> coachIds) async {
    final record = CoachAssignment(rosterId: rosterId, date: date, coachIds: coachIds);
    final index =
        _records.indexWhere((r) => r.rosterId == rosterId && r.date == date);
    if (index >= 0) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    await _persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _records.removeWhere((r) => r.rosterId == rosterId);
    await _persist();
  }

  /// Strips a deleted coach out of every date they were assigned to, across
  /// every roster.
  Future<void> removeCoachEverywhere(String coachId) async {
    _records = [
      for (final r in _records)
        if (r.coachIds.contains(coachId))
          CoachAssignment(
            rosterId: r.rosterId,
            date: r.date,
            coachIds: r.coachIds.where((id) => id != coachId).toList(),
          )
        else
          r,
    ];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _assignmentsKey,
      jsonEncode(_records.map((r) => r.toJson()).toList()),
    );
  }
}
