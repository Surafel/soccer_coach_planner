import '../models/age_group.dart';
import '../models/drill.dart';
import '../models/season_curriculum.dart';
import '../models/season_week.dart';
import '../models/session.dart';
import '../models/session_drill.dart';
import '../models/session_phase.dart';

/// The built-in U12 season plan: a 16-week curriculum in the same US Soccer
/// grassroots format as U10 (Warm-up → Game → Drill → Scrimmage), built for
/// the U11–U12 9v9 game, which adds offside and the build-out line. It moves
/// players on from U10's individual work to playing through lines, team
/// shape, and transition. Practices run 80 minutes instead of U10's 60.
const u12AgeGroup = AgeGroup.u12;

const _ageRange = '11-12';

/// The U10 warm-up pool reuses the starter library's games, which are aimed
/// at 5–8 year olds. U12 players need a warm-up that gets them ready for an
/// 80-minute practice, so this plan has its own pool.
const _warmups = [
  _ActivityContent(
    id: 'drill-u12-warmup-dynamic',
    name: 'Dynamic Warm-Up with the Ball',
    category: DrillCategory.ballControl,
    skills: ['Ball Mastery', 'Mobility'],
    description:
        'Jog the length of a grid with a ball each, adding a movement every '
        'lap: high knees, open/close the gate, side shuffles, then sole rolls '
        'and inside-outside touches. Finish with short accelerations.',
  ),
  _ActivityContent(
    id: 'drill-u12-warmup-rondo',
    name: '5v2 Warm-Up Rondo',
    category: DrillCategory.possession,
    skills: ['Passing', 'First Touch', 'Scanning'],
    description:
        'Five players keep the ball from two in a small grid. A defender who '
        'wins the ball swaps with whoever lost it. Two touches maximum.',
  ),
  _ActivityContent(
    id: 'drill-u12-warmup-pattern',
    name: 'Passing Pattern Activation',
    category: DrillCategory.passing,
    skills: ['Passing', 'Receiving', 'Movement'],
    description:
        'Groups of four run a set Y-shaped passing pattern and follow their '
        'pass. Start slowly, then speed up the ball and the movement each round.',
  ),
  _ActivityContent(
    id: 'drill-u12-warmup-tag',
    name: 'Dribble Tag',
    category: DrillCategory.dribbling,
    skills: ['Dribbling', 'Change of Direction', 'Awareness'],
    description:
        'Everyone dribbles a ball. Two taggers (also dribbling) try to tag '
        'players, who must keep their ball close while escaping. Rotate taggers '
        'every minute.',
  ),
];

/// A Game or Drill activity's content. The Warm-up pool and the
/// Scrimmage formats use it too, so every drill is described the same way.
class _ActivityContent {
  final String id;
  final String name;
  final DrillCategory category;
  final List<String> skills;
  final String description;

  const _ActivityContent({
    this.id = '',
    required this.name,
    required this.category,
    required this.skills,
    required this.description,
  });
}

const _scrimmageFormats = [
  _ActivityContent(
    id: 'drill-u12-scrimmage-block1',
    name: 'Scrimmage: 6v6 Scan-and-Play',
    category: DrillCategory.smallSidedGames,
    skills: ['First Touch', 'Scanning', '1v1'],
    description:
        '6v6 with keepers on a reduced field. A goal counts double if the '
        'scorer\'s team won a 1v1 or received on the half-turn in the build-up '
        '— reward players for looking before the ball arrives.',
  ),
  _ActivityContent(
    id: 'drill-u12-scrimmage-block2',
    name: 'Scrimmage: 7v7 Through the Thirds',
    category: DrillCategory.possession,
    skills: ['Possession', 'Combination Play', 'Switching Play'],
    description:
        '7v7 on a field split into thirds. The ball must be played into each '
        'third, not over it, before a team can score — encourages playing '
        'through lines with combinations instead of long balls.',
  ),
  _ActivityContent(
    id: 'drill-u12-scrimmage-block3',
    name: 'Scrimmage: 9v9 with Build-Out Line',
    category: DrillCategory.smallSidedGames,
    skills: ['Team Shape', 'Build-Out Play', 'Offside Line'],
    description:
        'Full 9v9 on the U12 field with the build-out line and offside called. '
        'Freeze play to point out team shape, the back line\'s height, and '
        'options when building out.',
  ),
  _ActivityContent(
    id: 'drill-u12-scrimmage-block4',
    name: 'Scrimmage: 9v9 Match Conditions',
    category: DrillCategory.gameRealism,
    skills: ['Game Management', 'Transition', 'Restarts'],
    description:
        'Two timed halves of 9v9 under full match rules: offside, build-out '
        'line, restarts, a running score, and the substitutions you would make '
        'on match day.',
  ),
];

