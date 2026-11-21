import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach.dart';
import 'data_store.dart';
import 'stored_repository.dart';

class CoachRepository extends StoredRepository {
  CoachRepository({DataStore? store}) : super('coaches', store);

  List<Coach> _coaches = [];

  List<Coach> get coaches => List.unmodifiable(_coaches);

  @override
  List<StoredItem> toItems() => [for (final c in _coaches) StoredItem(c.id, c.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _coaches = [for (final e in items) Coach.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'coaches_v1') as List?;
    return data
        ?.map((e) => Coach.fromJson(e as Map<String, dynamic>))
        .map((c) => StoredItem(c.id, c.toJson()))
        .toList();
  }

  Coach? byId(String id) {
    for (final c in _coaches) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<String> namesFor(Iterable<String> ids) => [
        for (final id in ids)
          if (byId(id) != null) byId(id)!.name,
      ];

  Future<void> saveCoach(Coach coach) async {
    final index = _coaches.indexWhere((c) => c.id == coach.id);
    if (index >= 0) {
      _coaches[index] = coach;
    } else {
      _coaches.add(coach);
    }
    await persist();
  }

  Future<void> deleteCoach(String id) async {
    _coaches.removeWhere((c) => c.id == id);
    await persist();
  }
}
