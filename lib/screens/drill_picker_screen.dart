import 'package:flutter/material.dart';

import '../services/drill_repository.dart';
import '../widgets/drill_browser.dart';

class DrillPickerScreen extends StatelessWidget {
  final DrillRepository drillRepository;

  const DrillPickerScreen({super.key, required this.drillRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Drill')),
      body: DrillBrowser(
        drills: drillRepository.drills,
        onTap: (drill) => Navigator.of(context).pop(drill),
      ),
    );
  }
}
