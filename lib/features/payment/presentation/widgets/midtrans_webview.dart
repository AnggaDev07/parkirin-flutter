// lib/features/payment/presentation/widgets/midtrans_webview.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(bool success) onFinish;

  const MidtransWebView({
    super.key,
    required this.paymentUrl,
    required this.onFinish,
  });

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          setState(() => _isLoading = false);

          // Check for success/failure URLs
          if (url.contains('payment/success')) {
            widget.onFinish(true);
          } else if (url.contains('payment/failed') ||
              url.contains('payment/cancel')) {
            widget.onFinish(false);
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
