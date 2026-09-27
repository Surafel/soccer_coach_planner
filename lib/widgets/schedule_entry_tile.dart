import 'package:flutter/material.dart';

import '../models/session.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats an ISO yyyy-MM-dd date as e.g. "Sat, Sep 27, 2026".
String formatScheduleDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  final weekday = _weekdayNames[date.weekday - 1];
  final month = _monthNames[date.month - 1];
  return '$weekday, $month ${date.day}, ${date.year}';
}

class ScheduleEntryTile extends StatelessWidget {
  final String date;
  final Session? assignedSession;
  final List<String> assignedCoachNames;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAssignCoaches;

  const ScheduleEntryTile({
    super.key,
    required this.date,
    required this.assignedSession,
    required this.assignedCoachNames,
    required this.onTap,
    required this.onRemove,
    required this.onAssignCoaches,
  });

  @override
  Widget build(BuildContext context) {
    final coachLine = assignedCoachNames.isEmpty
        ? 'No coach assigned'
        : 'Coaching: ${assignedCoachNames.join(', ')}';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(formatScheduleDate(date)),
        subtitle: Text('${assignedSession?.name ?? 'No practice'}\n$coachLine'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.groups_outlined),
              tooltip: 'Assign coaches',
              onPressed: onAssignCoaches,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
