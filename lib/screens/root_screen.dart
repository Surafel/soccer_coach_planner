import 'package:flutter/material.dart';

import '../models/coach.dart';
import '../models/roster.dart';
import '../services/attendance_repository.dart';
import '../services/coach_assignment_repository.dart';
import '../services/coach_availability_repository.dart';
import '../services/coach_repository.dart';
import '../services/data_store.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/season_auto_assign.dart';
import '../services/season_progress_repository.dart';
import '../services/session_repository.dart';
import 'library_screen.dart';
import 'sessions_screen.dart';
import 'team_hub_screen.dart';
import 'today_screen.dart';

class RootScreen extends StatefulWidget {
  /// Where the app's data lives: this device only (the default) or the
  /// club's shared database.
  final DataStore? store;

  /// The signed-in coach's email and how to sign out, when using shared data.
  final String? signedInEmail;
  final VoidCallback? onSignOut;

  const RootScreen({super.key, this.store, this.signedInEmail, this.onSignOut});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final DataStore _store = widget.store ?? LocalDataStore();
  late final _drillRepository = DrillRepository(store: _store);
  late final _sessionRepository = SessionRepository(store: _store);
  late final _scheduleRepository = ScheduleRepository(store: _store);
  late final _rosterRepository = RosterRepository(store: _store);
  late final _playerRepository = PlayerRepository(store: _store);
  late final _coachRepository = CoachRepository(store: _store);
  late final _availabilityRepository = CoachAvailabilityRepository(store: _store);
  late final _assignmentRepository = CoachAssignmentRepository(store: _store);
  late final _attendanceRepository = AttendanceRepository(store: _store);
  late final _progressRepository = SeasonProgressRepository(store: _store);

  int _tabIndex = 0;
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    // Another coach changed the shared data: the repositories are already
    // updated, so just redraw.
    _store.addListener(_refresh);
    _load();
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      await Future.wait([
        _drillRepository.load(),
        _sessionRepository.load(),
        _scheduleRepository.load(),
        _rosterRepository.load(),
        _playerRepository.load(),
        _coachRepository.load(),
        _availabilityRepository.load(),
        _assignmentRepository.load(),
        _attendanceRepository.load(),
        _progressRepository.load(),
      ]);
      // Upgrading from before rosters existed: give any pre-existing
      // players/schedule/attendance a real roster to live under so nothing
      // is lost.
      if (_rosterRepository.rosters.isEmpty && _playerRepository.players.isNotEmpty) {
        await _rosterRepository.saveRoster(
          const Roster(id: legacyRosterId, name: 'My Roster'),
        );
      }
      // Upgrading from before coaches were their own entity: turn each
      // roster's old free-text coach names into real Coach records.
      for (final roster in _rosterRepository.rosters) {
        if (roster.legacyCoachNames.isEmpty) continue;
        final ids = <String>[];
        for (var i = 0; i < roster.legacyCoachNames.length; i++) {
          final coach = Coach(
            id: '${DateTime.now().microsecondsSinceEpoch}-$i',
            name: roster.legacyCoachNames[i],
          );
          await _coachRepository.saveCoach(coach);
          ids.add(coach.id);
        }
        await _rosterRepository.saveRoster(roster.copyWith(coachIds: ids));
      }
      await runSeasonAutoAssignment(
        rosterRepository: _rosterRepository,
        scheduleRepository: _scheduleRepository,
        progressRepository: _progressRepository,
        drillRepository: _drillRepository,
        sessionRepository: _sessionRepository,
      );
      setState(() => _loading = false);
    } catch (_) {
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadFailed) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load app data.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final tabs = [
      TodayScreen(
        drillRepository: _drillRepository,
        sessionRepository: _sessionRepository,
        scheduleRepository: _scheduleRepository,
        rosterRepository: _rosterRepository,
        playerRepository: _playerRepository,
        coachRepository: _coachRepository,
        availabilityRepository: _availabilityRepository,
        assignmentRepository: _assignmentRepository,
        attendanceRepository: _attendanceRepository,
        onGoToRosters: () => setState(() => _tabIndex = 3),
        onChanged: _refresh,
      ),
      LibraryScreen(drillRepository: _drillRepository, onChanged: _refresh),
      SessionsScreen(
        drillRepository: _drillRepository,
        sessionRepository: _sessionRepository,
        scheduleRepository: _scheduleRepository,
        onChanged: _refresh,
      ),
      TeamHubScreen(
        rosterRepository: _rosterRepository,
        playerRepository: _playerRepository,
        coachRepository: _coachRepository,
        availabilityRepository: _availabilityRepository,
        assignmentRepository: _assignmentRepository,
        scheduleRepository: _scheduleRepository,
        attendanceRepository: _attendanceRepository,
        sessionRepository: _sessionRepository,
        drillRepository: _drillRepository,
        progressRepository: _progressRepository,
        onChanged: _refresh,
        signedInEmail: widget.signedInEmail,
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Drills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Team',
          ),
        ],
      ),
    );
  }
}
