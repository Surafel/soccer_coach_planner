import 'package:flutter/widgets.dart';

import 'youtube_embed_io.dart' if (dart.library.html) 'youtube_embed_web.dart'
    as platform;

/// Embeds a YouTube video: a WebView on Android, an iframe on web.
class YoutubeEmbed extends StatelessWidget {
  final String videoId;

  const YoutubeEmbed({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) => platform.buildYoutubeEmbed(videoId);
}
