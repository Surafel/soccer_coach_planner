import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/root_screen.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SoccerCoachPlannerApp(sharedData: await _startFirebase()));
}

/// Connects to the club's Firebase project. Returns false when Firebase
/// hasn't been set up for this build (lib/firebase_options.dart is still the
/// placeholder), in which case the app keeps its data on the device.
Future<bool> _startFirebase() async {
  final FirebaseOptions options;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
  } on UnsupportedError {
    return false;
  }
  await Firebase.initializeApp(options: options);
  // Keep a copy of the shared data on the device, so the app opens and
  // works without a connection and catches up when it's back.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  return true;
}

class SoccerCoachPlannerApp extends StatelessWidget {
  /// True when coaches sign in and share the club's data; false keeps
  /// everything on this device.
  final bool sharedData;

  const SoccerCoachPlannerApp({super.key, this.sharedData = false});

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
      home: sharedData ? const AuthGate() : const RootScreen(),
    );
  }
}
