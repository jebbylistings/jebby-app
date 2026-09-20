import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/views/screens/agreements/about_app.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/screens/profile/edit_profile.dart';
import 'package:jebby/views/screens/support/faqs.dart';
import 'package:jebby/views/screens/support/contact_support.dart';
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

  String _getEmailText(usp) {
    return usp.email.toString().trim();
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
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final showBack = widget.showBackButton ?? false;
    // Clear homemain footer (64px bar + 22px spacing) plus breathing room.
    const footerClearance = 86.0;

    return Scaffold(
      backgroundColor: Colors.white,
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
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  footerClearance + bottomSafe,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(usp, sp),
                    const SizedBox(height: 24),
                    if (!isProvider) _buildEarnMemberBanner(),
                    if (!isProvider) const SizedBox(height: 24),
                    _buildSectionHeader('ACCOUNT'),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _SettingsTileData(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        onTap: _openEditProfile,
                      ),
                      if (!isSocialAccount)
                        _SettingsTileData(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          isLoading: auth.signUpLoading,
                          onTap: () => _openChangePassword(usp),
                        ),
                      _SettingsTileData(
                        icon: Icons.verified_user_outlined,
                        label: 'Verification',
                        trailingLabel: _identityVerified ? 'Verified' : null,
                        trailingLabelColor: _verifiedGreen,
                        onTap: _openVerification,
                      ),
                      if (usp.role != 'Guest' && role != 'Guest')
                        _SettingsTileData(
                          icon: Icons.delete_outline,
                          label: 'Request Account Deletion',
                          isLoading: auth.accountDeletionLoading,
                          onTap: () => _openAccountDeletionRequest(usp, sp),
                        ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('SUPPORT & INFO'),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _SettingsTileData(
                        icon: Icons.info_outline,
                        label: 'About App',
                        onTap: () => Get.to(() => const AboutAppScreen()),
                      ),
                      _SettingsTileData(
                        icon: Icons.help_outline,
                        label: 'FAQs',
                        onTap: () => Get.to(() => const FaqsScreen()),
                      ),
                      _SettingsTileData(
                        icon: Icons.headset_mic_outlined,
                        label: 'Support',
                        onTap: () => Get.to(() => ContactSupportScreen()),
                      ),
                      _SettingsTileData(
                        icon: Icons.description_outlined,
                        label: 'Terms & Conditions',
                        onTap: () => Get.to(() => TermsAndConditionsScreen()),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('LEGAL'),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _SettingsTileData(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        onTap: () => Get.to(() => PrivacyPolicyScreen()),
                      ),
                    ]),
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
          style: _nunito(size: 28, weight: FontWeight.w800, height: 1.1),
        ),
        const SizedBox(height: 4),
        Text(
          isProvider
              ? 'Manage your account and business.'
              : 'Manage your account and preferences.',
          style: _nunito(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.2,
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

  Widget _buildProfileHeader(usp, sp) {
    final displayName = getText(usp, sp);
    final showEmail = !displayName.contains('+');

    return Column(
      children: [
        GestureDetector(
          onTap: _openEditProfile,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileImage.circularAvatar(
                radius: 44,
                baseUrl: Url,
                imagePath:
                    ProfileImage.isValidPath(usp.profileImage)
                        ? usp.profileImage!
                        : imagesapi,
                isLoading:
                    isLoadingImage &&
                    !ProfileImage.isValidPath(usp.profileImage),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.jebbyBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: _nunito(size: 22, weight: FontWeight.w800),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        if (showEmail) ...[
          const SizedBox(height: 4),
          Text(
            _getEmailText(usp),
            style: _nunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: _nunito(
        size: 13,
        weight: FontWeight.w700,
        color: AppColors.jebbyTextMuted,
        height: 1.2,
      ).copyWith(letterSpacing: 0.6),
    );
  }

  Widget _buildSettingsCard(List<_SettingsTileData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _SettingsTile(
                icon: item.icon,
                label: item.label,
                trailingLabel: item.trailingLabel,
                trailingLabelColor: item.trailingLabelColor,
                isLoading: item.isLoading,
                onTap: item.isLoading ? null : item.onTap,
              ),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 68,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsTileData {
  final IconData icon;
  final String label;
  final String? trailingLabel;
  final Color? trailingLabelColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _SettingsTileData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingLabel,
    this.trailingLabelColor,
    this.isLoading = false,
  });
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingLabel;
  final Color? trailingLabelColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailingLabel,
    this.trailingLabelColor,
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
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.jebbySoftBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.jebbyTextPrimary,
                    ),
                  ),
                ),
                if (trailingLabel != null) ...[
                  Text(
                    trailingLabel!,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: trailingLabelColor ?? AppColors.jebbyTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
