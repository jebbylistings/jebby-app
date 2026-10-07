import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';

class VerifyIdentityScreen extends StatefulWidget {
  final bool returnToReview;
  final bool embedded;
  final VoidCallback? onFinished;
  final VoidCallback? onDraftExit;

  const VerifyIdentityScreen({
    super.key,
    this.returnToReview = false,
    this.embedded = false,
    this.onFinished,
    this.onDraftExit,
  });

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  static const Color _fieldSurface = Colors.white;

  late final OnboardingController _controller = ensureOnboardingController();
  final ImagePicker _picker = ImagePicker();
  late String _idType;
  String? _frontPath;
  String? _backPath;

  @override
  void initState() {
    super.initState();
    if (!widget.returnToReview) {
      _controller.advanceTo(OnboardingSteps.stepIdentityDocs);
    }
    final data = _controller.providerData;
    _idType = data.idType;
    if (!ProviderIdType.labels.containsKey(_idType)) {
      _idType = ProviderIdType.drivingLicense;
    }
    _frontPath = data.frontImagePath;
    _backPath = data.backImagePath;
  }

  bool get _needsBack => ProviderIdType.requiresBack(_idType);

  bool get _hasFront =>
      _frontPath != null && File(_frontPath!).existsSync();

  bool get _hasBack => _backPath != null && File(_backPath!).existsSync();

  void _showError(String message) =>
      showAppErrorSnackbar(message, title: 'Required');

  Future<void> _pickImage(bool isBack) async {
    final source = await showOnboardingImageSourceSheet(context);
    if (source == null) return;

    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    setState(() {
      if (isBack) {
        _backPath = file.path;
      } else {
        _frontPath = file.path;
      }
    });
  }

  Future<void> _saveDraftAndExit() async {
    var data = _controller.providerData.copyWith(idType: _idType);

    if (_hasFront) {
      data = data.copyWith(
        frontImagePath: _frontPath,
        clearFrontFileId: true,
      );
    }

    if (!_needsBack) {
      data = data.copyWith(
        backImagePath: '',
        clearBackFileId: true,
      );
    } else if (_hasBack) {
      data = data.copyWith(
        backImagePath: _backPath,
        clearBackFileId: true,
      );
    }

    await _controller.updateProviderData(data);

    if (widget.onDraftExit != null) {
      widget.onDraftExit!();
      return;
    }
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    Get.back();
  }

  Future<void> _saveAndContinue() async {
    if (!_hasFront) {
      _showError('Please upload the front of your ID.');
      return;
    }
    if (_needsBack && !_hasBack) {
      _showError('Please upload the back of your ID.');
      return;
    }

    await _controller.updateProviderData(
      _controller.providerData.copyWith(
        idType: _idType,
        frontImagePath: _frontPath,
        backImagePath: _backPath,
        clearFrontFileId: true,
        clearBackFileId: true,
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

  void _primaryAction() {
    if (!_hasFront) {
      _pickImage(false);
      return;
    }
    if (_needsBack && !_hasBack) {
      _pickImage(true);
      return;
    }
    _saveAndContinue();
  }

  String get _primaryLabel {
    if (!_hasFront) return 'Add front of ID';
    if (_needsBack && !_hasBack) return 'Add back of ID';
    return widget.returnToReview ? 'Save' : 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    final idTypes = ProviderIdType.labels.keys.toList();

    final formFields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Add your photo ID',
          style: onboardingNunito(size: 22, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          "Your photo ID helps Stripe confirm it's you.",
          style: onboardingNunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('Document type', muted: true),
        OnboardingDropdownField<String>(
          value: idTypes.contains(_idType) ? _idType : idTypes.first,
          items: idTypes,
          fillColor: _fieldSurface,
          labelBuilder: (key) => ProviderIdType.labels[key]!,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _idType = value;
              if (!ProviderIdType.requiresBack(value)) {
                _backPath = null;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        _PhotoIdUploadCard(
          title: 'Front of ID',
          subtitle: _hasFront ? 'Photo added' : 'Add a clear photo',
          isComplete: _hasFront,
          isNextAction: !_hasFront,
          onTap: () => _pickImage(false),
        ),
        if (_needsBack) ...[
          const SizedBox(height: 16),
          _PhotoIdUploadCard(
            title: 'Back of ID',
            subtitle: _hasBack ? 'Photo added' : 'Add a clear photo',
            isComplete: _hasBack,
            isNextAction: _hasFront && !_hasBack,
            onTap: () => _pickImage(true),
          ),
        ],
        const SizedBox(height: 16),
        const OnboardingInfoBanner(
          message:
              'Make sure your photo is clear and all four corners are visible.',
        ),
      ],
    );

    final actionButtons = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnboardingPrimaryButton(
          label: _primaryLabel,
          onPressed: _primaryAction,
        ),
        const SizedBox(height: 10),
        OnboardingSecondaryButton(
          label: 'Save and exit',
          onPressed: () => _saveDraftAndExit(),
        ),
      ],
    );

    if (widget.embedded) {
      return OnboardingEmbeddedFormLayout(
        scrollChild: formFields,
        bottomBar: actionButtons,
      );
    }

    return OnboardingShell(
      title: 'Verify your identity',
      subtitle: 'Upload your ID to continue verification.',
      headerDivider: true,
      body: formFields,
      bottomBar: actionButtons,
    );
  }
}

class _PhotoIdUploadCard extends StatelessWidget {
  static const Color _completeCheckGreen = Color(0xFF52B788);
  static const Color _completeCheckBg = Color(0xFFEDF7F1);

  final String title;
  final String subtitle;
  final bool isComplete;
  final bool isNextAction;
  final VoidCallback onTap;

  const _PhotoIdUploadCard({
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.isNextAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isNextAction && !isComplete
        ? AppColors.earnerOrangeSoft
        : Colors.white;
    final border = isNextAction && !isComplete
        ? AppColors.jebbyAccentOrange.withValues(alpha: 0.35)
        : const Color(0xFFE3E6EC);
    final iconBg = isNextAction && !isComplete
        ? AppColors.primaryColorLight
        : AppColors.jebbySoftBlue;
    final iconFg = isNextAction && !isComplete
        ? AppColors.jebbyAccentOrange
        : AppColors.jebbyBlue;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: iconFg,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: onboardingNunito(
                        size: 17,
                        weight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete) ...[
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _completeCheckBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 20,
                    color: _completeCheckGreen,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.jebbyTextMuted.withValues(alpha: 0.7),
                  size: 24,
                ),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: isNextAction
                      ? AppColors.jebbyAccentOrange
                      : AppColors.jebbyTextMuted.withValues(alpha: 0.7),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
