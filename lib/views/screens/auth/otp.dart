import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    this.email,
    this.name,
    this.password,
    this.role,
    this.isForgotPasswordFlow = false,
  });

  final String? email;
  final dynamic name;
  final dynamic password;
  final dynamic role;
  final bool isForgotPasswordFlow;

  static const String heroAsset = LoginScreen.heroAsset;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static Color get _rippleSplash => AppColors.jebbyBlue.withValues(alpha: 0.12);

  static Color get _rippleHighlight =>
      AppColors.jebbyBlue.withValues(alpha: 0.06);

  final TextEditingController _codeController = TextEditingController();
  String? _otpValue;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _codeController.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
      return;
    }

    setState(() {
      _otpValue = digits.length == 4 ? digits : null;
    });
  }

  void _handleResend(AuthViewModel authViewModel) {
    if (authViewModel.resendOtpLoading || authViewModel.signUpLoading) {
      return;
    }

    if (widget.isForgotPasswordFlow) {
      authViewModel.resendForgotPasswordOtp(widget.email.toString());
      return;
    }

    if ((widget.password ?? '').toString().isEmpty) {
      showAppErrorSnackbar('Go back and sign in again to request a new code.');
      return;
    }

    authViewModel.resendRegistrationOtp(
      email: widget.email.toString(),
      password: widget.password.toString(),
    );
  }

  void _handleVerify(AuthViewModel authViewModel) {
    final code = _otpValue ?? _codeController.text.trim();
    if (code.isEmpty) {
      showAppErrorSnackbar(
        'Please enter the verification code',
        title: 'Required',
      );
      return;
    }

    if (widget.isForgotPasswordFlow) {
      authViewModel.otpForgetPasswordApi({
        'email': widget.email,
        'otp': code,
      }, context);
      return;
    }

    authViewModel.otpRegisterApi({
      'email': widget.email,
      'otp': code,
      'password': widget.password,
    }, context);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final textScale = MediaQuery.textScalerOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 720;
    final resendLoading = authViewModel.resendOtpLoading;
    final verifyLoading = authViewModel.signUpLoading;

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
                  OtpScreen.heroAsset,
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
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _VerificationIcon(),
                          SizedBox(height: compact ? 12 : 16),
                          Text(
                            'Enter verification code',
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
                            'Enter the code sent to your email.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: textScale.scale(15),
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          AutofillGroup(
                            child: _OtpCodeField(
                              controller: _codeController,
                              textScale: textScale,
                              compact: compact,
                              onChanged: _onCodeChanged,
                              onSubmitted: (_) => _handleVerify(authViewModel),
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: (verifyLoading || resendLoading)
                                  ? null
                                  : () => _handleVerify(authViewModel),
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
                              child: verifyLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                        fontSize: textScale.scale(16),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 18),
                          Center(
                            child: resendLoading
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.jebbyBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Sending code...',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w600,
                                          fontSize: textScale.scale(14),
                                          color: AppColors.jebbyTextMuted,
                                        ),
                                      ),
                                    ],
                                  )
                                : Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        "Didn't receive it? ",
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w400,
                                          fontSize: textScale.scale(14),
                                          color: AppColors.jebbyTextMuted,
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _handleResend(authViewModel),
                                          borderRadius: BorderRadius.circular(8),
                                          splashColor: _rippleSplash,
                                          highlightColor: _rippleHighlight,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              'Resend code',
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
                                    ],
                                  ),
                          ),
                          SizedBox(height: compact ? 12 : 16),
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Get.off(() => const LoginScreen()),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: _rippleSplash,
                                highlightColor: _rippleHighlight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Back to Log In',
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

class _VerificationIcon extends StatelessWidget {
  const _VerificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.jebbyBlue,
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.keyboard_alt,
        size: 22,
        color: AppColors.jebbyBlue,
      ),
    );
  }
}

class _OtpCodeField extends StatelessWidget {
  const _OtpCodeField({
    required this.controller,
    required this.textScale,
    required this.compact,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final TextScaler textScale;
  final bool compact;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification code',
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
          autofillHints: const [AutofillHints.oneTimeCode],
          autocorrect: false,
          enableSuggestions: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: textScale.scale(15),
            color: AppColors.jebbyTextPrimary,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            isDense: compact,
            counterText: '',
            hintText: 'Enter code',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w400,
              fontSize: textScale.scale(15),
              color: AppColors.jebbyTextMuted,
              letterSpacing: 0,
            ),
            prefixIcon: const Icon(
              Icons.keyboard_alt_outlined,
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
