import 'package:flutter/material.dart';

import '../models/drill.dart';
import '../services/drill_repository.dart';

/// Pulls an 11-character YouTube video id out of a pasted watch/share/embed
/// URL. If the input doesn't look like a URL, it's returned trimmed as-is,
/// so pasting a bare video id also works.
String? _parseVideoId(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme) {
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null) return v;
      final segments = uri.pathSegments;
      final embedIndex = segments.indexOf('embed');
      if (embedIndex >= 0 && embedIndex + 1 < segments.length) {
        return segments[embedIndex + 1];
      }
    }
    return null;
  }
  return text;
}

class DrillFormScreen extends StatefulWidget {
  final DrillRepository drillRepository;
  final Drill? existingDrill;

  const DrillFormScreen({
    super.key,
    required this.drillRepository,
    this.existingDrill,
  });

  @override
  State<DrillFormScreen> createState() => _DrillFormScreenState();
}

class _DrillFormScreenState extends State<DrillFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _skillTagsController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ageRangeController;
  late final TextEditingController _videoController;
  late DrillCategory _category;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDrill;
    _nameController = TextEditingController(text: existing?.name);
    _skillTagsController =
        TextEditingController(text: existing?.skillTags.join(', '));
    _descriptionController = TextEditingController(text: existing?.description);
    _ageRangeController = TextEditingController(text: existing?.ageRange);
    _videoController = TextEditingController(text: existing?.videoId);
    _category = existing?.category ?? DrillCategory.dribbling;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillTagsController.dispose();
    _descriptionController.dispose();
    _ageRangeController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the drill a name.')),
      );
      return;
    }
    final skillTags = _skillTagsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final ageRange = _ageRangeController.text.trim();
    final drill = Drill(
      id: widget.existingDrill?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: _category,
      skillTags: skillTags,
      description: _descriptionController.text.trim(),
      ageRange: ageRange.isEmpty ? 'All ages' : ageRange,
      videoId: _parseVideoId(_videoController.text),
    );
    await widget.drillRepository.saveDrill(drill);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingDrill == null ? 'New Drill' : 'Edit Drill'),
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
              labelText: 'Drill name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DrillCategory>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final category in DrillCategory.values)
                DropdownMenuItem(
                  value: category,
                  child: Text(drillCategoryLabel(category)),
                ),
            ],
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _skillTagsController,
            decoration: const InputDecoration(
              labelText: 'Skill tags (comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'First Touch, Turning',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageRangeController,
            decoration: const InputDecoration(
              labelText: 'Age range',
              border: OutlineInputBorder(),
              hintText: '9-10',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'How to run it',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _videoController,
            decoration: const InputDecoration(
              labelText: 'Video link or id (optional)',
              border: OutlineInputBorder(),
              hintText: 'https://www.youtube.com/watch?v=...',
            ),
          ),
        ],
      ),
    );
  }
}
