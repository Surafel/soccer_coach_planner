import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_record.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class AttendanceRepository extends StoredRepository {
  AttendanceRepository({DataStore? store}) : super('attendance', store);

  List<AttendanceRecord> _records = [];

  static String _id(AttendanceRecord r) => pairId(r.rosterId, r.date);

  @override
  List<StoredItem> toItems() => [for (final r in _records) StoredItem(_id(r), r.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _records = [for (final e in items) AttendanceRecord.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'attendance_v1') as List?;
    return data
        ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .map((r) => StoredItem(_id(r), r.toJson()))
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
    await persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _records.removeWhere((r) => r.rosterId == rosterId);
    await persist();
  }
}
