import '../data/u10_curriculum.dart';
import '../models/age_group.dart';
import '../models/attendance_record.dart';
import '../models/season_progress.dart';
import '../models/weekly_schedule.dart';
import 'drill_repository.dart';
import 'roster_repository.dart';
import 'schedule_repository.dart';
import 'season_progress_repository.dart';
import 'session_repository.dart';

/// Runs once per app start. On Saturdays, every roster with a built-in
/// curriculum (currently just U10) gets that week's session automatically
/// assigned to Saturday — unless a coach has changed Saturday away from
/// what was auto-assigned last time, in which case progress pauses on that
/// same week instead of advancing, and picks back up from there next time.
///
/// This intentionally only advances a roster's week when the app is opened
/// on the Saturday itself; there's no background execution to do it while
/// the app is closed.
Future<void> runSeasonAutoAssignment({
  required RosterRepository rosterRepository,
  required ScheduleRepository scheduleRepository,
  required SeasonProgressRepository progressRepository,
  required DrillRepository drillRepository,
  required SessionRepository sessionRepository,
  DateTime? now,
}) async {
  final today = now ?? DateTime.now();
  if (today.weekday != DateTime.saturday) return;
  final todayIso = AttendanceRecord.isoDate(today);

  final u10Weeks = buildU10SeasonPlan();
  final u10Drills = buildU10CurriculumDrills();
  final u10Sessions = buildU10CurriculumSessions();

  for (final roster in rosterRepository.rosters) {
    if (roster.ageGroup != AgeGroup.u10) continue;

    final progress = progressRepository.forRoster(roster.id);
    if (progress != null && progress.lastAssignedDate == todayIso) continue;

    final int nextWeek;
    if (progress == null) {
      nextWeek = 1;
    } else {
      final currentAssignment =
          scheduleRepository.scheduleFor(roster.id).sessionIdFor(DayOfWeek.saturday);
      final untouchedSinceLastAssignment =
          currentAssignment == progress.lastAssignedSessionId;
      nextWeek = untouchedSinceLastAssignment
          ? (progress.currentWeek + 1).clamp(1, u10Weeks.length)
          : progress.currentWeek; // overridden — pause on the same week
    }

    final weekInfo = u10Weeks.firstWhere((w) => w.weekNumber == nextWeek);
    final session = u10Sessions.firstWhere((s) => s.id == weekInfo.sessionId);

    for (final drill in u10Drills) {
      if (drillRepository.byId(drill.id) == null) {
        await drillRepository.saveDrill(drill);
      }
    }
    await sessionRepository.saveSession(session);
    await scheduleRepository.assignSession(roster.id, DayOfWeek.saturday, session.id);
    await progressRepository.save(SeasonProgress(
      rosterId: roster.id,
      currentWeek: nextWeek,
      lastAssignedSessionId: session.id,
      lastAssignedDate: todayIso,
    ));
  }
}
