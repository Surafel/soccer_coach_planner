enum PlayerPosition { goalkeeper, defender, midfielder, forward, unspecified }

class Player {
  final String id;
  final String name;
  final PlayerPosition position;
  final int? jerseyNumber;
  final String? notes;

  const Player({
    required this.id,
    required this.name,
    this.position = PlayerPosition.unspecified,
    this.jerseyNumber,
    this.notes,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        position: PlayerPosition.values.byName(json['position'] as String),
        jerseyNumber: json['jerseyNumber'] as int?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'position': position.name,
        if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
        if (notes != null) 'notes': notes,
      };

  Player copyWith({
    String? name,
    PlayerPosition? position,
    int? jerseyNumber,
    String? notes,
  }) =>
      Player(
        id: id,
        name: name ?? this.name,
        position: position ?? this.position,
        jerseyNumber: jerseyNumber ?? this.jerseyNumber,
        notes: notes ?? this.notes,
      );
}
