import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef UpgradeVerifyCallback = Future<bool> Function({
  int? orderId,
  String? paymentLinkId,
  bool showPendingMessage,
  bool showSuccessDialog,
});

class UpgradePaymentScreen extends StatefulWidget {
  final String paymentLink;
  final int orderId;
  final String paymentLinkId;
  final String planName;
  final UpgradeVerifyCallback onVerify;

  const UpgradePaymentScreen({
    Key? key,
    required this.paymentLink,
    required this.orderId,
    required this.paymentLinkId,
    required this.planName,
    required this.onVerify,
  }) : super(key: key);

  @override
  State<UpgradePaymentScreen> createState() => _UpgradePaymentScreenState();
}

class _UpgradePaymentScreenState extends State<UpgradePaymentScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool isVerifying = false;
  bool paid = false;
  Timer? pollTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => isLoading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (_shouldOpenExternally(url)) {
              _openExternalPaymentApp(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));

    pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkPayment(showSuccessDialog: false);
    });
  }

  bool _shouldOpenExternally(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('upi://') ||
        lower.startsWith('tez://') ||
        lower.startsWith('gpay://') ||
        lower.startsWith('phonepe://') ||
        lower.startsWith('paytmmp://') ||
        lower.startsWith('intent://');
  }

  Future<void> _openExternalPaymentApp(String url) async {
    try {
      Uri? target;
      if (url.startsWith('intent://')) {
        final fallback = RegExp(r';S\.browser_fallback_url=([^;]+)')
            .firstMatch(url)
            ?.group(1);
        if (fallback != null) {
          target = Uri.parse(Uri.decodeComponent(fallback));
        }
      } else {
        target = Uri.parse(url);
      }

      if (target != null && await canLaunchUrl(target)) {
        await launchUrl(target, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _checkPayment({
    bool showSuccessDialog = true,
    bool showPendingMessage = false,
  }) async {
    if (paid || isVerifying) return;
    isVerifying = true;
    if (mounted) setState(() {});
    final success = await widget.onVerify(
      orderId: widget.orderId,
      paymentLinkId: widget.paymentLinkId,
      showPendingMessage: showPendingMessage,
      showSuccessDialog: showSuccessDialog,
    );
    isVerifying = false;
    if (mounted) setState(() {});
    if (success && mounted) {
      paid = true;
      pollTimer?.cancel();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _closeAndVerify() async {
    pollTimer?.cancel();
    if (!paid) {
      await _checkPayment(showPendingMessage: true);
    }
    if (mounted && !paid) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _closeAndVerify();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          title: Text(
            widget.planName.isEmpty ? 'Complete Payment' : widget.planName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: isVerifying ? null : _closeAndVerify,
              child: const Text(
                'Done',
                style: TextStyle(color: ThemeProvider.golden),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: ThemeProvider.appColor),
              ),
            if (isVerifying)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ThemeProvider.golden,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Checking payment status...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
