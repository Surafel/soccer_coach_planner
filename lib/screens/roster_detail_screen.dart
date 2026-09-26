import 'package:flutter/material.dart';

import '../models/age_group.dart';
import '../models/attendance_record.dart';
import '../models/player.dart';
import '../models/roster.dart';
import '../services/attendance_repository.dart';
import '../services/drill_repository.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/season_progress_repository.dart';
import '../services/session_repository.dart';
import '../widgets/player_tile.dart';
import 'attendance_screen.dart';
import 'player_form_screen.dart';
import 'roster_form_screen.dart';
import 'schedule_screen.dart';
import 'season_plan_screen.dart';

class RosterDetailScreen extends StatefulWidget {
  final String rosterId;
  final RosterRepository rosterRepository;
  final PlayerRepository playerRepository;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final SessionRepository sessionRepository;
  final DrillRepository drillRepository;
  final SeasonProgressRepository progressRepository;
  final VoidCallback onChanged;

  const RosterDetailScreen({
    super.key,
    required this.rosterId,
    required this.rosterRepository,
    required this.playerRepository,
    required this.scheduleRepository,
    required this.attendanceRepository,
    required this.sessionRepository,
    required this.drillRepository,
    required this.progressRepository,
    required this.onChanged,
  });

  @override
  State<RosterDetailScreen> createState() => _RosterDetailScreenState();
}

class _RosterDetailScreenState extends State<RosterDetailScreen> {
  Roster get _roster => widget.rosterRepository.byId(widget.rosterId)!;

  Future<void> _editRoster() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RosterFormScreen(
          rosterRepository: widget.rosterRepository,
          existingRoster: _roster,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _deleteRoster() async {
    final roster = _roster;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete roster?'),
        content: Text(
          'This removes "${roster.name}", its players, schedule, and '
          'attendance history. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.playerRepository.deleteForRoster(roster.id);
    await widget.scheduleRepository.deleteRoster(roster.id);
    await widget.attendanceRepository.deleteForRoster(roster.id);
    await widget.progressRepository.deleteForRoster(roster.id);
    await widget.rosterRepository.deleteRoster(roster.id);
    widget.onChanged();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _openPlayerForm({Player? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerFormScreen(
          playerRepository: widget.playerRepository,
          rosterId: widget.rosterId,
          existingPlayer: existing,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _deletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove player?'),
        content: Text('This will remove "${player.name}" from the roster.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.playerRepository.deletePlayer(player.id);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _openSchedule() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleScreen(
          rosterId: widget.rosterId,
          sessionRepository: widget.sessionRepository,
          scheduleRepository: widget.scheduleRepository,
          onChanged: widget.onChanged,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _openAttendance() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          rosterId: widget.rosterId,
          date: AttendanceRecord.isoDate(DateTime.now()),
          playerRepository: widget.playerRepository,
          attendanceRepository: widget.attendanceRepository,
        ),
      ),
    );
  }

  Future<void> _openSeasonPlan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeasonPlanScreen(
          drillRepository: widget.drillRepository,
          sessionRepository: widget.sessionRepository,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roster = _roster;
    final players = widget.playerRepository.playersForRoster(roster.id);
    final progress = widget.progressRepository.forRoster(roster.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(roster.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _editRoster),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteRoster),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    roster.ageGroup == null ? 'No age group' : ageGroupLabel(roster.ageGroup!),
                  ),
                ),
                if (roster.coachNames.isEmpty)
                  const Chip(label: Text('No coaches assigned'))
                else
                  for (final coach in roster.coachNames) Chip(label: Text(coach)),
              ],
            ),
          ),
          if (roster.ageGroup == AgeGroup.u10)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      progress == null
                          ? 'Season plan starts this Saturday.'
                          : 'Season plan: Week ${progress.currentWeek} of 16 '
                              '(auto-assigned to Saturday).',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _openSeasonPlan,
                    child: const Text('Browse'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openSchedule,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Weekly Schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openAttendance,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Take Attendance'),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Players'),
            ),
          ),
          if (players.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('No players yet. Tap + to add one.'),
            )
          else
            for (final player in players)
              PlayerTile(
                player: player,
                onTap: () => _openPlayerForm(existing: player),
                onDelete: () => _deletePlayer(player),
              ),
          const SizedBox(height: 72),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPlayerForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
