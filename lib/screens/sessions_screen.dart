import 'package:flutter/material.dart';

import '../models/session.dart';
import '../services/drill_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_card.dart';
import 'season_plan_screen.dart';
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

  Future<void> _openSeasonPlan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeasonPlanScreen(
          drillRepository: widget.drillRepository,
          sessionRepository: widget.sessionRepository,
          onChanged: widget.onChanged,
        ),
      ),
    );
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessionRepository.sessions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Season Plan',
            onPressed: _openSeasonPlan,
          ),
        ],
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No sessions yet. Tap + to build a practice plan,',
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'or open the Season Plan for a ready-made curriculum.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openSeasonPlan,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Season Plan'),
                  ),
                ],
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
