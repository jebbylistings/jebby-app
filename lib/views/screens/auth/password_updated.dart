import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_preferences.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/services/provider/sign_in_provider.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/view_models/user_view_model.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordUpdatedScreen extends StatefulWidget {
  const PasswordUpdatedScreen({super.key});

  static const String heroAsset = LoginScreen.heroAsset;

  @override
  State<PasswordUpdatedScreen> createState() => _PasswordUpdatedScreenState();
}

class _PasswordUpdatedScreenState extends State<PasswordUpdatedScreen> {
  bool _isLoggingOut = false;

  Future<void> _backToLogin() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    final userPreference = context.read<UserViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final signInProvider = context.read<SignInProvider>();

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setBool('time', false);
      await userPreference.remove();
      authViewModel.userName = '';
      await sharedPreferences.clear();
      await AppPreferences.restoreRenterGetStartedFlag();
      try {
        await signInProvider.userSignOut();
      } catch (_) {
        try {
          await signInProvider.clearStoredData();
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

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight * (compact ? 0.72 : 0.66);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  PasswordUpdatedScreen.heroAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.06),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.18),
                        Colors.black.withValues(alpha: 0.42),
                      ],
                      stops: const [0.0, 0.45, 0.72, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: cardHeight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 16 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _SuccessShieldIcon(),
                        SizedBox(height: compact ? 20 : 24),
                        Text(
                          'Password updated',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: textScale.scale(compact ? 26 : 28),
                            color: AppColors.jebbyTextPrimary,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 12),
                        Text(
                          'You can now log in with your new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            fontSize: textScale.scale(15),
                            color: AppColors.jebbyTextMuted,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: compact ? 24 : 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isLoggingOut ? null : _backToLogin,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.jebbyBlue,
                              disabledBackgroundColor: AppColors.jebbyBlue
                                  .withValues(alpha: 0.55),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              minimumSize: Size.fromHeight(compact ? 48 : 52),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                _isLoggingOut
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      'Back to Log In',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                        fontSize: textScale.scale(16),
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SuccessShieldIcon extends StatelessWidget {
  const _SuccessShieldIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.jebbyBackground,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 60, color: AppColors.jebbyBlue),
          Icon(Icons.check, size: 25, color: AppColors.jebbyBlue),
        ],
      ),
    );
  }
}
