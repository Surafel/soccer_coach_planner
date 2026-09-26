import 'package:flutter/material.dart';

import '../data/u10_curriculum.dart';
import '../models/age_group.dart';
import '../services/drill_repository.dart';
import '../services/session_repository.dart';
import 'session_builder_screen.dart';

/// Read-only, built-in seasonal curriculum: every coach of a given age
/// group sees the identical week-by-week plan (no accounts or sync needed —
/// it's just fixed content shipped with the app). Coaches add a week's
/// session into "My Sessions" to use and schedule it like any other.
class SeasonPlanScreen extends StatefulWidget {
  final DrillRepository drillRepository;
  final SessionRepository sessionRepository;
  final VoidCallback onChanged;

  const SeasonPlanScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    required this.onChanged,
  });

  @override
  State<SeasonPlanScreen> createState() => _SeasonPlanScreenState();
}

class _SeasonPlanScreenState extends State<SeasonPlanScreen> {
  AgeGroup _ageGroup = AgeGroup.u10;

  @override
  void initState() {
    super.initState();
    _ensureCurriculumDrillsSeeded();
  }

  // Seeds the curriculum's drills (idempotent, fixed ids) so week previews
  // always show real drill names, whether or not a coach has "added" that
  // week's session yet.
  Future<void> _ensureCurriculumDrillsSeeded() async {
    for (final drill in buildU10CurriculumDrills()) {
      if (widget.drillRepository.byId(drill.id) == null) {
        await widget.drillRepository.saveDrill(drill);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _addWeek(String sessionId) async {
    final session = buildU10CurriculumSessions().firstWhere((s) => s.id == sessionId);
    await widget.sessionRepository.saveSession(session);
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${session.name}" added to My Sessions.')),
      );
    }
  }

  Future<void> _addFullSeason() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add the full U10 season?'),
        content: const Text(
          'Adds all 16 weekly sessions to My Sessions. Assign each week to '
          'a practice day in the Schedule tab as the season progresses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    for (final session in buildU10CurriculumSessions()) {
      await widget.sessionRepository.saveSession(session);
    }
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full U10 season added to My Sessions.')),
      );
    }
  }

  void _openWeek(String sessionId) {
    final existing = widget.sessionRepository.byId(sessionId) ??
        buildU10CurriculumSessions().firstWhere((s) => s.id == sessionId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionBuilderScreen(
          drillRepository: widget.drillRepository,
          sessionRepository: widget.sessionRepository,
          existingSession: existing,
        ),
      ),
    ).then((_) => widget.onChanged());
  }

  @override
  Widget build(BuildContext context) {
    final seasonPlan = buildU10SeasonPlan();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Season Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Add the full season',
            onPressed: _ageGroup == AgeGroup.u10 ? _addFullSeason : null,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                for (final group in AgeGroup.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(ageGroupLabel(group)),
                      selected: _ageGroup == group,
                      onSelected: (_) {
                        setState(() => _ageGroup = group);
                        if (group != AgeGroup.u10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${ageGroupLabel(group)} curriculum is coming soon — U10 is the only age group with a built-in plan right now.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _ageGroup != AgeGroup.u10
                ? Center(
                    child: Text(
                      '${ageGroupLabel(_ageGroup)} curriculum is coming soon.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final block in u10SeasonBlocks) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${block.weekRange} · ${block.title}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                block.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        for (final week in seasonPlan.where((w) => w.blockTitle == block.title))
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              onTap: () => _openWeek(week.sessionId),
                              title: Text('Week ${week.weekNumber}'),
                              subtitle: Text(week.focus),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Add to My Sessions',
                                onPressed: () => _addWeek(week.sessionId),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
