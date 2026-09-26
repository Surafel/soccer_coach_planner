import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/data/u10_curriculum.dart';
import 'package:soccer_coach_planner/models/age_group.dart';
import 'package:soccer_coach_planner/models/attendance_record.dart';
import 'package:soccer_coach_planner/models/roster.dart';
import 'package:soccer_coach_planner/services/drill_repository.dart';
import 'package:soccer_coach_planner/services/roster_repository.dart';
import 'package:soccer_coach_planner/services/schedule_repository.dart';
import 'package:soccer_coach_planner/services/season_auto_assign.dart';
import 'package:soccer_coach_planner/services/season_progress_repository.dart';
import 'package:soccer_coach_planner/services/session_repository.dart';

// A known Saturday, and the following Saturdays a week apart.
final _week1Saturday = DateTime(2026, 1, 3);
final _week2Saturday = _week1Saturday.add(const Duration(days: 7));
final _week3Saturday = _week1Saturday.add(const Duration(days: 14));
final _week4Saturday = _week1Saturday.add(const Duration(days: 21));

String _iso(DateTime date) => AttendanceRecord.isoDate(date);

void main() {
  late RosterRepository rosterRepository;
  late ScheduleRepository scheduleRepository;
  late SeasonProgressRepository progressRepository;
  late DrillRepository drillRepository;
  late SessionRepository sessionRepository;
  const rosterId = 'roster-1';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    rosterRepository = RosterRepository();
    scheduleRepository = ScheduleRepository();
    progressRepository = SeasonProgressRepository();
    drillRepository = DrillRepository();
    sessionRepository = SessionRepository();
    await Future.wait([
      rosterRepository.load(),
      scheduleRepository.load(),
      progressRepository.load(),
      drillRepository.load(),
      sessionRepository.load(),
    ]);
    await rosterRepository.saveRoster(
      const Roster(id: rosterId, name: 'U10 Blue', ageGroup: AgeGroup.u10),
    );
  });

  Future<void> runFor(DateTime saturday) => runSeasonAutoAssignment(
        rosterRepository: rosterRepository,
        scheduleRepository: scheduleRepository,
        progressRepository: progressRepository,
        drillRepository: drillRepository,
        sessionRepository: sessionRepository,
        now: saturday,
      );

  String? sessionIdOn(DateTime date) =>
      scheduleRepository.scheduleFor(rosterId).sessionIdFor(_iso(date));

  test('does nothing on a non-Saturday', () async {
    final monday = DateTime(2026, 1, 5);
    await runFor(monday);
    expect(progressRepository.forRoster(rosterId), isNull);
    expect(sessionIdOn(monday), isNull);
  });

  test('first Saturday assigns week 1 to that date', () async {
    await runFor(_week1Saturday);
    final progress = progressRepository.forRoster(rosterId);
    expect(progress?.currentWeek, 1);
    final week1SessionId = buildU10SeasonPlan().first.sessionId;
    expect(sessionIdOn(_week1Saturday), week1SessionId);
  });

  test('running again the same Saturday does not advance', () async {
    await runFor(_week1Saturday);
    await runFor(_week1Saturday);
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 1);
  });

  test('untouched week advances to the next week on the next Saturday\'s date', () async {
    await runFor(_week1Saturday);
    await runFor(_week2Saturday);
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 2);
    final week2SessionId = buildU10SeasonPlan()[1].sessionId;
    expect(sessionIdOn(_week2Saturday), week2SessionId);
    // Week 1's own date keeps its original assignment.
    final week1SessionId = buildU10SeasonPlan().first.sessionId;
    expect(sessionIdOn(_week1Saturday), week1SessionId);
  });

  test('an override on the past Saturday pauses progress on the same week', () async {
    await runFor(_week1Saturday);
    // Coach overrides that Saturday's date with something else during the week.
    await scheduleRepository.assignSession(rosterId, _iso(_week1Saturday), 'custom-session');

    await runFor(_week2Saturday);
    // Stays paused on week 1, and assigns week 1's session to this Saturday.
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 1);
    final week1SessionId = buildU10SeasonPlan().first.sessionId;
    expect(sessionIdOn(_week2Saturday), week1SessionId);
  });

  test('resumes advancing normally the Saturday after an override', () async {
    await runFor(_week1Saturday);
    await scheduleRepository.assignSession(rosterId, _iso(_week1Saturday), 'custom-session');
    await runFor(_week2Saturday); // paused on week 1 again (assigned to week2's date)

    await runFor(_week3Saturday); // week2's date left untouched -> advances
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 2);

    await runFor(_week4Saturday); // untouched again -> advances
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 3);
  });

  test('a roster without an age group is never auto-assigned', () async {
    await rosterRepository.saveRoster(
      const Roster(id: 'no-age-group', name: 'Mixed Team'),
    );
    await runFor(_week1Saturday);
    expect(progressRepository.forRoster('no-age-group'), isNull);
    expect(
      scheduleRepository.scheduleFor('no-age-group').sessionIdFor(_iso(_week1Saturday)),
      isNull,
    );
  });
}
