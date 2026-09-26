import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredViewTypes = {};

Widget buildYoutubeEmbed(String videoId) {
  final viewType = 'youtube-embed-$videoId';
  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return web.HTMLIFrameElement()
        ..src = 'https://www.youtube-nocookie.com/embed/$videoId'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
        ..allowFullscreen = true;
    });
  }
  return HtmlElementView(viewType: viewType);
}
