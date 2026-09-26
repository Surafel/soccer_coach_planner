import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildYoutubeEmbed(String videoId) => _YoutubeEmbedIo(videoId: videoId);

class _YoutubeEmbedIo extends StatefulWidget {
  final String videoId;

  const _YoutubeEmbedIo({required this.videoId});

  @override
  State<_YoutubeEmbedIo> createState() => _YoutubeEmbedIoState();
}

class _YoutubeEmbedIoState extends State<_YoutubeEmbedIo> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.youtube-nocookie.com/embed/${widget.videoId}'),
      );
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
