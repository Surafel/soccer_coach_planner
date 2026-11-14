import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/starter_drills.dart';
import '../models/drill.dart';

const _drillsKey = 'drills_v1';

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

class DrillRepository {
  List<Drill> _drills = [];
  SharedPreferences? _prefs;

  List<Drill> get drills => List.unmodifiable(_drills);

  /// Seeds the starter drills on first launch (empty storage), then persists
  /// so a coach can freely edit or delete them afterward.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_drillsKey);
    if (raw == null) {
      // buildStarterDrills() returns a `const` list, which is unmodifiable —
      // copy it into a growable list so saveDrill/deleteDrill work on a
      // brand-new install without a restart in between.
      _drills = List.of(buildStarterDrills());
      await _persist();
      return;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    _drills = data.map((e) => Drill.fromJson(e as Map<String, dynamic>)).toList();

    if (_drills.any(_hasRetiredCategoryVideo)) {
      _drills = [
        for (final d in _drills) _hasRetiredCategoryVideo(d) ? _withoutVideo(d) : d,
      ];
      await _persist();
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
    await _persist();
  }

  Future<void> deleteDrill(String id) async {
    _drills.removeWhere((d) => d.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _drillsKey,
      jsonEncode(_drills.map((d) => d.toJson()).toList()),
    );
  }
}
