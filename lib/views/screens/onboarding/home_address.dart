import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';

class HomeAddressScreen extends StatefulWidget {
  final bool returnToReview;
  final bool embedded;
  final VoidCallback? onFinished;

  const HomeAddressScreen({
    super.key,
    this.returnToReview = false,
    this.embedded = false,
    this.onFinished,
  });

  @override
  State<HomeAddressScreen> createState() => _HomeAddressScreenState();
}

class _HomeAddressScreenState extends State<HomeAddressScreen> {
  static const Color _fieldSurface = Colors.white;

  late final OnboardingController _controller = ensureOnboardingController();
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;
  late String _stateCode;

  @override
  void initState() {
    super.initState();
    _bindFieldsFromProvider(_controller.providerData);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfileAddress());
  }

  void _bindFieldsFromProvider(ProviderOnboardingData data) {
    _line1Controller = TextEditingController(text: data.addressLine1);
    _line2Controller = TextEditingController(text: data.addressLine2);
    _cityController = TextEditingController(text: data.addressCity);
    _zipController = TextEditingController(text: data.addressPostalCode);
    _stateCode = _initialStateCode(data.addressState);
  }

  String _initialStateCode(String raw) {
    final code = raw.toUpperCase().trim();
    if (ProviderOnboardingData.isValidUsStateCode(code)) return code;
    return 'CA';
  }

  Future<void> _loadProfileAddress() async {
    await _controller.prefillHomeAddressFromUserProfile();
    if (!mounted) return;
    final data = _controller.providerData;
    setState(() {
      _line1Controller.text = data.addressLine1;
      _line2Controller.text = data.addressLine2;
      _cityController.text = data.addressCity;
      _zipController.text = data.addressPostalCode;
      _stateCode = _initialStateCode(data.addressState);
    });
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _showError(String message) =>
      showAppErrorSnackbar(message, title: 'Required');

  Future<void> _save() async {
    final line1 = _line1Controller.text.trim();
    final city = _cityController.text.trim();
    final zip = _zipController.text.trim();

    if (line1.isEmpty) {
      _showError('Enter your street address.');
      return;
    }
    if (city.isEmpty) {
      _showError('Enter your city.');
      return;
    }
    if (!ProviderOnboardingData.isValidUsStateCode(_stateCode)) {
      _showError('Select a valid state.');
      return;
    }
    if (!ProviderOnboardingData.isValidUsPostalCode(zip)) {
      _showError('Enter a valid ZIP code.');
      return;
    }

    await _controller.updateProviderData(
      _controller.providerData.copyWith(
        addressLine1: line1,
        addressLine2: _line2Controller.text.trim(),
        addressCity: city,
        addressState: _stateCode,
        addressPostalCode: zip.replaceAll(RegExp(r'\D'), ''),
        country: 'US',
      ),
    );

    if (widget.returnToReview) {
      await _controller.advanceTo(OnboardingSteps.stepReview);
    }
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final states = ProviderOnboardingData.usStates.map((s) => s['code']!).toList();

    final formFields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Lets add your address',
          style: onboardingNunito(size: 22, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the current address where you live.',
          style: onboardingNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('Country', muted: true),
        OnboardingDropdownField<String>(
          value: 'US',
          items: const ['US'],
          fillColor: _fieldSurface,
          labelBuilder: (_) => 'United States',
          onChanged: null,
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Street address', muted: true),
        OnboardingTextField(
          controller: _line1Controller,
          hint: '123 Bayside Lane',
          fillColor: _fieldSurface,
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Apartment / unit (optional)', muted: true),
        OnboardingTextField(
          controller: _line2Controller,
          hint: 'Apt, suite, etc.',
          fillColor: _fieldSurface,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingFieldLabel('City', muted: true),
                  OnboardingTextField(
                    controller: _cityController,
                    hint: 'City',
                    fillColor: _fieldSurface,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingFieldLabel('State', muted: true),
                  OnboardingDropdownField<String>(
                    value: states.contains(_stateCode) ? _stateCode : null,
                    hint: 'State',
                    items: states,
                    fillColor: _fieldSurface,
                    labelBuilder: (code) => code,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _stateCode = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('ZIP code', muted: true),
        OnboardingTextField(
          controller: _zipController,
          hint: '33602',
          keyboardType: TextInputType.number,
          maxLength: 10,
          fillColor: _fieldSurface,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );

    if (widget.embedded) {
      return OnboardingEmbeddedFormLayout(
        scrollChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            formFields,
            const SizedBox(height: 24),
            _addressPrivacyFooter(),
          ],
        ),
        bottomBar: OnboardingPrimaryButton(
          label: 'Save address',
          onPressed: _save,
        ),
      );
    }

    return OnboardingShell(
      title: 'Home address',
      subtitle: "Your address helps us verify it's you.",
      headerDivider: true,
      body: formFields,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _addressPrivacyFooter(),
          const SizedBox(height: 16),
          OnboardingPrimaryButton(
            label: 'Save address',
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _addressPrivacyFooter() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppColors.jebbyBlue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Your address won't appear on your public profile",
                  textAlign: TextAlign.center,
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.to(() => const PrivacyPolicyScreen()),
            child: Text(
              'Jebby Privacy',
              textAlign: TextAlign.center,
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.jebbyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
