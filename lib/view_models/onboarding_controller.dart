import 'dart:convert';

import 'package:get/get.dart';
import 'package:jebby/models/onboarding_state.dart';
import 'package:jebby/models/provider_onboarding_data.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/repositories/auth_repository.dart';
import 'package:jebby/services/analytics_service.dart';
import 'package:jebby/utils/google_places_address.dart';
import 'package:jebby/view_models/user_view_model.dart';
import 'package:jebby/views/screens/onboarding/earn_intro.dart';
import 'package:jebby/views/screens/onboarding/identity_hub.dart';
import 'package:jebby/views/screens/onboarding/identity_hub_panel.dart';
import 'package:jebby/views/screens/onboarding/identity_verified.dart';
import 'package:jebby/views/screens/onboarding/payout_enabled.dart';
import 'package:jebby/views/screens/onboarding/payout_in_review.dart';
import 'package:jebby/views/screens/onboarding/payout_method.dart';
import 'package:jebby/views/screens/onboarding/verification_in_progress.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

OnboardingController ensureOnboardingController() {
  if (Get.isRegistered<OnboardingController>()) {
    return Get.find<OnboardingController>();
  }
  return Get.put(OnboardingController());
}

/// Clears in-memory onboarding state when the session ends.
void clearOnboardingControllerForLogout() {
  if (Get.isRegistered<OnboardingController>()) {
    Get.find<OnboardingController>().resetForLogout();
    Get.delete<OnboardingController>(force: true);
  }
}

class OnboardingController extends GetxController {
  static const String _keyStep = 'onboarding_step';
  static const String _keyStatus = 'onboarding_status';
  static const String _keyIdentityStatus = 'identity_status';
  static const String _keyPayoutStatus = 'payout_status';
  static const String _keyStripeAccountId = 'stripe_account_id';
  static const String _keyStripeComplete = 'is_stripe_onboarding_complete';
  static const String _keyProviderData = 'provider_onboarding_data';
  static const String _keyIntroSeen = 'onboarding_intro_seen';
  static const String _keyPayoutsEnabled = 'payouts_enabled';
  static const String _keyBankLast4 = 'bank_last4';
  static const String _keyStripeAccountStatus = 'stripe_account_status';

  OnboardingState _state = const OnboardingState();
  ProviderOnboardingData providerData = ProviderOnboardingData();
  bool _introSeen = false;
  bool get introSeen => _introSeen;
  bool isLoading = false;
  String userId = '';
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  String userAddress = '';
  String userLatitude = '';
  String userLongitude = '';
  bool payoutsEnabled = false;
  String? bankLast4;
  Map<String, dynamic>? _stripeRequirements;
  String _stripeAccountStatus = '';
  Map<String, dynamic>? _lastStripeStatusResponse;

  Map<String, dynamic>? get lastStripeStatusResponse => _lastStripeStatusResponse;

  OnboardingState get state => _state;

  void cacheStripeRequirements(dynamic requirements) {
    if (requirements is Map) {
      _stripeRequirements = Map<String, dynamic>.from(requirements);
    }
  }

  bool shouldPromptIdentityActionScreen() {
    if (_state.isIdentityComplete) return false;
    final dueKeys =
        StripeRequirementFields.collectDueKeys(_stripeRequirements);
    return StripeRequirementFields.shouldPromptIdentityAction(
      dueKeys,
      identityAlreadyVerified: _state.isIdentityComplete,
    );
  }

  bool stripeRequirementsAreBankOnly([Map<String, dynamic>? requirements]) {
    final dueKeys = StripeRequirementFields.collectDueKeys(
      requirements ?? _stripeRequirements,
    );
    return StripeRequirementFields.isBankOnlyRequirements(dueKeys);
  }

  bool stripeRequirementsAreBankOnlyInResponse(Map<String, dynamic> response) {
    final requirements =
        StripeRequirementFields.requirementsFromResponse(response);
    return stripeRequirementsAreBankOnly(requirements);
  }

