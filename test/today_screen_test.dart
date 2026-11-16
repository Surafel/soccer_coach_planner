import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/models/attendance_record.dart';
import 'package:soccer_coach_planner/models/roster.dart';
import 'package:soccer_coach_planner/models/session.dart';
import 'package:soccer_coach_planner/models/session_drill.dart';
import 'package:soccer_coach_planner/models/session_phase.dart';
import 'package:soccer_coach_planner/screens/today_screen.dart';
import 'package:soccer_coach_planner/services/attendance_repository.dart';
import 'package:soccer_coach_planner/services/coach_assignment_repository.dart';
import 'package:soccer_coach_planner/services/coach_availability_repository.dart';
import 'package:soccer_coach_planner/services/coach_repository.dart';
import 'package:soccer_coach_planner/services/drill_repository.dart';
import 'package:soccer_coach_planner/services/player_repository.dart';
import 'package:soccer_coach_planner/services/roster_repository.dart';
import 'package:soccer_coach_planner/services/schedule_repository.dart';
import 'package:soccer_coach_planner/services/session_repository.dart';
import 'package:soccer_coach_planner/widgets/schedule_entry_tile.dart';

Session _session(String id, String name) => Session(
      id: id,
      name: name,
      drills: const [
        SessionDrill(drillId: 'drill-body-parts', phase: SessionPhase.warmUp, durationMinutes: 10),
      ],
    );

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  // A day in the current month (the one the date picker opens on) at least
  // five days from today, so it never collides with yesterday or tomorrow.
  final pickedDay = DateTime(today.year, today.month, today.day <= 15 ? 20 : 5);
  String iso(DateTime d) => AttendanceRecord.isoDate(d);

  Future<void> pumpToday(WidgetTester tester, {DateTime Function()? clock}) async {
    SharedPreferences.setMockInitialValues({});
    final drills = DrillRepository();
    final sessions = SessionRepository();
    final schedules = ScheduleRepository();
    final rosters = RosterRepository();
    final players = PlayerRepository();
    final coaches = CoachRepository();
    final availability = CoachAvailabilityRepository();
    final assignments = CoachAssignmentRepository();
    final attendance = AttendanceRepository();
    await tester.runAsync(() async {
      await Future.wait([
        drills.load(), sessions.load(), schedules.load(), rosters.load(), players.load(),
        coaches.load(), availability.load(), assignments.load(), attendance.load(),
      ]);
      await rosters.saveRoster(const Roster(id: 'r1', name: 'Blue'));
      await sessions.saveSession(_session('s-today', 'Today Session'));
      await sessions.saveSession(_session('s-tomorrow', 'Tomorrow Session'));
      await sessions.saveSession(_session('s-picked', 'Picked Session'));
      await schedules.assignSession('r1', iso(today), 's-today');
      await schedules.assignSession('r1', iso(tomorrow), 's-tomorrow');
      await schedules.assignSession('r1', iso(pickedDay), 's-picked');
    });

    await tester.pumpWidget(MaterialApp(
      home: TodayScreen(
        drillRepository: drills,
        sessionRepository: sessions,
        scheduleRepository: schedules,
        rosterRepository: rosters,
        playerRepository: players,
        coachRepository: coaches,
        availabilityRepository: availability,
        assignmentRepository: assignments,
        attendanceRepository: attendance,
        onGoToRosters: () {},
        onChanged: () {},
        clock: clock ?? DateTime.now,
      ),
    ));
  }

  testWidgets('starts on today', (tester) async {
    await pumpToday(tester);
    expect(find.text(formatScheduleDate(iso(today))), findsOneWidget);
    expect(find.text('Today Session'), findsOneWidget);
  });

  testWidgets('next and previous show that day\'s practice', (tester) async {
    await pumpToday(tester);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();
    expect(find.text(formatScheduleDate(iso(tomorrow))), findsOneWidget);
    expect(find.text('Tomorrow Session'), findsOneWidget);
    expect(find.text('Today Session'), findsNothing);

    await tester.tap(find.byTooltip('Previous day'));
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pump();
    expect(find.text(formatScheduleDate(iso(yesterday))), findsOneWidget);
    expect(find.text('No practice this day.'), findsOneWidget);
  });

  testWidgets('"Today" jumps back to the current day', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Today'));
    await tester.pump();
    expect(find.text(formatScheduleDate(iso(today))), findsOneWidget);
    expect(find.text('Today Session'), findsOneWidget);
  });

  testWidgets('picking a date from the calendar shows that day', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.text(formatScheduleDate(iso(today))));
    await tester.pumpAndSettle();

    await tester.tap(find.text('${pickedDay.day}').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(formatScheduleDate(iso(pickedDay))), findsOneWidget);
    expect(find.text('Picked Session'), findsOneWidget);
  });

  group('at midnight', () {
    // The fake clock starts 30 seconds before the end of today.
    late DateTime fakeNow;

    setUp(() => fakeNow = DateTime(today.year, today.month, today.day, 23, 59, 30));

    testWidgets('moves to the new day without any interaction', (tester) async {
      await pumpToday(tester, clock: () => fakeNow);
      expect(find.text('Today Session'), findsOneWidget);

      fakeNow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 1);
      await tester.pump(const Duration(seconds: 31));

      expect(find.text(formatScheduleDate(iso(tomorrow))), findsOneWidget);
      expect(find.text('Tomorrow Session'), findsOneWidget);
    });

    testWidgets('keeps a date the coach picked', (tester) async {
      await pumpToday(tester, clock: () => fakeNow);
      await tester.tap(find.byTooltip('Previous day'));
      await tester.pump();

      fakeNow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 1);
      await tester.pump(const Duration(seconds: 31));

      expect(find.text(formatScheduleDate(iso(yesterday))), findsOneWidget);
    });
  });
}
