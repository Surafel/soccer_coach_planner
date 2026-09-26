import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/main.dart';

void main() {
  testWidgets('App loads and shows the bottom navigation tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SoccerCoachPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Drills'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Rosters'), findsWidgets);
  });
}
