import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/view_models/auth_view_model.dart';
import 'package:jebby/views/screens/agreements/privacy_policy.dart';
import 'package:jebby/views/screens/agreements/terms_and_conditions.dart';
import 'package:jebby/views/screens/auth/login.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String heroAsset = LoginScreen.heroAsset;
  static const String logoAsset = LoginScreen.logoAsset;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _roleValue = 0;

  static Color get _rippleSplash =>
      AppColors.jebbyBlue.withValues(alpha: 0.12);

  static Color get _rippleHighlight =>
      AppColors.jebbyBlue.withValues(alpha: 0.06);

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final ValueNotifier<bool> _termsAccepted = ValueNotifier(false);
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  late final Listenable _formFieldsListenable = Listenable.merge([
    _firstNameController,
    _lastNameController,
    _emailController,
    _passwordController,
    _confirmPasswordController,
    _termsAccepted,
  ]);

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _termsAccepted.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  _PasswordRequirements get _passwordRequirements =>
      _PasswordRequirements.evaluate(_passwordController.text);

  bool get _isRegisterEnabled {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        _emailPattern.hasMatch(email) &&
        _passwordRequirements.isComplete &&
        confirm.isNotEmpty &&
        password == confirm &&
        _termsAccepted.value;
  }

  void _submitRegistration(AuthViewModel authViewModel) {
    if (!_isRegisterEnabled || authViewModel.signUpLoading) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName'.trim();

    authViewModel.signUpApi({
      'name': fullName,
      'email': _emailController.text,
      'password': _passwordController.text,
      'source': 'simple',
      'role': _roleValue.toString(),
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

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = constraints.maxHeight * (compact ? 0.84 : 0.77);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(
                  RegisterScreen.heroAsset,
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
                          Text(
                            'Create your account',
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
                            'Rent nearby, or list what you own.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                              fontSize: textScale.scale(15),
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _RegisterField(
                                  label: 'First name',
                                  controller: _firstNameController,
                                  hintText: 'First name',
                                  textScale: textScale,
                                  compact: compact,
                                  prefixIcon: Icons.person_outline,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RegisterField(
                                  label: 'Last name',
                                  controller: _lastNameController,
                                  hintText: 'Last name',
                                  textScale: textScale,
                                  compact: compact,
                                  prefixIcon: Icons.person_outline,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _RegisterField(
                            label: 'Email address',
                            controller: _emailController,
                            hintText: 'you@example.com',
                            textScale: textScale,
                            compact: compact,
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _RegisterField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: 'Create a password',
                            textScale: textScale,
                            compact: compact,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            focusNode: _passwordFocusNode,
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
                              final showChecklist = !requirements.isComplete &&
                                  (password.isNotEmpty ||
                                      _passwordFocusNode.hasFocus);

                              if (!showChecklist) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
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
                          _RegisterField(
                            label: 'Confirm password',
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter your password',
                            textScale: textScale,
                            compact: compact,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
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
                          SizedBox(height: compact ? 10 : 12),
                          ValueListenableBuilder<bool>(
                            valueListenable: _termsAccepted,
                            builder: (context, termsAccepted, _) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: termsAccepted,
                                      activeColor: AppColors.jebbyBlue,
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (value) {
                                        _termsAccepted.value = value ?? false;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: _TermsAgreementText(
                                        textScale: textScale,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: compact ? 16 : 20),
                          ListenableBuilder(
                            listenable: _formFieldsListenable,
                            builder: (context, _) {
                              final enabled = _isRegisterEnabled &&
                                  !authViewModel.signUpLoading;

                              return SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: enabled
                                      ? () => _submitRegistration(authViewModel)
                                      : null,
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
                                  child: authViewModel.signUpLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Create Account',
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
                          SizedBox(height: compact ? 12 : 14),
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
                                          text: 'Already have an account? ',
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

class _RegisterField extends StatelessWidget {
  const _RegisterField({
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
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
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
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

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
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
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

class _TermsAgreementText extends StatefulWidget {
  const _TermsAgreementText({required this.textScale});

  final TextScaler textScale;

  @override
  State<_TermsAgreementText> createState() => _TermsAgreementTextState();
}

class _TermsAgreementTextState extends State<_TermsAgreementText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Get.to(() => const TermsAndConditionsScreen());
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => Get.to(() => const PrivacyPolicyScreen());
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mutedStyle = TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w400,
      fontSize: widget.textScale.scale(13),
      color: AppColors.jebbyTextMuted,
      height: 1.45,
    );

    final linkStyle = mutedStyle.copyWith(
      color: AppColors.jebbyBlue,
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      TextSpan(
        style: mutedStyle,
        children: [
          TextSpan(text: 'I agree to the ', style: mutedStyle),
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: ' and ', style: mutedStyle),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          TextSpan(text: '.', style: mutedStyle),
        ],
      ),
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
      hasSpecial: RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-\[\]\\/`~+=;']''')
          .hasMatch(password),
    );
  }
}