class _WeekContent {
  final int week;
  final String blockTitle;
  final String focus;
  final _ActivityContent game;
  final _ActivityContent drill;
  final int scrimmageBlock; // 1-based index into _scrimmageFormats

  const _WeekContent({
    required this.week,
    required this.blockTitle,
    required this.focus,
    required this.game,
    required this.drill,
    required this.scrimmageBlock,
  });
}

const _block1 = 'First Touch, Scanning & Beating Players';
const _block2 = 'Possession & Playing Through Lines';
const _block3 = 'Team Shape in the 9v9 Game';
const _block4 = 'Transition & Match Readiness';

const _weeks = [
  _WeekContent(
    week: 1,
    blockTitle: _block1,
    focus: 'Receiving on the half-turn — scan before the ball arrives',
    game: _ActivityContent(
      name: 'Check Your Shoulder Rondo',
      category: DrillCategory.possession,
      skills: ['Scanning', 'Receiving', 'Body Shape'],
      description:
          '4v1 rondo with a coach holding up a number of fingers behind the '
          'receiver. A pass only counts if the receiver calls out the number '
          '— they have to look before the ball comes.',
    ),
    drill: _ActivityContent(
      name: 'Half-Turn Receiving Gates',
      category: DrillCategory.ballControl,
      skills: ['First Touch', 'Half-Turn', 'Open Body Shape'],
      description:
          'Server passes into a receiver standing between two cone gates. '
          'Receiver opens their hips and takes the first touch across the body '
          'through the gate away from a passive defender.',
    ),
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 2,
    blockTitle: _block1,
    focus: 'Longer passing — driven and lofted balls',
    game: _ActivityContent(
      name: 'Long Ball Target Zones',
      category: DrillCategory.passing,
      skills: ['Driven Pass', 'Lofted Pass', 'Accuracy'],
      description:
          'Two teams pass across a 30–35 yard gap into a marked target zone '
          'where a teammate must control the ball. Points for a clean first '
          'touch inside the zone.',
    ),
    drill: _ActivityContent(
      name: 'Driven Pass Technique Pairs',
      category: DrillCategory.passing,
      skills: ['Driven Pass', 'Laces Technique', 'Receiving'],
      description:
          'Partners 20 yards apart strike driven passes with the laces, '
          'non-kicking foot beside the ball and body over it. Lengthen the '
          'distance and add lofted passes as technique holds up.',
    ),
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 3,
    blockTitle: _block1,
    focus: 'Controlling balls out of the air',
    game: _ActivityContent(
      name: 'Toss-Control-Pass Volleyball',
      category: DrillCategory.ballControl,
      skills: ['Thigh Control', 'Chest Control', 'Cushioning'],
      description:
          'Teams across a low cone "net". The ball is thrown or lofted over; '
          'the receiving side must bring it down with thigh, chest, or foot '
          'and pass it back over within three touches.',
    ),
    drill: _ActivityContent(
      name: 'Cushion & Set Circuit',
      category: DrillCategory.ballControl,
      skills: ['Instep Cushion', 'Thigh Control', 'Chest Control'],
      description:
          'Server tosses balls at different heights. Receiver cushions it '
          'into the ground with the right surface and sets it into a dribble '
          'or pass in one movement.',
    ),
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 4,
    blockTitle: _block1,
    focus: 'Running with the ball and beating players in wide areas',
    game: _ActivityContent(
      name: 'Wing Channel 1v1s',
      category: DrillCategory.oneVOne,
      skills: ['1v1 Attacking', 'Running With the Ball', 'Crossing'],
      description:
          'Attackers in a wide channel take on a defender and either get to '
          'the end line to cross or cut inside to shoot on a small goal.',
    ),
    drill: _ActivityContent(
      name: 'Speed Dribble & Cut Inside',
      category: DrillCategory.dribbling,
      skills: ['Running With the Ball', 'Cut Inside', 'Change of Pace'],
      description:
          'Run with the ball at speed using big touches with the laces, then '
          'slow down and cut inside past a cone defender with a sharp change '
          'of direction.',
    ),
    scrimmageBlock: 1,
  ),
  _WeekContent(
    week: 5,
    blockTitle: _block2,
    focus: 'Directional possession — keep the ball and move it forward',
    game: _ActivityContent(
      name: 'End-Zone Possession',
      category: DrillCategory.possession,
      skills: ['Possession', 'Forward Passing', 'Support'],
      description:
          '5v5 plus two neutrals. A team scores by passing to a teammate '
          'running into the end zone, not by keeping the ball for its own sake.',
    ),
    drill: _ActivityContent(
      name: 'Diamond Rondo with Direction',
      category: DrillCategory.possession,
      skills: ['Support Angles', 'Playing Forward', 'Tempo'],
      description:
          'Four players on a diamond keep the ball from two defenders. Points '
          'for each pass from the back of the diamond to the front without '
          'going around the outside.',
    ),
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 6,
    blockTitle: _block2,
    focus: 'Wall passes and combination play',
    game: _ActivityContent(
      name: '2v1 + Wall Player to Goal',
      category: DrillCategory.attackingPrinciples,
      skills: ['Wall Pass', 'Combination Play', 'Finishing'],
      description:
          'Two attackers against one defender, plus a target player who can '
          'play one-touch wall passes. Finish on goal within eight seconds.',
    ),
    drill: _ActivityContent(
      name: 'Give-and-Go Pattern Lanes',
      category: DrillCategory.passing,
      skills: ['Wall Pass', 'Timing of Runs', 'One-Touch Passing'],
      description:
          'Players run a give-and-go around a mannequin or cone, timing the '
          'run so the return pass is played into space. Run it off both feet.',
    ),
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 7,
    blockTitle: _block2,
    focus: 'Third-man runs — playing through lines',
    game: _ActivityContent(
      name: 'Three-Zone Line Breaker',
      category: DrillCategory.possession,
      skills: ['Third-Man Run', 'Playing Through Lines', 'Timing'],
      description:
          'Three zones with defenders in the middle. Attackers in one end zone '
          'try to get the ball to the far zone through a teammate who drops '
          'into the middle, then a third player running beyond.',
    ),
    drill: _ActivityContent(
      name: 'Up-Back-Through Pattern',
      category: DrillCategory.passing,
      skills: ['Third-Man Run', 'Lay-Off', 'Through Ball'],
      description:
          'A plays into B, B lays off to C, and C plays through for A running '
          'beyond. Rotate positions and add a passive defender once the timing '
          'is consistent.',
    ),
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 8,
    blockTitle: _block2,
    focus: 'Switching the point of attack',
    game: _ActivityContent(
      name: 'Four-Goal Switch Game',
      category: DrillCategory.smallSidedGames,
      skills: ['Switching Play', 'Scanning', 'Width'],
      description:
          '6v6 with two small goals on each end line. Defenders shift to the '
          'ball; attackers look to switch play quickly to the open goal.',
    ),
    drill: _ActivityContent(
      name: 'Switch Through the Middle',
      category: DrillCategory.passing,
      skills: ['Switching Play', 'Driven Pass', 'Body Shape'],
      description:
          'Ball moves from a wide player to a central player and out to the '
          'opposite side, first with three passes, then by skipping the middle '
          'with a longer driven pass.',
    ),
    scrimmageBlock: 2,
  ),
  _WeekContent(
    week: 9,
    blockTitle: _block3,
    focus: 'Building out from the back with the build-out line',
    game: _ActivityContent(
      name: 'Build-Out Line Game',
      category: DrillCategory.gameRealism,
      skills: ['Build-Out Play', 'Composure', 'Support'],
      description:
          'Keeper plus four defenders try to play out past the build-out line '
          'against three pressing attackers. Attackers must retreat behind the '
          'line on a goal kick or keeper possession, as in U12 matches.',
    ),
    drill: _ActivityContent(
      name: 'Keeper Distribution Patterns',
      category: DrillCategory.passing,
      skills: ['Goalkeeper Distribution', 'Split Center-Backs', 'Angles'],
      description:
          'Center-backs split wide, outside backs push up, and a midfielder '
          'drops in. Rehearse the keeper finding each option, then playing '
          'forward from there.',
    ),
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 10,
    blockTitle: _block3,
    focus: 'Defending as a unit — compactness and when to press',
    game: _ActivityContent(
      name: 'Press Trigger Small-Sided Game',
      category: DrillCategory.defendingPrinciples,
      skills: ['Pressing Triggers', 'Compactness', 'Communication'],
      description:
          '7v7 where the defending team scores a bonus point for winning the '
          'ball within five seconds of a trigger: a bad touch, a backward pass, '
          'or a pass to the sideline.',
    ),
    drill: _ActivityContent(
      name: 'Shift as a Back Four',
      category: DrillCategory.defendingPrinciples,
      skills: ['Pressure', 'Cover', 'Balance', 'Compactness'],
      description:
          'Four defenders shift together as the coach moves the ball across '
          'a line of servers: nearest player presses, others cover and tuck in, '
          'staying connected.',
    ),
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 11,
    blockTitle: _block3,
    focus: 'Offside — holding the line and timing runs',
    game: _ActivityContent(
      name: 'Offside Line Battle',
      category: DrillCategory.smallSidedGames,
      skills: ['Offside Line', 'Timing of Runs', 'Through Balls'],
      description:
          '5v4 to goal with offside enforced. Defenders step up together to '
          'catch attackers; attackers practice bending runs to stay onside and '
          'timing them with the pass.',
    ),
    drill: _ActivityContent(
      name: 'Step-Up & Drop Drill',
      category: DrillCategory.defendingPrinciples,
      skills: ['Defensive Line', 'Communication', 'Offside Trap'],
      description:
          'Back line reacts to the coach: step up together when the ball goes '
          'backward or is under pressure, drop when the passer has time. One '
          'player is the voice of the line.',
    ),
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 12,
    blockTitle: _block3,
    focus: 'Attacking the box — crosses and finishing',
    game: _ActivityContent(
      name: 'Crossing & Finishing Waves',
      category: DrillCategory.shooting,
      skills: ['Crossing', 'Finishing', 'Near/Far Post Runs'],
      description:
          'Wide players deliver crosses while two attackers attack the near '
          'and far post against one defender and a keeper. Waves rotate '
          'quickly.',
    ),
    drill: _ActivityContent(
      name: 'Finishing Technique Stations',
      category: DrillCategory.shooting,
      skills: ['Placement', 'Laces Strike', 'One-Touch Finish'],
      description:
          'Rotate through three finishing stations: shooting across the keeper '
          'after a dribble, a first-time finish from a lay-off, and a volley '
          'from a tossed ball.',
    ),
    scrimmageBlock: 3,
  ),
  _WeekContent(
    week: 13,
    blockTitle: _block4,
    focus: 'Counter-pressing — win it back in five seconds',
    game: _ActivityContent(
      name: 'Five-Second Rule Game',
      category: DrillCategory.smallSidedGames,
      skills: ['Counter-Pressing', 'Reaction Speed', 'Transition'],
      description:
          '6v6. The team that loses the ball scores a point if it wins it back '
          'within five seconds; after that, it drops into shape.',
    ),
    drill: _ActivityContent(
      name: 'Lose It, Hunt It Rondo',
      category: DrillCategory.possession,
      skills: ['Counter-Pressing', 'Possession', 'Compactness'],
      description:
          'Rondo in two touching grids. When the ball is lost, the nearest '
          'three players sprint to press immediately before the opponents can '
          'escape into the other grid.',
    ),
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 14,
    blockTitle: _block4,
    focus: 'Counter-attacking at speed',
    game: _ActivityContent(
      name: '3v2 Counter Waves',
      category: DrillCategory.attackingPrinciples,
      skills: ['Counter-Attack', 'Decision Making', 'Finishing'],
      description:
          'Three attackers break against two recovering defenders. Defenders '
          'who win the ball counter the other way against the next wave.',
    ),
    drill: _ActivityContent(
      name: 'Win It & Go Pattern',
      category: DrillCategory.attackingPrinciples,
      skills: ['Forward Passing', 'Runs in Behind', 'Speed of Play'],
      description:
          'On a regain, the first pass goes forward into a target player while '
          'two runners sprint beyond. Finish within three passes.',
    ),
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 15,
    blockTitle: _block4,
    focus: 'Set pieces — attacking and defending corners and free kicks',
    game: _ActivityContent(
      name: 'Set Piece Showdown',
      category: DrillCategory.gameRealism,
      skills: ['Corners', 'Free Kicks', 'Marking'],
      description:
          'Teams alternate attacking and defending corners and wide free kicks. '
          'Points for a goal on offense or a clean clearance on defense.',
    ),
    drill: _ActivityContent(
      name: 'Set Piece Routines Walkthrough',
      category: DrillCategory.gameRealism,
      skills: ['Corner Routines', 'Zonal/Player Marking', 'Free Kicks'],
      description:
          'Walk through two corner routines, one free-kick routine, and the '
          'team\'s defending setup, then run them at full speed with light '
          'pressure.',
    ),
    scrimmageBlock: 4,
  ),
  _WeekContent(
    week: 16,
    blockTitle: _block4,
    focus: 'Positional roles and game management',
    game: _ActivityContent(
      name: 'Scenario Small-Sided Game',
      category: DrillCategory.gameRealism,
      skills: ['Game Management', 'Decision Making', 'Leadership'],
      description:
          'Coach sets a match scenario ("down 1-0, ten minutes left", "up a '
          'player") and the team chooses and carries out how to play it.',
    ),
    drill: _ActivityContent(
      name: '9v9 Shape & Roles Walkthrough',
      category: DrillCategory.gameRealism,
      skills: ['Formation', 'Roles & Responsibilities', 'Shape'],
      description:
          'Walk through the team\'s 9v9 formation (e.g. 3-2-3 or 2-3-1-2) in '
          'and out of possession: where each player goes when the ball is won, '
          'lost, and at restarts.',
    ),
    scrimmageBlock: 4,
  ),
];

