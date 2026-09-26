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
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const ScheduleEntryTile({
    super.key,
    required this.date,
    required this.assignedSession,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(formatScheduleDate(date)),
        subtitle: Text(assignedSession?.name ?? 'No practice'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
