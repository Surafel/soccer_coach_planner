import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/data/u12_curriculum.dart';
import 'package:soccer_coach_planner/screens/schedule_screen.dart';
import 'package:soccer_coach_planner/services/coach_assignment_repository.dart';
import 'package:soccer_coach_planner/services/coach_availability_repository.dart';
import 'package:soccer_coach_planner/services/coach_repository.dart';
import 'package:soccer_coach_planner/services/roster_repository.dart';
import 'package:soccer_coach_planner/services/schedule_repository.dart';
import 'package:soccer_coach_planner/services/session_repository.dart';

void main() {
  const rosterId = 'roster-1';
  const date = '2026-01-03';
  late SessionRepository sessionRepository;
  late ScheduleRepository scheduleRepository;

  Future<void> pumpSchedule(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    sessionRepository = SessionRepository();
    scheduleRepository = ScheduleRepository();
    final rosterRepository = RosterRepository();
    final coachRepository = CoachRepository();
    final availabilityRepository = CoachAvailabilityRepository();
    final assignmentRepository = CoachAssignmentRepository();
    await tester.runAsync(() async {
      await Future.wait([
        sessionRepository.load(),
        scheduleRepository.load(),
        rosterRepository.load(),
        coachRepository.load(),
        availabilityRepository.load(),
        assignmentRepository.load(),
      ]);
      // The whole 16-week season, as "Add the full season" saves it.
      for (final session in buildU12CurriculumSessions()) {
        await sessionRepository.saveSession(session);
      }
      await scheduleRepository.assignSession(
        rosterId,
        date,
        buildU12CurriculumSessions().first.id,
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: ScheduleScreen(
        rosterId: rosterId,
        sessionRepository: sessionRepository,
        scheduleRepository: scheduleRepository,
        rosterRepository: rosterRepository,
        coachRepository: coachRepository,
        availabilityRepository: availabilityRepository,
        assignmentRepository: assignmentRepository,
        onChanged: () {},
      ),
    ));
  }

  testWidgets('session picker scrolls to every week of the season', (tester) async {
    await pumpSchedule(tester);
    await tester.tap(find.text('Sat, Jan 3, 2026'));
    await tester.pumpAndSettle();

    final week16 = find.textContaining('U12 Week 16:');
    await tester.scrollUntilVisible(
      week16,
      200,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(week16);
    await tester.pumpAndSettle();

    expect(
      scheduleRepository.scheduleFor(rosterId).sessionIdFor(date),
      buildU12CurriculumSessions().last.id,
    );
  });

  testWidgets('dismissing the picker keeps the assigned session', (tester) async {
    await pumpSchedule(tester);
    await tester.tap(find.text('Sat, Jan 3, 2026'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10)); // tap the barrier above the sheet
    await tester.pumpAndSettle();

    expect(
      scheduleRepository.scheduleFor(rosterId).sessionIdFor(date),
      buildU12CurriculumSessions().first.id,
    );
  });

  testWidgets('"No practice" clears the date', (tester) async {
    await pumpSchedule(tester);
    await tester.tap(find.text('Sat, Jan 3, 2026'));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('No practice'),
    ));
    await tester.pumpAndSettle();

    expect(scheduleRepository.scheduleFor(rosterId).sessionIdFor(date), isNull);
  });
}
