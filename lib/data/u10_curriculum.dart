import '../models/age_group.dart';
import '../models/drill.dart';
import '../models/season_week.dart';
import '../models/session.dart';
import '../models/session_drill.dart';
import '../models/session_phase.dart';

/// The built-in U10 season plan: a 16-week periodization curriculum in the
/// standard US Soccer grassroots practice format — every practice runs
/// Warm-up → Game → Drill → Scrimmage. This is reference content, not
/// something a coach edits, so every U10 coach who loads it sees the exact
/// same weekly focus and sequence.
const u10AgeGroup = AgeGroup.u10;

const _ageRange = '9-10';

/// Rotates through drills already in the starter library that work well as
/// quick, fun warm-up games, so no new content is needed for this phase.
const _warmupPool = [
  'drill-body-parts',
  'drill-treasure-hunt',
  'drill-sharks-and-minnows',
  'drill-gates-dribbling',
  'drill-fill-empty-bucket',
];

class _ScrimmageFormat {
  final String id;
  final String name;
  final DrillCategory category;
  final List<String> skillTags;
  final String description;

  const _ScrimmageFormat({
    required this.id,
    required this.name,
    required this.category,
    required this.skillTags,
    required this.description,
  });
}

const _scrimmageFormats = [
  _ScrimmageFormat(
    id: 'drill-u10-scrimmage-block1',
    name: 'Small-Sided Scrimmage: 3v3 to End Zones',
    category: DrillCategory.smallSidedGames,
    skillTags: ['1v1', 'Ball Mastery', 'Decision Making'],
    description:
        'Play 3v3 (no keepers) to end zones or small goals. The small '
        'numbers mean frequent 1v1 duels — encourage players to try the '
        'moves practiced this week.',
  ),
  _ScrimmageFormat(
    id: 'drill-u10-scrimmage-block2',
    name: 'Small-Sided Scrimmage: 4v4 Possession Focus',
    category: DrillCategory.possession,
    skillTags: ['Passing', 'Possession', 'Support Play'],
    description:
        '4v4 scrimmage with a 2-touch guideline. Award a bonus goal for '
        'stringing together 5+ passes before scoring to reward possession.',
  ),
  _ScrimmageFormat(
    id: 'drill-u10-scrimmage-block3',
    name: 'Small-Sided Scrimmage: 5v5 with Freeze Coaching',
    category: DrillCategory.smallSidedGames,
    skillTags: ['Attacking Principles', 'Defending Principles', 'Shape'],
    description:
        '5v5 with keepers. Freeze play at key moments to highlight attacking '
        'width/depth or defending pressure/cover/balance, then resume.',
  ),
  _ScrimmageFormat(
    id: 'drill-u10-scrimmage-block4',
    name: 'Full Scrimmage: 7v7 Game Realism',
    category: DrillCategory.gameRealism,
    skillTags: ['Game Management', 'Restarts', 'Tournament Readiness'],
    description:
        'Full 7v7 scrimmage with real match rules — throw-ins, goal kicks, '
        'corners — and a running score to simulate tournament pressure.',
  ),
];

class _WeekContent {
  final int week;
  final String blockTitle;
  final String focus;
  final String gameName;
  final DrillCategory gameCategory;
  final List<String> gameSkills;
  final String gameDescription;
  final String drillName;
  final DrillCategory drillCategory;
  final List<String> drillSkills;
  final String drillDescription;
  final int scrimmageBlock; // 1-based index into _scrimmageFormats

  const _WeekContent({
    required this.week,
    required this.blockTitle,
    required this.focus,
    required this.gameName,
    required this.gameCategory,
    required this.gameSkills,
    required this.gameDescription,
    required this.drillName,
    required this.drillCategory,
    required this.drillSkills,
    required this.drillDescription,
    required this.scrimmageBlock,
  });
}

const _block1 = 'Individual Ball Mastery & 1v1s';
const _block2 = 'Passing, Receiving & Possession';
const _block3 = 'Attacking/Defending Principles & Small-Sided Games';
const _block4 = 'Game Realism & Tournament Prep';

