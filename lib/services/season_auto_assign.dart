import '../data/season_curricula.dart';
import '../models/attendance_record.dart';
import '../models/season_progress.dart';
import 'drill_repository.dart';
import 'roster_repository.dart';
import 'schedule_repository.dart';
import 'season_progress_repository.dart';
import 'session_repository.dart';

/// Runs once per app start. On Saturdays, every roster with a built-in
/// curriculum (see [curriculumAgeGroups]) gets that week's session automatically
/// assigned to that specific Saturday's calendar date — unless a coach has
/// changed what's on the *previous* auto-assigned Saturday, in which case
/// progress pauses on that same week instead of advancing, and picks back
/// up from there the next Saturday.
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

  for (final roster in rosterRepository.rosters) {
    final curriculum = seasonCurriculumFor(roster.ageGroup);
    if (curriculum == null) continue;

    final progress = progressRepository.forRoster(roster.id);
    if (progress != null && progress.lastAssignedDate == todayIso) continue;

    final int nextWeek;
    // Progress from a different plan (the roster's age group was changed)
    // doesn't carry over: the new plan starts from its own week 1.
    if (progress == null || !curriculum.ownsSession(progress.lastAssignedSessionId)) {
      nextWeek = 1;
    } else {
      final pastAssignment = scheduleRepository
          .scheduleFor(roster.id)
          .sessionIdFor(progress.lastAssignedDate);
      final untouchedSinceLastAssignment =
          pastAssignment == progress.lastAssignedSessionId;
      nextWeek = untouchedSinceLastAssignment
          ? (progress.currentWeek + 1).clamp(1, curriculum.weeks.length)
          : progress.currentWeek; // overridden — pause on the same week
    }

    final weekInfo = curriculum.weeks.firstWhere((w) => w.weekNumber == nextWeek);
    final session = curriculum.sessionById(weekInfo.sessionId);

    for (final drill in curriculum.drills) {
      if (drillRepository.byId(drill.id) == null) {
        await drillRepository.saveDrill(drill);
      }
    }
    await sessionRepository.saveSession(session);
    await scheduleRepository.assignSession(roster.id, todayIso, session.id);
    await progressRepository.save(SeasonProgress(
      rosterId: roster.id,
      currentWeek: nextWeek,
      lastAssignedSessionId: session.id,
      lastAssignedDate: todayIso,
    ));
  }
}
