import 'package:flutter/material.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';

export 'onboarding_kit.dart';

/// Legacy shell — prefer [OnboardingShell] from `onboarding_kit.dart`.
class OnboardingScaffold extends StatelessWidget {
  final int? currentStep;
  final String title;
  final Widget body;
  final Widget? bottomBar;
  final bool showBackButton;
  final bool showStepProgress;
  final VoidCallback? onBack;

  const OnboardingScaffold({
    super.key,
    this.currentStep,
    required this.title,
    required this.body,
    this.bottomBar,
    this.showBackButton = true,
    this.showStepProgress = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: title,
      showBackButton: showBackButton,
      onBack: onBack,
      body: body,
      bottomBar: bottomBar,
    );
  }
}

/// Legacy footer row — prefer [OnboardingLockNote].
class OnboardingStripeFooter extends StatelessWidget {
  const OnboardingStripeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingLockNote();
  }
}
