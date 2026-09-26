enum DrillCategory { dribbling, passing, shooting, fitness, ballControl }

class Drill {
  final String id;
  final String name;
  final DrillCategory category;
  final List<String> skillTags;
  final String description;
  final String ageRange;
  final String videoId;

  const Drill({
    required this.id,
    required this.name,
    required this.category,
    required this.skillTags,
    required this.description,
    required this.ageRange,
    required this.videoId,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => Drill(
        id: json['id'] as String,
        name: json['name'] as String,
        category: DrillCategory.values.byName(json['category'] as String),
        skillTags: (json['skillTags'] as List).cast<String>(),
        description: json['description'] as String,
        ageRange: json['ageRange'] as String,
        videoId: json['videoId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'skillTags': skillTags,
        'description': description,
        'ageRange': ageRange,
        'videoId': videoId,
      };

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
