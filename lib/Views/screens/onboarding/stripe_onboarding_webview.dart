import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/screens/onboarding/all_set.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/view_model/onboarding_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class StripeOnboardingWebView extends StatefulWidget {
  final String onboardingUrl;
  final String? returnUrl;
  final String? refreshUrl;
  final bool isFromTransactions;

  const StripeOnboardingWebView({
    super.key,
    required this.onboardingUrl,
    this.returnUrl,
    this.refreshUrl,
    this.isFromTransactions = false,
  });

  @override
  State<StripeOnboardingWebView> createState() => _StripeOnboardingWebViewState();
}

class _StripeOnboardingWebViewState extends State<StripeOnboardingWebView> {
  late final OnboardingController _controller = ensureOnboardingController();
  late final WebViewController _webViewController;
  late final String _returnUrl;
  late final String _refreshUrl;

  bool _isPageLoading = true;
  bool _isHandlingExit = false;
  bool _isConfirmingCompletion = false;

  @override
  void initState() {
    super.initState();
    _returnUrl = _resolveReturnUrl();
    _refreshUrl = _resolveRefreshUrl();
    _initWebView();
  }

  String _resolveReturnUrl() {
    if (widget.returnUrl != null && widget.returnUrl!.trim().isNotEmpty) {
      return widget.returnUrl!.trim();
    }
    final envReturn = dotenv.env['STRIPE_CONNECT_RETURN_URL']?.trim() ?? '';
    if (envReturn.isNotEmpty) return envReturn;
    final base = dotenv.env['baseUrlM']?.trim() ?? '';
    if (base.isNotEmpty) return '$base/stripe/onboarding/return';
    return '';
  }

  String _resolveRefreshUrl() {
    if (widget.refreshUrl != null && widget.refreshUrl!.trim().isNotEmpty) {
      return widget.refreshUrl!.trim();
    }
    final envRefresh = dotenv.env['STRIPE_CONNECT_REFRESH_URL']?.trim() ?? '';
    if (envRefresh.isNotEmpty) return envRefresh;
    final base = dotenv.env['baseUrlM']?.trim() ?? '';
    if (base.isNotEmpty) return '$base/stripe/onboarding/refresh';
    return '';
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
          onNavigationRequest: (request) {
            final url = request.url;

            if (_isRefreshNavigation(url)) {
              _handleRefresh();
              return NavigationDecision.prevent;
            }
            if (_isReturnNavigation(url)) {
              _handleReturn();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not load verification page. Please try again.',
                ),
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.onboardingUrl));

    if (controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  bool _isReturnNavigation(String url) {
    if (_returnUrl.isEmpty) return false;
    return _matchesUrl(url, _returnUrl);
  }

  bool _isRefreshNavigation(String url) {
    if (_refreshUrl.isEmpty) return false;
    return _matchesUrl(url, _refreshUrl);
  }

  /// Strict prefix match only — avoids false positives from Plaid/identity URLs.
  bool _matchesUrl(String url, String configured) {
    final normalized = configured.trim();
    if (normalized.isEmpty) return false;
    return url.startsWith(normalized);
  }

  Future<void> _handleReturn() async {
    if (_isHandlingExit) return;
    _isHandlingExit = true;
    if (mounted) setState(() => _isConfirmingCompletion = true);

    final completed = await _pollStripeAccountStatus();
    if (!mounted) return;

    setState(() => _isConfirmingCompletion = false);

    if (completed) {
      if (widget.isFromTransactions) {
        Get.back();
        Get.back();
      } else {
        Get.offAll(() => const AllSetScreen());
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification not complete yet. You can resume from the menu.',
          ),
        ),
      );
    }

    if (mounted) setState(() => _isHandlingExit = false);
  }

  Future<bool> _pollStripeAccountStatus({
    int attempts = 6,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      final complete = await _fetchStripeAccountStatus();
      if (complete) return true;
      if (i < attempts - 1) {
        await Future.delayed(delay);
      }
    }
    return false;
  }

  Future<bool> _fetchStripeAccountStatus() async {
    if (_controller.userId.isEmpty) return false;

    final completer = Completer<bool>();

    ApiRepository.shared.checkStripeAccountStatus(
      _controller.userId,
      (response) async {
        if (completer.isCompleted) return;

        final status = response['status']?.toString() ?? '';
        final account = response['account'];
        final detailsSubmitted = account is Map
            ? (account['details_submitted'] == true)
            : (response['details_submitted'] == true);
        final payoutsEnabled = account is Map
            ? (account['payouts_enabled'] == true)
            : false;
        final accountId = account is Map
            ? account['id']?.toString()
            : response['account_id']?.toString();

        final isComplete = status == 'active' ||
            detailsSubmitted ||
            payoutsEnabled;

        if (isComplete) {
          await _controller.markComplete(accountId: accountId);
          await _controller.completeProviderRole();
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

  Future<void> _handleRefresh() async {
    if (_isHandlingExit || _controller.userId.isEmpty) return;
    _isHandlingExit = true;

    ApiRepository.shared.createStripeExpressAccountLink(
      _controller.userId,
      (response) async {
        if (!mounted) return;

        if (response is Map && response.containsKey('url')) {
          final accountId = response['account_id']?.toString();
          await _controller.markStripePending(accountId: accountId);
          await _webViewController.loadRequest(
            Uri.parse(response['url'].toString()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not refresh verification link')),
          );
        }

        if (mounted) setState(() => _isHandlingExit = false);
      },
      (error) {
        if (mounted) {
          setState(() => _isHandlingExit = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error refreshing link: $error')),
          );
        }
      },
      name: _controller.userName,
      email: _controller.userEmail,
      phone: _controller.userPhone,
    );
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
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(50),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          'Verification',
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
          if (_isConfirmingCompletion)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.12),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Confirming verification...',
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
