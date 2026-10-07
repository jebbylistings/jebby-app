import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/bank_account.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';
import 'package:url_launcher/url_launcher.dart';

class PayoutMethodScreen extends StatefulWidget {
  final bool fromTransactions;

  /// After Stripe returns `requires_info` (e.g. micro-deposit verification).
  final bool stripeVerificationNeeded;

  const PayoutMethodScreen({
    super.key,
    this.fromTransactions = false,
    this.stripeVerificationNeeded = false,
  });

  @override
  State<PayoutMethodScreen> createState() => _PayoutMethodScreenState();
}

class _PayoutMethodScreenState extends State<PayoutMethodScreen> {
  static const _stripePrivacyUrl = 'https://stripe.com/privacy';

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapSession());
  }

  Future<void> _bootstrapSession() async {
    final controller = ensureOnboardingController();
    await controller.ensureUserSession();
    if (!mounted) return;
    controller.update();
  }

  Future<void> _openStripePrivacy() async {
    final uri = Uri.parse(_stripePrivacyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBankForm(OnboardingController controller) async {
    await Get.to(
      () => BankAccountScreen(fromTransactions: widget.fromTransactions),
    );
    controller.update();
  }

  bool _bankConnected(OnboardingController controller) {
    return controller.payoutsEnabled ||
        (controller.bankLast4?.trim().isNotEmpty ?? false);
  }

  bool _inReviewMode(OnboardingController controller) {
    if (controller.payoutsEnabled) return false;
    if (controller.providerData.hasBankDetails) return true;
    final last4 = controller.bankLast4?.trim();
    return last4 != null && last4.isNotEmpty;
  }

  String _accountEndingLast4(OnboardingController controller) {
    final fromStripe = controller.bankLast4?.trim();
    if (fromStripe != null && fromStripe.isNotEmpty) return fromStripe;
    final account =
        controller.providerData.accountNumber.replaceAll(RegExp(r'\D'), '');
    if (account.length >= 4) return account.substring(account.length - 4);
    return '****';
  }

  String _bankCardSubtitle(OnboardingController controller, {required bool reviewMode}) {
    if (reviewMode) {
      return 'Ending in ${_accountEndingLast4(controller)}';
    }

    if (controller.payoutsEnabled) {
      final last4 = controller.bankLast4?.trim();
      if (last4 != null && last4.isNotEmpty) {
        return 'Payouts enabled · ••••$last4';
      }
      return 'Payouts enabled';
    }

    return 'Choose your bank and follow Stripe\'s steps.';
  }

  Future<void> _onPrimaryPressed(OnboardingController controller) async {
    if (_inReviewMode(controller)) {
      await _submitToStripe(controller);
      return;
    }
    if (widget.stripeVerificationNeeded &&
        (controller.bankLast4?.trim().isNotEmpty ?? false)) {
      await _submitToStripe(controller);
      return;
    }
    await _openBankForm(controller);
  }

  Future<void> _submitToStripe(OnboardingController controller) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await controller.ensureUserSession();
      await controller.submitBankAccountToStripe();
    } catch (error) {
      if (!mounted) return;
      showAppErrorSnackbar(
        error is StateError
            ? error.message
            : ApiRepository.extractApiErrorMessage(
                error,
                fallback: error.toString(),
              ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      init: ensureOnboardingController(),
      builder: (controller) {
        final connected = _bankConnected(controller);
        final reviewMode = _inReviewMode(controller);
        final showBankReview = reviewMode || widget.stripeVerificationNeeded;

        return OnboardingShell(
          title: 'Payout setup',
          subtitle: showBankReview
              ? 'Verify your deposits to enable payouts.'
              : 'Lets finish getting you ready to receive your earnings.',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: OnboardingIllustration(
                  assetPath: showBankReview
                      ? OnboardingAssets.connectBank
                      : OnboardingAssets.payoutChooser,
                  height: showBankReview ? 200 : 248,
                ),
              ),
              if (showBankReview) ...[
                const SizedBox(height: 8),
                Text(
                  'Confirm your bank account.',
                  style: onboardingNunito(size: 20, weight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stripe needs you to verify the deposits sent to your bank.',
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Where should we',
                  style: onboardingNunito(size: 22, weight: FontWeight.w800),
                ),
                Text(
                  'send your earnings?',
                  style: onboardingNunito(size: 22, weight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you would like to add your bank account.',
                  style: onboardingNunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              OnboardingTaskCard(
                icon: Icons.account_balance_outlined,
                title: showBankReview ? 'Bank account' : 'Connect your bank',
                subtitle: _bankCardSubtitle(
                  controller,
                  reviewMode: showBankReview,
                ),
                isComplete: showBankReview ? false : connected,
                isNextAction: !connected && !showBankReview,
                onTap: () => _openBankForm(controller),
              ),
              if (showBankReview) ...[
                const SizedBox(height: 12),
                const OnboardingInfoBanner(
                  message:
                      'Your listing stays published. Booking is unavailable until setup is complete.',
                ),
              ],
            ],
          ),
          bottomBar: Column(
            children: [
              if (!showBankReview) ...[
                OnboardingStripeConnectPrivacyFooter(
                  onStripePrivacy: _openStripePrivacy,
                ),
                const SizedBox(height: 20),
              ],
              OnboardingPrimaryButton(
                label: showBankReview ? 'Verify bank account' : 'Continue to Stripe',
                isLoading: _submitting,
                onPressed: _submitting ? null : () => _onPrimaryPressed(controller),
              ),
              const SizedBox(height: 10),
              OnboardingSecondaryButton(
                label: 'Go to Transactions',
                onPressed: _submitting
                    ? null
                    : () => Get.offAll(() => const VendorMyTransactionsScreen()),
              ),
            ],
          ),
        );
      },
    );
  }
}
