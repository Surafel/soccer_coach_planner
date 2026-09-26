import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/data/u10_curriculum.dart';
import 'package:soccer_coach_planner/models/age_group.dart';
import 'package:soccer_coach_planner/models/roster.dart';
import 'package:soccer_coach_planner/models/weekly_schedule.dart';
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

  String? saturdaySessionId() =>
      scheduleRepository.scheduleFor(rosterId).sessionIdFor(DayOfWeek.saturday);

  test('does nothing on a non-Saturday', () async {
    await runFor(DateTime(2026, 1, 5)); // a Monday
    expect(progressRepository.forRoster(rosterId), isNull);
    expect(saturdaySessionId(), isNull);
  });

  test('first Saturday assigns week 1', () async {
    await runFor(_week1Saturday);
    final progress = progressRepository.forRoster(rosterId);
    expect(progress?.currentWeek, 1);
    final week1SessionId = buildU10SeasonPlan().first.sessionId;
    expect(saturdaySessionId(), week1SessionId);
  });

  test('running again the same Saturday does not advance', () async {
    await runFor(_week1Saturday);
    await runFor(_week1Saturday);
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 1);
  });

  test('untouched week advances to the next week next Saturday', () async {
    await runFor(_week1Saturday);
    await runFor(_week2Saturday);
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 2);
    final week2SessionId = buildU10SeasonPlan()[1].sessionId;
    expect(saturdaySessionId(), week2SessionId);
  });

  test('an override pauses progress on the same week', () async {
    await runFor(_week1Saturday);
    // Coach overrides Saturday with something else during the week.
    await scheduleRepository.assignSession(rosterId, DayOfWeek.saturday, 'custom-session');

    await runFor(_week2Saturday);
    // Stays paused on week 1, and re-establishes week 1's session.
    expect(progressRepository.forRoster(rosterId)?.currentWeek, 1);
    final week1SessionId = buildU10SeasonPlan().first.sessionId;
    expect(saturdaySessionId(), week1SessionId);
  });

  test('resumes advancing normally the Saturday after an override', () async {
    await runFor(_week1Saturday);
    await scheduleRepository.assignSession(rosterId, DayOfWeek.saturday, 'custom-session');
    await runFor(_week2Saturday); // paused on week 1 again

    await runFor(_week3Saturday); // left untouched this time -> advances
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
    expect(scheduleRepository.scheduleFor('no-age-group').sessionIdFor(DayOfWeek.saturday), isNull);
  });
}
