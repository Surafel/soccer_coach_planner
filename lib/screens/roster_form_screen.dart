import 'package:flutter/material.dart';

import '../models/age_group.dart';
import '../models/roster.dart';
import '../services/roster_repository.dart';

class RosterFormScreen extends StatefulWidget {
  final RosterRepository rosterRepository;
  final Roster? existingRoster;

  const RosterFormScreen({
    super.key,
    required this.rosterRepository,
    this.existingRoster,
  });

  @override
  State<RosterFormScreen> createState() => _RosterFormScreenState();
}

class _RosterFormScreenState extends State<RosterFormScreen> {
  late final TextEditingController _nameController;
  late List<TextEditingController> _coachControllers;
  AgeGroup? _ageGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingRoster?.name);
    _ageGroup = widget.existingRoster?.ageGroup;
    _coachControllers = [
      for (final name in widget.existingRoster?.coachNames ?? const [])
        TextEditingController(text: name),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _coachControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCoachField() {
    setState(() => _coachControllers.add(TextEditingController()));
  }

  void _removeCoachField(int index) {
    setState(() {
      _coachControllers[index].dispose();
      _coachControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the roster a name.')),
      );
      return;
    }
    final coachNames = _coachControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final roster = Roster(
      id: widget.existingRoster?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      ageGroup: _ageGroup,
      coachNames: coachNames,
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
                onPressed: _addCoachField,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add coach'),
              ),
            ],
          ),
          if (_coachControllers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No coaches added yet.'),
            ),
          for (var i = 0; i < _coachControllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _coachControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Coach ${i + 1} name',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeCoachField(i),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
