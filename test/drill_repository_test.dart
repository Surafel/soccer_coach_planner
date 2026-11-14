import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soccer_coach_planner/models/drill.dart';
import 'package:soccer_coach_planner/services/drill_repository.dart';

Drill _drill(String id, {String? videoId}) => Drill(
      id: id,
      name: id,
      category: DrillCategory.passing,
      skillTags: const ['Passing'],
      description: 'desc',
      ageRange: '9-10',
      videoId: videoId,
    );

void main() {
  group('clearing the old shared category videos', () {
    late DrillRepository repository;

    setUp(() async {
      // Drills as an earlier version saved them.
      SharedPreferences.setMockInitialValues({
        'drills_v1': jsonEncode([
          // Curriculum drills with the old shared category video.
          _drill('drill-u10-w06-game', videoId: '6RGJBj1tNC8').toJson(),
          _drill('drill-u12-w02-drill', videoId: '6RGJBj1tNC8').toJson(),
          // Curriculum drill where a coach set their own video.
          _drill('drill-u10-w07-game', videoId: 'coachPicked').toJson(),
          // A coach's own drill that happens to use one of those videos.
          _drill('drill-custom-1', videoId: '6RGJBj1tNC8').toJson(),
        ]),
      });
      repository = DrillRepository();
      await repository.load();
    });

    test('removes them from curriculum drills', () {
      expect(repository.byId('drill-u10-w06-game')?.videoId, isNull);
      expect(repository.byId('drill-u12-w02-drill')?.videoId, isNull);
    });

    test('keeps a video a coach set on a curriculum drill', () {
      expect(repository.byId('drill-u10-w07-game')?.videoId, 'coachPicked');
    });

    test('leaves coaches\' own drills alone', () {
      expect(repository.byId('drill-custom-1')?.videoId, '6RGJBj1tNC8');
    });

    test('saves the cleaned drills', () async {
      final reloaded = DrillRepository();
      await reloaded.load();
      expect(reloaded.byId('drill-u10-w06-game')?.videoId, isNull);
      expect(reloaded.drills.length, 4);
    });
  });
}
