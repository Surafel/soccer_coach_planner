import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/schedule_entry_tile.dart';

class ScheduleScreen extends StatefulWidget {
  final String rosterId;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final VoidCallback onChanged;

  const ScheduleScreen({
    super.key,
    required this.rosterId,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.onChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Future<String?> _pickSession() {
    final sessions = widget.sessionRepository.sessions;
    return showModalBottomSheet<String?>(
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
  }

  Future<void> _assignDate(String date) async {
    final selected = await _pickSession();
    await widget.scheduleRepository.assignSession(widget.rosterId, date, selected);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _removeDate(String date) async {
    await widget.scheduleRepository.assignSession(widget.rosterId, date, null);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _addToSchedule() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    await _assignDate(AttendanceRecord.isoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.scheduleRepository.scheduleFor(widget.rosterId);
    final dates = schedule.sortedDates;
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: dates.isEmpty
          ? const Center(
              child: Text(
                'No practices scheduled yet. Tap + to pick a date.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              children: [
                for (final date in dates)
                  ScheduleEntryTile(
                    date: date,
                    assignedSession: schedule.sessionIdFor(date) == null
                        ? null
                        : widget.sessionRepository.byId(schedule.sessionIdFor(date)!),
                    onTap: () => _assignDate(date),
                    onRemove: () => _removeDate(date),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addToSchedule,
        icon: const Icon(Icons.calendar_month),
        label: const Text('Add date'),
      ),
    );
  }
}
