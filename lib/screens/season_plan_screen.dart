import 'package:flutter/material.dart';

import '../data/season_curricula.dart';
import '../models/age_group.dart';
import '../models/season_curriculum.dart';
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

  /// The age group to show first, e.g. the roster the screen was opened
  /// from. Falls back to the first age group with a plan.
  final AgeGroup? initialAgeGroup;

  const SeasonPlanScreen({
    super.key,
    required this.drillRepository,
    required this.sessionRepository,
    required this.onChanged,
    this.initialAgeGroup,
  });

  @override
  State<SeasonPlanScreen> createState() => _SeasonPlanScreenState();
}

class _SeasonPlanScreenState extends State<SeasonPlanScreen> {
  late AgeGroup _ageGroup;
  SeasonCurriculum? _curriculum;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAgeGroup;
    _selectAgeGroup(
      initial != null && curriculumAgeGroups.contains(initial)
          ? initial
          : curriculumAgeGroups.first,
    );
  }

  void _selectAgeGroup(AgeGroup group) {
    _ageGroup = group;
    _curriculum = seasonCurriculumFor(group);
    final curriculum = _curriculum;
    if (curriculum != null) _ensureCurriculumDrillsSeeded(curriculum);
  }

  // Seeds the curriculum's drills (idempotent, fixed ids) so week previews
  // always show real drill names, whether or not a coach has "added" that
  // week's session yet.
  Future<void> _ensureCurriculumDrillsSeeded(SeasonCurriculum curriculum) async {
    for (final drill in curriculum.drills) {
      if (widget.drillRepository.byId(drill.id) == null) {
        await widget.drillRepository.saveDrill(drill);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _addWeek(SeasonCurriculum curriculum, String sessionId) async {
    final session = curriculum.sessionById(sessionId);
    await widget.sessionRepository.saveSession(session);
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${session.name}" added to My Sessions.')),
      );
    }
  }

  Future<void> _addFullSeason(SeasonCurriculum curriculum) async {
    final label = ageGroupLabel(curriculum.ageGroup);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add the full $label season?'),
        content: Text(
          'Adds all ${curriculum.sessions.length} weekly sessions to My '
          'Sessions. Assign each week to a practice day in the Schedule tab '
          'as the season progresses.',
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

    for (final session in curriculum.sessions) {
      await widget.sessionRepository.saveSession(session);
    }
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Full $label season added to My Sessions.')),
      );
    }
  }

  void _openWeek(SeasonCurriculum curriculum, String sessionId) {
    final existing =
        widget.sessionRepository.byId(sessionId) ?? curriculum.sessionById(sessionId);
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
    final curriculum = _curriculum;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Season Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Add the full season',
            onPressed: curriculum == null ? null : () => _addFullSeason(curriculum),
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
                        setState(() => _selectAgeGroup(group));
                        if (_curriculum == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${ageGroupLabel(group)} curriculum is coming soon — '
                                '${curriculumAgeGroupsLabel()} have built-in plans right now.',
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
            child: curriculum == null
                ? Center(
                    child: Text(
                      '${ageGroupLabel(_ageGroup)} curriculum is coming soon.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final block in curriculum.blocks) ...[
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
                        for (final week
                            in curriculum.weeks.where((w) => w.blockTitle == block.title))
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              onTap: () => _openWeek(curriculum, week.sessionId),
                              title: Text('Week ${week.weekNumber}'),
                              subtitle: Text(week.focus),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Add to My Sessions',
                                onPressed: () => _addWeek(curriculum, week.sessionId),
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
