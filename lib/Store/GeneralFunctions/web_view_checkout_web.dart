import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebViewCheckout extends StatefulWidget {
  final String initialUrl;
  final int? orderId;

  const WebViewCheckout({super.key, required this.initialUrl, required this.orderId});

  @override
  State<WebViewCheckout> createState() => _WebViewCheckoutWebState();
}

class _WebViewCheckoutWebState extends State<WebViewCheckout> {
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    // Defer opening to the next frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_opened) {
        _opened = true;
        try {
          html.window.open(widget.initialUrl, '_blank');
        } catch (_) {}
        // Optionally pop back to previous screen after opening
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Opening payment in a new tab...'),
              SizedBox(height: 12),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
