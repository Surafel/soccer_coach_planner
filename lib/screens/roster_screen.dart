import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../models/player.dart';
import '../services/attendance_repository.dart';
import '../services/roster_repository.dart';
import '../widgets/player_tile.dart';
import 'attendance_screen.dart';
import 'player_form_screen.dart';

class RosterScreen extends StatefulWidget {
  final RosterRepository rosterRepository;
  final AttendanceRepository attendanceRepository;
  final VoidCallback onChanged;

  const RosterScreen({
    super.key,
    required this.rosterRepository,
    required this.attendanceRepository,
    required this.onChanged,
  });

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  Future<void> _openForm({Player? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerFormScreen(
          rosterRepository: widget.rosterRepository,
          existingPlayer: existing,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _delete(Player player) async {
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
    await widget.rosterRepository.deletePlayer(player.id);
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.rosterRepository.players;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Take attendance for today',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AttendanceScreen(
                  date: AttendanceRecord.isoDate(DateTime.now()),
                  rosterRepository: widget.rosterRepository,
                  attendanceRepository: widget.attendanceRepository,
                ),
              ),
            ),
          ),
        ],
      ),
      body: players.isEmpty
          ? const Center(
              child: Text(
                'No players yet. Tap + to add your roster.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return PlayerTile(
                  player: player,
                  onTap: () => _openForm(existing: player),
                  onDelete: () => _delete(player),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
