import 'package:flutter/material.dart';

import '../models/age_group.dart';
import '../models/roster.dart';

class RosterCard extends StatelessWidget {
  final Roster roster;
  final int playerCount;
  final List<String> coachNames;
  final VoidCallback onTap;

  const RosterCard({
    super.key,
    required this.roster,
    required this.playerCount,
    required this.coachNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ageGroupText =
        roster.ageGroup == null ? 'No age group' : ageGroupLabel(roster.ageGroup!);
    final coachText =
        coachNames.isEmpty ? 'No coaches assigned' : coachNames.join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: Text(roster.name),
        subtitle: Text('$ageGroupText · $playerCount players · $coachText'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
