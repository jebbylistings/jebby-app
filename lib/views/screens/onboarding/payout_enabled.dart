import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/navigation/home_main.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/onboarding/payout_in_review.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';

class PayoutEnabledScreen extends StatefulWidget {
  const PayoutEnabledScreen({super.key});

  @override
  State<PayoutEnabledScreen> createState() => _PayoutEnabledScreenState();
}

class _PayoutEnabledScreenState extends State<PayoutEnabledScreen> {
  bool _confirmedEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirmPayoutsEnabled());
  }

  Future<void> _confirmPayoutsEnabled() async {
    final controller = ensureOnboardingController();
    await controller.ensureUserSession();
    await controller.refreshStripeStatus();

    if (!mounted) return;

    final response = controller.lastStripeStatusResponse;
    final enabledOnServer = response != null &&
        StripeRequirementFields.showPayoutEnabledAfterBankSubmit(response);
    final enabledLocally = controller.payoutsEnabled &&
        controller.state.payoutStatus == PayoutStatus.enabled;

    if (!enabledOnServer || !enabledLocally) {
      Get.off(() => const PayoutInReviewScreen());
      return;
    }

    setState(() => _confirmedEnabled = true);
  }

  static String _bankEndingLabel(OnboardingController controller) {
    final fromStripe = controller.bankLast4?.trim();
    if (fromStripe != null && fromStripe.isNotEmpty) {
      return 'Ending in $fromStripe';
    }
    final account =
        controller.providerData.accountNumber.replaceAll(RegExp(r'\D'), '');
    if (account.length >= 4) {
      return 'Ending in ${account.substring(account.length - 4)}';
    }
    return 'Ending in ****';
  }

  @override
  Widget build(BuildContext context) {
    if (!_confirmedEnabled) {
      return OnboardingShell(
        title: 'Payout setup',
        subtitle: 'Checking your payout status…',
        showBackButton: false,
        headerLeadingInset: false,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(
              color: AppColors.jebbyBlue,
              strokeWidth: 2.4,
            ),
          ),
        ),
      );
    }

    final controller = ensureOnboardingController();
    final bankSubtitle = _bankEndingLabel(controller);

    return OnboardingShell(
      title: 'Payout setup',
      subtitle: 'Your payout setup is complete.',
      showBackButton: false,
      headerLeadingInset: false,
      body: Column(
        children: [
          const Center(
            child: OnboardingStatusPill(kind: OnboardingPillKind.payoutsEnabled),
          ),
          const SizedBox(height: 16),
          Text(
            'You\'re ready to earn.',
            style: onboardingNunito(size: 20, weight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all set! Renters can now book your items',
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
            assetPath: OnboardingAssets.allSet,
            height: 220,
          ),
          const SizedBox(height: 8),
          OnboardingTaskCard(
            icon: Icons.account_balance_outlined,
            title: 'Bank account',
            subtitle: bankSubtitle,
            showTrailingIcons: false,
            circularIcon: true,
          ),
          const SizedBox(height: 12),
          OnboardingTaskCard(
            icon: Icons.calendar_month_outlined,
            title: 'Booking availability',
            subtitle: 'Bookings enabled',
            showTrailingIcons: false,
            circularIcon: true,
          ),
        ],
      ),
      bottomBar: Column(
        children: [
          OnboardingPrimaryButton(
            label: 'Go to Earning',
            onPressed: () => Get.offAll(() => const MainScreen()),
          ),
          const SizedBox(height: 10),
          OnboardingSecondaryButton(
            label: 'View Transactions',
            onPressed: () => Get.offAll(() => const VendorMyTransactionsScreen()),
          ),
        ],
      ),
    );
  }
}
