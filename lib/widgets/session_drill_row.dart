import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../models/session_drill.dart';

/// Editable, draggable row for one SessionDrill inside the session builder.
/// The parent screen owns the state; this widget just reports changes.
class SessionDrillRow extends StatelessWidget {
  final int index;
  final Drill drill;
  final SessionDrill entry;
  final ValueChanged<SessionDrill> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onViewDetails;

  const SessionDrillRow({
    super.key,
    required this.index,
    required this.drill,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.drag_handle),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onViewDetails,
                    child: Text(
                      drill.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            _Stepper(
              label: 'Minutes',
              value: entry.durationMinutes,
              min: 1,
              step: 1,
              onChanged: (v) => onChanged(entry.copyWith(durationMinutes: v)),
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

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int step;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              visualDensity: VisualDensity.compact,
              onPressed:
                  value > min ? () => onChanged((value - step).clamp(min, 1 << 30)) : null,
            ),
            SizedBox(
              width: 28,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(value + step),
            ),
          ],
        ),
      ],
    );
  }
}
