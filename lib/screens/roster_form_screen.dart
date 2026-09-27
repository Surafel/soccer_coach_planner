import 'package:flutter/material.dart';

import '../models/age_group.dart';
import '../models/roster.dart';
import '../services/coach_assignment_repository.dart';
import '../services/coach_availability_repository.dart';
import '../services/coach_repository.dart';
import '../services/roster_repository.dart';
import 'coach_form_screen.dart';
import 'coaches_screen.dart';

class RosterFormScreen extends StatefulWidget {
  final RosterRepository rosterRepository;
  final CoachRepository coachRepository;
  final CoachAvailabilityRepository availabilityRepository;
  final CoachAssignmentRepository assignmentRepository;
  final Roster? existingRoster;

  const RosterFormScreen({
    super.key,
    required this.rosterRepository,
    required this.coachRepository,
    required this.availabilityRepository,
    required this.assignmentRepository,
    this.existingRoster,
  });

  @override
  State<RosterFormScreen> createState() => _RosterFormScreenState();
}

class _RosterFormScreenState extends State<RosterFormScreen> {
  late final TextEditingController _nameController;
  late Set<String> _selectedCoachIds;
  AgeGroup? _ageGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingRoster?.name);
    _ageGroup = widget.existingRoster?.ageGroup;
    _selectedCoachIds = {...widget.existingRoster?.coachIds ?? const []};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addNewCoach() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachFormScreen(coachRepository: widget.coachRepository),
      ),
    );
    setState(() {
      // Newly added coach is the last one in the repository's list.
      if (widget.coachRepository.coaches.isNotEmpty) {
        _selectedCoachIds.add(widget.coachRepository.coaches.last.id);
      }
    });
  }

  Future<void> _manageCoaches() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachesScreen(
          coachRepository: widget.coachRepository,
          rosterRepository: widget.rosterRepository,
          availabilityRepository: widget.availabilityRepository,
          assignmentRepository: widget.assignmentRepository,
          onChanged: () {},
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the roster a name.')),
      );
      return;
    }
    final roster = Roster(
      id: widget.existingRoster?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      ageGroup: _ageGroup,
      coachIds: _selectedCoachIds.toList(),
    );
    await widget.rosterRepository.saveRoster(roster);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRoster == null ? 'New Roster' : 'Edit Roster'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Roster name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AgeGroup?>(
            value: _ageGroup,
            decoration: const InputDecoration(
              labelText: 'Age group',
              border: OutlineInputBorder(),
              helperText: 'Only U10 has a built-in season plan right now.',
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Not set')),
              for (final group in AgeGroup.values)
                DropdownMenuItem(value: group, child: Text(ageGroupLabel(group))),
            ],
            onChanged: (value) => setState(() => _ageGroup = value),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('Coaches', style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton.icon(
                onPressed: _addNewCoach,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New coach'),
              ),
            ],
          ),
          if (widget.coachRepository.coaches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No coaches yet. Tap "New coach" to add one.'),
            )
          else
            for (final coach in widget.coachRepository.coaches)
              CheckboxListTile(
                value: _selectedCoachIds.contains(coach.id),
                title: Text(coach.name),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _selectedCoachIds.add(coach.id);
                  } else {
                    _selectedCoachIds.remove(coach.id);
                  }
                }),
              ),
          TextButton(
            onPressed: _manageCoaches,
            child: const Text('Manage all coaches'),
          ),
        ],
      ),
    );
  }
}
