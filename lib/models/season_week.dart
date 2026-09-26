/// One week of a built-in seasonal curriculum. This is reference content,
/// not something a coach edits — every coach coaching the same age group
/// sees the identical plan, which is what makes it "uniform" across coaches
/// without needing any account or server.
class SeasonWeek {
  final int weekNumber;
  final String blockTitle;
  final String focus;
  final String sessionId;

  const SeasonWeek({
    required this.weekNumber,
    required this.blockTitle,
    required this.focus,
    required this.sessionId,
  });
}

/// One of the season's macro training blocks, spanning several weeks.
class SeasonBlock {
  final String title;
  final String weekRange;
  final String description;

  const SeasonBlock({
    required this.title,
    required this.weekRange,
    required this.description,
  });
}
