import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String heroAsset = LoginScreen.heroAsset;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static Color get _rippleSplash => AppColors.jebbyBlue.withValues(alpha: 0.12);

  static Color get _rippleHighlight =>
      AppColors.jebbyBlue.withValues(alpha: 0.06);

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(AuthViewModel authViewModel) {
    if (authViewModel.signUpLoading) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAppErrorSnackbar(
        'Please enter your email address',
        title: 'Required',
      );
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      showAppErrorSnackbar(
        'Please enter a valid email address',
        title: 'Required',
      );
      return;
    }

    authViewModel.forgetPasswordApi({'email': email}, context, 'forgot');
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final textScale = MediaQuery.textScalerOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight * (compact ? 0.72 : 0.65);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  ForgotPasswordScreen.heroAsset,
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
                      padding: EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        16 + bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SecurityShieldIcon(),
                          SizedBox(height: compact ? 12 : 16),
                          Text(
                            'Reset your password',
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
                            'Enter the email connected to your Jebby account. '
                            "We'll send you a verification code.",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: textScale.scale(15),
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          _ForgotPasswordField(
                            label: 'Email address',
                            controller: _emailController,
                            hintText: 'you@example.com',
                            textScale: textScale,
                            compact: compact,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(authViewModel),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  authViewModel.signUpLoading
                                      ? null
                                      : () => _submit(authViewModel),
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
                                  authViewModel.signUpLoading
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        'Send Code',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                          fontSize: textScale.scale(16),
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 16),
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.to(() => const LoginScreen()),
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
                                          text: 'Remember your password? ',
                                          style: TextStyle(
                                            color: AppColors.jebbyTextMuted,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Log in',
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

class _SecurityShieldIcon extends StatelessWidget {
  const _SecurityShieldIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield, size: 44, color: AppColors.lightBlue),
          Icon(Icons.shield_outlined, size: 50, color: AppColors.jebbyBlue),
          Icon(Icons.lock, size: 16, color: AppColors.jebbyBlue),
        ],
      ),
    );
  }
}

class _ForgotPasswordField extends StatelessWidget {
  const _ForgotPasswordField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textScale,
    required this.compact,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextScaler textScale;
  final bool compact;
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
            prefixIcon: const Icon(
              Icons.mail_outline,
              color: AppColors.jebbyTextMuted,
              size: 20,
            ),
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
