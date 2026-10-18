import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/constants/app_preferences.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/views/screens/agreements/about_app.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/screens/profile/edit_profile.dart';
import 'package:jebby/views/screens/support/contact_support.dart';
import 'package:jebby/views/screens/support/faqs.dart';
import 'package:jebby/views/screens/support/provide_feedback.dart';
import 'package:jebby/views/widgets/earn_member_banner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/provider/sign_in_provider.dart';
import '../../../models/user_model.dart';
import '../../../view_models/user_view_model.dart';
import '../agreements/terms_and_conditions.dart';

class SettingsScreen extends StatefulWidget {
  /// When true (drawer push), shows a back button. Null/false for bottom nav tab.
  final bool? showBackButton;

  const SettingsScreen({Key? key, this.showBackButton}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _verifiedGreen = Color(0xFF16A34A);
  static const Color _verifiedBadgeBg = Color(0xFFDCFCE7);

  TextStyle _nunito({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.jebbyTextPrimary,
      height: height,
    );
  }

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  bool _identityVerified = false;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  Future getProductsApi(id) async {
    try {
      final row = await ApiRepository.shared.fetchUserProfileRow(id.toString());
      if (row == null) {
        if (mounted) setState(() => isLoadingImage = false);
        return null;
      }

      if (mounted) {
        setState(() {
          datalength = 1;
          imagesapi = ProfileImage.sanitizePath(
            row['profile_image']?.toString(),
          );
          nameapi = row['name']?.toString() ?? '';
          emailapi = row['email']?.toString() ?? '';
          addressapi = row['address']?.toString().trim() ?? '';
          isLoadingImage = false;
        });
      }
      return {
        'data': [row],
      };
    } catch (error) {
      if (mounted) setState(() => isLoadingImage = false);
      return "No data";
    }
  }

  var imagesapi = "";
  var nameapi = "null";
  var emailapi = "user email";
  var addressapi = "";
  var datalength;
  bool isLoadingImage = true;

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  String Url = AppUrl.baseUrlM;

  Future<void> _openEditProfile() async {
    final updated = await Get.to(() => const EditProfileScreen());
    if (updated != true || !mounted) return;

    await context.read<UserViewModel>().getUpdatedUser();
    if (id != null) {
      await getProductsApi(id);
    }
    if (mounted) setState(() {});
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          getProductsApi(id);
          role = value.role.toString();

          final usp = context.read<UserViewModel>();
          if (usp.role != value.role.toString()) {
            usp.setRole(value.role.toString());
          }
          await usp.getUser();

          await _loadVerificationStatus();

          if (mounted) {
            setState(() {});
          }
        })
        .onError((error, stackTrace) {});
  }

  Future<void> _loadVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var verified = prefs.getBool('is_identity_verified') ?? false;

    final controller = ensureOnboardingController();
    if (controller.userId.isEmpty && id != null && id!.isNotEmpty) {
      await controller.loadAndReconcile(
        userId: id!,
        name: fullname,
        email: email,
        phone: prefs.getString('phoneNumber'),
      );
    }
    if (await controller.isStripeIdentityVerified()) {
      verified = true;
    }

    if (mounted) {
      setState(() => _identityVerified = verified);
    }
  }

  @override
  void initState() {
    super.initState();
    ensureOnboardingController();
    getData();
    profileData(context);
  }

  String getText(usp, sp) {
    final uspName = usp.name?.toString().trim() ?? '';
    if (uspName.isNotEmpty) {
      return uspName;
    }
    final spName = sp.name?.toString().trim() ?? '';
    if (spName.isNotEmpty) {
      return spName;
    }
    final phone = sp.phoneNumber?.toString().trim() ?? '';
    if (phone.isNotEmpty) {
      return phone;
    }
    return "user name";
  }

  String _getLocationText(usp) {
    final fromProfile = usp.address?.toString().trim() ?? '';
    final raw = fromProfile.isNotEmpty ? fromProfile : addressapi.trim();
    if (raw.isEmpty || raw == 'null') return '';
    return PublicLocation.cityStateLine(raw) ?? '';
  }

  void _openChangePassword(usp) {
    if (context.read<AuthViewModel>().signUpLoading) return;

    if (UserViewModel.isSocialAuthSource(usp.source)) {
      showAppSnackbar(
        'Change Password',
        UserViewModel.socialAuthPasswordMessage(usp.source),
      );
      return;
    }

    final ue = usp.email.toString().trim();
    String? pwdEmail;
    if (ue.isNotEmpty) {
      pwdEmail = ue;
    } else if (emailapi != 'user email' && emailapi.trim().isNotEmpty) {
      pwdEmail = emailapi.trim();
    }
    if (pwdEmail == null || pwdEmail.isEmpty) {
      showAppSnackbar(
        'Change Password',
        'Add or fix your email in Edit Profile before changing password.',
      );
      return;
    }
    context.read<AuthViewModel>().forgetPasswordApi(
      {'email': pwdEmail},
      context,
      'forgot',
    );
  }

  void _openVerification() {
    if (_identityVerified) return;
    final controller = ensureOnboardingController();
    controller.startOrResume();
  }

  Future<void> _signOut(SignInProvider sp) async {
    try {
      clearOnboardingControllerForLogout();
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setBool('time', false);
      final userPreference = context.read<UserViewModel>();
      final authViewModel = context.read<AuthViewModel>();
      await userPreference.remove();
      authViewModel.userName = '';
      await sharedPreferences.clear();
      await AppPreferences.restoreRenterGetStartedFlag();
      try {
        await sp.userSignOut();
      } catch (_) {
        try {
          await sp.clearStoredData();
        } catch (_) {}
      }
    } catch (_) {
      // Still navigate to login even if cleanup partially fails.
    } finally {
      notiTimer().cancelTimer();
      if (!mounted) return;
      Get.offAll(() => const LoginScreen());
    }
  }

  Widget _settingsSheetRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.jebbySoftBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: _nunito(size: 16, weight: FontWeight.w800),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLegalAndPolicies() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  'Legal & Policies',
                  style: _nunito(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              _settingsSheetRow(
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.to(() => TermsAndConditionsScreen());
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: _cardBorder,
              ),
              _settingsSheetRow(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.to(() => PrivacyPolicyScreen());
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openHelpAndSupport() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  'Help & Support',
                  style: _nunito(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              _settingsSheetRow(
                icon: Icons.headset_mic_outlined,
                label: 'Contact Support',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.to(() => ContactSupportScreen());
                },
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: _cardBorder,
              ),
              _settingsSheetRow(
                icon: Icons.menu_book_outlined,
                label: 'FAQs',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.to(() => const FaqsScreen());
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAccountDeletionRequest(usp, sp) async {
    if (context.read<AuthViewModel>().accountDeletionLoading) return;

    final userRole = usp.role?.toString() ?? role ?? '';
    if (userRole == 'Guest') {
      showAppSnackbar(
        'Account Deletion',
        'Please sign in to request account deletion.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final contactNumber =
        (usp.phoneNumber?.toString().trim().isNotEmpty == true
                ? usp.phoneNumber.toString()
                : prefs.getString('phoneNumber'))
            ?.trim() ??
        '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Request account deletion?',
            style: _nunito(size: 18, weight: FontWeight.w700),
          ),
          content: Text(
            'This submits a request for our team to review. Your account is not deleted immediately.',
            style: _nunito(
              size: 14,
              weight: FontWeight.w400,
              color: AppColors.jebbyTextMuted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: _nunito(
                  weight: FontWeight.w600,
                  size: 14,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Submit request',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthViewModel>().requestAccountDeletion(
      context: context,
      contactNumber: contactNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();
    final auth = context.watch<AuthViewModel>();
    final isProvider = usp.role == "1" || role == "1";
    final isSocialAccount = UserViewModel.isSocialAuthSource(usp.source);
    final showBack = widget.showBackButton ?? false;
    // Tab: body already sits above [MainScreen] bottom nav — only end inset.
    // Pushed (back): extra room above home indicator when not in tab shell.
    final scrollBottomPadding = showBack
        ? 24 + MediaQuery.paddingOf(context).bottom
        : 16.0;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _pageHeader(showBack: showBack, isProvider: isProvider),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, scrollBottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(usp, sp),
                    const SizedBox(height: 24),
                    if (!isProvider) _buildEarnMemberBanner(),
                    if (!isProvider) const SizedBox(height: 24),
                    _buildSettingsCard(
                      sectionTitle: 'ACCOUNT',
                      items: [
                        _SettingsTileData(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profile',
                          subtitle: 'Update your personal info',
                          onTap: _openEditProfile,
                        ),
                        if (!isSocialAccount)
                          _SettingsTileData(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            subtitle: 'Update your account password',
                            isLoading: auth.signUpLoading,
                            onTap: () => _openChangePassword(usp),
                          ),
                        _SettingsTileData(
                          icon: Icons.verified_user_outlined,
                          label: 'Identity Verification',
                          subtitle: 'Verify your identity',
                          trailingLabel: _identityVerified ? 'Verified' : null,
                          trailingLabelColor: _verifiedGreen,
                          trailingBadgeStyle: _identityVerified,
                          onTap: _openVerification,
                        ),
                        if (usp.role != 'Guest' && role != 'Guest')
                          _SettingsTileData(
                            icon: Icons.delete_outline_rounded,
                            label: 'Account Deletion',
                            subtitle: 'Permanently delete your account',
                            isLoading: auth.accountDeletionLoading,
                            onTap: () => _openAccountDeletionRequest(usp, sp),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      sectionTitle: 'SUPPORT & INFO',
                      items: [
                        _SettingsTileData(
                          icon: Icons.headset_mic_outlined,
                          label: 'Help & Support',
                          onTap: _openHelpAndSupport,
                        ),
                        _SettingsTileData(
                          icon: Icons.rate_review_outlined,
                          label: 'Send Feedback',
                          onTap: () => Get.to(() => const ProvideFeedbackScreen()),
                        ),
                        _SettingsTileData(
                          icon: Icons.info_outline_rounded,
                          label: 'About App',
                          onTap: () => Get.to(() => const AboutAppScreen()),
                        ),
                        _SettingsTileData(
                          icon: Icons.gavel_outlined,
                          label: 'Legal & Policies',
                          onTap: _openLegalAndPolicies,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => _signOut(sp),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.jebbyBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 22),
                        label: Text(
                          'Sign Out',
                          style: _nunito(
                            size: 16,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageHeader({required bool showBack, required bool isProvider}) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: _nunito(
            size: 22,
            weight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isProvider
              ? 'Manage your account and business.'
              : 'Manage your account and preferences.',
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
      ],
    );

    if (!showBack) return titleColumn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: titleColumn,
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleBack,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const double _settingsAvatarRadius = 44;
  static const double _settingsAvatarRingWidth = 3.5;
  static const double _profileLocationMaxWidth = 300;

  Widget _buildProfileHeader(usp, sp) {
    final displayName = getText(usp, sp);
    final locationLine = _getLocationText(usp);
    final outerSize = (_settingsAvatarRadius + _settingsAvatarRingWidth) * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: outerSize,
            height: outerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.jebbyBlue,
            ),
            padding: const EdgeInsets.all(_settingsAvatarRingWidth),
            child: ClipOval(
              child: ProfileImage.circularAvatar(
                radius: _settingsAvatarRadius,
                baseUrl: Url,
                imagePath:
                    ProfileImage.isValidPath(usp.profileImage)
                        ? usp.profileImage!
                        : imagesapi,
                isLoading:
                    isLoadingImage &&
                    !ProfileImage.isValidPath(usp.profileImage),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          displayName,
          style: _nunito(size: 22, weight: FontWeight.w800),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        if (locationLine.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.min(
                  _profileLocationMaxWidth,
                  MediaQuery.sizeOf(context).width - 40,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                  children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.jebbyBlue,
                        ),
                      ),
                    ),
                    TextSpan(text: locationLine),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEarnMemberBanner() {
    return GetBuilder<OnboardingController>(
      builder: (controller) {
        if (controller.isLoading || controller.state.isComplete) {
          return const SizedBox.shrink();
        }

        return EarnMemberBanner(onTap: () => controller.startOrResume());
      },
    );
  }

  Widget _buildSettingsCard({
    required String sectionTitle,
    required List<_SettingsTileData> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              sectionTitle,
              style: _nunito(
                size: 12,
                weight: FontWeight.w800,
                color: AppColors.jebbyTextPrimary,
                height: 1.2,
              ).copyWith(letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                _SettingsTile(
                  icon: item.icon,
                  label: item.label,
                  subtitle: item.subtitle,
                  trailingLabel: item.trailingLabel,
                  trailingLabelColor: item.trailingLabelColor,
                  trailingBadgeStyle: item.trailingBadgeStyle,
                  isLoading: item.isLoading,
                  onTap: item.isLoading ? null : item.onTap,
                ),
                if (index < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: _cardBorder,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsTileData {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingLabel;
  final Color? trailingLabelColor;
  final bool trailingBadgeStyle;
  final bool isLoading;
  final VoidCallback onTap;

  const _SettingsTileData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailingLabel,
    this.trailingLabelColor,
    this.trailingBadgeStyle = false,
    this.isLoading = false,
  });
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingLabel;
  final Color? trailingLabelColor;
  final bool trailingBadgeStyle;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailingLabel,
    this.trailingLabelColor,
    this.trailingBadgeStyle = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: disabled ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.jebbySoftBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: subtitle == null || subtitle!.isEmpty
                      ? Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.jebbyTextPrimary,
                            height: 1.25,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.jebbyTextPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.jebbyTextMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                ),
                if (trailingLabel != null) ...[
                  if (trailingBadgeStyle)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _SettingsScreenState._verifiedBadgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trailingLabel!,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: trailingLabelColor ?? _SettingsScreenState._verifiedGreen,
                        ),
                      ),
                    )
                  else
                    Text(
                      trailingLabel!,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: trailingLabelColor ?? AppColors.jebbyTextPrimary,
                      ),
                    ),
                  const SizedBox(width: 6),
                ],
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.jebbyBlue,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
