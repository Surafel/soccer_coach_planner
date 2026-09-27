import 'package:flutter/material.dart';

import '../models/player.dart';

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _positionLabel(PlayerPosition position) {
  switch (position) {
    case PlayerPosition.goalkeeper:
      return 'Goalkeeper';
    case PlayerPosition.defender:
      return 'Defender';
    case PlayerPosition.midfielder:
      return 'Midfielder';
    case PlayerPosition.forward:
      return 'Forward';
    case PlayerPosition.unspecified:
      return 'Position not set';
  }
}

class PlayerTile extends StatelessWidget {
  final Player player;

  /// The player's group name, shown alongside position when set. Used by
  /// the global Players list where players from every group are mixed
  /// together; omitted in a single group's own player list.
  final String? groupLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlayerTile({
    super.key,
    required this.player,
    this.groupLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      if (player.age != null) 'Age ${player.age}',
      _positionLabel(player.position),
      if (groupLabel != null) groupLabel!,
      if (player.notes != null && player.notes!.isNotEmpty) 'has notes',
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            player.jerseyNumber?.toString() ??
                (player.name.isNotEmpty ? _capitalize(player.name[0]) : '?'),
          ),
        ),
        title: Text(player.name),
        subtitle: Text(details.join(' · ')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
