import 'package:flutter/material.dart';

import '../models/coach.dart';
import '../services/coach_assignment_repository.dart';
import '../services/coach_availability_repository.dart';
import '../services/coach_repository.dart';
import '../services/roster_repository.dart';
import 'coach_availability_screen.dart';
import 'coach_form_screen.dart';

class CoachesScreen extends StatefulWidget {
  final CoachRepository coachRepository;
  final RosterRepository rosterRepository;
  final CoachAvailabilityRepository availabilityRepository;
  final CoachAssignmentRepository assignmentRepository;
  final VoidCallback onChanged;

  const CoachesScreen({
    super.key,
    required this.coachRepository,
    required this.rosterRepository,
    required this.availabilityRepository,
    required this.assignmentRepository,
    required this.onChanged,
  });

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  Future<void> _openForm({Coach? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachFormScreen(
          coachRepository: widget.coachRepository,
          existingCoach: existing,
        ),
      ),
    );
    setState(() {});
    widget.onChanged();
  }

  Future<void> _deleteCoach(Coach coach) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove coach?'),
        content: Text(
          'This removes "${coach.name}" and unassigns them from any groups.',
        ),
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
    for (final roster in widget.rosterRepository.rosters) {
      if (roster.coachIds.contains(coach.id)) {
        await widget.rosterRepository.saveRoster(
          roster.copyWith(
            coachIds: roster.coachIds.where((id) => id != coach.id).toList(),
          ),
        );
      }
    }
    await widget.assignmentRepository.removeCoachEverywhere(coach.id);
    await widget.availabilityRepository.deleteForCoach(coach.id);
    await widget.coachRepository.deleteCoach(coach.id);
    setState(() {});
    widget.onChanged();
  }

  Future<void> _openAvailability(Coach coach) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachAvailabilityScreen(
          coach: coach,
          availabilityRepository: widget.availabilityRepository,
        ),
      ),
    );
  }

  String _groupsFor(Coach coach) {
    final names = [
      for (final roster in widget.rosterRepository.rosters)
        if (roster.coachIds.contains(coach.id)) roster.name,
    ];
    return names.isEmpty ? 'Not assigned to a group' : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final coaches = widget.coachRepository.coaches;
    return Scaffold(
      appBar: AppBar(title: const Text('Coaches')),
      body: coaches.isEmpty
          ? const Center(
              child: Text(
                'No coaches yet. Tap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(coach.name),
                    subtitle: Text(_groupsFor(coach)),
                    onTap: () => _openForm(existing: coach),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.event_available_outlined),
                          tooltip: 'Set availability',
                          onPressed: () => _openAvailability(coach),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteCoach(coach),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
