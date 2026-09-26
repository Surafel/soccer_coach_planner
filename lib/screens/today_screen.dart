import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/drill.dart';
import '../models/roster.dart';
import '../models/session_drill.dart';
import '../models/session_phase.dart';
import '../services/attendance_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_card.dart';
import 'attendance_screen.dart';
import 'drill_detail_screen.dart';
import 'schedule_screen.dart';

class TodayScreen extends StatelessWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final AttendanceRepository attendanceRepository;
  final VoidCallback onGoToRosters;
  final VoidCallback onChanged;

  const TodayScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.rosterRepository,
    required this.playerRepository,
    required this.attendanceRepository,
    required this.onGoToRosters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final rosters = rosterRepository.rosters;

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: rosters.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No rosters yet.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onGoToRosters,
                    child: const Text('Create a roster'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                for (final roster in rosters)
                  _RosterToday(
                    roster: roster,
                    drillRepository: drillRepository,
                    sessionRepository: sessionRepository,
                    scheduleRepository: scheduleRepository,
                    playerRepository: playerRepository,
                    attendanceRepository: attendanceRepository,
                    onChanged: onChanged,
                  ),
              ],
            ),
    );
  }
}

class _RosterToday extends StatelessWidget {
  final Roster roster;
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final PlayerRepository playerRepository;
  final AttendanceRepository attendanceRepository;
  final VoidCallback onChanged;

  const _RosterToday({
    required this.roster,
    required this.drillRepository,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.playerRepository,
    required this.attendanceRepository,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final todayIso = AttendanceRecord.isoDate(DateTime.now());
    final sessionId = scheduleRepository.scheduleFor(roster.id).sessionIdFor(todayIso);
    final session = sessionId == null ? null : sessionRepository.byId(sessionId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(roster.name, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (session == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  const Expanded(child: Text('No practice today.')),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScheduleScreen(
                          rosterId: roster.id,
                          sessionRepository: sessionRepository,
                          scheduleRepository: scheduleRepository,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                    child: const Text('Edit schedule'),
                  ),
                ],
              ),
            )
          else ...[
            SessionCard(session: session),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                            rosterId: roster.id,
                            date: AttendanceRecord.isoDate(DateTime.now()),
                            playerRepository: playerRepository,
                            attendanceRepository: attendanceRepository,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Take Attendance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScheduleScreen(
                            rosterId: roster.id,
                            sessionRepository: sessionRepository,
                            scheduleRepository: scheduleRepository,
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Full Schedule'),
                    ),
                  ),
                ],
              ),
            ),
            for (final group in session.phaseGroups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Text(
                  sessionPhaseLabel(group.key),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              for (final entry in group.value)
                if (drillRepository.byId(entry.drillId) != null)
                  _TodayDrillTile(
                    drill: drillRepository.byId(entry.drillId)!,
                    entry: entry,
                  ),
            ],
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class _TodayDrillTile extends StatelessWidget {
  final Drill drill;
  final SessionDrill entry;

  const _TodayDrillTile({required this.drill, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(drill.name),
      subtitle: Text('${entry.durationMinutes} min'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DrillDetailScreen(drill: drill),
        ),
      ),
    );
  }
}
