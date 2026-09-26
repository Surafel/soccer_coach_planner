import 'package:flutter/material.dart';

import '../models/roster.dart';
import '../services/attendance_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/season_auto_assign.dart';
import '../services/season_progress_repository.dart';
import '../services/session_repository.dart';
import 'library_screen.dart';
import 'rosters_screen.dart';
import 'sessions_screen.dart';
import 'today_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final _drillRepository = DrillRepository();
  final _sessionRepository = SessionRepository();
  final _scheduleRepository = ScheduleRepository();
  final _rosterRepository = RosterRepository();
  final _playerRepository = PlayerRepository();
  final _attendanceRepository = AttendanceRepository();
  final _progressRepository = SeasonProgressRepository();

  int _tabIndex = 0;
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
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

  void _refresh() => setState(() {});

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
      RostersScreen(
        rosterRepository: _rosterRepository,
        playerRepository: _playerRepository,
        scheduleRepository: _scheduleRepository,
        attendanceRepository: _attendanceRepository,
        sessionRepository: _sessionRepository,
        drillRepository: _drillRepository,
        progressRepository: _progressRepository,
        onChanged: _refresh,
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
            label: 'Rosters',
          ),
        ],
      ),
    );
  }
}
