import 'package:flutter/widgets.dart';
// Use ui_web for the registry and dart:ui for the underlying view logic
import 'dart:ui_web' as ui_web; 
// Using package:web is now preferred over dart:html
import 'package:web/web.dart' as web; 

class WebIframe extends StatelessWidget {
  final String url;
  final String viewType;
  static final Set<String> _registered = {};

  WebIframe({super.key, required this.url})
      : viewType = 'iframe-${url.hashCode}';

  @override
  Widget build(BuildContext context) {
    if (!_registered.contains(viewType)) {
      // Use ui_web to register the factory
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      });
      _registered.add(viewType);
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: HtmlElementView(viewType: viewType),
    );
  }
}