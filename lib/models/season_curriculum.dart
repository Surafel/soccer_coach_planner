import 'age_group.dart';
import 'drill.dart';
import 'season_week.dart';
import 'session.dart';

/// Everything one age group's built-in season plan ships with: the drills
/// it introduces, the weekly sessions built from them, and the week/block
/// metadata the Season Plan screen shows.
class SeasonCurriculum {
  final AgeGroup ageGroup;
  final List<Drill> drills;
  final List<Session> sessions;
  final List<SeasonWeek> weeks;
  final List<SeasonBlock> blocks;

  const SeasonCurriculum({
    required this.ageGroup,
    required this.drills,
    required this.sessions,
    required this.weeks,
    required this.blocks,
  });

  Session sessionById(String id) => sessions.firstWhere((s) => s.id == id);

  bool ownsSession(String sessionId) => sessions.any((s) => s.id == sessionId);
}
