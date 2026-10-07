import 'package:flutter/material.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_illustrations.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class EarnIntroScreen extends StatelessWidget {
  const EarnIntroScreen({super.key});

  static const _stripeDetailsUrl = 'https://stripe.com/privacy';

  @override
  Widget build(BuildContext context) {
    final controller = ensureOnboardingController();

    return OnboardingShell(
      title: 'Start earning',
      subtitle: 'Earn from items you already own',
      showBackButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const OnboardingIllustration(
              assetPath: OnboardingAssets.intro,
              height: 224,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your things.',
            style: onboardingNunito(size: 24, weight: FontWeight.w800, height: 1.2),
          ),
          Text(
            'Their next adventure.',
            style: onboardingNunito(size: 24, weight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 22),
          _stepItem(
            Icons.person_outline_rounded,
            'Verify your identity',
            'Add a few personal details and photo ID if requested.',
          ),
          _stepItem(
            Icons.sell_outlined,
            'List your first item',
            'Create a listing while verification is in progress.',
          ),
          _stepItem(
            Icons.account_balance_outlined,
            'Set up payouts after listing',
            'Add your bank from Transactions when you are ready.',
            showDivider: false,
          ),
          const SizedBox(height: 18),
          _verificationPayoutsCard(context),
        ],
      ),
      bottomBar: Column(
        children: [
          OnboardingPrimaryButton(
            label: "Let's get started",
            onPressed: () async {
              await controller.markIntroSeen();
              await controller.advanceTo(OnboardingSteps.stepPersonal);
              controller.navigateToIdentityHub();
            },
          ),
        ],
      ),
    );
  }

  Widget _verificationPayoutsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            OnboardingIllustrationAsset.stripeLogo,
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.account_balance,
              size: 22,
              color: const Color(0xFF635BFF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification and payouts',
                  style: onboardingNunito(size: 15, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jebby uses Stripe for identity checks and payouts.',
                  style: onboardingNunito(
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _openHowDetailsUsed(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'How your details are used',
                          style: onboardingNunito(
                            size: 12,
                            weight: FontWeight.w700,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.jebbyBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHowDetailsUsed(BuildContext context) async {
    final uri = Uri.parse(EarnIntroScreen._stripeDetailsUrl);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _stepItem(
    IconData icon,
    String title,
    String subtitle, {
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepRow(icon, title, subtitle),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _stepRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.jebbySoftBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.jebbyBlue, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: onboardingNunito(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
