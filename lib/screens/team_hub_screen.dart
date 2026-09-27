import 'package:flutter/material.dart';

import '../services/attendance_repository.dart';
import '../services/coach_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/season_progress_repository.dart';
import '../services/session_repository.dart';
import 'coaches_screen.dart';
import 'players_screen.dart';
import 'rosters_screen.dart';

/// Entry point for everything about the people on the team: the groups
/// (rosters), the full player pool across all of them, and the coaches
/// available to assign to groups.
class TeamHubScreen extends StatelessWidget {
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final CoachRepository coachRepository;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final SessionRepository sessionRepository;
  final DrillRepository drillRepository;
  final SeasonProgressRepository progressRepository;
  final VoidCallback onChanged;

  const TeamHubScreen({
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.groups)),
              title: const Text('Groups'),
              subtitle: Text('${rosterRepository.rosters.length} groups'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RostersScreen(
                    rosterRepository: rosterRepository,
                    playerRepository: playerRepository,
                    coachRepository: coachRepository,
                    scheduleRepository: scheduleRepository,
                    attendanceRepository: attendanceRepository,
                    sessionRepository: sessionRepository,
                    drillRepository: drillRepository,
                    progressRepository: progressRepository,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: const Text('Players'),
              subtitle: Text('${playerRepository.players.length} players across all groups'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayersScreen(
                    playerRepository: playerRepository,
                    rosterRepository: rosterRepository,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.assignment_ind_outlined)),
              title: const Text('Coaches'),
              subtitle: Text('${coachRepository.coaches.length} coaches'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CoachesScreen(
                    coachRepository: coachRepository,
                    rosterRepository: rosterRepository,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
