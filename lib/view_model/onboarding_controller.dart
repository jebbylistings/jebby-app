import 'package:get/get.dart';
import 'package:jebby/Views/screens/onboarding/all_set.dart';
import 'package:jebby/Views/screens/onboarding/before_you_continue.dart';
import 'package:jebby/Views/screens/onboarding/start_earning_intro.dart';
import 'package:jebby/Views/screens/onboarding/stripe_identity_screen.dart';
import 'package:jebby/Views/screens/onboarding/stripe_welcome.dart';
import 'package:jebby/Views/screens/onboarding/what_youll_need.dart';
import 'package:jebby/model/onboarding_state.dart';
import 'package:jebby/respository/auth_repository.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

OnboardingController ensureOnboardingController() {
  if (Get.isRegistered<OnboardingController>()) {
    return Get.find<OnboardingController>();
  }
  return Get.put(OnboardingController());
}

class OnboardingController extends GetxController {
  static const String _keyStep = 'onboarding_step';
  static const String _keyStatus = 'onboarding_status';
  static const String _keyStripeAccountId = 'stripe_account_id';
  static const String _keyStripeComplete = 'stripe_onboarding_complete';

  OnboardingState _state = const OnboardingState();
  bool isLoading = false;
  String userId = '';
  String userName = '';
  String userEmail = '';
  String userPhone = '';

  OnboardingState get state => _state;

  Future<void> loadAndReconcile({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    this.userId = userId;
    if (name != null && name.isNotEmpty) userName = name;
    if (email != null && email.isNotEmpty) userEmail = email;
    if (phone != null && phone.isNotEmpty) userPhone = _sanitizePhone(phone);

    final prefs = await SharedPreferences.getInstance();
    if (userPhone.isEmpty) {
      userPhone = _sanitizePhone(prefs.getString('phoneNumber') ?? '');
    }

    isLoading = true;
    update();

    await _loadFromLocalCache();
    await _reconcileWithServer();
    await _reconcileWithStripeStatus();

    isLoading = false;
    update();
  }

  Future<void> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '0';
    final identityVerified = prefs.getBool('identity_verified') ?? false;

    final rawStep = prefs.getInt(_keyStep) ?? 1;
    final rawStatus = prefs.getString(_keyStatus);

    final migratedStep = _migrateLegacyStep(rawStep, rawStatus);

    _state = OnboardingState(
      onboardingStep: migratedStep,
      onboardingStatus:
          rawStatus ??
          (identityVerified || role == '1'
              ? OnboardingStatus.complete
              : OnboardingStatus.notStarted),
      stripeAccountId: prefs.getString(_keyStripeAccountId),
      stripeOnboardingComplete: prefs.getBool(_keyStripeComplete) ?? false,
    );

    if (migratedStep != rawStep) {
      await _persistLocal();
    }
  }

  /// Older builds stored the intro as step 2 (drawer was step 1).
  int _migrateLegacyStep(int step, String? status) {
    if (status == OnboardingStatus.complete || step >= 10) return step;
    if (status == OnboardingStatus.stripePending) return step;
    if (step >= 2 && step <= 5) return step - 1;
    return step;
  }

  Future<void> _reconcileWithServer() async {
    if (userId.isEmpty) return;

    try {
      await ApiRepository.shared.getOnboardingState(
        userId,
        (data) {
          if (data is Map<String, dynamic> && data.isNotEmpty) {
            final serverState = OnboardingState.fromJson(data);
            _state = _mergeStates(_state, serverState);
            _persistLocal();
          }
        },
        (_) {},
      );
    } catch (_) {}
  }

  Future<void> _reconcileWithStripeStatus() async {
    if (userId.isEmpty) return;

    try {
      await ApiRepository.shared.checkStripeAccountStatus(
        userId,
        (response) {
          if (response is! Map) return;

          final status = response['status']?.toString() ?? '';
          final account = response['account'];
          final detailsSubmitted = account is Map
              ? (account['details_submitted'] == true)
              : (response['details_submitted'] == true);
          final isActive = status == 'active' || detailsSubmitted;

          if (isActive) {
            final accountId = account is Map
                ? account['id']?.toString()
                : response['account_id']?.toString();

            _state = _state.copyWith(
              onboardingStep: 10,
              onboardingStatus: OnboardingStatus.complete,
              stripeOnboardingComplete: true,
              stripeAccountId: accountId ?? _state.stripeAccountId,
            );
            _persistLocal(setIdentityVerified: true);
          } else if (_state.onboardingStatus == OnboardingStatus.stripePending) {
            _state = _state.copyWith(
              onboardingStep:
                  _state.onboardingStep < 5 ? 5 : _state.onboardingStep,
            );
            _persistLocal();
          }
        },
        (_) {},
      );
    } catch (_) {}
  }