const _weeks = [
  _WeekContent(
    week: 1,
    blockTitle: _block1,
    focus: 'Ball mastery foundations — close control at speed',
    gameName: 'Knockout',
    gameCategory: DrillCategory.ballControl,
    gameSkills: ['Ball Mastery', 'Shielding'],
    gameDescription:
        'Everyone dribbles in a grid with a ball each. Try to knock other '
        'balls out of the grid while protecting your own — last one in wins.',
    drillName: 'Toe Taps & Sole Rolls Circuit',
    drillCategory: DrillCategory.ballControl,
    drillSkills: ['Toe Taps', 'Sole Rolls', 'Inside-Outside Touches'],
    drillDescription:
        'Cone-to-cone circuit practicing toe taps, sole rolls, and '
        'inside-outside touches — focus on quick, light touches with both feet.',
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 2,
    blockTitle: _block1,
    focus: 'Moves to beat a defender',
    gameName: '1v1 to the End Line',
    gameCategory: DrillCategory.oneVOne,
    gameSkills: ['1v1 Attacking', 'Dribbling'],
    gameDescription:
        'Attacker tries to dribble through a mini-gate against a passive '
        'defender to reach the end line. Swap roles every turn.',
    drillName: 'Step-Over & Scissor Move Practice',
    drillCategory: DrillCategory.oneVOne,
    drillSkills: ['Step-Over', 'Scissor Move', 'Change of Direction'],
    drillDescription:
        'Cone course practicing two signature 1v1 moves (step-over, scissor) '
        'in isolation before adding a defender.',
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 3,
    blockTitle: _block1,
    focus: '1v1 attacking — take players on to score',
    gameName: '1v1 to Small Goals',
    gameCategory: DrillCategory.oneVOne,
    gameSkills: ['1v1 Attacking', 'Finishing'],
    gameDescription:
        'Attacker vs. defender, 1v1 to two small goals. Winner stays on — '
        'losers rotate in. Coach cues players to use this week\'s moves.',
    drillName: 'Attack the Cone Gates',
    drillCategory: DrillCategory.oneVOne,
    drillSkills: ['1v1 Attacking', 'Speed of Play'],
    drillDescription:
        'Dribble at speed and use a move to beat a defender, then finish '
        'through one of two cone gates — rewards committing to a decision.',
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 4,
    blockTitle: _block1,
    focus: '1v1 defending — jockey, delay, and win the ball',
    gameName: 'Defend Your Zone',
    gameCategory: DrillCategory.defendingPrinciples,
    gameSkills: ['1v1 Defending', 'Positioning'],
    gameDescription:
        'Two defenders protect a marked zone. Attackers try to dribble '
        'through — defenders practice jockeying instead of diving in.',
    drillName: 'Jockey & Delay Ladder',
    drillCategory: DrillCategory.defendingPrinciples,
    drillSkills: ['Jockeying', 'Delay', 'Tackle Timing'],
    drillDescription:
        'Defender shuffles to stay goal-side of a dribbling attacker, '
        'delaying without diving in, then closes the gap on the coach\'s cue.',
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 5,
    blockTitle: _block2,
    focus: 'First touch & receiving away from pressure',
    gameName: 'Numbers-Up Receiving',
    gameCategory: DrillCategory.passing,
    gameSkills: ['Receiving', 'Movement Off the Ball'],
    gameDescription:
        'Pairs pass and move into open space, always receiving on the back '
        'foot, away from an imaginary defender.',
    drillName: 'Receive & Turn Gates',
    drillCategory: DrillCategory.ballControl,
    drillSkills: ['First Touch', 'Turning'],
    drillDescription:
        'Partner passes the ball; receiver takes a touch through a cone '
        'gate to turn away from pressure before playing it back.',
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 6,
    blockTitle: _block2,
    focus: 'Passing accuracy & weight of pass',
    gameName: 'Target Passing Relay',
    gameCategory: DrillCategory.passing,
    gameSkills: ['Passing Accuracy'],
    gameDescription:
        'Teams race to hit a series of target cones with accurate ground '
        'passes — points only count for clean hits.',
    drillName: 'Gate Passing Progression',
    drillCategory: DrillCategory.passing,
    drillSkills: ['Passing Accuracy', 'Weight of Pass'],
    drillDescription:
        'Pass through cone gates that get narrower and farther apart as '
        'players succeed — builds accuracy and appropriate pace.',
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 7,
    blockTitle: _block2,
    focus: 'Support angles & possession',
    gameName: '3v1 Rondo',
    gameCategory: DrillCategory.possession,
    gameSkills: ['Possession', 'Support Angles'],
    gameDescription:
        'Keep-away in a grid: 3 attackers keep the ball from 1 defender, '
        'rotating who defends when the ball is won or goes out.',
    drillName: 'Triangle Support Passing',
    drillCategory: DrillCategory.possession,
    drillSkills: ['Support Angles', 'Passing'],
    drillDescription:
        'Three players form a passing triangle, practicing the supporting '
        'angles and movement needed to always give the ball-carrier an option.',
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 8,
    blockTitle: _block2,
    focus: 'Possession under pressure',
    gameName: '4v2 Keep Away',
    gameCategory: DrillCategory.possession,
    gameSkills: ['Possession', 'Composure Under Pressure'],
    gameDescription:
        'Classic rondo: 4 attackers keep the ball from 2 defenders in the '
        'middle of a grid.',
    drillName: 'Possession Box with Conditions',
    drillCategory: DrillCategory.possession,
    drillSkills: ['Possession', 'Switching the Point of Attack'],
    drillDescription:
        'Possession game in a box with a touch limit; add a condition that '
        'the team must switch the point of attack every few passes.',
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 9,
    blockTitle: _block3,
    focus: 'Attacking principles — width & depth',
    gameName: 'Expand the Field',
    gameCategory: DrillCategory.attackingPrinciples,
    gameSkills: ['Width', 'Depth', 'Spacing'],
    gameDescription:
        'Small-sided game where the team in possession earns bonus points '
        'for using the full width of the field before attacking.',
    drillName: 'Width & Depth Passing Shape',
    drillCategory: DrillCategory.attackingPrinciples,
    drillSkills: ['Width', 'Depth', 'Combination Play'],
    drillDescription:
        'Players positioned wide and deep practice combination passing into '
        'space created by good team shape.',
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 10,
    blockTitle: _block3,
    focus: 'Defending principles — pressure, cover, balance',
    gameName: '3v3 Defending Shape Game',
    gameCategory: DrillCategory.defendingPrinciples,
    gameSkills: ['Pressure', 'Cover', 'Balance'],
    gameDescription:
        '3 defenders vs. 3 attackers to a small goal — defenders practice '
        'organizing who pressures and who covers as the attack shifts.',
    drillName: 'Pressure-Cover-Balance Shadowing',
    drillCategory: DrillCategory.defendingPrinciples,
    drillSkills: ['Pressure', 'Cover', 'Balance'],
    drillDescription:
        'Three defenders shadow a moving ball without opposition, practicing '
        'their roles: first defender pressures, second covers, third balances.',
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 11,
    blockTitle: _block3,
    focus: 'Transition moments — attack to defend and back',
    gameName: 'Transition Small-Sided Game',
    gameCategory: DrillCategory.smallSidedGames,
    gameSkills: ['Transition', 'Reaction Speed'],
    gameDescription:
        'Small-sided game where every turnover triggers an immediate counter '
        'attack race to goal before the defense can reorganize.',
    drillName: 'Counter-Attack Reaction Drill',
    drillCategory: DrillCategory.attackingPrinciples,
    drillSkills: ['Transition', 'Quick Decision Making'],
    drillDescription:
        'Team wins the ball and has 6 seconds to attack a target before the '
        'defense is allowed to reset — rewards fast, direct decisions.',
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 12,
    blockTitle: _block3,
    focus: 'Small-sided games — applying attacking & defending principles',
    gameName: '4v4 Principles Game',
    gameCategory: DrillCategory.smallSidedGames,
    gameSkills: ['Attacking Principles', 'Defending Principles'],
    gameDescription:
        '4v4 to small goals. Coach calls out a principle mid-game (width, '
        'pressure, cover) for players to focus on for the next few minutes.',
    drillName: 'Rotating Small-Sided Stations',
    drillCategory: DrillCategory.smallSidedGames,
    drillSkills: ['Game Understanding', 'Variety of Reps'],
    drillDescription:
        'Run two or three small-sided games simultaneously on adjacent '
        'grids, rotating groups every few minutes for maximum touches.',
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 13,
    blockTitle: _block4,
    focus: 'Game realism — playing out of pressure',
    gameName: 'Press-Escape Small-Sided Game',
    gameCategory: DrillCategory.gameRealism,
    gameSkills: ['Composure', 'Playing Out From the Back'],
    gameDescription:
        'Build-out game from the back against organized pressure — the '
        'defending team presses high to force mistakes.',
    drillName: 'Goalkeeper Build-Out Pattern',
    drillCategory: DrillCategory.gameRealism,
    drillSkills: ['Build-Out Play', 'Composure Under Pressure'],
    drillDescription:
        'Keeper and defenders practice specific passing patterns to play '
        'out from the back safely under simulated pressure.',
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 14,
    blockTitle: _block4,
    focus: 'Set pieces & restarts',
    gameName: 'Restart Scramble',
    gameCategory: DrillCategory.gameRealism,
    gameSkills: ['Restarts', 'Reaction to Live Play'],
    gameDescription:
        'Live play restarts repeatedly from throw-ins, corners, and free '
        'kicks so players get comfortable with the game restarting quickly.',
    drillName: 'Set Piece Routines',
    drillCategory: DrillCategory.gameRealism,
    drillSkills: ['Corners', 'Throw-Ins', 'Free Kicks'],
    drillDescription:
        'Practice the team\'s specific throw-in, corner, and free-kick '
        'routines without opposition, then with light pressure.',
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 15,
    blockTitle: _block4,
    focus: 'Game management',
    gameName: 'Game Situations Small-Sided Game',
    gameCategory: DrillCategory.gameRealism,
    gameSkills: ['Game Management', 'Decision Making'],
    gameDescription:
        'Coach sets a scenario before kickoff (e.g. "you\'re up 1-0 with 5 '
        'minutes left") and the team practices managing the game accordingly.',
    drillName: 'Tempo Control Possession Game',
    drillCategory: DrillCategory.gameRealism,
    drillSkills: ['Tempo', 'Composure'],
    drillDescription:
        'Possession game where the coach calls "speed up" or "slow down" so '
        'players practice controlling the tempo of play on demand.',
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 16,
    blockTitle: _block4,
    focus: 'Tournament prep — full team readiness',
    gameName: 'Mock Match Warm-Up Routine',
    gameCategory: DrillCategory.gameRealism,
    gameSkills: ['Pre-Game Routine', 'Focus'],
    gameDescription:
        'Rehearse the team\'s actual pre-game warm-up routine start to '
        'finish, exactly as it will run on tournament day.',
    drillName: 'Full Team Shape Walkthrough',
    drillCategory: DrillCategory.gameRealism,
    drillSkills: ['Formation', 'Roles & Responsibilities'],
    drillDescription:
        'Walk through the team\'s formation, individual roles, and set '
        'piece assignments at game speed without opposition.',
    scrimmageBlock: 4,
  ),
];

