import 'package:flutter/material.dart';

import '../models/session.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.list_alt)),
        title: Text(session.name),
        subtitle: Text(
          '${session.drills.length} drills · ${session.totalDurationMinutes} min',
        ),
        trailing: trailing,
      ),
    );
  }
}
