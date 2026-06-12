import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/onboarding/all_set.dart';
import 'package:jebby/Views/screens/onboarding/onboarding_scaffold.dart';
import 'package:jebby/Views/screens/onboarding/stripe_onboarding_webview.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/view_model/onboarding_controller.dart';

class StripeWelcomeScreen extends StatefulWidget {
  final bool isFromTransactions;

  const StripeWelcomeScreen({
    super.key,
    this.isFromTransactions = false,
  });

  @override
  State<StripeWelcomeScreen> createState() => _StripeWelcomeScreenState();
}

class _StripeWelcomeScreenState extends State<StripeWelcomeScreen> {
  late final OnboardingController _controller =
      ensureOnboardingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.advanceTo(5);

    if (_controller.state.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => const AllSetScreen());
      });
    }
  }

  Future<void> _launchStripeOnboarding() async {
    if (_controller.userId.isEmpty) return;

    setState(() => _isLoading = true);

    ApiRepository.shared.createStripeExpressAccountLink(
      _controller.userId,
      (response) async {
        if (!mounted) return;
        if (response is Map && response.containsKey('url')) {
          final accountId = response['account_id']?.toString();
          await _controller.markStripePending(accountId: accountId);

          await Get.to(
            () => StripeOnboardingWebView(
              onboardingUrl: response['url'].toString(),
              returnUrl: response['return_url']?.toString(),
              refreshUrl: response['refresh_url']?.toString(),
              isFromTransactions: widget.isFromTransactions,
            ),
          );

          if (mounted && !widget.isFromTransactions) {
            _checkStripeAccountStatus();
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error creating Stripe account link')),
          );
        }

        if (mounted) setState(() => _isLoading = false);
      },
      (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      },
      name: _controller.userName,
      email: _controller.userEmail,
      phone: _controller.userPhone,
    );
  }

  void _checkStripeAccountStatus() {
    if (_controller.userId.isEmpty) return;

    ApiRepository.shared.checkStripeAccountStatus(
      _controller.userId,
      (response) async {
        if (!mounted) return;

        final status = response['status']?.toString() ?? '';
        final account = response['account'];
        final detailsSubmitted = account is Map
            ? (account['details_submitted'] == true)
            : (response['details_submitted'] == true);
        final accountId = account is Map
            ? account['id']?.toString()
            : response['account_id']?.toString();

        if (status == 'active' || detailsSubmitted) {
          await _controller.markComplete(accountId: accountId);
          await _controller.completeProviderRole();
          Get.off(() => const AllSetScreen());
        }
      },
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 5,
      title: 'Verification',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF635BFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Color(0xFF635BFF),
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Jebby partners with Stripe for secure payouts',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stripe handles identity verification, bank account setup, and secure payouts so you can focus on renting your items.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const _BenefitItem(
            icon: Icons.verified_user_outlined,
            text: 'Bank-level security for your personal and financial data',
          ),
          const SizedBox(height: 12),
          const _BenefitItem(
            icon: Icons.payments_outlined,
            text: 'Fast, reliable payouts directly to your bank account',
          ),
          const SizedBox(height: 12),
          const _BenefitItem(
            icon: Icons.fact_check_outlined,
            text: 'Quick identity verification with your government ID',
          ),
          const SizedBox(height: 24),
          const OnboardingStripeFooter(),
          const SizedBox(height: 16),
          Text(
            'By continuing, you agree to Stripe\'s Terms of Service and Privacy Policy.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.black38,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: OnboardingPrimaryButton(
          label: 'Continue',
          isLoading: _isLoading,
          onPressed: _launchStripeOnboarding,
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: darkBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