String _weekId(int week) => week.toString().padLeft(2, '0');

/// None of these 36 drills (Game + Drill phase content for all 16 weeks,
/// plus the 4 reusable scrimmage formats) has a video specific to its exact
/// name — inventing a video id for a drill this app made up isn't possible.
/// Instead, each one embeds a real, verified reference video for its skill
/// category (found and confirmed to exist via YouTube's oEmbed endpoint),
/// so every drill in the library has something to watch, and the specific
/// id can be swapped for an exact match later without any model changes.
const _categoryReferenceVideoIds = {
  DrillCategory.ballControl: 'CosG13seo3o', // Progressive Soccer: 10 Ball Mastery Soccer Drills for Kids U6 U8 U10 U12
  DrillCategory.oneVOne: 'npeM7yvN_8A', // Soccerspective: 1v1 Dribbling Drill for U10-U12
  DrillCategory.passing: '6RGJBj1tNC8', // Progressive Soccer: 6 Essential Soccer Passing Drills for Kids
  DrillCategory.possession: '9jQRQsnyfKw', // Soccerspective: 8v3 Rondo Possession Drill
  DrillCategory.attackingPrinciples: 'OzTEOTEVMPg', // World Class Coaching: Coaching Width and Depth
  DrillCategory.defendingPrinciples: 'IHeUKdsVHHg', // KS Performance: Press & Cover Defending Drill (U8-U10+)
  DrillCategory.smallSidedGames: '9ojC_3pd-3k', // KS Performance: Small Sided Games, 5 Variations
  DrillCategory.gameRealism: 'EvZdkjyrx5k', // Dyches Fam: Kids Soccer Drills, Training, and Scrimmage
};

