import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';

const _attendanceKey = 'attendance_v1';

class AttendanceRepository {
  List<AttendanceRecord> _records = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_attendanceKey);
    if (raw == null) return;
    final data = jsonDecode(raw) as List<dynamic>;
    _records = data
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  AttendanceRecord? forRosterAndDate(String rosterId, String date) {
    for (final r in _records) {
      if (r.rosterId == rosterId && r.date == date) return r;
    }
    return null;
  }

  Future<void> saveAttendance(
    String rosterId,
    String date,
    List<String> presentPlayerIds,
  ) async {
    final record = AttendanceRecord(
      rosterId: rosterId,
      date: date,
      presentPlayerIds: presentPlayerIds,
    );
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

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _attendanceKey,
      jsonEncode(_records.map((r) => r.toJson()).toList()),
    );
  }
}
