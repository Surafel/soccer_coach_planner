import 'package:flutter/material.dart';

import '../models/age_group.dart';
import '../models/attendance_record.dart';
import '../models/drill.dart';
import '../models/roster.dart';
import '../models/session_drill.dart';
import '../models/session_phase.dart';
import '../services/attendance_repository.dart';
import '../services/coach_assignment_repository.dart';
import '../services/coach_availability_repository.dart';
import '../services/coach_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import 'attendance_screen.dart';
import 'drill_detail_screen.dart';
import 'schedule_screen.dart';

class TodayScreen extends StatelessWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final CoachRepository coachRepository;
  final CoachAvailabilityRepository availabilityRepository;
  final CoachAssignmentRepository assignmentRepository;
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
    required this.coachRepository,
    required this.availabilityRepository,
    required this.assignmentRepository,
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
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                for (final roster in rosters)
                  _RosterToday(
                    roster: roster,
                    drillRepository: drillRepository,
                    sessionRepository: sessionRepository,
                    scheduleRepository: scheduleRepository,
                    rosterRepository: rosterRepository,
                    playerRepository: playerRepository,
                    coachRepository: coachRepository,
                    availabilityRepository: availabilityRepository,
                    assignmentRepository: assignmentRepository,
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
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final CoachRepository coachRepository;
  final CoachAvailabilityRepository availabilityRepository;
  final CoachAssignmentRepository assignmentRepository;
  final AttendanceRepository attendanceRepository;
  final VoidCallback onChanged;

  const _RosterToday({
    required this.roster,
    required this.drillRepository,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.rosterRepository,
    required this.playerRepository,
    required this.coachRepository,
    required this.availabilityRepository,
    required this.assignmentRepository,
    required this.attendanceRepository,
    required this.onChanged,
  });

  void _openSchedule(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          rosterId: roster.id,
          sessionRepository: sessionRepository,
          scheduleRepository: scheduleRepository,
          rosterRepository: rosterRepository,
          coachRepository: coachRepository,
          availabilityRepository: availabilityRepository,
          assignmentRepository: assignmentRepository,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _openAttendance(BuildContext context, String date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          rosterId: roster.id,
          date: date,
          playerRepository: playerRepository,
          attendanceRepository: attendanceRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final todayIso = AttendanceRecord.isoDate(DateTime.now());
    final sessionId = scheduleRepository.scheduleFor(roster.id).sessionIdFor(todayIso);
    final session = sessionId == null ? null : sessionRepository.byId(sessionId);
    final ageGroup = roster.ageGroup;

    // One card per group, so each group's practice reads as its own block
    // instead of running together down the page.
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      elevation: 2,
      // White body so the card stands out from the tinted page background.
      color: colors.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: colors.primaryContainer,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Icon(Icons.groups, color: colors.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    roster.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (ageGroup != null)
                  Text(
                    ageGroupLabel(ageGroup),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
          ),
          if (session == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: Row(
                children: [
                  const Expanded(child: Text('No practice today.')),
                  TextButton(
                    onPressed: () => _openSchedule(context),
                    child: const Text('Edit schedule'),
                  ),
                ],
              ),
            )
          else ...[
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.list_alt)),
              title: Text(session.name),
              subtitle: Text(
                '${session.drills.length} drills · ${session.totalDurationMinutes} min',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openAttendance(context, todayIso),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Take Attendance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSchedule(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Full Schedule'),
                    ),
                  ),
                ],
              ),
            ),
            for (final group in session.phaseGroups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  sessionPhaseLabel(group.key),
                  style: theme.textTheme.titleSmall?.copyWith(color: colors.primary),
                ),
              ),
              for (final entry in group.value)
                if (drillRepository.byId(entry.drillId) != null)
                  _TodayDrillTile(
                    drill: drillRepository.byId(entry.drillId)!,
                    entry: entry,
                  ),
            ],
            const SizedBox(height: 8),
          ],
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
