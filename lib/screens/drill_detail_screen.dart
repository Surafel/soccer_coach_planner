import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/drill.dart';
import '../theme/app_colors.dart';
import '../widgets/youtube_embed.dart';

class DrillDetailScreen extends StatelessWidget {
  final Drill drill;

  const DrillDetailScreen({super.key, required this.drill});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.colorFor(drill.category);
    final videoId = drill.videoId;

    return Scaffold(
      appBar: AppBar(title: Text(drill.name)),
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
