import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final bool returnToReview;
  final bool embedded;
  final VoidCallback? onFinished;

  const PersonalDetailsScreen({
    super.key,
    this.returnToReview = false,
    this.embedded = false,
    this.onFinished,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  static const Color _fieldSurface = Colors.white;
  static const _stripePrivacyUrl = 'https://stripe.com/privacy';

  late final OnboardingController _controller = ensureOnboardingController();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ssnController;
  DateTime? _selectedDob;
  bool _obscureSsn = true;

  @override
  void initState() {
    super.initState();
    final data = _controller.providerData;
    _firstNameController = TextEditingController(text: data.firstName);
    _lastNameController = TextEditingController(text: data.lastName);
    _emailController = TextEditingController(text: data.email);
    _phoneController = TextEditingController(text: _initialPhoneDisplay());
    _ssnController = TextEditingController(text: data.ssnLast4 ?? '');
    _selectedDob = data.dateOfBirth;
    if (_emailController.text.isEmpty) {
      _emailController.text = _controller.userEmail;
    }
    if (_firstNameController.text.isEmpty && _controller.userName.isNotEmpty) {
      final parts = _controller.userName.trim().split(RegExp(r'\s+'));
      _firstNameController.text = parts.first;
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ssnController.dispose();
    super.dispose();
  }

  String get _dobLabel {
    if (_selectedDob == null) return 'Select date of birth';
    return DateFormat('MM / dd / yyyy').format(_selectedDob!);
  }

  String _initialPhoneDisplay() {
    for (final raw in [_controller.providerData.phone, _controller.userPhone]) {
      final display = ProviderOnboardingData.displayUsPhone(raw);
      if (display.isNotEmpty) return display;
    }
    return '';
  }

  void _showError(String message) =>
      showAppErrorSnackbar(message, title: 'Required');

  Future<void> _openStripePrivacy() async {
    final uri = Uri.parse(_stripePrivacyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final ssn = _ssnController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showError('Please enter your first and last name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email.');
      return;
    }
    if (phone.isEmpty) {
      _showError('Please enter your phone number.');
      return;
    }
    if (!ProviderOnboardingData.isValidUsPhone(phone)) {
      _showError(
        'Enter a 10-digit US mobile number (area code + number).',
      );
      return;
    }
    if (_selectedDob == null) {
      _showError('Please select your date of birth.');
      return;
    }
    if (ssn.length != 4) {
      _showError('Enter the last 4 digits of your SSN.');
      return;
    }

    final dob = _selectedDob!;
    await _controller.updateProviderData(
      _controller.providerData.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: ProviderOnboardingData.formatPhoneE164(phone),
        ssnLast4: ssn,
        dobDay: dob.day,
        dobMonth: dob.month,
        dobYear: dob.year,
        accountHolderName: '$firstName $lastName'.trim(),
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
    final formFields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'A little about you',
          style: onboardingNunito(size: 22, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the legal details.',
          style: onboardingNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('First name', muted: true),
        OnboardingTextField(
          controller: _firstNameController,
          hint: 'First name',
          fillColor: _fieldSurface,
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Last name', muted: true),
        OnboardingTextField(
          controller: _lastNameController,
          hint: 'Last name',
          fillColor: _fieldSurface,
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Date of birth', muted: true),
        OnboardingDateField(
          label: _dobLabel,
          fillColor: _fieldSurface,
          showCalendarIcon: false,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showOnboardingDatePicker(
              context,
              initialDate: _selectedDob ?? DateTime(now.year - 25),
              firstDate: DateTime(1900),
              lastDate: DateTime(now.year - 18, now.month, now.day),
              entryMode: DatePickerEntryMode.inputOnly,
            );
            if (picked != null) setState(() => _selectedDob = picked);
          },
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Phone number', muted: true),
        OnboardingTextField(
          controller: _phoneController,
          hint: '(555) 555-5555',
          keyboardType: TextInputType.phone,
          fillColor: _fieldSurface,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]')),
            LengthLimitingTextInputFormatter(18),
          ],
        ),
        const SizedBox(height: 16),
        const OnboardingFieldLabel('Last 4 digits of SSN', muted: true),
        OnboardingTextField(
          controller: _ssnController,
          hint: '••••',
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: _obscureSsn,
          fillColor: _fieldSurface,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          suffix: IconButton(
            icon: Icon(
              _obscureSsn
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.jebbyBlue,
              size: 22,
            ),
            onPressed: () => setState(() => _obscureSsn = !_obscureSsn),
          ),
        ),
        _legalDisclosureSection(),
      ],
    );

    if (widget.embedded) {
      return OnboardingEmbeddedFormLayout(
        scrollChild: formFields,
        bottomBar: OnboardingPrimaryButton(
          label: 'Save details',
          onPressed: _save,
        ),
      );
    }

    return OnboardingShell(
      title: 'Personal details',
      subtitle: "Help us verify it's you.",
      headerDivider: true,
      body: formFields,
      bottomBar: OnboardingPrimaryButton(
        label: 'Save details',
        onPressed: _save,
      ),
    );
  }

  Widget _legalDisclosureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Why do we ask for this ?',
          style: onboardingNunito(
            size: 14,
            weight: FontWeight.w700,
            color: AppColors.jebbyBlue,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Jebby shares these details with Stripe to verify your identity. Stripe may request additional information to complete verification.',
            style: onboardingNunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextPrimary,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ssnPrivacyLinksFooter(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _ssnPrivacyLinksFooter() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.jebbyBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Your SSN is not shown on your public profile.',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _openStripePrivacy,
                child: Text(
                  'Stripe Privacy',
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.jebbyBlue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 1,
                  height: 14,
                  color: const Color(0xFFC6C8CF),
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                child: Text(
                  'Jebby Privacy',
                  style: onboardingNunito(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.jebbyBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
