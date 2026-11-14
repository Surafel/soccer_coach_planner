import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../services/coach_assignment_repository.dart';
import '../services/coach_availability_repository.dart';
import '../services/coach_repository.dart';
import '../services/roster_repository.dart';
import '../services/schedule_repository.dart';
import '../services/session_repository.dart';
import '../widgets/schedule_entry_tile.dart';

class ScheduleScreen extends StatefulWidget {
  final String rosterId;
  final SessionRepository sessionRepository;
  final ScheduleRepository scheduleRepository;
  final RosterRepository rosterRepository;
  final CoachRepository coachRepository;
  final CoachAvailabilityRepository availabilityRepository;
  final CoachAssignmentRepository assignmentRepository;
  final VoidCallback onChanged;

  const ScheduleScreen({
    super.key,
    required this.rosterId,
    required this.sessionRepository,
    required this.scheduleRepository,
    required this.rosterRepository,
    required this.coachRepository,
    required this.availabilityRepository,
    required this.assignmentRepository,
    required this.onChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

/// Returned by the session picker for "No practice", so it can be told
/// apart from the sheet being dismissed without a choice (which returns null).
const _noPractice = '';

class _ScheduleScreenState extends State<ScheduleScreen> {
  /// Returns the chosen session id, [_noPractice], or null if the coach
  /// closed the sheet without choosing.
  Future<String?> _pickSession() {
    final sessions = widget.sessionRepository.sessions;
    return showModalBottomSheet<String>(
      context: context,
      // Let the sheet grow past the default ~half-screen cap; the list
      // scrolls once there are more sessions than fit.
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('No practice'),
              onTap: () => Navigator.of(context).pop(_noPractice),
            ),
            const Divider(height: 1),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No saved sessions yet. Build one in the Sessions tab.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(sessions[i].name),
                    onTap: () => Navigator.of(context).pop(sessions[i].id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignDate(String date) async {
    final selected = await _pickSession();
    if (selected == null) return; // dismissed — leave the date unchanged
    await widget.scheduleRepository.assignSession(
      widget.rosterId,
      date,
      selected == _noPractice ? null : selected,
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _removeDate(String date) async {
    await widget.scheduleRepository.assignSession(widget.rosterId, date, null);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _addToSchedule() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    await _assignDate(AttendanceRecord.isoDate(picked));
  }

  String _availabilityLabel(String coachId, String date) {
    switch (widget.availabilityRepository.availabilityFor(coachId, date)) {
      case true:
        return 'Available';
      case false:
        return "Can't make it";
      default:
        return 'No answer yet';
    }
  }

  Future<void> _assignCoaches(String date) async {
    final roster = widget.rosterRepository.byId(widget.rosterId);
    final coachIds = roster?.coachIds ?? const [];
    final selected = {...widget.assignmentRepository.forRosterAndDate(widget.rosterId, date)};

    if (coachIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This group has no coaches yet. Add some from the Team tab.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign coaches — ${formatScheduleDate(date)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final coachId in coachIds)
                  CheckboxListTile(
                    value: selected.contains(coachId),
                    title: Text(widget.coachRepository.byId(coachId)?.name ?? 'Unknown coach'),
                    subtitle: Text(_availabilityLabel(coachId, date)),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) => setSheetState(() {
                      if (checked == true) {
                        selected.add(coachId);
                      } else {
                        selected.remove(coachId);
                      }
                    }),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () async {
                    await widget.assignmentRepository
                        .saveAssignment(widget.rosterId, date, selected.toList());
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.scheduleRepository.scheduleFor(widget.rosterId);
    final dates = schedule.sortedDates;
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: dates.isEmpty
          ? const Center(
              child: Text(
                'No practices scheduled yet. Tap + to pick a date.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              children: [
                for (final date in dates)
                  ScheduleEntryTile(
                    date: date,
                    assignedSession: schedule.sessionIdFor(date) == null
                        ? null
                        : widget.sessionRepository.byId(schedule.sessionIdFor(date)!),
                    assignedCoachNames: [
                      for (final id
                          in widget.assignmentRepository.forRosterAndDate(widget.rosterId, date))
                        if (widget.coachRepository.byId(id) != null)
                          widget.coachRepository.byId(id)!.name,
                    ],
                    onTap: () => _assignDate(date),
                    onRemove: () => _removeDate(date),
                    onAssignCoaches: () => _assignCoaches(date),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addToSchedule,
        icon: const Icon(Icons.calendar_month),
        label: const Text('Add date'),
      ),
    );
  }
}
