import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/player_repository.dart';
import '../services/roster_repository.dart';
import '../widgets/player_tile.dart';
import 'player_form_screen.dart';

/// The full player pool across every group, in one list — the master roster
/// coaches can browse regardless of which group a player is currently in.
class PlayersScreen extends StatefulWidget {
  final PlayerRepository playerRepository;
  final RosterRepository rosterRepository;
  final VoidCallback onChanged;

  const PlayersScreen({
    super.key,
    required this.playerRepository,
    required this.rosterRepository,
    required this.onChanged,
  });

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  Future<void> _openForm({Player? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerFormScreen(
          playerRepository: widget.playerRepository,
          rosterRepository: widget.rosterRepository,
          initialRosterId: widget.rosterRepository.rosters.isEmpty
              ? null
              : widget.rosterRepository.rosters.first.id,
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

  @override
  Widget build(BuildContext context) {
    final players = widget.playerRepository.players;
    final hasGroups = widget.rosterRepository.rosters.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Players')),
      body: players.isEmpty
          ? Center(
              child: Text(
                hasGroups
                    ? 'No players yet. Tap + to add one.'
                    : 'Create a group first, then add players to it.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final group = widget.rosterRepository.byId(player.rosterId);
                return PlayerTile(
                  player: player,
                  groupLabel: group?.name,
                  onTap: () => _openForm(existing: player),
                  onDelete: () => _deletePlayer(player),
                );
              },
            ),
      floatingActionButton: hasGroups
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
