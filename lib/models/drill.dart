enum DrillCategory {
  dribbling,
  passing,
  shooting,
  fitness,
  ballControl,
  oneVOne,
  possession,
  attackingPrinciples,
  defendingPrinciples,
  smallSidedGames,
  gameRealism,
}

String drillCategoryLabel(DrillCategory category) {
  switch (category) {
    case DrillCategory.dribbling:
      return 'Dribbling';
    case DrillCategory.passing:
      return 'Passing';
    case DrillCategory.shooting:
      return 'Shooting';
    case DrillCategory.fitness:
      return 'Fitness';
    case DrillCategory.ballControl:
      return 'Ball Control';
    case DrillCategory.oneVOne:
      return '1v1';
    case DrillCategory.possession:
      return 'Possession';
    case DrillCategory.attackingPrinciples:
      return 'Attacking Principles';
    case DrillCategory.defendingPrinciples:
      return 'Defending Principles';
    case DrillCategory.smallSidedGames:
      return 'Small-Sided Games';
    case DrillCategory.gameRealism:
      return 'Game Realism';
  }
}

class Drill {
  final String id;
  final String name;
  final DrillCategory category;
  final List<String> skillTags;
  final String description;
  final String ageRange;

  /// Curated YouTube video id, when one has been verified for this drill.
  /// Null for drills without a confirmed video — the detail screen falls
  /// back to a YouTube search instead of guessing a video id.
  final String? videoId;

  const Drill({
    required this.id,
    required this.name,
    required this.category,
    required this.skillTags,
    required this.description,
    required this.ageRange,
    this.videoId,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => Drill(
        id: json['id'] as String,
        name: json['name'] as String,
        category: DrillCategory.values.byName(json['category'] as String),
        skillTags: (json['skillTags'] as List).cast<String>(),
        description: json['description'] as String,
        ageRange: json['ageRange'] as String,
        videoId: json['videoId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'skillTags': skillTags,
        'description': description,
        'ageRange': ageRange,
        if (videoId != null) 'videoId': videoId,
      };

  /// A YouTube search for this drill, used as a fallback when no curated
  /// video is available for it.
  Uri get videoSearchUrl => Uri.https(
        'www.youtube.com',
        '/results',
        {'search_query': '$name youth soccer drill'},
      );

  Drill copyWith({
    String? name,
    DrillCategory? category,
    List<String>? skillTags,
    String? description,
    String? ageRange,
    String? videoId,
  }) =>
      Drill(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        skillTags: skillTags ?? this.skillTags,
        description: description ?? this.description,
        ageRange: ageRange ?? this.ageRange,
        videoId: videoId ?? this.videoId,
      );
}
