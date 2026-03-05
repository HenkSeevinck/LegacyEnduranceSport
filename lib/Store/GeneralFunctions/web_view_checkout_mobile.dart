import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/woocommerce_store_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewCheckout extends StatefulWidget {
  final String initialUrl;
  final int? orderId;

  const WebViewCheckout({super.key, required this.initialUrl, required this.orderId});

  @override
  State<WebViewCheckout> createState() => WebViewCheckoutState();
}

class WebViewCheckoutState extends State<WebViewCheckout> {
  bool _loading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) async {
          final url = request.url;

          if (widget.orderId != null) {
            try {
              final store = Provider.of<WoocommerceStore>(context, listen: false);
              final status = await store.getOrderStatus(widget.orderId!);
              if (status != null) {
                final s = status.toLowerCase();
                if (s == 'processing' || s == 'completed' || s == 'paid') {
                  Navigator.of(context).pop(true);
                  return NavigationDecision.prevent;
                }
              }
            } catch (_) {}
          }

          if (url.contains('legacyendurancesport.com') && (url.contains('order-received') || url.contains('thank_you') || url.contains('success') || url.contains('return'))) {
            if (widget.orderId != null) {
              try {
                final store = Provider.of<WoocommerceStore>(context, listen: false);
                final status = await store.getOrderStatus(widget.orderId!);
                if (status != null) {
                  final s = status.toLowerCase();
                  if (s == 'processing' || s == 'completed' || s == 'paid') {
                    Navigator.of(context).pop(true);
                    return NavigationDecision.prevent;
                  }
                }
              } catch (_) {}
            }
          }

          return NavigationDecision.navigate;
        },
        onPageStarted: (url) => setState(() => _loading = true),
        onPageFinished: (url) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
