import '../models/session.dart';
import '../models/session_drill.dart';

const saturdayPracticeId = 'session-saturday-practice';

/// A balanced 50-minute practice touching dribbling, passing, and shooting,
/// built from the starter drill library. Fixed id makes reloading it
/// idempotent (it updates the same session rather than duplicating it).
Session buildStarterSession() => const Session(
      id: saturdayPracticeId,
      name: 'Saturday Practice',
      drills: [
        SessionDrill(drillId: 'drill-body-parts', durationMinutes: 10),
        SessionDrill(drillId: 'drill-treasure-hunt', durationMinutes: 10),
        SessionDrill(drillId: 'drill-pass-and-move', durationMinutes: 10),
        SessionDrill(drillId: 'drill-cone-ball', durationMinutes: 10),
        SessionDrill(drillId: 'drill-lightning-shooting', durationMinutes: 10),
      ],
    );
