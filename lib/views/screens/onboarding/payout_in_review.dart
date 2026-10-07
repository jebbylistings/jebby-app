import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';

class PayoutInReviewScreen extends StatelessWidget {
  const PayoutInReviewScreen({super.key});

  static String _accountEndingLabel(OnboardingController controller) {
    final fromStripe = controller.bankLast4?.trim();
    if (fromStripe != null && fromStripe.isNotEmpty) {
      return 'Account ending in $fromStripe';
    }
    final account =
        controller.providerData.accountNumber.replaceAll(RegExp(r'\D'), '');
    if (account.length >= 4) {
      return 'Account ending in ${account.substring(account.length - 4)}';
    }
    return 'Account ending in ****';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ensureOnboardingController();
    final bankSubtitle = _accountEndingLabel(controller);

    return OnboardingShell(
      title: 'Payout setup',
      subtitle: "You're one step closer to getting paid.",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: OnboardingIllustration(
              assetPath: OnboardingAssets.listingPublished,
              height: 220,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: OnboardingStatusPill(
              kind: OnboardingPillKind.payoutInProgress,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your bank details are in review.',
            style: onboardingNunito(size: 20, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve received your bank details. Payouts aren\'t enabled yet.',
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          OnboardingTaskCard(
            icon: Icons.account_balance_outlined,
            title: 'Bank account added',
            subtitle: bankSubtitle,
            circularIcon: true,
            showTrailingIcons: false,
          ),
          const SizedBox(height: 12),
          OnboardingTaskCard(
            icon: Icons.description_outlined,
            title: 'Your listing is published',
            subtitle:
                'Renters can book your item once your payout setup is complete.',
            circularIcon: true,
            showTrailingIcons: false,
          ),
          const SizedBox(height: 16),
          Text(
            'Check Transactions for updates.',
            style: onboardingNunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
      bottomBar: OnboardingPrimaryButton(
        label: 'View payout status',
        onPressed: () => Get.offAll(() => const VendorMyTransactionsScreen()),
      ),
    );
  }
}
