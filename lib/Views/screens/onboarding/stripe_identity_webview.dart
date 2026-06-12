import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/screens/onboarding/before_you_continue.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/view_model/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class StripeIdentityWebView extends StatefulWidget {
  final String verificationUrl;
  final String verificationSessionId;

  const StripeIdentityWebView({
    super.key,
    required this.verificationUrl,
    required this.verificationSessionId,
  });

  @override
  State<StripeIdentityWebView> createState() => _StripeIdentityWebViewState();
}

class _StripeIdentityWebViewState extends State<StripeIdentityWebView>
    with WidgetsBindingObserver {
  late final OnboardingController _controller = ensureOnboardingController();
  late final WebViewController _webViewController;

  bool _isPageLoading = true;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _saveSessionId();
    _initWebView();
  }

  Future<void> _saveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'verification_session_id',
      widget.verificationSessionId,
    );
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isPageLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isPageLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.verificationUrl));

    if (controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkVerificationStatus();
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    final verified = await _pollVerificationStatus();
    if (!mounted) return;

    setState(() => _isCheckingStatus = false);

    if (verified) {
      await _controller.advanceTo(4);
      Get.off(() => const BeforeYouContinueScreen());
    }
  }

  Future<bool> _pollVerificationStatus({
    int attempts = 4,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      final verified = await _fetchVerificationStatus();
      if (verified) return true;
      if (i < attempts - 1) await Future.delayed(delay);
    }
    return false;
  }

  Future<bool> _fetchVerificationStatus() async {
    final completer = Completer<bool>();

    ApiRepository.shared.checkVerificationStatus(
      widget.verificationSessionId,
      (data) async {
        if (completer.isCompleted) return;

        final status = data['status']?.toString().toLowerCase() ?? '';
        if (status == 'verified') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('stripe_verification_status', 'verified');
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
      (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () async {
            if (_isCheckingStatus) return;
            setState(() => _isCheckingStatus = true);
            final verified = await _pollVerificationStatus(attempts: 2);
            if (!mounted) return;
            setState(() => _isCheckingStatus = false);
            if (verified) {
              await _controller.advanceTo(4);
              Get.off(() => const BeforeYouContinueScreen());
            } else {
              Get.back();
            }
          },
          borderRadius: BorderRadius.circular(50),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          'Verify Identity',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isPageLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (_isCheckingStatus)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.08),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Checking verification status...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
