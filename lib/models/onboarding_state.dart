/// Legacy status strings stored in SharedPreferences and `/onboarding-state`.
class OnboardingStatus {
  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String stripePending = 'stripe_pending';
  static const String complete = 'complete';
}

/// Identity verification track (required before listings are live).
enum IdentityStatus {
  notStarted,
  inProgress,
  submitted,
  verified,
  actionNeeded,
}

/// Payout / bank setup track (optional during onboarding).
enum PayoutStatus {
  notStarted,
  inReview,
  enabled,
  actionNeeded,
}

/// Internal steps 6–10 map to legacy resume + server sync.
/// Intro screens are outside this range.
class OnboardingSteps {
  static const int formStart = 6;
  static const int formEnd = 10;
  static const int formCount = formEnd - formStart + 1;

  static const int stepPersonal = 6;
  static const int stepIdentityDocs = 7;
  static const int stepReview = 9;
  static const int stepIdentityOutcome = 10;

  static int normalize(int step) {
    if (step < formStart) return formStart;
    if (step > formEnd) return formEnd;
    return step;
  }

  static int toDisplayStep(int internalStep) {
    return (normalize(internalStep) - formStart + 1).clamp(1, formCount);
  }
}

class OnboardingState {
  final int onboardingStep;
  final String onboardingStatus;
  final String? stripeAccountId;
  final bool stripeOnboardingComplete;
  final IdentityStatus identityStatus;
  final PayoutStatus payoutStatus;

  const OnboardingState({
    this.onboardingStep = OnboardingSteps.formStart,
    this.onboardingStatus = OnboardingStatus.notStarted,
    this.stripeAccountId,
    this.stripeOnboardingComplete = false,
    this.identityStatus = IdentityStatus.notStarted,
    this.payoutStatus = PayoutStatus.notStarted,
  });

  /// Identity verified — user can create listings (payout optional).
  bool get isIdentityComplete =>
      identityStatus == IdentityStatus.verified ||
      onboardingStatus == OnboardingStatus.complete ||
      stripeOnboardingComplete;

  /// @deprecated Use [isIdentityComplete]. Kept for existing call sites during migration.
  bool get isComplete => isIdentityComplete;

  bool get canResume =>
      onboardingStatus == OnboardingStatus.inProgress ||
      onboardingStatus == OnboardingStatus.stripePending ||
      identityStatus == IdentityStatus.inProgress ||
      identityStatus == IdentityStatus.submitted ||
      identityStatus == IdentityStatus.actionNeeded;

  int get stepsRemaining {
    if (isIdentityComplete) return 0;
    if (onboardingStatus == OnboardingStatus.notStarted &&
        identityStatus == IdentityStatus.notStarted) {
      return OnboardingSteps.formCount;
    }
    final step = OnboardingSteps.normalize(onboardingStep);
    return (OnboardingSteps.formEnd - step).clamp(0, OnboardingSteps.formCount);
  }

  int get resumeStep {
    if (onboardingStatus == OnboardingStatus.notStarted &&
        identityStatus == IdentityStatus.notStarted) {
      return OnboardingSteps.formStart;
    }
    if (isIdentityComplete) return OnboardingSteps.formEnd;
    return OnboardingSteps.normalize(onboardingStep);
  }

  OnboardingState copyWith({
    int? onboardingStep,
    String? onboardingStatus,
    String? stripeAccountId,
    bool? stripeOnboardingComplete,
    IdentityStatus? identityStatus,
    PayoutStatus? payoutStatus,
  }) {
    return OnboardingState(
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      stripeOnboardingComplete:
          stripeOnboardingComplete ?? this.stripeOnboardingComplete,
      identityStatus: identityStatus ?? this.identityStatus,
      payoutStatus: payoutStatus ?? this.payoutStatus,
    );
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      onboardingStep: _parseInt(
        json['onboarding_step'],
        fallback: OnboardingSteps.formStart,
      ),
      onboardingStatus:
          json['onboarding_status']?.toString() ??
          OnboardingStatus.notStarted,
      stripeAccountId: json['stripe_account_id']?.toString(),
      stripeOnboardingComplete:
          json['is_stripe_onboarding_complete'] == true ||
          json['is_stripe_onboarding_complete'] == 1 ||
          json['is_stripe_onboarding_complete'] == '1',
      identityStatus: _parseIdentityStatus(json['identity_status']),
      payoutStatus: _parsePayoutStatus(json['payout_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboarding_step': onboardingStep,
      'onboarding_status': onboardingStatus,
      'stripe_account_id': stripeAccountId,
      'is_stripe_onboarding_complete': stripeOnboardingComplete,
      'identity_status': identityStatus.name,
      'payout_status': payoutStatus.name,
    };
  }

  static IdentityStatus _parseIdentityStatus(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return IdentityStatus.notStarted;
    return IdentityStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => IdentityStatus.notStarted,
    );
  }

  static PayoutStatus _parsePayoutStatus(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return PayoutStatus.notStarted;
    return PayoutStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PayoutStatus.notStarted,
    );
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }
}
