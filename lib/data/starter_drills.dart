import '../models/drill.dart';

/// The coach's starter drill library. Fixed ids make reloading idempotent
/// (it updates the same 10 drills rather than duplicating them).
///
/// Video ids were transcribed from the coach's "Soccer drills" spreadsheet
/// by opening each cell and reading its formula-bar value directly (not
/// just the rendered text, which read ambiguously at small sizes — e.g.
/// I/l and O/0 look-alikes). All 10 below were confirmed this way.
List<Drill> buildStarterDrills() => const [
      Drill(
        id: 'drill-body-parts',
        name: 'Body Parts',
        category: DrillCategory.ballControl,
        skillTags: ['Ball Familiarity', 'Control', 'Listening'],
        description: 'Players dribble; stop ball with called body part.',
        ageRange: '5-8',
        videoId: 'mxcomZlIPU8',
      ),
      Drill(
        id: 'drill-treasure-hunt',
        name: 'Treasure Hunt / Bring It Home',
        category: DrillCategory.dribbling,
        skillTags: ['Dribbling', 'Speed', 'Control'],
        description:
            'Teams collect balls from center; "Bring It Home" adds stealing.',
        ageRange: '5-8',
        videoId: 'fJiibYRPq0s',
      ),
      Drill(
        id: 'drill-sharks-and-minnows',
        name: 'Sharks and Minnows / British Bulldog',
        category: DrillCategory.dribbling,
        skillTags: ['Dribbling under pressure', 'Shielding'],
        description: 'Minnows dribble past Sharks to other side.',
        ageRange: '5-8',
        videoId: 'OkAUW5MxjuM',
      ),
      Drill(
        id: 'drill-gates-dribbling',
        name: 'Gates Dribbling',
        category: DrillCategory.dribbling,
        skillTags: ['Dribbling Control', 'Changing Direction'],
        description: 'Players dribble through as many cone "gates" as possible.',
        ageRange: '6-8',
        videoId: 'GajIbRgBUzU',
      ),
      Drill(
        id: 'drill-fill-empty-bucket',
        name: 'Fill/Empty the Bucket',
        category: DrillCategory.dribbling,
        skillTags: ['Dribbling Speed & Control'],
        description: 'Teams race to dribble into/out of a "bucket."',
        ageRange: '6-8',
        videoId: 'gsdGp-CT3tk',
      ),
      Drill(
        id: 'drill-pass-and-move',
        name: 'Pass and Move',
        category: DrillCategory.passing,
        skillTags: ['Passing', 'Receiving', 'Movement off ball'],
        description:
            "Player A passes to B, A moves, B passes to A's new spot.",
        ageRange: '6-8',
        videoId: 'EDJKPs2Qcag',
      ),
      Drill(
        id: 'drill-cone-ball',
        name: 'Soccer Obstacle Passing / Cone Ball',
        category: DrillCategory.passing,
        skillTags: ['Passing Accuracy'],
        description: 'Pass through cone gate / Knock balls off cones.',
        ageRange: '6-8',
        videoId: 'JMnCtVzdew0',
      ),
      Drill(
        id: 'drill-clean-your-backyard',
        name: 'Clean Your Backyard / Clean the Room',
        category: DrillCategory.passing,
        skillTags: ['Kicking/Passing for Distance'],
        description:
            'Players kick balls out of their area; coaches kick them back.',
        ageRange: '5-8',
        videoId: '9QMlskAHQPI',
      ),
      Drill(
        id: 'drill-lightning-shooting',
        name: 'Lightning Shooting',
        category: DrillCategory.shooting,
        skillTags: ['Quick Shooting', 'Goalkeeping'],
        description: 'Players shoot; miss = become goalie.',
        ageRange: '6-8',
        videoId: '3ErsILOiUfo',
      ),
      Drill(
        id: 'drill-four-goals',
        name: 'Four Goals',
        category: DrillCategory.dribbling,
        skillTags: ['Dribbling', 'Kicking', 'Scoring'],
        description:
            'Players get ball from center, dribble to one of four goals, score.',
        ageRange: '6-8',
        videoId: 'maEjpkdINzM',
      ),
    ];
