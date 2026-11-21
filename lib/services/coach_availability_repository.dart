import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach_availability.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class CoachAvailabilityRepository extends StoredRepository {
  CoachAvailabilityRepository({DataStore? store}) : super('coachAvailability', store);

  List<CoachAvailability> _records = [];

  static String _id(CoachAvailability r) => pairId(r.coachId, r.date);

  @override
  List<StoredItem> toItems() => [for (final r in _records) StoredItem(_id(r), r.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _records = [for (final e in items) CoachAvailability.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'coach_availability_v1') as List?;
    return data
        ?.map((e) => CoachAvailability.fromJson(e as Map<String, dynamic>))
        .map((r) => StoredItem(_id(r), r.toJson()))
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
    await persist();
  }

  Future<void> deleteForCoach(String coachId) async {
    _records.removeWhere((r) => r.coachId == coachId);
    await persist();
  }
}