List<Drill> buildU10CurriculumDrills() => [
      for (final w in _weeks) ...[
        Drill(
          id: 'drill-u10-w${_weekId(w.week)}-game',
          name: w.gameName,
          category: w.gameCategory,
          skillTags: w.gameSkills,
          description: w.gameDescription,
          ageRange: _ageRange,
          videoId: _categoryReferenceVideoIds[w.gameCategory],
        ),
        Drill(
          id: 'drill-u10-w${_weekId(w.week)}-drill',
          name: w.drillName,
          category: w.drillCategory,
          skillTags: w.drillSkills,
          description: w.drillDescription,
          ageRange: _ageRange,
          videoId: _categoryReferenceVideoIds[w.drillCategory],
        ),
      ],
      for (final s in _scrimmageFormats)
        Drill(
          id: s.id,
          name: s.name,
          category: s.category,
          skillTags: s.skillTags,
          description: s.description,
          ageRange: _ageRange,
          videoId: _categoryReferenceVideoIds[s.category],
        ),
    ];

/// The 16 built-in weekly sessions, each structured as
/// Warm-up → Game → Drill → Scrimmage.
List<Session> buildU10CurriculumSessions() => [
      for (final w in _weeks)
        Session(
          id: 'session-u10-week-${_weekId(w.week)}',
          name: 'U10 Week ${w.week}: ${w.focus}',
          drills: [
            SessionDrill(
              drillId: _warmupPool[(w.week - 1) % _warmupPool.length],
              phase: SessionPhase.warmUp,
              durationMinutes: 10,
            ),
            SessionDrill(
              drillId: 'drill-u10-w${_weekId(w.week)}-game',
              phase: SessionPhase.game,
              durationMinutes: 15,
            ),
            SessionDrill(
              drillId: 'drill-u10-w${_weekId(w.week)}-drill',
              phase: SessionPhase.drill,
              durationMinutes: 15,
            ),
            SessionDrill(
              drillId: _scrimmageFormats[w.scrimmageBlock - 1].id,
              phase: SessionPhase.scrimmage,
              durationMinutes: 20,
            ),
          ],
        ),
    ];

/// Reference metadata for the Season Plan screen: which week belongs to
/// which block, its focus, and the session it maps to.
List<SeasonWeek> buildU10SeasonPlan() => [
      for (final w in _weeks)
        SeasonWeek(
          weekNumber: w.week,
          blockTitle: w.blockTitle,
          focus: w.focus,
          sessionId: 'session-u10-week-${_weekId(w.week)}',
        ),
    ];

const u10SeasonBlocks = [
  SeasonBlock(
    title: _block1,
    weekRange: 'Weeks 1–4',
    description: 'Close control, moves, and 1v1 attacking & defending duels.',
  ),
  SeasonBlock(
    title: _block2,
    weekRange: 'Weeks 5–8',
    description: 'First touch, passing accuracy, support angles, and possession.',
  ),
  SeasonBlock(
    title: _block3,
    weekRange: 'Weeks 9–12',
    description:
        'Attacking and defending principles, applied in small-sided games.',
  ),
  SeasonBlock(
    title: _block4,
    weekRange: 'Weeks 13–16',
    description: 'Game realism, set pieces, and tournament readiness.',
  ),
];
