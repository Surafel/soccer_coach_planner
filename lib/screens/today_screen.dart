import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/drill.dart';
import '../models/session_drill.dart';
import '../models/weekly_schedule.dart';
import '../services/attendance_repository.dart';
import '../services/drill_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_card.dart';
import 'attendance_screen.dart';
import 'drill_detail_screen.dart';

DayOfWeek _todayAsDayOfWeek() {
  // DateTime.weekday is 1 (Monday) through 7 (Sunday), matching enum order.
  return DayOfWeek.values[DateTime.now().weekday - 1];
}

class TodayScreen extends StatelessWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final RosterRepository rosterRepository;
  final AttendanceRepository attendanceRepository;
  final VoidCallback onGoToSchedule;

  const TodayScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.rosterRepository,
    required this.attendanceRepository,
    required this.onGoToSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final today = _todayAsDayOfWeek();
    final sessionId = scheduleRepository.schedule.sessionIdFor(today);
    final session = sessionId == null ? null : sessionRepository.byId(sessionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: session == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No practice today.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onGoToSchedule,
                    child: const Text('Edit schedule'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
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
                                date: AttendanceRecord.isoDate(DateTime.now()),
                                rosterRepository: rosterRepository,
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
                          onPressed: onGoToSchedule,
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Full Schedule'),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final entry in session.drills)
                  if (drillRepository.byId(entry.drillId) != null)
                    _TodayDrillTile(
                      drill: drillRepository.byId(entry.drillId)!,
                      entry: entry,
                    ),
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
