import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';

class BankAccountScreen extends StatefulWidget {
  final bool fromTransactions;

  /// Legacy review flow parameter — ignored; payout uses [fromTransactions].
  final bool returnToReview;

  const BankAccountScreen({
    super.key,
    this.fromTransactions = false,
    this.returnToReview = false,
  });

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  static const Color _fieldSurface = Colors.white;

  late final OnboardingController _controller = ensureOnboardingController();
  late final TextEditingController _holderController;
  late final TextEditingController _routingController;
  late final TextEditingController _accountController;
  late final TextEditingController _confirmController;
  bool _saving = false;
  bool _holderPrefillDone = false;

  @override
  void initState() {
    super.initState();
    final data = _controller.providerData;
    _holderController = TextEditingController(
      text: _controller.resolvedAccountHolderNameSync(),
    );
    _routingController = TextEditingController(text: data.routingNumber);
    _accountController = TextEditingController(text: data.accountNumber);
    _confirmController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillAccountHolderName();
    });
  }

  Future<void> _prefillAccountHolderName() async {
    if (_holderPrefillDone) return;
    _holderPrefillDone = true;
    final name = await _controller.resolveAccountHolderNameAsync();
    if (!mounted || name.isEmpty) return;
    if (_holderController.text.trim() == name) return;
    _holderController.text = name;
  }

  @override
  void dispose() {
    _holderController.dispose();
    _routingController.dispose();
    _accountController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) =>
      showAppErrorSnackbar(message, title: 'Required');

  Future<void> _saveForReview() async {
    final holder = _holderController.text.trim();
    final routing = _routingController.text.replaceAll(RegExp(r'\D'), '');
    final account = _accountController.text.replaceAll(RegExp(r'\D'), '');
    final confirm = _confirmController.text.replaceAll(RegExp(r'\D'), '');

    if (holder.isEmpty) {
      _showError('Please enter the account holder name.');
      return;
    }
    if (routing.length != 9) {
      _showError('Routing number must be 9 digits.');
      return;
    }
    if (account.length < 4) {
      _showError('Please enter a valid account number.');
      return;
    }
    if (account != confirm) {
      _showError('Account numbers do not match.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _controller.updateProviderData(
        _controller.providerData.copyWith(
          accountHolderName: holder,
          routingNumber: routing,
          accountNumber: account,
        ),
      );
      if (!mounted) return;
      Get.back();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: 'Payout setup',
      subtitle: 'Connect a bank account to receive earnings.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Add your bank account',
            style: onboardingNunito(size: 22, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'This is where we\'ll send your payouts.',
            style: onboardingNunito(
              size: 15,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          const OnboardingFieldLabel('Account holder name', muted: true),
          OnboardingTextField(
            controller: _holderController,
            hint: 'Name on account',
            fillColor: _fieldSurface,
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel('Routing number', muted: true),
          OnboardingTextField(
            controller: _routingController,
            hint: '110000000',
            fillColor: _fieldSurface,
            keyboardType: TextInputType.number,
            maxLength: 9,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          const OnboardingFieldLabel('Account number', muted: true),
          OnboardingTextField(
            controller: _accountController,
            hint: '000123456789',
            fillColor: _fieldSurface,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel('Confirm account number', muted: true),
          OnboardingTextField(
            controller: _confirmController,
            hint: '000123456789',
            fillColor: _fieldSurface,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          const OnboardingStripePayoutTrustCard(),
        ],
      ),
      bottomBar: Column(
        children: [
          const OnboardingLockNote(
            message: 'Your bank details are encrypted and kept secure.',
          ),
          const SizedBox(height: 14),
          OnboardingPrimaryButton(
            label: 'Review bank details',
            isLoading: _saving,
            onPressed: _saving ? null : _saveForReview,
          ),
          if (widget.fromTransactions) ...[
            const SizedBox(height: 10),
            OnboardingSecondaryButton(
              label: 'Go to Transactions',
              onPressed: _saving
                  ? null
                  : () => Get.offAll(() => const VendorMyTransactionsScreen()),
            ),
          ],
        ],
      ),
    );
  }
}
