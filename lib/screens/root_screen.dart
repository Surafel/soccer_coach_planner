import 'package:flutter/material.dart';

import '../services/attendance_repository.dart';
import '../services/drill_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import 'library_screen.dart';
import 'roster_screen.dart';
import 'schedule_screen.dart';
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
  final _attendanceRepository = AttendanceRepository();

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
        _attendanceRepository.load(),
      ]);
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
        attendanceRepository: _attendanceRepository,
        onGoToSchedule: () => setState(() => _tabIndex = 3),
      ),
      LibraryScreen(drillRepository: _drillRepository, onChanged: _refresh),
      SessionsScreen(
        drillRepository: _drillRepository,
        sessionRepository: _sessionRepository,
        scheduleRepository: _scheduleRepository,
        onChanged: _refresh,
      ),
      ScheduleScreen(
        sessionRepository: _sessionRepository,
        scheduleRepository: _scheduleRepository,
        onChanged: _refresh,
      ),
      RosterScreen(
        rosterRepository: _rosterRepository,
        attendanceRepository: _attendanceRepository,
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
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Roster',
          ),
        ],
      ),
    );
  }
}
