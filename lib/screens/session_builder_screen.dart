import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../models/session.dart';
import '../models/session_drill.dart';
import '../models/session_phase.dart';
import '../services/drill_repository.dart';
import '../services/session_repository.dart';
import '../widgets/session_drill_row.dart';
import 'drill_detail_screen.dart';
import 'drill_picker_screen.dart';

const _defaultDurationByPhase = {
  SessionPhase.warmUp: 10,
  SessionPhase.game: 15,
  SessionPhase.drill: 15,
  SessionPhase.scrimmage: 20,
};

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

  Future<void> _addDrill(SessionPhase phase) async {
    final picked = await Navigator.of(context).push<Drill>(
      MaterialPageRoute(
        builder: (_) => DrillPickerScreen(drillRepository: widget.drillRepository),
      ),
    );
    if (picked == null) return;
    setState(() {
      _drills.add(SessionDrill(
        drillId: picked.id,
        phase: phase,
        durationMinutes: _defaultDurationByPhase[phase]!,
      ));
    });
  }

  void _removeDrill(SessionDrill target) {
    setState(() => _drills.remove(target));
  }

  void _updateDrill(SessionDrill target, SessionDrill updated) {
    setState(() {
      final index = _drills.indexOf(target);
      _drills[index] = updated;
    });
  }

  void _reorderPhase(SessionPhase phase, int oldIndex, int newIndex) {
    setState(() {
      final phaseDrills = _drills.where((d) => d.phase == phase).toList();
      if (newIndex > oldIndex) newIndex -= 1;
      final moved = phaseDrills.removeAt(oldIndex);
      phaseDrills.insert(newIndex, moved);
      _drills = [
        for (final p in SessionPhase.values)
          ...(p == phase ? phaseDrills : _drills.where((d) => d.phase == p)),
      ];
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
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                for (final phase in SessionPhase.values)
                  _PhaseSection(
                    phase: phase,
                    drills: _drills.where((d) => d.phase == phase).toList(),
                    drillRepository: widget.drillRepository,
                    onAdd: () => _addDrill(phase),
                    onReorder: (oldIndex, newIndex) =>
                        _reorderPhase(phase, oldIndex, newIndex),
                    onRemove: _removeDrill,
                    onChanged: _updateDrill,
                    onViewDetails: (drill) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DrillDetailScreen(drill: drill),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  final SessionPhase phase;
  final List<SessionDrill> drills;
  final DrillRepository drillRepository;
  final VoidCallback onAdd;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(SessionDrill target) onRemove;
  final void Function(SessionDrill target, SessionDrill updated) onChanged;
  final void Function(Drill drill) onViewDetails;

  const _PhaseSection({
    required this.phase,
    required this.drills,
    required this.drillRepository,
    required this.onAdd,
    required this.onReorder,
    required this.onRemove,
    required this.onChanged,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sessionPhaseLabel(phase),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add drill'),
              ),
            ],
          ),
        ),
        if (drills.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('No drills in this phase yet.'),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: drills.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              final entry = drills[index];
              final drill = drillRepository.byId(entry.drillId);
              if (drill == null) {
                return const SizedBox.shrink(key: ValueKey('missing'));
              }
              return SessionDrillRow(
                key: ValueKey(entry),
                index: index,
                drill: drill,
                entry: entry,
                onChanged: (updated) => onChanged(entry, updated),
                onRemove: () => onRemove(entry),
                onViewDetails: () => onViewDetails(drill),
              );
            },
          ),
      ],
    );
  }
}
