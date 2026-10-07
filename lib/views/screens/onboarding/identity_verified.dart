import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/views/screens/navigation/home_main.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';

class IdentityVerifiedScreen extends StatelessWidget {
  const IdentityVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Start earning',
      subtitle: "You're Verified! Lets create your first listing.",
      showBackButton: false,
      headerLeadingInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: OnboardingStatusPill(
              kind: OnboardingPillKind.identityVerified,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What will you list first?',
            style: onboardingNunito(size: 20, weight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start with something, like a camera, tools or clothing. Something laying around unused',
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const OnboardingIllustration(
            assetPath: OnboardingAssets.identityVerified,
            height: 240,
          ),
          const SizedBox(height: 8),
          const OnboardingTaskCard(
            icon: Icons.account_balance_outlined,
            title: 'Payout setup comes afterward',
            subtitle: 'After you list, finish payout setup in Transactions.',
            circularIcon: true,
            showTrailingIcons: false,
          ),
        ],
      ),
      bottomBar: Column(
        children: [
          OnboardingPrimaryButton(
            label: 'List my first item',
            onPressed: () => Get.offAll(() => const CreateListingScreen()),
          ),
          const SizedBox(height: 10),
          OnboardingSecondaryButton(
            label: 'Go to Earning',
            onPressed: () => Get.offAll(() => const MainScreen()),
          ),
        ],
      ),
    );
  }
}
