import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach_assignment.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class CoachAssignmentRepository extends StoredRepository {
  CoachAssignmentRepository({DataStore? store}) : super('coachAssignments', store);

  List<CoachAssignment> _records = [];

  static String _id(CoachAssignment r) => pairId(r.rosterId, r.date);

  @override
  List<StoredItem> toItems() => [for (final r in _records) StoredItem(_id(r), r.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _records = [for (final e in items) CoachAssignment.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'coach_assignments_v1') as List?;
    return data
        ?.map((e) => CoachAssignment.fromJson(e as Map<String, dynamic>))
        .map((r) => StoredItem(_id(r), r.toJson()))
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
    await persist();
  }

  Future<void> deleteForRoster(String rosterId) async {
    _records.removeWhere((r) => r.rosterId == rosterId);
    await persist();
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
    await persist();
  }
}
