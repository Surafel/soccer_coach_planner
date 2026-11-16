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
import '../widgets/schedule_entry_tile.dart';
import 'attendance_screen.dart';
import 'drill_detail_screen.dart';
import 'schedule_screen.dart';

class TodayScreen extends StatefulWidget {
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
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  /// The date a coach picked, or null to follow the current day (so the
  /// screen still shows "today" if the app is left open past midnight).
  DateTime? _pickedDate;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _date => _pickedDate ?? _dateOnly(DateTime.now());

  bool get _isToday => _date == _dateOnly(DateTime.now());

  void _setDate(DateTime date) {
    final day = _dateOnly(date);
    setState(() => _pickedDate = day == _dateOnly(DateTime.now()) ? null : day);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) _setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final rosters = widget.rosterRepository.rosters;
    final date = AttendanceRecord.isoDate(_date);

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
                    onPressed: widget.onGoToRosters,
                    child: const Text('Create a roster'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _DateSelector(
                  label: formatScheduleDate(date),
                  isToday: _isToday,
                  onPrevious: () => _setDate(_date.subtract(const Duration(days: 1))),
                  onNext: () => _setDate(_date.add(const Duration(days: 1))),
                  onPick: _pickDate,
                  onToday: () => setState(() => _pickedDate = null),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      for (final roster in rosters)
                        _RosterToday(
                          roster: roster,
                          date: date,
                          isToday: _isToday,
                          drillRepository: widget.drillRepository,
                          sessionRepository: widget.sessionRepository,
                          scheduleRepository: widget.scheduleRepository,
                          rosterRepository: widget.rosterRepository,
                          playerRepository: widget.playerRepository,
                          coachRepository: widget.coachRepository,
                          availabilityRepository: widget.availabilityRepository,
                          assignmentRepository: widget.assignmentRepository,
                          attendanceRepository: widget.attendanceRepository,
                          onChanged: widget.onChanged,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// The bar at the top of the Today screen for choosing which date's
/// practices to show.
class _DateSelector extends StatelessWidget {
  final String label;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;
  final VoidCallback onToday;

  const _DateSelector({
    required this.label,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous day',
              onPressed: onPrevious,
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  label,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next day',
              onPressed: onNext,
            ),
            // Same width either way, so the date doesn't shift when it appears.
            Visibility(
              visible: !isToday,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(onPressed: onToday, child: const Text('Today')),
            ),
          ],
        ),
      ),
    );
  }
}

class _RosterToday extends StatelessWidget {
  final Roster roster;
  final String date;
  final bool isToday;
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
    required this.date,
    required this.isToday,
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
    final sessionId = scheduleRepository.scheduleFor(roster.id).sessionIdFor(date);
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
                  Expanded(
                    child: Text(isToday ? 'No practice today.' : 'No practice this day.'),
                  ),
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
                      onPressed: () => _openAttendance(context, date),
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
