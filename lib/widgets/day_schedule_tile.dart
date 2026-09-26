import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/weekly_schedule.dart';

String _dayLabel(DayOfWeek day) {
  const labels = {
    DayOfWeek.monday: 'Monday',
    DayOfWeek.tuesday: 'Tuesday',
    DayOfWeek.wednesday: 'Wednesday',
    DayOfWeek.thursday: 'Thursday',
    DayOfWeek.friday: 'Friday',
    DayOfWeek.saturday: 'Saturday',
    DayOfWeek.sunday: 'Sunday',
  };
  return labels[day]!;
}

class DayScheduleTile extends StatelessWidget {
  final DayOfWeek day;
  final Session? assignedSession;
  final VoidCallback onTap;

  const DayScheduleTile({
    super.key,
    required this.day,
    required this.assignedSession,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(_dayLabel(day)),
        subtitle: Text(assignedSession?.name ?? 'No practice'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
