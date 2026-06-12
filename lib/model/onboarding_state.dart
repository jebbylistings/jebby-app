class OnboardingStatus {
  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String stripePending = 'stripe_pending';
  static const String complete = 'complete';
}

class OnboardingState {
  final int onboardingStep;
  final String onboardingStatus;
  final String? stripeAccountId;
  final bool stripeOnboardingComplete;

  const OnboardingState({
    this.onboardingStep = 1,
    this.onboardingStatus = OnboardingStatus.notStarted,
    this.stripeAccountId,
    this.stripeOnboardingComplete = false,
  });

  bool get isComplete =>
      onboardingStatus == OnboardingStatus.complete ||
      stripeOnboardingComplete;

  bool get canResume =>
      onboardingStatus == OnboardingStatus.inProgress ||
      onboardingStatus == OnboardingStatus.stripePending;

  int get stepsRemaining {
    if (isComplete) return 0;
    if (onboardingStatus == OnboardingStatus.notStarted) return 10;
    return (10 - onboardingStep).clamp(1, 10);
  }

  int get resumeStep {
    if (onboardingStatus == OnboardingStatus.notStarted) return 1;
    if (isComplete) return 10;
    return onboardingStep.clamp(1, 10);
  }

  OnboardingState copyWith({
    int? onboardingStep,
    String? onboardingStatus,
    String? stripeAccountId,
    bool? stripeOnboardingComplete,
  }) {
    return OnboardingState(
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      stripeOnboardingComplete:
          stripeOnboardingComplete ?? this.stripeOnboardingComplete,
    );
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      onboardingStep: _parseInt(json['onboarding_step'], fallback: 1),
      onboardingStatus:
          json['onboarding_status']?.toString() ??
          OnboardingStatus.notStarted,
      stripeAccountId: json['stripe_account_id']?.toString(),
      stripeOnboardingComplete:
          json['stripe_onboarding_complete'] == true ||
          json['stripe_onboarding_complete'] == 1 ||
          json['stripe_onboarding_complete'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboarding_step': onboardingStep,
      'onboarding_status': onboardingStatus,
      'stripe_account_id': stripeAccountId,
      'stripe_onboarding_complete': stripeOnboardingComplete,
    };
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }
}
