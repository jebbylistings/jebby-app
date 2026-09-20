import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:provider/provider.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key, this.email, this.otp});

  final String? email;
  final String? otp;

  static const String heroAsset = LoginScreen.heroAsset;

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  static Color get _rippleSplash => AppColors.jebbyBlue.withValues(alpha: 0.12);

  static Color get _rippleHighlight =>
      AppColors.jebbyBlue.withValues(alpha: 0.06);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  _PasswordRequirements get _passwordRequirements =>
      _PasswordRequirements.evaluate(_passwordController.text);

  bool get _canSave {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    return _passwordRequirements.isComplete &&
        confirm.isNotEmpty &&
        password == confirm;
  }

  void _submit(AuthViewModel authViewModel) {
    if (authViewModel.signUpLoading) return;

    if (_passwordController.text.isEmpty) {
      showAppErrorSnackbar('Enter your password', title: 'Required');
      return;
    }
    if (!_passwordRequirements.isComplete) {
      showAppErrorSnackbar(
        'Password should be minimum of 8 characters and contain uppercase, lowercase, number, and special character',
      );
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      showAppErrorSnackbar('Enter confirm password', title: 'Required');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showAppErrorSnackbar('Password doesn\'t match');
      return;
    }

    authViewModel.changePasswordAPi({
      'email': widget.email.toString(),
      'otp': widget.otp.toString(),
      'password': _passwordController.text,
    }, context);
  }

  Widget _passwordRequirementRow({
    required String label,
    required bool met,
    required TextScaler textScale,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: met ? Colors.green.shade600 : AppColors.jebbyTextMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: textScale.scale(13),
                fontWeight: FontWeight.w500,
                color: met ? Colors.green.shade700 : AppColors.jebbyTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
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
          final cardHeight = constraints.maxHeight * (compact ? 0.78 : 0.72);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  CreateNewPasswordScreen.heroAsset,
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
                            'Create a new password',
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
                            'Choose a new password for your Jebby account.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: textScale.scale(15),
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          _PasswordField(
                            label: 'New password',
                            controller: _passwordController,
                            hintText: 'Enter a new password',
                            textScale: textScale,
                            compact: compact,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            focusNode: _passwordFocusNode,
                            suffixIcon: IconButton(
                              onPressed:
                                  () => setState(
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
                          ),
                          ListenableBuilder(
                            listenable: Listenable.merge([
                              _passwordController,
                              _passwordFocusNode,
                            ]),
                            builder: (context, _) {
                              final password = _passwordController.text;
                              final requirements =
                                  _PasswordRequirements.evaluate(password);
                              final showChecklist =
                                  !requirements.isComplete &&
                                  (password.isNotEmpty ||
                                      _passwordFocusNode.hasFocus);

                              if (!showChecklist) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: compact ? 10 : 12),
                                  _passwordRequirementRow(
                                    label: 'Minimum 8 characters',
                                    met: requirements.minLength,
                                    textScale: textScale,
                                  ),
                                  _passwordRequirementRow(
                                    label: 'At least 1 uppercase letter',
                                    met: requirements.hasUppercase,
                                    textScale: textScale,
                                  ),
                                  _passwordRequirementRow(
                                    label: 'At least 1 lowercase letter',
                                    met: requirements.hasLowercase,
                                    textScale: textScale,
                                  ),
                                  _passwordRequirementRow(
                                    label: 'At least 1 number',
                                    met: requirements.hasNumber,
                                    textScale: textScale,
                                  ),
                                  _passwordRequirementRow(
                                    label: 'At least 1 special character',
                                    met: requirements.hasSpecial,
                                    textScale: textScale,
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _PasswordField(
                            label: 'Confirm new password',
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter your password',
                            textScale: textScale,
                            compact: compact,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (_canSave) _submit(authViewModel);
                            },
                            suffixIcon: IconButton(
                              onPressed:
                                  () => setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  ),
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.jebbyTextMuted,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          ListenableBuilder(
                            listenable: Listenable.merge([
                              _passwordController,
                              _confirmPasswordController,
                            ]),
                            builder: (context, _) {
                              final enabled =
                                  _canSave && !authViewModel.signUpLoading;

                              return SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      enabled
                                          ? () => _submit(authViewModel)
                                          : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.jebbyBlue,
                                    disabledBackgroundColor: AppColors.jebbyBlue
                                        .withValues(alpha: 0.55),
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white,
                                    minimumSize: Size.fromHeight(
                                      compact ? 48 : 52,
                                    ),
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
                                            'Update Password',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w700,
                                              fontSize: textScale.scale(16),
                                            ),
                                          ),
                                ),
                              );
                            },
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
          Icon(Icons.check, size: 16, color: AppColors.jebbyBlue),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textScale,
    required this.compact,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction,
    this.focusNode,
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
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
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
          focusNode: focusNode,
          autocorrect: false,
          obscureText: obscureText,
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
            prefixIcon:
                prefixIcon == null
                    ? null
                    : Icon(
                      prefixIcon,
                      color: AppColors.jebbyTextMuted,
                      size: 20,
                    ),
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

class _PasswordRequirements {
  final bool minLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  const _PasswordRequirements({
    required this.minLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  bool get isComplete =>
      minLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;

  static _PasswordRequirements evaluate(String password) {
    return _PasswordRequirements(
      minLength: password.length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
      hasLowercase: RegExp(r'[a-z]').hasMatch(password),
      hasNumber: RegExp(r'\d').hasMatch(password),
      hasSpecial: RegExp(
        r'''[!@#$%^&*(),.?":{}|<>_\-\[\]\\/`~+=;']''',
      ).hasMatch(password),
    );
  }
}
