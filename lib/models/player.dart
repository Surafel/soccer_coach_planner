import 'roster.dart';

enum PlayerPosition { goalkeeper, defender, midfielder, forward, unspecified }

class Player {
  final String id;
  final String rosterId;
  final String name;
  final int? age;
  final PlayerPosition position;
  final int? jerseyNumber;
  final String? notes;

  const Player({
    required this.id,
    required this.rosterId,
    required this.name,
    this.age,
    this.position = PlayerPosition.unspecified,
    this.jerseyNumber,
    this.notes,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        // Players saved before rosters existed belong to the legacy roster
        // created for them on upgrade, so existing data isn't lost.
        rosterId: json['rosterId'] as String? ?? legacyRosterId,
        name: json['name'] as String,
        age: json['age'] as int?,
        position: PlayerPosition.values.byName(json['position'] as String),
        jerseyNumber: json['jerseyNumber'] as int?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rosterId': rosterId,
        'name': name,
        if (age != null) 'age': age,
        'position': position.name,
        if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
        if (notes != null) 'notes': notes,
      };

  Player copyWith({
    String? name,
    String? rosterId,
    int? age,
    bool clearAge = false,
    PlayerPosition? position,
    int? jerseyNumber,
    String? notes,
  }) =>
      Player(
        id: id,
        rosterId: rosterId ?? this.rosterId,
        name: name ?? this.name,
        age: clearAge ? null : age ?? this.age,
        position: position ?? this.position,
        jerseyNumber: jerseyNumber ?? this.jerseyNumber,
        notes: notes ?? this.notes,
      );
}
