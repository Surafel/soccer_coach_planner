import 'package:flutter/material.dart';

import '../data/starter_plan.dart';
import '../models/session.dart';
import '../models/weekly_schedule.dart';
import '../services/drill_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_card.dart';
import 'session_builder_screen.dart';

class SessionsScreen extends StatefulWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final VoidCallback onChanged;

  const SessionsScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.onChanged,
  });

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  Future<void> _openBuilder({Session? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionBuilderScreen(
          drillRepository: widget.drillRepository,
          sessionRepository: widget.sessionRepository,
          existingSession: existing,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _delete(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text('This will remove "${session.name}" and unschedule it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.sessionRepository.deleteSession(session.id);
    await widget.scheduleRepository.clearSession(session.id);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _loadStarterSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Saturday practice?'),
        content: const Text(
          'Adds a "Saturday Practice" session and schedules it every '
          'Saturday, every week, all year, until you change it. This only '
          'touches Saturday — whatever you have scheduled on other days is '
          'left as-is.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Load'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final session = buildStarterSession();
    await widget.sessionRepository.saveSession(session);
    await widget.scheduleRepository.assignSession(DayOfWeek.saturday, session.id);
    setState(() {});
    widget.onChanged();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saturday practice scheduled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessionRepository.sessions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_repeat),
            tooltip: 'Load Saturday practice',
            onPressed: _loadStarterSchedule,
          ),
        ],
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'No sessions yet. Tap + to build a practice plan.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionCard(
                  session: session,
                  onTap: () => _openBuilder(existing: session),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(session),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openBuilder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
