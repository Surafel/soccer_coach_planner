import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/drill.dart';
import '../services/drill_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/youtube_embed.dart';
import 'drill_form_screen.dart';

class DrillDetailScreen extends StatefulWidget {
  final Drill drill;
  final DrillRepository? drillRepository;
  final VoidCallback? onChanged;

  const DrillDetailScreen({
    super.key,
    required this.drill,
    this.drillRepository,
    this.onChanged,
  });

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  late Drill drill;

  @override
  void initState() {
    super.initState();
    drill = widget.drill;
  }

  Future<void> _edit() async {
    final repo = widget.drillRepository;
    if (repo == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DrillFormScreen(
          drillRepository: repo,
          existingDrill: drill,
        ),
      ),
    );
    final updated = repo.byId(drill.id);
    if (updated != null) setState(() => drill = updated);
    widget.onChanged?.call();
  }

  Future<void> _delete() async {
    final repo = widget.drillRepository;
    if (repo == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete drill?'),
        content: Text('This removes "${drill.name}" from the library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repo.deleteDrill(drill.id);
    widget.onChanged?.call();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.colorFor(drill.category);
    final videoId = drill.videoId;
    final canEdit = widget.drillRepository != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(drill.name),
        actions: canEdit
            ? [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _edit),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (videoId != null) ...[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubeEmbed(videoId: videoId),
            ),
            const SizedBox(height: 20),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(drillCategoryLabel(drill.category)),
                backgroundColor: categoryColor.withValues(alpha: 0.15),
              ),
              Chip(label: Text('Ages ${drill.ageRange}')),
            ],
          ),
          const SizedBox(height: 20),
          Text('Skills', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in drill.skillTags) Chip(label: Text(tag)),
            ],
          ),
          const SizedBox(height: 20),
          Text('How to run it', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(drill.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          if (videoId != null)
            OutlinedButton.icon(
              onPressed: () => _openInYoutube(context, videoId),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in YouTube'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _openVideoSearch(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Search for a video'),
            ),
        ],
      ),
    );
  }

  Future<void> _openInYoutube(BuildContext context, String videoId) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.https('www.youtube.com', '/watch', {'v': videoId}),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the video link.')),
      );
    }
  }

  Future<void> _openVideoSearch(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      drill.videoSearchUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the video link.')),
      );
    }
  }
}
