import 'package:flutter_test/flutter_test.dart';

import 'package:soccer_coach_planner/data/season_curricula.dart';
import 'package:soccer_coach_planner/data/starter_drills.dart';
import 'package:soccer_coach_planner/models/age_group.dart';
import 'package:soccer_coach_planner/models/session_phase.dart';

void main() {
  final starterDrillIds = buildStarterDrills().map((d) => d.id).toSet();

  for (final ageGroup in curriculumAgeGroups) {
    group('${ageGroupLabel(ageGroup)} curriculum', () {
      final curriculum = seasonCurriculumFor(ageGroup)!;

      test('belongs to its age group', () {
        expect(curriculum.ageGroup, ageGroup);
      });

      test('has 16 weeks, each mapped to one of its sessions', () {
        expect(curriculum.weeks.map((w) => w.weekNumber), List.generate(16, (i) => i + 1));
        for (final week in curriculum.weeks) {
          expect(curriculum.ownsSession(week.sessionId), isTrue);
          expect(curriculum.blocks.map((b) => b.title), contains(week.blockTitle));
        }
      });

      test('every session runs Warm-up → Game → Drill → Scrimmage', () {
        for (final session in curriculum.sessions) {
          expect(session.drills.map((d) => d.phase), SessionPhase.values);
        }
      });

      test('every session drill exists in the curriculum or starter library', () {
        final drillIds = curriculum.drills.map((d) => d.id).toSet();
        expect(drillIds.length, curriculum.drills.length, reason: 'duplicate drill ids');
        for (final session in curriculum.sessions) {
          for (final d in session.drills) {
            expect(
              drillIds.contains(d.drillId) || starterDrillIds.contains(d.drillId),
              isTrue,
              reason: '${session.id} references unknown drill ${d.drillId}',
            );
          }
        }
      });
    });
  }

  test('curricula use distinct drill and session ids', () {
    final drillIds = <String>{};
    final sessionIds = <String>{};
    for (final group in curriculumAgeGroups) {
      final c = seasonCurriculumFor(group)!;
      for (final d in c.drills) {
        expect(drillIds.add(d.id), isTrue, reason: 'shared drill id ${d.id}');
      }
      for (final s in c.sessions) {
        expect(sessionIds.add(s.id), isTrue, reason: 'shared session id ${s.id}');
      }
    }
  });

  test('no two built-in drills share a video', () {
    final owners = <String, String>{};
    final drills = [
      ...buildStarterDrills(),
      for (final group in curriculumAgeGroups) ...seasonCurriculumFor(group)!.drills,
    ];
    for (final d in drills) {
      final videoId = d.videoId;
      if (videoId == null) continue;
      expect(owners.containsKey(videoId), isFalse,
          reason: '${d.id} reuses ${owners[videoId]}\'s video $videoId');
      owners[videoId] = d.id;
    }
  });

  test('age groups without a plan return null', () {
    expect(seasonCurriculumFor(AgeGroup.u14), isNull);
    expect(seasonCurriculumFor(null), isNull);
  });
}
