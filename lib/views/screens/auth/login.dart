import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/services/provider/internet_provider.dart';
import 'package:jebby/services/provider/sign_in_provider.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/views/screens/auth/forgot_password.dart';
import 'package:jebby/views/screens/auth/register.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String heroAsset = 'assets/images/get-started-slide-1.png';
  static const String logoAsset = 'assets/images/splashicon.png';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  static const int _roleValue = 0;

  static const double _socialButtonHeight = 56;
  static const double _socialButtonRadius = 14;

  static Color get _rippleSplash =>
      AppColors.jebbyBlue.withValues(alpha: 0.12);

  static Color get _rippleHighlight =>
      AppColors.jebbyBlue.withValues(alpha: 0.06);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(AuthViewModel authViewModel) {
    if (authViewModel.loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      showAppErrorSnackbar('Please enter a valid email address', title: 'Required');
      return;
    }
    if (password.isEmpty) {
      showAppErrorSnackbar('Please enter your password', title: 'Required');
      return;
    }
    if (password.length < 6) {
      showAppErrorSnackbar('Password must be at least 6 characters', title: 'Required');
      return;
    }

    authViewModel.loginApi({
      'email': email,
      'password': password,
    }, context);
  }

  Future<void> _handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showAppErrorSnackbar('Check your Internet connection');
      return;
    }

    try {
      await sp.signInWithGoogle(_roleValue, context);
      if (sp.hasError == true) {
        showAppErrorSnackbar(sp.errorCode.toString());
      }
    } catch (e) {
      showAppErrorSnackbar(e.toString());
    }
  }

  Future<void> _handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showAppErrorSnackbar('Check your Internet connection');
      return;
    }

    try {
      await sp.signInWithFacebook(_roleValue, context);
      if (sp.hasError == true) {
        showAppErrorSnackbar(sp.errorCode.toString());
      }
    } catch (e) {
      showAppErrorSnackbar(e.toString());
    }
  }

  Future<void> _handleAppleAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showAppErrorSnackbar('Check your Internet connection');
      return;
    }

    try {
      await sp.signInWithApple(_roleValue, context);
      if (sp.hasError == true) {
        showAppErrorSnackbar(sp.errorCode.toString());
      }
    } catch (e) {
      showAppErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final textScale = MediaQuery.textScalerOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 720;
    final showBackButton = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight * (compact ? 0.76 : 0.68);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  LoginScreen.heroAsset,
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
              if (showBackButton)
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: Get.back,
                          customBorder: const CircleBorder(),
                          splashColor: Colors.white.withValues(alpha: 0.14),
                          highlightColor: Colors.white.withValues(alpha: 0.08),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: textScale.scale(compact ? 26 : 28),
                              color: AppColors.jebbyTextPrimary,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: compact ? 6 : 8),
                          Text(
                            'Log in to continue to Jebby.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: textScale.scale(15),
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 16),
                          _LoginField(
                            label: 'Email address',
                            controller: _emailController,
                            hintText: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline,
                            textScale: textScale,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _LoginField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.jebbyTextMuted,
                                size: 20,
                              ),
                            ),
                            onSubmitted: (_) => _submitLogin(authViewModel),
                            textScale: textScale,
                            compact: compact,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    Get.to(() => const ForgotPasswordScreen()),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: _rippleSplash,
                                highlightColor: _rippleHighlight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      fontSize: textScale.scale(14),
                                      color: AppColors.jebbyBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: authViewModel.loading
                                  ? null
                                  : () => _submitLogin(authViewModel),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.jebbyBlue,
                                disabledBackgroundColor:
                                    AppColors.jebbyBlue.withValues(alpha: 0.55),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                minimumSize: Size.fromHeight(compact ? 48 : 52),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: authViewModel.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                        fontSize: textScale.scale(16),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.to(() => const RegisterScreen()),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: _rippleSplash,
                                highlightColor: _rippleHighlight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w400,
                                        fontSize: textScale.scale(14),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'New to Jebby? ',
                                          style: TextStyle(
                                            color: AppColors.jebbyTextMuted,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Create an account',
                                          style: TextStyle(
                                            color: AppColors.jebbyBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 18),
                          _OrContinueDivider(textScale: textScale),
                          SizedBox(height: compact ? 14 : 18),
                          Row(
                            children: [
                              Expanded(
                                child: _SocialLoginButton(
                                  child: Image.asset(
                                    'assets/images/google.png',
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: _handleGoogleSignIn,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SocialLoginButton(
                                  child: Image.asset(
                                    'assets/images/fb.png',
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: _handleFacebookAuth,
                                ),
                              ),
                              if (GetPlatform.isIOS) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SocialLoginButton(
                                    child: Image.asset(
                                      'assets/images/aple.png',
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.contain,
                                    ),
                                    onPressed: _handleAppleAuth,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GuestLoginButton(
                                  textScale: textScale,
                                  onTap: () =>
                                      authViewModel.loginAsGuest(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textScale,
    required this.compact,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextScaler textScale;
  final bool compact;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: textScale.scale(14),
            color: AppColors.jebbyTextPrimary,
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        TextFormField(
          controller: controller,
          autocorrect: false,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: textScale.scale(15),
            color: AppColors.jebbyTextPrimary,
          ),
          decoration: InputDecoration(
            isDense: compact,
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w400,
              fontSize: textScale.scale(15),
              color: AppColors.jebbyTextMuted,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.jebbyTextMuted, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 12 : 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.jebbyBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrContinueDivider extends StatelessWidget {
  const _OrContinueDivider({required this.textScale});

  final TextScaler textScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w400,
              fontSize: textScale.scale(13),
              color: AppColors.jebbyTextMuted,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
      ],
    );
  }
}

class _SocialLoginButton extends StatefulWidget {
  const _SocialLoginButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final Future<void> Function() onPressed;

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_LoginScreenState._socialButtonRadius),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _loading ? null : _handleTap,
        borderRadius: BorderRadius.circular(_LoginScreenState._socialButtonRadius),
        splashColor: _LoginScreenState._rippleSplash,
        highlightColor: _LoginScreenState._rippleHighlight,
        child: SizedBox(
          height: _LoginScreenState._socialButtonHeight,
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                )
              : Center(child: widget.child),
        ),
      ),
    );
  }
}

class _GuestLoginButton extends StatelessWidget {
  const _GuestLoginButton({
    required this.textScale,
    required this.onTap,
  });

  final TextScaler textScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_LoginScreenState._socialButtonRadius),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_LoginScreenState._socialButtonRadius),
        splashColor: _LoginScreenState._rippleSplash,
        highlightColor: _LoginScreenState._rippleHighlight,
        child: SizedBox(
          height: _LoginScreenState._socialButtonHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                color: AppColors.jebbyTextPrimary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                'Guest',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: textScale.scale(11),
                  color: AppColors.jebbyTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
