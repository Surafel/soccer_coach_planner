/// One drill entry inside a saved Session, with the duration a coach
/// allotted to it.
class SessionDrill {
  final String drillId;
  final int durationMinutes;

  const SessionDrill({required this.drillId, required this.durationMinutes});

  factory SessionDrill.fromJson(Map<String, dynamic> json) => SessionDrill(
        drillId: json['drillId'] as String,
        durationMinutes: json['durationMinutes'] as int,
      );

  Map<String, dynamic> toJson() => {
        'drillId': drillId,
        'durationMinutes': durationMinutes,
      };

  SessionDrill copyWith({int? durationMinutes}) => SessionDrill(
        drillId: drillId,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
}
