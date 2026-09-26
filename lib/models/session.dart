import 'session_drill.dart';

class Session {
  final String id;
  final String name;
  final List<SessionDrill> drills;

  const Session({
    required this.id,
    required this.name,
    required this.drills,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        name: json['name'] as String,
        drills: (json['drills'] as List)
            .map((e) => SessionDrill.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'drills': drills.map((d) => d.toJson()).toList(),
      };

  int get totalDurationMinutes =>
      drills.fold(0, (sum, d) => sum + d.durationMinutes);

  Session copyWith({String? name, List<SessionDrill>? drills}) => Session(
        id: id,
        name: name ?? this.name,
        drills: drills ?? this.drills,
      );
}
