import 'package:flutter/material.dart';

import 'screens/root_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const SoccerCoachPlannerApp());
}

class SoccerCoachPlannerApp extends StatelessWidget {
  const SoccerCoachPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soccer Coach Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pitch,
          primary: AppColors.pitch,
          secondary: AppColors.accent,
        ),
        scaffoldBackgroundColor: AppColors.surface,
      ),
      home: const RootScreen(),
    );
  }
}
