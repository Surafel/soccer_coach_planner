import 'package:flutter/material.dart';

import '../models/drill.dart';

class AppColors {
  AppColors._();

  static const pitch = Color(0xFF1B5E3A);
  static const pitchDark = Color(0xFF123D26);
  static const accent = Color(0xFFFFC107);
  static const surface = Color(0xFFF5F7F5);
  static const bodyText = Color(0xFF1C1C1E);
  static const muted = Color(0xFF6E7A72);

  static const _categoryColors = {
    DrillCategory.dribbling: Color(0xFF2E86AB),
    DrillCategory.passing: Color(0xFF4CAF50),
    DrillCategory.shooting: Color(0xFFE0522E),
    DrillCategory.fitness: Color(0xFFB185DB),
    DrillCategory.ballControl: Color(0xFFE0B02E),
  };

  static Color colorFor(DrillCategory category) =>
      _categoryColors[category] ?? pitch;
}
