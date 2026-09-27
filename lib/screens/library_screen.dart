import 'package:flutter/material.dart';

import '../data/starter_drills.dart';
import '../services/drill_repository.dart';
import '../widgets/drill_browser.dart';
import 'drill_detail_screen.dart';
import 'drill_form_screen.dart';

class LibraryScreen extends StatefulWidget {
  final DrillRepository drillRepository;
  final VoidCallback onChanged;

  const LibraryScreen({
    super.key,
    required this.drillRepository,
    required this.onChanged,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> _reloadStarterDrills() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reload starter drills?'),
        content: const Text(
          'Restores the 10 built-in drills to their original names, '
          'descriptions, and videos. Any of your own drills are left alone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reload'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    for (final drill in buildStarterDrills()) {
      await widget.drillRepository.saveDrill(drill);
    }
    setState(() {});
    widget.onChanged();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starter drills reloaded.')),
      );
    }
  }

  Future<void> _addDrill() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrillFormScreen(drillRepository: widget.drillRepository),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Reload starter drills',
            onPressed: _reloadStarterDrills,
          ),
        ],
      ),
      body: DrillBrowser(
        drills: widget.drillRepository.drills,
        onTap: (drill) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DrillDetailScreen(
              drill: drill,
              drillRepository: widget.drillRepository,
              onChanged: () {
                setState(() {});
                widget.onChanged();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDrill,
        child: const Icon(Icons.add),
      ),
    );
  }
}
