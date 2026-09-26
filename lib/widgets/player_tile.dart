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
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlayerTile({
    super.key,
    required this.player,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        subtitle: Text(
          player.notes != null && player.notes!.isNotEmpty
              ? '${_positionLabel(player.position)} · has notes'
              : _positionLabel(player.position),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