  Future<void> loadAndReconcile({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    this.userId = userId;

    final prefs = await SharedPreferences.getInstance();
    userName = _resolveProfileName(name ?? prefs.getString('fullname') ?? '');
    userEmail = _resolveProfileEmail(email ?? prefs.getString('email') ?? '');
    userPhone = _sanitizePhone(phone ?? prefs.getString('phoneNumber') ?? '');
    userAddress = (prefs.getString('address') ?? '').trim();
    userLatitude = (prefs.getString('latitude') ?? '').trim();
    userLongitude = (prefs.getString('longitude') ?? '').trim();

    isLoading = true;
    update();

    await _loadFromLocalCache();
    await _loadProviderData();
    await _sanitizeLoadedProviderIdentity();
    _prefillProviderDataFromProfile();
    await prefillHomeAddressFromUserProfile();
    await _reconcileWithServer();
    await _reconcileWithStripeStatus();

    isLoading = false;
    update();
  }

  /// Ensures [userId] is set from an active login (prefs / user profile).
  Future<void> ensureUserSession({String? userIdOverride}) async {
    final override = userIdOverride?.trim() ?? '';
    if (override.isNotEmpty) {
      userId = override;
      return;
    }
    if (userId.trim().isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = (prefs.getString('id') ?? '').trim();
    if (fromPrefs.isNotEmpty) {
      userId = fromPrefs;
      if (userName.isEmpty) {
        userName = _resolveProfileName(prefs.getString('fullname') ?? '');
      }
      if (userEmail.isEmpty) {
        userEmail = _resolveProfileEmail(prefs.getString('email') ?? '');
      }
      if (userPhone.isEmpty) {
        userPhone = _sanitizePhone(prefs.getString('phoneNumber') ?? '');
      }
      return;
    }

    try {
      final user = await UserViewModel().getUser();
      final id = user.id?.toString().trim() ?? '';
      if (id.isEmpty) return;
      userId = id;
      userName = _resolveProfileName(user.name?.toString() ?? userName);
      userEmail = _resolveProfileEmail(user.email?.toString() ?? userEmail);
    } catch (_) {}
  }

  /// Reload Stripe account flags from the server (e.g. after login when prefs were cleared).
  Future<void> refreshStripeStatus() async {
    await ensureUserSession();
    if (userId.isEmpty) return;
    isLoading = true;
    update();
    await _reconcileWithStripeStatus();
    isLoading = false;
    update();
  }

  void resetForLogout() {
    userId = '';
    userName = '';
    userEmail = '';
    userPhone = '';
    userAddress = '';
    userLatitude = '';
    userLongitude = '';
    payoutsEnabled = false;
    bankLast4 = null;
    _stripeAccountStatus = '';
    _stripeRequirements = null;
    _lastStripeStatusResponse = null;
    providerData = ProviderOnboardingData();
    _state = const OnboardingState();
    _introSeen = false;
    isLoading = false;
  }

  Future<void> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '0';
    final identityVerified = prefs.getBool('is_identity_verified') ?? false;

    final rawStep = prefs.getInt(_keyStep) ?? OnboardingSteps.formStart;
    final rawStatus = prefs.getString(_keyStatus);

    final migratedStep = _normalizeStoredStep(rawStep, rawStatus);

    _state = OnboardingState(
      onboardingStep: migratedStep,
      onboardingStatus: rawStatus ??
          (identityVerified || role == '1'
              ? OnboardingStatus.complete
              : OnboardingStatus.notStarted),
      stripeAccountId: prefs.getString(_keyStripeAccountId),
      stripeOnboardingComplete: prefs.getBool(_keyStripeComplete) ?? false,
      identityStatus: _parseIdentityStatus(
        prefs.getString(_keyIdentityStatus),
        identityVerified: identityVerified,
      ),
      payoutStatus: _parsePayoutStatus(prefs.getString(_keyPayoutStatus)),
    );
    payoutsEnabled = prefs.getBool(_keyPayoutsEnabled) ?? false;
    bankLast4 = prefs.getString(_keyBankLast4);
    _stripeAccountStatus = prefs.getString(_keyStripeAccountStatus) ?? '';
    _introSeen = prefs.getBool(_keyIntroSeen) ?? false;
    if (_state.onboardingStep >= OnboardingSteps.formStart &&
        _state.onboardingStatus != OnboardingStatus.notStarted) {
      _introSeen = true;
    }

    if (migratedStep != rawStep) {
      await _persistLocal();
    }
  }

  IdentityStatus _parseIdentityStatus(String? raw, {required bool identityVerified}) {
    if (raw != null && raw.isNotEmpty) {
      return IdentityStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => IdentityStatus.notStarted,
      );
    }
    if (identityVerified) return IdentityStatus.verified;
    return IdentityStatus.notStarted;
  }

