import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/services/analytics_service.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/views/screens/onboarding/home_address.dart';
import 'package:jebby/views/screens/onboarding/identity_hub_panel.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/onboarding/personal_details.dart';
import 'package:jebby/views/screens/onboarding/verify_identity.dart';
import 'package:url_launcher/url_launcher.dart';

class IdentityHubScreen extends StatefulWidget {
  final IdentityHubPanel initialPanel;

  const IdentityHubScreen({
    super.key,
    this.initialPanel = IdentityHubPanel.overview,
  });

  @override
  State<IdentityHubScreen> createState() => _IdentityHubScreenState();
}

class _IdentityHubScreenState extends State<IdentityHubScreen> {
  static const _stripeConnectedAccountUrl =
      'https://stripe.com/legal/connect-account';
  static const _stripePrivacyUrl = 'https://stripe.com/privacy';

  late IdentityHubPanel _panel;
  IdentityHubPanel _returnPanel = IdentityHubPanel.overview;
  bool _tosAccepted = false;
  bool _isSubmitting = false;
  bool _reviewExpanded = false;
  bool _restoreReviewAfterFinish = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPanel == IdentityHubPanel.review) {
      _panel = IdentityHubPanel.overview;
      _reviewExpanded = true;
      _prepareReviewPanel();
    } else {
      _panel = widget.initialPanel;
    }
    if (_panel == IdentityHubPanel.photoId) {
      ensureOnboardingController().advanceTo(OnboardingSteps.stepIdentityDocs);
    }
  }

  void _prepareReviewPanel() {
    final controller = ensureOnboardingController();
    controller.advanceTo(OnboardingSteps.stepReview);
    _tosAccepted = controller.providerData.tosAccepted;
  }

  void _showSubmitError(String message, {String title = 'Error'}) {
    showAppErrorSnackbar(message, title: title);
  }

  bool _identityActionRequiredFromSubmit(Map<String, dynamic> response) {
    final requirements =
        StripeRequirementFields.requirementsFromResponse(response);
    final dueKeys = StripeRequirementFields.collectDueKeys(requirements);
    return StripeRequirementFields.shouldPromptIdentityAction(
      dueKeys,
      identityAlreadyVerified: false,
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStripeConnectedAccountAgreement() =>
      _openExternalUrl(_stripeConnectedAccountUrl);

  Future<void> _openStripePrivacy() => _openExternalUrl(_stripePrivacyUrl);

  bool _showIdentityPhase(OnboardingController c) {
    return c.providerData.hasPersonalDetails && c.providerData.hasHomeAddress;
  }

  void _openPanel(
    IdentityHubPanel panel, {
    IdentityHubPanel? returnTo,
    bool restoreReviewAfter = false,
  }) {
    setState(() {
      _returnPanel = returnTo ?? IdentityHubPanel.overview;
      _panel = panel;
      _restoreReviewAfterFinish = restoreReviewAfter;
    });
    if (panel == IdentityHubPanel.photoId) {
      ensureOnboardingController().advanceTo(OnboardingSteps.stepIdentityDocs);
    }
  }

  void _openOverviewSection(IdentityHubPanel panel) {
    _openPanel(
      panel,
      returnTo: IdentityHubPanel.overview,
      restoreReviewAfter: _reviewExpanded,
    );
  }

  void _expandReview() {
    setState(() {
      _reviewExpanded = true;
      _prepareReviewPanel();
    });
  }

  void _finishSection() {
    setState(() {
      _panel = _returnPanel;
      if (_restoreReviewAfterFinish) {
        _reviewExpanded = true;
        _prepareReviewPanel();
      }
      _restoreReviewAfterFinish = false;
      _returnPanel = IdentityHubPanel.overview;
    });
  }

  void _handleBack() {
    if (_panel == IdentityHubPanel.overview) {
      if (_reviewExpanded) {
        setState(() => _reviewExpanded = false);
        return;
      }
      Get.back();
      return;
    }
    setState(() {
      _panel = _returnPanel;
      _restoreReviewAfterFinish = false;
      _returnPanel = IdentityHubPanel.overview;
    });
  }

  String _homeSubtitle(ProviderOnboardingData data) {
    if (data.hasHomeAddress) return data.formattedHomeAddress;
    return 'Where you currently live';
  }

  String _personalSubtitle(ProviderOnboardingData data) {
    if (data.hasPersonalDetails) return data.legalFullName;
    return 'Name, birth date and required tax details';
  }

  String _phaseOnePrimaryLabel(ProviderOnboardingData data) {
    if (!data.hasHomeAddress) return 'Add home address';
    if (!data.hasPersonalDetails) return 'Add Personal details';
    return 'Continue';
  }

  void _phaseOnePrimaryAction(ProviderOnboardingData data) {
    if (!data.hasHomeAddress) {
      _openPanel(IdentityHubPanel.homeAddress);
      return;
    }
    if (!data.hasPersonalDetails) {
      _openPanel(IdentityHubPanel.personalDetails);
      return;
    }
  }

  Future<void> _submitForVerification(OnboardingController controller) async {
    final data = controller.providerData;
    final needsBack = ProviderIdType.requiresBack(data.idType);

    if (!_tosAccepted) {
      _showSubmitError(
        'Please accept the Connected Account Agreement.',
        title: 'Required',
      );
      return;
    }
    if (controller.userId.isEmpty) {
      _showSubmitError(
        'User session not found. Please sign in again.',
        title: 'Required',
      );
      return;
    }
    if (data.frontImagePath == null ||
        !File(data.frontImagePath!).existsSync()) {
      _showSubmitError('ID photos are required.', title: 'Required');
      return;
    }
    if (needsBack &&
        (data.backImagePath == null ||
            !File(data.backImagePath!).existsSync())) {
      _showSubmitError('Back of ID is required.', title: 'Required');
      return;
    }
    final ssnLast4 = data.ssnLast4?.trim();
    if (ssnLast4 == null || ssnLast4.length != 4) {
      _showSubmitError('SSN last 4 is required.', title: 'Required');
      return;
    }
    if (!data.hasHomeAddress) {
      _showSubmitError('Home address is required.', title: 'Required');
      return;
    }
    if (!data.hasPersonalDetails) {
      if (!ProviderOnboardingData.isValidUsPhone(data.phone)) {
        _showSubmitError(
          'Add a valid US phone number in Personal details.',
          title: 'Required',
        );
      } else {
        _showSubmitError('Personal details are required.', title: 'Required');
      }
      return;
    }

    setState(() => _isSubmitting = true);

    AnalyticsService.instance.track('stripe_onboarding_submitted');

    await controller.updateProviderData(
      controller.providerData.copyWith(tosAccepted: true, ssnLast4: ssnLast4),
    );

    try {
      final uploadResponse = await ApiRepository.shared
          .uploadIdentityDocumentFuture(
            userId: controller.userId,
            documentType: data.idType,
            frontPath: data.frontImagePath!,
            backPath: needsBack ? data.backImagePath : null,
          );

      final frontFileId = uploadResponse['front_file_id']?.toString();
      if (frontFileId == null || frontFileId.isEmpty) {
        throw Exception('Could not upload identity document.');
      }

      await controller.updateProviderData(
        controller.providerData.copyWith(
          frontFileId: frontFileId,
          backFileId: uploadResponse['back_file_id']?.toString(),
          ssnLast4: ssnLast4,
        ),
      );

      final response = await ApiRepository.shared
          .submitProviderOnboardingFuture(
            body: controller.providerData.toSubmitJson(
              userId: controller.userId,
              includeBank: false,
            ),
          );

      if (!mounted) return;

      final status = response['status']?.toString() ?? 'pending';
      final accountId = response['account_id']?.toString();

      if (status == 'error' || status == 'failed' || status == 'failure') {
        if (mounted) setState(() => _isSubmitting = false);
        _showSubmitError(
          ApiRepository.extractApiErrorMessage(
            response,
            fallback: 'Unable to submit verification.',
          ),
        );
        return;
      }

      await controller.clearSensitiveProviderData();

      if (StripeRequirementFields.identityClearedForNextStep(response)) {
        await controller.markIdentityVerified(accountId: accountId);
      } else if (status == 'requires_info' &&
          _identityActionRequiredFromSubmit(response)) {
        await controller.markIdentityActionNeeded(accountId: accountId);
      } else {
        await controller.markIdentitySubmitted(accountId: accountId);
      }

      if (!mounted) return;
      controller.navigateAfterIdentitySubmit(status, response: response);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSubmitError(
        ApiRepository.extractApiErrorMessage(error, fallback: error.toString()),
      );
    }
  }

  Widget _buildReviewIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'One last check before we send the details.',
          style: onboardingNunito(size: 18, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Make sure everything looks right. Tap any section to make changes.',
          style: onboardingNunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewConsentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Once you submit, Stripe will review your details',
          style: onboardingNunito(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _tosAccepted,
              activeColor: AppColors.jebbyBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged:
                  _isSubmitting
                      ? null
                      : (_) => setState(() => _tosAccepted = !_tosAccepted),
            ),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'I agree to the ',
                    style: onboardingNunito(
                      size: 13,
                      weight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        _isSubmitting
                            ? null
                            : _openStripeConnectedAccountAgreement,
                    child: Text(
                      'Stripe Connected Account Agreement.',
                      style: onboardingNunito(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.jebbyBlue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStripeFooter() {
    return OnboardingPrivacyLinks(
      onStripePrivacy: _openStripePrivacy,
      onJebbyPrivacy: () => Get.to(() => const PrivacyPolicyScreen()),
    );
  }

  ({String title, String subtitle, bool headerDivider}) _shellMeta(
    IdentityHubPanel panel,
    bool phaseTwo,
  ) {
    switch (panel) {
      case IdentityHubPanel.homeAddress:
        return (
          title: 'Home address',
          subtitle: "Your address helps us verify it's you.",
          headerDivider: true,
        );
      case IdentityHubPanel.personalDetails:
        return (
          title: 'Personal details',
          subtitle: "Help us verify it's you.",
          headerDivider: true,
        );
      case IdentityHubPanel.photoId:
        return (
          title: 'Verify your identity',
          subtitle: 'Upload your ID to continue verification.',
          headerDivider: true,
        );
      case IdentityHubPanel.overview:
        return (
          title: 'Verify identity',
          subtitle:
              _reviewExpanded
                  ? 'Review your details before submitting.'
                  : phaseTwo
                  ? 'Add your ID to finish verification.'
                  : 'A few details to help you get started.',
          headerDivider: false,
        );
      case IdentityHubPanel.review:
        return (
          title: 'Verify identity',
          subtitle: 'Review your details before submitting.',
          headerDivider: false,
        );
    }
  }

  Widget _buildPanelBody(OnboardingController controller) {
    final data = controller.providerData;
    final returnToReview =
        _returnPanel == IdentityHubPanel.overview && _restoreReviewAfterFinish;

    switch (_panel) {
      case IdentityHubPanel.homeAddress:
        return HomeAddressScreen(
          key: const ValueKey('hub_home_address'),
          embedded: true,
          returnToReview: returnToReview,
          onFinished: _finishSection,
        );
      case IdentityHubPanel.personalDetails:
        return PersonalDetailsScreen(
          key: const ValueKey('hub_personal'),
          embedded: true,
          returnToReview: returnToReview,
          onFinished: _finishSection,
        );
      case IdentityHubPanel.photoId:
        return VerifyIdentityScreen(
          key: const ValueKey('hub_photo_id'),
          embedded: true,
          returnToReview: returnToReview,
          onFinished: _finishSection,
          onDraftExit: _finishSection,
        );
      case IdentityHubPanel.review:
        final phaseTwo = _showIdentityPhase(controller);
        return _buildOverviewCards(
          controller,
          data,
          phaseTwo,
          includeReviewConsent: true,
        );
      case IdentityHubPanel.overview:
        final phaseTwo = _showIdentityPhase(controller);
        return _buildOverviewCards(
          controller,
          data,
          phaseTwo,
          includeReviewConsent: _reviewExpanded,
        );
    }
  }

  Widget _buildOverviewCards(
    OnboardingController controller,
    ProviderOnboardingData data,
    bool phaseTwo, {
    required bool includeReviewConsent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!phaseTwo) ...[
          const SizedBox(height: 12),
          Text(
            "Let's start with you",
            style: onboardingNunito(size: 24, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us a little about yourself.',
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
        ] else if (includeReviewConsent) ...[
          _buildReviewIntroSection(),
        ] else ...[
          const SizedBox(height: 12),
          Text(
            'Add your ID to finish verification.',
            style: onboardingNunito(size: 18, weight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
        ],
        OnboardingTaskCard(
          icon: Icons.home_outlined,
          title: 'Home address',
          subtitle: _homeSubtitle(data),
          isComplete: data.hasHomeAddress,
          isNextAction: !data.hasHomeAddress,
          onTap:
              () =>
                  phaseTwo && includeReviewConsent
                      ? _openOverviewSection(IdentityHubPanel.homeAddress)
                      : _openPanel(IdentityHubPanel.homeAddress),
        ),
        const SizedBox(height: 16),
        OnboardingTaskCard(
          icon: Icons.person_outline,
          title: 'Personal details',
          subtitle: _personalSubtitle(data),
          detailSubtitle:
              data.hasPersonalDetails ? 'Birth date and SSN provided' : null,
          isComplete: data.hasPersonalDetails,
          isNextAction: !data.hasPersonalDetails,
          onTap:
              () =>
                  phaseTwo && includeReviewConsent
                      ? _openOverviewSection(IdentityHubPanel.personalDetails)
                      : _openPanel(IdentityHubPanel.personalDetails),
        ),
        if (phaseTwo) ...[
          const SizedBox(height: 16),
          OnboardingTaskCard(
            icon: Icons.badge_outlined,
            title: 'Photo ID',
            subtitle:
                data.hasIdentityDocuments
                    ? 'Documents added'
                    : 'Front and back if required',
            isComplete: data.hasIdentityDocuments,
            isNextAction: !data.hasIdentityDocuments,
            onTap:
                () =>
                    includeReviewConsent
                        ? _openOverviewSection(IdentityHubPanel.photoId)
                        : _openPanel(IdentityHubPanel.photoId),
          ),
        ],
        if (!includeReviewConsent) ...[
          const SizedBox(height: 18),
          Text(
            'We may also ask for a photo ID to complete verification.',
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _bankDetailsWaitCard(),
        ],
        if (includeReviewConsent) _buildReviewConsentSection(),
      ],
    );
  }

  Widget? _buildBottomBar(
    OnboardingController controller,
    ProviderOnboardingData data,
    bool phaseTwo,
  ) {
    if (_panel != IdentityHubPanel.overview) return null;

    if (phaseTwo && _reviewExpanded) {
      return Column(
        children: [
          _buildReviewStripeFooter(),
          const SizedBox(height: 24),
          OnboardingPrimaryButton(
            label: 'Submit for verification',
            isLoading: _isSubmitting,
            onPressed:
                _isSubmitting ? null : () => _submitForVerification(controller),
          ),
          const SizedBox(height: 10),
          OnboardingSecondaryButton(
            label: 'Save and exit',
            onPressed: _isSubmitting ? null : () => Get.back(),
          ),
        ],
      );
    }

    if (phaseTwo) {
      return Column(
        children: [
          OnboardingPrimaryButton(
            label: data.hasIdentityDocuments ? 'Review and submit' : 'Add ID',
            onPressed: () {
              if (data.hasIdentityDocuments) {
                _expandReview();
                return;
              }
              _openPanel(IdentityHubPanel.photoId);
            },
          ),
          const SizedBox(height: 10),
          OnboardingSecondaryButton(
            label: 'Save and exit',
            onPressed: () => Get.back(),
          ),
        ],
      );
    }

    return Column(
      children: [
        OnboardingPrimaryButton(
          label: _phaseOnePrimaryLabel(data),
          onPressed: () => _phaseOnePrimaryAction(data),
        ),
        const SizedBox(height: 10),
        OnboardingSecondaryButton(
          label: 'Save and exit',
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      init: ensureOnboardingController(),
      builder: (controller) {
        final data = controller.providerData;
        final phaseTwo = _showIdentityPhase(controller);
        final meta = _shellMeta(_panel, phaseTwo);

        return OnboardingShell(
          title: meta.title,
          subtitle: meta.subtitle,
          headerDivider: meta.headerDivider,
          onBack: _handleBack,
          bodyScrollable: _panel == IdentityHubPanel.overview,
          body: _buildPanelBody(controller),
          bottomBar: _buildBottomBar(controller, data, phaseTwo),
        );
      },
    );
  }

  Widget _bankDetailsWaitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.jebbySoftBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.jebbyBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_outlined,
              color: AppColors.jebbyBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank details can wait.',
                  style: onboardingNunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can add your payout details once your first item is live.',
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
      ),
    );
  }
}
