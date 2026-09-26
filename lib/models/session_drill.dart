import 'session_phase.dart';

/// One drill entry inside a saved Session: which part of practice it
/// belongs to, and the duration a coach allotted to it.
class SessionDrill {
  final String drillId;
  final SessionPhase phase;
  final int durationMinutes;

  const SessionDrill({
    required this.drillId,
    required this.phase,
    required this.durationMinutes,
  });

  factory SessionDrill.fromJson(Map<String, dynamic> json) => SessionDrill(
        drillId: json['drillId'] as String,
        // Sessions saved before phases existed default to "drill" so they
        // still show up somewhere sensible in the phase-grouped view.
        phase: SessionPhase.values.byName(
          json['phase'] as String? ?? SessionPhase.drill.name,
        ),
        durationMinutes: json['durationMinutes'] as int,
      );

  Map<String, dynamic> toJson() => {
        'drillId': drillId,
        'phase': phase.name,
        'durationMinutes': durationMinutes,
      };

  SessionDrill copyWith({SessionPhase? phase, int? durationMinutes}) =>
      SessionDrill(
        drillId: drillId,
        phase: phase ?? this.phase,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
}
