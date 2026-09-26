import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/drill.dart';
import '../theme/app_colors.dart';
import '../widgets/youtube_embed.dart';

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class DrillDetailScreen extends StatelessWidget {
  final Drill drill;

  const DrillDetailScreen({super.key, required this.drill});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.colorFor(drill.category);

    return Scaffold(
      appBar: AppBar(title: Text(drill.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubeEmbed(videoId: drill.videoId),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(_capitalize(drill.category.name)),
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
          OutlinedButton.icon(
            onPressed: () => _openInYoutube(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in YouTube'),
          ),
        ],
      ),
    );
  }

  Future<void> _openInYoutube(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.https('www.youtube.com', '/watch', {'v': drill.videoId}),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the video link.')),
      );
    }
  }
}
