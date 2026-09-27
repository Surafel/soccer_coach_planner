import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach_availability.dart';

const _availabilityKey = 'coach_availability_v1';

class CoachAvailabilityRepository {
  List<CoachAvailability> _records = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_availabilityKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _records = data
        .map((e) => CoachAvailability.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// True if available, false if marked unavailable, null if the coach
  /// hasn't answered for this date yet.
  bool? availabilityFor(String coachId, String date) {
    for (final r in _records) {
      if (r.coachId == coachId && r.date == date) return r.available;
    }
    return null;
  }

  Map<String, bool> allFor(String coachId) => {
        for (final r in _records)
          if (r.coachId == coachId) r.date: r.available,
      };

  /// Pass `null` to clear a coach's answer for that date.
  Future<void> setAvailability(String coachId, String date, bool? available) async {
    _records.removeWhere((r) => r.coachId == coachId && r.date == date);
    if (available != null) {
      _records.add(CoachAvailability(coachId: coachId, date: date, available: available));
    }
    await _persist();
  }

  Future<void> deleteForCoach(String coachId) async {
    _records.removeWhere((r) => r.coachId == coachId);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _availabilityKey,
      jsonEncode(_records.map((r) => r.toJson()).toList()),
    );
  }
}
