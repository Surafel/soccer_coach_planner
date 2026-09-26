/// The four parts of a practice, always run in this order — the standard
/// US Soccer grassroots practice structure: introduce the theme as a game,
/// isolate it with a focused drill, then put it back into a game.
enum SessionPhase { warmUp, game, drill, scrimmage }

String sessionPhaseLabel(SessionPhase phase) {
  switch (phase) {
    case SessionPhase.warmUp:
      return 'Warm-up';
    case SessionPhase.game:
      return 'Game';
    case SessionPhase.drill:
      return 'Drill';
    case SessionPhase.scrimmage:
      return 'Scrimmage';
  }
}
