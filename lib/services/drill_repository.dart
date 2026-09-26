import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/starter_drills.dart';
import '../models/drill.dart';

const _drillsKey = 'drills_v1';

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
