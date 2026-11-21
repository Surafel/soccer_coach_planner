import 'package:shared_preferences/shared_preferences.dart';

import '../data/starter_drills.dart';
import '../models/drill.dart';
import 'data_store.dart';
import 'stored_repository.dart';

/// Earlier versions gave every built-in curriculum drill one shared
/// "reference" video per category, so different drills showed the same
/// unrelated video. These are those ids; [DrillRepository.load] clears them
/// from curriculum drills saved by those versions so the drills fall back to
/// a search for their own name. A video a coach set themselves is kept.
const _retiredCategoryVideoIds = {
  'CosG13seo3o',
  'npeM7yvN_8A',
  '6RGJBj1tNC8',
  '9jQRQsnyfKw',
  'OzTEOTEVMPg',
  'IHeUKdsVHHg',
  '9ojC_3pd-3k',
  'EvZdkjyrx5k',
};

const _curriculumDrillPrefixes = ['drill-u10-', 'drill-u12-'];

bool _hasRetiredCategoryVideo(Drill d) =>
    _retiredCategoryVideoIds.contains(d.videoId) &&
    _curriculumDrillPrefixes.any(d.id.startsWith);

Drill _withoutVideo(Drill d) => Drill(
      id: d.id,
      name: d.name,
      category: d.category,
      skillTags: d.skillTags,
      description: d.description,
      ageRange: d.ageRange,
    );

class DrillRepository extends StoredRepository {
  DrillRepository({DataStore? store}) : super('drills', store);

  List<Drill> _drills = [];

  List<Drill> get drills => List.unmodifiable(_drills);

  @override
  List<StoredItem> toItems() => [for (final d in _drills) StoredItem(d.id, d.toJson())];

  @override
  void fromItems(List<StoredItem> items) =>
      _drills = [for (final e in items) Drill.fromJson(e.value)];

  @override
  List<StoredItem>? readLegacy(SharedPreferences prefs) {
    final data = readLegacyJson(prefs, 'drills_v1') as List?;
    return data
        ?.map((e) => Drill.fromJson(e as Map<String, dynamic>))
        .map((d) => StoredItem(d.id, d.toJson()))
        .toList();
  }

  /// Seeds the starter drills the first time (nothing ever saved), then
  /// persists so a coach can freely edit or delete them afterward.
  @override
  Future<void> load() async {
    await super.load();
    if (loadedNothing) {
      _drills = List.of(buildStarterDrills());
      await persist();
      return;
    }
    if (_drills.any(_hasRetiredCategoryVideo)) {
      _drills = [
        for (final d in _drills) _hasRetiredCategoryVideo(d) ? _withoutVideo(d) : d,
      ];
      await persist();
    }
  }

  Drill? byId(String id) {
    for (final d in _drills) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<Drill> byCategory(DrillCategory? category) {
    if (category == null) return drills;
    return _drills.where((d) => d.category == category).toList();
  }

  List<Drill> search(String query) {
    if (query.isEmpty) return drills;
    final q = query.toLowerCase();
    return _drills.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  Future<void> saveDrill(Drill drill) async {
    final index = _drills.indexWhere((d) => d.id == drill.id);
    if (index >= 0) {
      _drills[index] = drill;
    } else {
      _drills.add(drill);
    }
    await persist();
  }

  Future<void> deleteDrill(String id) async {
    _drills.removeWhere((d) => d.id == id);
    await persist();
  }
}
