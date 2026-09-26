import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../models/session.dart';
import '../models/session_drill.dart';
import '../services/drill_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_drill_row.dart';
import 'drill_detail_screen.dart';
import 'drill_picker_screen.dart';

class SessionBuilderScreen extends StatefulWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final Session? existingSession;

  const SessionBuilderScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    this.existingSession,
  });

  @override
  State<SessionBuilderScreen> createState() => _SessionBuilderScreenState();
}

class _SessionBuilderScreenState extends State<SessionBuilderScreen> {
  late final TextEditingController _nameController;
  late List<SessionDrill> _drills;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingSession?.name);
    _drills = List.of(widget.existingSession?.drills ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _totalMinutes =>
      _drills.fold(0, (sum, d) => sum + d.durationMinutes);

  Future<void> _addDrill() async {
    final picked = await Navigator.of(context).push<Drill>(
      MaterialPageRoute(
        builder: (_) => DrillPickerScreen(drillRepository: widget.drillRepository),
      ),
    );
    if (picked == null) return;
    setState(() {
      _drills.add(SessionDrill(drillId: picked.id, durationMinutes: 10));
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _drills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Give the session a name and at least one drill.'),
        ),
      );
      return;
    }
    final session = Session(
      id: widget.existingSession?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      drills: _drills,
    );
    await widget.sessionRepository.saveSession(session);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingSession == null ? 'New Session' : 'Edit Session'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total: $_totalMinutes min',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: _drills.isEmpty
                ? const Center(child: Text('Add drills to build this session.'))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _drills.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final moved = _drills.removeAt(oldIndex);
                        _drills.insert(newIndex, moved);
                      });
                    },
                    itemBuilder: (context, index) {
                      final entry = _drills[index];
                      final drill = widget.drillRepository.byId(entry.drillId);
                      if (drill == null) {
                        return const SizedBox.shrink(key: ValueKey('missing'));
                      }
                      return SessionDrillRow(
                        key: ValueKey(index),
                        index: index,
                        drill: drill,
                        entry: entry,
                        onChanged: (updated) =>
                            setState(() => _drills[index] = updated),
                        onRemove: () => setState(() => _drills.removeAt(index)),
                        onViewDetails: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DrillDetailScreen(drill: drill),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDrill,
        icon: const Icon(Icons.add),
        label: const Text('Add drill'),
      ),
    );
  }
}