String _weekId(int week) => week.toString().padLeft(2, '0');

String _gameDrillId(int week) => 'drill-u12-w${_weekId(week)}-game';
String _drillDrillId(int week) => 'drill-u12-w${_weekId(week)}-drill';
String _sessionId(int week) => 'session-u12-week-${_weekId(week)}';

Drill _toDrill(String id, _ActivityContent a) => Drill(
      id: id,
      name: a.name,
      category: a.category,
      skillTags: a.skills,
      description: a.description,
      ageRange: _ageRange,
    );

/// The plan's 44 drills: Game + Drill for each of the 16 weeks, the 4
/// warm-ups, and the 4 scrimmage formats. Like U10's, they have no videoId,
/// so the detail screen offers a YouTube search for each drill's own name.
List<Drill> buildU12CurriculumDrills() => [
      for (final w in _weeks) ...[
        _toDrill(_gameDrillId(w.week), w.game),
        _toDrill(_drillDrillId(w.week), w.drill),
      ],
      for (final a in _warmups) _toDrill(a.id, a),
      for (final s in _scrimmageFormats) _toDrill(s.id, s),
    ];

/// The 16 built-in weekly sessions, each 80 minutes, structured as
/// Warm-up → Game → Drill → Scrimmage.
List<Session> buildU12CurriculumSessions() => [
      for (final w in _weeks)
        Session(
          id: _sessionId(w.week),
          name: 'U12 Week ${w.week}: ${w.focus}',
          drills: [
            SessionDrill(
              drillId: _warmups[(w.week - 1) % _warmups.length].id,
              phase: SessionPhase.warmUp,
              durationMinutes: 15,
            ),
            SessionDrill(
              drillId: _gameDrillId(w.week),
              phase: SessionPhase.game,
              durationMinutes: 20,
            ),
            SessionDrill(
              drillId: _drillDrillId(w.week),
              phase: SessionPhase.drill,
              durationMinutes: 20,
            ),
            SessionDrill(
              drillId: _scrimmageFormats[w.scrimmageBlock - 1].id,
              phase: SessionPhase.scrimmage,
              durationMinutes: 25,
            ),
          ],
        ),
    ];

