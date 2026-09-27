import 'package:flutter/material.dart';

import '../models/coach.dart';
import '../services/coach_repository.dart';

class CoachFormScreen extends StatefulWidget {
  final CoachRepository coachRepository;
  final Coach? existingCoach;

  const CoachFormScreen({
    super.key,
    required this.coachRepository,
    this.existingCoach,
  });

  @override
  State<CoachFormScreen> createState() => _CoachFormScreenState();
}

class _CoachFormScreenState extends State<CoachFormScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingCoach?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the coach a name.')),
      );
      return;
    }
    final coach = Coach(
      id: widget.existingCoach?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    await widget.coachRepository.saveCoach(coach);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCoach == null ? 'New Coach' : 'Edit Coach'),
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
              labelText: 'Coach name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