  PayoutStatus _parsePayoutStatus(String? raw) {
    if (raw == null || raw.isEmpty) return PayoutStatus.notStarted;
    return PayoutStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PayoutStatus.notStarted,
    );
  }

  int _normalizeStoredStep(int step, String? status) {
    if (status == OnboardingStatus.complete || step >= OnboardingSteps.formEnd) {
      return OnboardingSteps.formEnd;
    }
    if (status == OnboardingStatus.stripePending) {
      return step < OnboardingSteps.stepReview
          ? OnboardingSteps.stepReview
          : OnboardingSteps.normalize(step);
    }
    return OnboardingSteps.normalize(step);
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
            _state = _state.copyWith(
              onboardingStep: _normalizeStoredStep(
                _state.onboardingStep,
                _state.onboardingStatus,
              ),
            );
            _persistLocal();
          }
        },
        (_) {},
      );
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _reconcileWithStripeStatus() async {
    if (userId.isEmpty) return null;

    try {
      Map<String, dynamic>? latest;
      await ApiRepository.shared.checkStripeAccountStatus(
        userId,
        (response) {
          if (response is! Map) return;
          latest = Map<String, dynamic>.from(response);
          applyStripeAccountStatus(latest!);
        },
        (_) {},
      );
      return latest;
    } catch (_) {}
    return null;
  }

  void applyStripeAccountStatus(Map<String, dynamic> response) {
    _lastStripeStatusResponse = Map<String, dynamic>.from(response);
    final status = response['status']?.toString() ?? '';
    _stripeAccountStatus = status;
    final account = response['account'];
    final identityVerifiedFlag = response['identity_verified'] == true;
    final payoutsFullyEnabled =
        StripeRequirementFields.payoutsFullyEnabledFromResponse(response);
    final bookingsReady =
        StripeRequirementFields.payoutSetupCompleteForBookings(response);
    payoutsEnabled = bookingsReady;
    final responseLast4 = response['bank_last4']?.toString().trim();
    if (responseLast4 != null && responseLast4.isNotEmpty) {
      bankLast4 = responseLast4;
    }

    _stripeRequirements =
        StripeRequirementFields.requirementsFromResponse(response);
    final dueKeys =
        StripeRequirementFields.collectDueKeys(_stripeRequirements);

    final detailsSubmitted = account is Map
        ? (account['details_submitted'] == true)
        : (response['details_submitted'] == true);

    IdentityStatus identity = _state.identityStatus;
    PayoutStatus payout = _state.payoutStatus;
    final wasIdentityComplete = _state.isIdentityComplete;

    final identityPendingReview =
        StripeRequirementFields.isIdentityPendingReview(_stripeRequirements);

    if (identityPendingReview) {
      identity = IdentityStatus.submitted;
    } else if (identityVerifiedFlag || status == 'active' || detailsSubmitted) {
      identity = IdentityStatus.verified;
    } else if (status == 'requires_info' &&
        StripeRequirementFields.isBankOnlyRequirements(dueKeys)) {
      identity = IdentityStatus.verified;
    } else if (status == 'requires_info') {
      if (StripeRequirementFields.shouldPromptIdentityAction(
        dueKeys,
        identityAlreadyVerified: false,
      )) {
        identity = IdentityStatus.actionNeeded;
      } else {
        identity = IdentityStatus.submitted;
      }
    } else if (status == 'pending') {
      identity = IdentityStatus.submitted;
    }

    final pendingPayoutReview =
        StripeRequirementFields.isPayoutPendingReview(_stripeRequirements);
    final shouldShowInReview =
        StripeRequirementFields.shouldShowPayoutInReview(response);

    if ((payoutsFullyEnabled || bookingsReady) && !shouldShowInReview) {
      payout = PayoutStatus.enabled;
    } else if (shouldShowInReview || pendingPayoutReview) {
      payout = PayoutStatus.inReview;
      if (!bookingsReady) payoutsEnabled = false;
    } else if (status == 'requires_info' &&
        StripeRequirementFields.dueKeysNeedBank(dueKeys)) {
      payout = PayoutStatus.actionNeeded;
    } else if (status == 'requires_info' &&
        _state.payoutStatus != PayoutStatus.notStarted) {
      payout = PayoutStatus.actionNeeded;
    } else if (_state.payoutStatus == PayoutStatus.inReview &&
        !bookingsReady &&
        (shouldShowInReview ||
            pendingPayoutReview ||
            (responseLast4?.trim().isNotEmpty ?? false))) {
      payout = PayoutStatus.inReview;
      payoutsEnabled = false;
    } else if (status == 'pending' || status == 'in_review') {
      payout = PayoutStatus.inReview;
      if (!bookingsReady) payoutsEnabled = false;
    } else if (_state.payoutStatus == PayoutStatus.inReview) {
      payout = StripeRequirementFields.dueKeysNeedBank(dueKeys)
          ? PayoutStatus.actionNeeded
          : PayoutStatus.notStarted;
    }

    final accountId = account is Map
        ? account['id']?.toString()
        : response['account_id']?.toString();

    final identityComplete = identity == IdentityStatus.verified;

    _state = _state.copyWith(
      stripeAccountId: accountId ?? _state.stripeAccountId,
      identityStatus: identity,
      payoutStatus: payout,
      onboardingStep: identityComplete ? OnboardingSteps.formEnd : _state.onboardingStep,
      onboardingStatus: identityComplete
          ? OnboardingStatus.complete
          : identity == IdentityStatus.submitted
              ? OnboardingStatus.stripePending
              : _state.onboardingStatus,
      stripeOnboardingComplete: identityComplete,
    );

    _persistLocal(setIdentityVerified: identityComplete);
    if (identityComplete && !wasIdentityComplete) {
      completeProviderRole(skipMarkComplete: true);
    }
    update();
  }

  OnboardingState _mergeStates(OnboardingState local, OnboardingState server) {
    if (server.isIdentityComplete) return server;
    if (local.isIdentityComplete) return local;
    if (server.onboardingStep > local.onboardingStep) return server;
    if (local.onboardingStep > server.onboardingStep) return local;
    return server;
  }

  Future<void> advanceTo(int step) async {
    String status;
    IdentityStatus identity = _state.identityStatus;

    if (step >= OnboardingSteps.formEnd) {
      status = OnboardingStatus.complete;
    } else if (_state.onboardingStatus == OnboardingStatus.stripePending ||
        identity == IdentityStatus.submitted) {
      status = OnboardingStatus.stripePending;
    } else {
      status = OnboardingStatus.inProgress;
      if (identity == IdentityStatus.notStarted) {
        identity = IdentityStatus.inProgress;
      }
    }

    _state = _state.copyWith(
      onboardingStep: step,
      onboardingStatus: status,
      identityStatus: identity,
    );

    await _persistLocal();
    _syncToServer();

    if (step >= OnboardingSteps.formStart && step <= OnboardingSteps.formEnd) {
      AnalyticsService.instance.track(
        'stripe_onboarding_step_completed',
        props: {'step': step},
      );
    }

    update();
  }

  Future<void> markIdentitySubmitted({String? accountId}) async {
    _state = _state.copyWith(
      onboardingStep: OnboardingSteps.stepIdentityOutcome,
      onboardingStatus: OnboardingStatus.stripePending,
      identityStatus: IdentityStatus.submitted,
      stripeAccountId: accountId ?? _state.stripeAccountId,
    );
    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> markIdentityActionNeeded({String? accountId}) async {
    _state = _state.copyWith(
      onboardingStep: OnboardingSteps.stepIdentityOutcome,
      onboardingStatus: OnboardingStatus.inProgress,
      identityStatus: IdentityStatus.actionNeeded,
      stripeAccountId: accountId ?? _state.stripeAccountId,
    );
    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> markIdentityVerified({String? accountId}) async {
    _state = _state.copyWith(
      onboardingStep: OnboardingSteps.formEnd,
      onboardingStatus: OnboardingStatus.complete,
      identityStatus: IdentityStatus.verified,
      stripeOnboardingComplete: true,
      stripeAccountId: accountId ?? _state.stripeAccountId,
    );
    await _persistLocal(setIdentityVerified: true);
    _syncToServer();
    await completeProviderRole(skipMarkComplete: true);
    update();
  }

  /// Legacy name from pre-redesign identity submit flow.
  Future<void> markComplete({String? accountId}) =>
      markIdentityVerified(accountId: accountId);

  Future<void> markPayoutInReview({String? last4}) async {
    _state = _state.copyWith(payoutStatus: PayoutStatus.inReview);
    if (last4 != null) bankLast4 = last4;
    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> markPayoutEnabled({String? last4}) async {
    payoutsEnabled = true;
    if (last4 != null) bankLast4 = last4;
    _state = _state.copyWith(payoutStatus: PayoutStatus.enabled);
    await _persistLocal();
    _syncToServer();
    update();
  }

  Future<void> updateProviderData(ProviderOnboardingData data) async {
    providerData = data;
    await _persistProviderData();
    update();
  }

  Future<void> _loadProviderData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProviderData);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        final previousSsn = providerData.ssnLast4;
        providerData = ProviderOnboardingData.fromPersistedJson(map);
        final loadedSsn = providerData.ssnLast4;
        if ((loadedSsn == null || loadedSsn.isEmpty) &&
            previousSsn != null &&
            previousSsn.isNotEmpty) {
          providerData.ssnLast4 = previousSsn;
        }
      }
    } catch (_) {}
  }

  Future<void> _persistProviderData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyProviderData,
      jsonEncode(providerData.toPersistedJson()),
    );
  }

  Future<void> _sanitizeLoadedProviderIdentity() async {
    var changed = false;
    if (_isPlaceholderName(providerData.firstName)) {
      providerData.firstName = '';
      changed = true;
    }
    if (!_isValidStoredPhone(providerData.phone)) {
      providerData.phone = '';
      changed = true;
    }
    if (changed) {
      await _persistProviderData();
    }
  }

  void _prefillProviderDataFromProfile() {
    if (providerData.firstName.isEmpty && userName.isNotEmpty) {
      final parts = userName.trim().split(RegExp(r'\s+'));
      providerData.firstName = parts.first;
      if (parts.length > 1) {
        providerData.lastName = parts.sublist(1).join(' ');
      }
    }
    if (providerData.email.isEmpty && userEmail.isNotEmpty) {
      providerData.email = userEmail;
    }
    if (providerData.phone.isEmpty && userPhone.isNotEmpty) {
      providerData.phone = userPhone;
    }
    if (providerData.accountHolderName.isEmpty) {
      if (providerData.legalFullName.isNotEmpty) {
        providerData.accountHolderName = providerData.legalFullName;
      } else if (userName.trim().isNotEmpty) {
        providerData.accountHolderName = userName.trim();
      }
    }
  }

  String resolvedAccountHolderNameSync() {
    _prefillProviderDataFromProfile();
    if (providerData.accountHolderName.trim().isNotEmpty) {
      return providerData.accountHolderName.trim();
    }
    if (providerData.legalFullName.isNotEmpty) {
      return providerData.legalFullName;
    }
    return userName.trim();
  }

  Future<String> resolveAccountHolderNameAsync() async {
    if (userName.trim().isEmpty || userEmail.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      if (userName.trim().isEmpty) {
        userName = _resolveProfileName(prefs.getString('fullname') ?? '');
      }
      if (userEmail.isEmpty) {
        userEmail = _resolveProfileEmail(prefs.getString('email') ?? '');
      }
    }
    _prefillProviderDataFromProfile();
    final resolved = resolvedAccountHolderNameSync();
    if (resolved.isNotEmpty &&
        providerData.accountHolderName.trim().isEmpty) {
      providerData = providerData.copyWith(accountHolderName: resolved);
    }
    return resolved;
  }

  bool get _providerHomeAddressIncomplete =>
      providerData.addressLine1.trim().isEmpty ||
      providerData.addressCity.trim().isEmpty ||
      !ProviderOnboardingData.isValidUsStateCode(providerData.addressState) ||
      !ProviderOnboardingData.isValidUsPostalCode(
        providerData.addressPostalCode,
      );

  /// Fills onboarding address fields from the user's saved profile address.
  Future<void> prefillHomeAddressFromUserProfile({bool persist = true}) async {
    if (!_providerHomeAddressIncomplete) return;

    final prefs = await SharedPreferences.getInstance();
    var profileAddress = userAddress;
    if (profileAddress.isEmpty) {
      profileAddress = (prefs.getString('address') ?? '').trim();
    }
    var latText = userLatitude;
    var lngText = userLongitude;
    if (latText.isEmpty) latText = (prefs.getString('latitude') ?? '').trim();
    if (lngText.isEmpty) lngText = (prefs.getString('longitude') ?? '').trim();

    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);

    ParsedUsAddress? parsed;
    final places = GooglePlacesAddressService();

    if (lat != null && lng != null) {
      parsed = await places.reverseGeocode(lat, lng);
    }
    if ((parsed == null || !parsed.hasLine1) && profileAddress.isNotEmpty) {
      parsed = await places.geocodeAddress(profileAddress);
    }

    if (parsed == null || !parsed.hasLine1) return;

    providerData = providerData.copyWith(
      addressLine1: parsed.line1,
      addressCity: parsed.city.isNotEmpty
          ? parsed.city
          : providerData.addressCity,
      addressState: parsed.hasState
          ? parsed.state
          : providerData.addressState,
      addressPostalCode: parsed.hasPostalCode
          ? parsed.postalCode
          : providerData.addressPostalCode,
      country: 'US',
    );

    if (persist) {
      await _persistProviderData();
    }
    update();
  }

  Future<void> clearSensitiveProviderData() async {
    providerData.clearSensitiveFields();
    await _persistProviderData();
    update();
  }

  Future<void> markIntroSeen() async {
    _introSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIntroSeen, true);
    update();
  }

  void navigateToIntroFlow() {
    Get.to(() => const EarnIntroScreen());
  }

  void navigateToIdentityHub() {
    Get.to(() => const IdentityHubScreen());
  }

  void navigateToReview() {
    Get.to(() => const IdentityHubScreen(initialPanel: IdentityHubPanel.review));
  }

  void navigateToPayoutMethod({bool fromTransactions = false}) {
    Get.to(() => PayoutMethodScreen(fromTransactions: fromTransactions));
  }

  void navigateAfterIdentitySubmit(
    String status, {
    Map<String, dynamic>? response,
  }) {
    if (response != null) {
      cacheStripeRequirements(
        StripeRequirementFields.requirementsFromResponse(response) ??
            response['requirements'],
      );

      final requirements =
          StripeRequirementFields.requirementsFromResponse(response);
      if (StripeRequirementFields.isIdentityPendingReview(requirements)) {
        Get.off(() => const VerificationInProgressScreen());
        return;
      }
      if (StripeRequirementFields.identityClearedForNextStep(response)) {
        Get.off(() => const IdentityVerifiedScreen());
        return;
      }
    }

    switch (status) {
      case 'active':
        Get.off(() => const IdentityVerifiedScreen());
        break;
      case 'requires_info':
        if (shouldPromptIdentityActionScreen()) {
          Get.off(() => const IdentityHubScreen());
        } else if (stripeRequirementsAreBankOnly()) {
          Get.off(() => const IdentityVerifiedScreen());
        } else {
          Get.off(() => const VerificationInProgressScreen());
        }
        break;
      case 'pending':
      default:
        Get.off(() => const VerificationInProgressScreen());
    }
  }

  Future<void> submitBankAccountToStripe() async {
    await ensureUserSession();
    if (userId.trim().isEmpty) {
      throw StateError('User session not found. Please sign in again.');
    }
    if (!providerData.hasBankDetails) {
      throw StateError('Add your bank details before continuing.');
    }

    final response = await ApiRepository.shared.submitProviderBankAccountFuture(
      body: providerData.toBankSubmitJson(userId: userId),
    );

    cacheStripeRequirements(
      StripeRequirementFields.requirementsFromResponse(response),
    );

    final account = providerData.accountNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = response['bank_last4']?.toString() ??
        (account.length >= 4 ? account.substring(account.length - 4) : null);

    final statusMap =
        await _reconcileWithStripeStatus() ?? Map<String, dynamic>.from(response);

    if (StripeRequirementFields.showPayoutEnabledAfterBankSubmit(statusMap)) {
      await markPayoutEnabled(last4: last4);
    } else {
      await markPayoutInReview(last4: last4);
    }

    navigateAfterBankSubmit(statusMap);
  }

  void navigateAfterBankSubmit(Map<String, dynamic> response) {
    if (StripeRequirementFields.showPayoutEnabledAfterBankSubmit(response)) {
      Get.off(() => const PayoutEnabledScreen());
      return;
    }

    final status = response['status']?.toString().trim() ?? 'in_review';
    if (status == 'requires_info') {
      Get.off(
        () => const PayoutMethodScreen(
          fromTransactions: true,
          stripeVerificationNeeded: true,
        ),
      );
      return;
    }

    Get.off(() => const PayoutInReviewScreen());
  }

  void navigateToStep(int step) {
    switch (OnboardingSteps.normalize(step)) {
      case OnboardingSteps.stepPersonal:
      case OnboardingSteps.stepIdentityDocs:
        navigateToIdentityHub();
        break;
      case OnboardingSteps.stepReview:
        navigateToReview();
        break;
      case OnboardingSteps.stepIdentityOutcome:
        if (_state.identityStatus == IdentityStatus.verified) {
          Get.to(() => const IdentityVerifiedScreen());
        } else if (_state.identityStatus == IdentityStatus.actionNeeded &&
            shouldPromptIdentityActionScreen()) {
          navigateToIdentityHub();
        } else if (_state.identityStatus == IdentityStatus.submitted ||
            _state.identityStatus == IdentityStatus.actionNeeded) {
          Get.to(() => const VerificationInProgressScreen());
        } else {
          navigateToIdentityHub();
        }
        break;
      default:
        navigateToIdentityHub();
    }
  }

  Future<void> startOrResume() async {
    if (_state.isIdentityComplete) return;

    if (_state.onboardingStatus == OnboardingStatus.notStarted &&
        _state.identityStatus == IdentityStatus.notStarted) {
      if (!_introSeen) {
        navigateToIntroFlow();
        return;
      }
      await advanceTo(OnboardingSteps.stepPersonal);
      AnalyticsService.instance.track('stripe_onboarding_started');
      navigateToIdentityHub();
      return;
    }

    navigateToStep(_state.resumeStep);
  }

  /// Returns a user-facing message when publish must be blocked, or null if allowed.
  Future<String?> publishListingBlockedMessage({String? forUserId}) async {
    final uid = (forUserId ?? userId).trim();
    if (uid.isNotEmpty) {
      userId = uid;
      await _reconcileWithStripeStatus();
    }

    if (!payoutsEnabled) {
      return 'Add a bank account in Transactions before you can publish a listing.';
    }

    final status = _stripeAccountStatus.trim().toLowerCase();
    if (status == 'pending') {
      return 'Stripe is still reviewing your payout setup. Try again once review is complete.';
    }

    return null;
  }

  Future<void> completeProviderRole({bool skipMarkComplete = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final email =
        userEmail.isNotEmpty ? userEmail : (prefs.getString('email') ?? '');

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

    final ctx = Get.context;
    if (ctx != null) {
      ctx.read<UserViewModel>().setRole('1');
    }

    if (!skipMarkComplete) {
      await markIdentityVerified();
    }
  }

  Future<bool> isStripeIdentityVerified() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('stripe_verification_status') ?? '';
    return status == 'verified' ||
        (prefs.getBool('is_identity_verified') ?? false);
  }

  Future<void> _persistLocal({bool setIdentityVerified = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStep, _state.onboardingStep);
    await prefs.setString(_keyStatus, _state.onboardingStatus);
    await prefs.setString(_keyIdentityStatus, _state.identityStatus.name);
    await prefs.setString(_keyPayoutStatus, _state.payoutStatus.name);
    if (_state.stripeAccountId != null) {
      await prefs.setString(_keyStripeAccountId, _state.stripeAccountId!);
    }
    await prefs.setBool(_keyStripeComplete, _state.stripeOnboardingComplete);
    await prefs.setBool(_keyPayoutsEnabled, payoutsEnabled);
    if (_stripeAccountStatus.isNotEmpty) {
      await prefs.setString(_keyStripeAccountStatus, _stripeAccountStatus);
    }
    if (bankLast4 != null) {
      await prefs.setString(_keyBankLast4, bankLast4!);
    }
    if (setIdentityVerified || _state.isIdentityComplete) {
      await prefs.setBool('is_identity_verified', true);
      await prefs.setString('stripe_verification_status', 'verified');
    }
  }

  String _resolveProfileName(String value) {
    final trimmed = value.trim();
    if (_isPlaceholderName(trimmed)) return '';
    return trimmed;
  }

  String _resolveProfileEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
    return trimmed;
  }

  bool _isPlaceholderName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'guest' ||
        normalized == 'null';
  }

  bool _isValidStoredPhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return ProviderOnboardingData.isValidUsPhone(trimmed);
  }

  String _sanitizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final formatted = ProviderOnboardingData.formatPhoneE164(trimmed);
    if (!_isValidStoredPhone(formatted)) return '';
    return formatted;
  }

  void _syncToServer() {
    if (userId.isEmpty) return;

    ApiRepository.shared.updateOnboardingState(
      {
        'user_id': userId,
        'onboarding_step': _state.onboardingStep,
        'onboarding_status': _state.onboardingStatus,
        'identity_status': _state.identityStatus.name,
        'payout_status': _state.payoutStatus.name,
        if (_state.stripeAccountId != null)
          'stripe_account_id': _state.stripeAccountId,
        'is_stripe_onboarding_complete': _state.stripeOnboardingComplete,
      },
      (_) {},
      (_) {},
    );
  }
}