  OnboardingState _mergeStates(
    OnboardingState local,
    OnboardingState server,
  ) {
    if (server.isComplete) return server;
    if (local.isComplete) return local;
    if (server.onboardingStep > local.onboardingStep) return server;
    if (local.onboardingStep > server.onboardingStep) return local;
    return server;
  }

  Future<void> advanceTo(int step) async {
    String status;
    if (step >= 10) {
      status = OnboardingStatus.complete;
    } else if (_state.onboardingStatus == OnboardingStatus.stripePending) {
      status = OnboardingStatus.stripePending;
    } else {
      status = OnboardingStatus.inProgress;
    }

    _state = _state.copyWith(
      onboardingStep: step,
      onboardingStatus: status,
    );

    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> markStripePending({String? accountId}) async {
    _state = _state.copyWith(
      onboardingStep: 5, // Stripe Connect welcome / hosted flow
      onboardingStatus: OnboardingStatus.stripePending,
      stripeAccountId: accountId ?? _state.stripeAccountId,
    );
    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> markComplete({String? accountId}) async {
    _state = _state.copyWith(
      onboardingStep: 10,
      onboardingStatus: OnboardingStatus.complete,
      stripeOnboardingComplete: true,
      stripeAccountId: accountId ?? _state.stripeAccountId,
    );
    await _persistLocal(setIdentityVerified: true);
    _syncToServer();
    update();
  }

  Future<void> completeProviderRole() async {
    final prefs = await SharedPreferences.getInstance();
    final email = userEmail.isNotEmpty
        ? userEmail
        : (prefs.getString('email') ?? '');

    try {
      final response = await AuthRepository().updateRoleApi({
        'role': '1',
        'email': email,
      });
      if (response['status'] == 200) {
        await prefs.setString('role', '1');
      }
    } catch (_) {
      await prefs.setString('role', '1');
    }

    await markComplete();
  }

  void navigateToStep(int step) {
    switch (step) {
      case 1:
        Get.to(() => const StartEarningIntroScreen());
        break;
      case 2:
        Get.to(() => const WhatYoullNeedScreen());
        break;
      case 3:
        Get.to(() => const StripeIdentityScreen());
        break;
      case 4:
        Get.to(() => const BeforeYouContinueScreen());
        break;
      case 5:
        Get.to(() => const StripeWelcomeScreen());
        break;
      case 10:
        Get.to(() => const AllSetScreen());
        break;
      default:
        if (step >= 5 && step < 10) {
          Get.to(() => const StripeWelcomeScreen());
        } else {
          Get.to(() => const StartEarningIntroScreen());
        }
    }
  }

  Future<void> startOrResume() async {
    if (_state.isComplete) return;

    if (_state.onboardingStatus == OnboardingStatus.notStarted) {
      await advanceTo(1);
      navigateToStep(1);
      return;
    }

    final resumeStep = _state.resumeStep;
    if (!await isStripeIdentityVerified() && resumeStep >= 4) {
      navigateToStep(3);
      return;
    }
    navigateToStep(resumeStep);
  }

  Future<void> resumeFromStep(int step) async {
    await advanceTo(step);
    navigateToStep(step);
  }

  Future<bool> isStripeIdentityVerified() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('stripe_verification_status') ?? '';
    return status == 'verified';
  }

  Future<void> _persistLocal({bool setIdentityVerified = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStep, _state.onboardingStep);
    await prefs.setString(_keyStatus, _state.onboardingStatus);
    if (_state.stripeAccountId != null) {
      await prefs.setString(_keyStripeAccountId, _state.stripeAccountId!);
    }
    await prefs.setBool(_keyStripeComplete, _state.stripeOnboardingComplete);
    if (setIdentityVerified || _state.isComplete) {
      await prefs.setBool('identity_verified', true);
      await prefs.setString('stripe_verification_status', 'verified');
    }
  }

  String _sanitizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') return '';
    return _toE164(trimmed);
  }

  /// Stripe requires E.164 format (e.g. +14155552671).
  String _toE164(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (phone.startsWith('+')) return '+$digits';
    if (digits.length == 10) return '+1$digits';
    if (digits.length == 11 && digits.startsWith('1')) return '+$digits';
    return '+$digits';
  }

  void _syncToServer() {
    if (userId.isEmpty) return;

    ApiRepository.shared.updateOnboardingState(
      {
        'user_id': userId,
        'onboarding_step': _state.onboardingStep,
        'onboarding_status': _state.onboardingStatus,
        if (_state.stripeAccountId != null)
          'stripe_account_id': _state.stripeAccountId,
        'stripe_onboarding_complete': _state.stripeOnboardingComplete,
      },
      (_) {},
      (_) {},
    );
  }
}
