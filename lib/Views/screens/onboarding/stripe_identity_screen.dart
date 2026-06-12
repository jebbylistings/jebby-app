import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/onboarding/before_you_continue.dart';
import 'package:jebby/Views/screens/onboarding/onboarding_scaffold.dart';
import 'package:jebby/Views/screens/onboarding/stripe_identity_webview.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/view_model/onboarding_controller.dart';

class StripeIdentityScreen extends StatefulWidget {
  const StripeIdentityScreen({super.key});

  @override
  State<StripeIdentityScreen> createState() => _StripeIdentityScreenState();
}

class _StripeIdentityScreenState extends State<StripeIdentityScreen> {
  late final OnboardingController _controller =
      ensureOnboardingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.advanceTo(3);
    _maybeSkipIfAlreadyVerified();
  }

  Future<void> _maybeSkipIfAlreadyVerified() async {
    if (await _controller.isStripeIdentityVerified()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.advanceTo(4);
          Get.off(() => const BeforeYouContinueScreen());
        }
      });
    }
  }

  Future<void> _startIdentityVerification() async {
    if (_controller.userId.isEmpty) return;

    setState(() => _isLoading = true);

    ApiRepository.shared.createVerificationSession(
      _controller.userId,
      (data) async {
        if (!mounted) return;

        final url = data.verificationUrl;
        final sessionId = data.verificationSessionId;

        if (url != null &&
            url.isNotEmpty &&
            sessionId != null &&
            sessionId.isNotEmpty) {
          await Get.to(
            () => StripeIdentityWebView(
              verificationUrl: url,
              verificationSessionId: sessionId,
            ),
          );

          if (mounted && await _controller.isStripeIdentityVerified()) {
            await _controller.advanceTo(4);
            Get.off(() => const BeforeYouContinueScreen());
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not start identity verification'),
            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 3,
      title: 'Verify Identity',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(Icons.badge_outlined, color: darkBlue, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Verify your identity',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stripe will guide you through a quick ID check using your government-issued ID and a selfie.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const _InfoRow(
            icon: Icons.credit_card,
            text: "Driver's license, passport, or state ID",
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.face_outlined,
            text: 'A quick selfie to match your ID',
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.lock_outline,
            text: 'Your data is encrypted and never shared',
          ),
          const SizedBox(height: 24),
          const OnboardingStripeFooter(),
          const SizedBox(height: 24),
        ],
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: OnboardingPrimaryButton(
          label: 'Continue to ID Verification',
          isLoading: _isLoading,
          onPressed: _startIdentityVerification,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

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
