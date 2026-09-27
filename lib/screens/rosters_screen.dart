import 'package:flutter/material.dart';

import '../services/attendance_repository.dart';
import '../services/coach_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/season_progress_repository.dart';
import '../services/session_repository.dart';
import '../widgets/roster_card.dart';
import 'roster_detail_screen.dart';
import 'roster_form_screen.dart';

class RostersScreen extends StatefulWidget {
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final CoachRepository coachRepository;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final SessionRepository sessionRepository;
  final DrillRepository drillRepository;
  final SeasonProgressRepository progressRepository;
  final VoidCallback onChanged;

  const RostersScreen({
    super.key,
    required this.rosterRepository,
    required this.playerRepository,
    required this.coachRepository,
    required this.scheduleRepository,
    required this.attendanceRepository,
    required this.sessionRepository,
    required this.drillRepository,
    required this.progressRepository,
    required this.onChanged,
  });

  @override
  State<RostersScreen> createState() => _RostersScreenState();
}

class _RostersScreenState extends State<RostersScreen> {
  Future<void> _createRoster() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RosterFormScreen(
          rosterRepository: widget.rosterRepository,
          coachRepository: widget.coachRepository,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _openRoster(String rosterId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RosterDetailScreen(
          rosterId: rosterId,
          rosterRepository: widget.rosterRepository,
          playerRepository: widget.playerRepository,
          coachRepository: widget.coachRepository,
          scheduleRepository: widget.scheduleRepository,
          attendanceRepository: widget.attendanceRepository,
          sessionRepository: widget.sessionRepository,
          drillRepository: widget.drillRepository,
          progressRepository: widget.progressRepository,
          onChanged: widget.onChanged,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final rosters = widget.rosterRepository.rosters;
    return Scaffold(
      appBar: AppBar(title: const Text('Rosters')),
      body: rosters.isEmpty
          ? const Center(
              child: Text(
                'No rosters yet. Tap + to create your first team.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: rosters.length,
              itemBuilder: (context, index) {
                final roster = rosters[index];
                return RosterCard(
                  roster: roster,
                  playerCount: widget.playerRepository.playersForRoster(roster.id).length,
                  coachNames: widget.coachRepository.namesFor(roster.coachIds),
                  onTap: () => _openRoster(roster.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoster,
        child: const Icon(Icons.add),
      ),
    );
  }
}
