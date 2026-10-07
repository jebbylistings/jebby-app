import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';

class VerificationInProgressScreen extends StatelessWidget {
  const VerificationInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Start earning',
      subtitle: "You're one step closer to earning with Jebby.",
      body: Column(
        children: [
          const Center(child: OnboardingStatusPill(kind: OnboardingPillKind.verificationInProgress)),
          const SizedBox(height: 16),
          Text(
            'Lets get your first listing ready.',
            style: onboardingNunito(size: 24, weight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your details are under review while you prepare your first listing.',
            style: onboardingNunito(
              size: 16,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const OnboardingIllustration(
            assetPath: OnboardingAssets.verificationInProgress,
            height: 268,
          ),
          OnboardingTaskCard(
            icon: Icons.description_outlined,
            title: 'Publish after verification',
            subtitle: 'Published once you\'re verified',
            subtitleFontSize: 15,
            isComplete: false,
            onTap: null,
          ),
        ],
      ),
      bottomBar: Column(
        children: [
          OnboardingPrimaryButton(
            label: 'Create a listing',
            onPressed: () => Get.offAll(() => const CreateListingScreen()),
          ),
          const SizedBox(height: 10),
          OnboardingSecondaryButton(
            label: 'Go to Dashboard',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