List<SeasonWeek> buildU12SeasonPlan() => [
      for (final w in _weeks)
        SeasonWeek(
          weekNumber: w.week,
          blockTitle: w.blockTitle,
          focus: w.focus,
          sessionId: _sessionId(w.week),
        ),
    ];

const u12SeasonBlocks = [
  SeasonBlock(
    title: _block1,
    weekRange: 'Weeks 1–4',
    description:
        'Scanning, receiving on the half-turn and out of the air, longer '
        'passing, and 1v1s in wide areas.',
  ),
  SeasonBlock(
    title: _block2,
    weekRange: 'Weeks 5–8',
    description:
        'Directional possession, wall passes, third-man runs, and switching play.',
  ),
  SeasonBlock(
    title: _block3,
    weekRange: 'Weeks 9–12',
    description:
        'Building out past the build-out line, defending as a unit, the '
        'offside line, and attacking the box.',
  ),
  SeasonBlock(
    title: _block4,
    weekRange: 'Weeks 13–16',
    description:
        'Counter-pressing, counter-attacks, set pieces, and match readiness.',
  ),
];

SeasonCurriculum buildU12Curriculum() => SeasonCurriculum(
      ageGroup: u12AgeGroup,
      drills: buildU12CurriculumDrills(),
      sessions: buildU12CurriculumSessions(),
      weeks: buildU12SeasonPlan(),
      blocks: u12SeasonBlocks,
    );
