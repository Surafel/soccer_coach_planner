import 'package:flutter/material.dart';

import '../models/weekly_schedule.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/day_schedule_tile.dart';

class ScheduleScreen extends StatefulWidget {
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final VoidCallback onChanged;

  const ScheduleScreen({
    super.key,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.onChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Future<void> _pickSession(DayOfWeek day) async {
    final sessions = widget.sessionRepository.sessions;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('No practice'),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1),
            for (final session in sessions)
              ListTile(
                title: Text(session.name),
                onTap: () => Navigator.of(context).pop(session.id),
              ),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No saved sessions yet. Build one in the Sessions tab.'),
              ),
          ],
        ),
      ),
    );
    await widget.scheduleRepository.assignSession(day, selected);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.scheduleRepository.schedule;
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Schedule')),
      body: ListView(
        children: [
          for (final day in DayOfWeek.values)
            DayScheduleTile(
              day: day,
              assignedSession: schedule.sessionIdFor(day) == null
                  ? null
                  : widget.sessionRepository.byId(schedule.sessionIdFor(day)!),
              onTap: () => _pickSession(day),
            ),
        ],
      ),
    );
  }
}
