import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/auth_repository.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvideFeedbackScreen extends StatefulWidget {
  const ProvideFeedbackScreen({super.key});

  @override
  State<ProvideFeedbackScreen> createState() => _ProvideFeedbackScreenState();
}

class _ProvideFeedbackScreenState extends State<ProvideFeedbackScreen> {
  static const String _feedbackBannerAsset =
      'assets/images/feedback-banner.png';
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _fieldFill = Color(0xFFF5F7FA);
  static const Color _fieldValueColor = Color(0xFF4B5563);
  static const Color _fieldPlaceholderColor = Color(0xFF9CA3AF);
  static const Color _titleDark = Color(0xFF1A1A1A);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentsController = TextEditingController();
  final _repo = AuthRepository();

  String _userId = '';
  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
    _loadUserFields();
  }

  Future<void> _loadUserFields() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final name = prefs.getString('fullname')?.trim() ?? '';
    final email = prefs.getString('email')?.trim() ?? '';
    final id = prefs.getString('id')?.trim() ?? '';

    setState(() {
      _userId = id;
      _nameController.text = name == 'Guest' || name == 'null' ? '' : name;
      _emailController.text = email == 'null' ? '' : email;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final comments = _commentsController.text.trim();

    if (name.isEmpty) {
      showAppErrorSnackbar('Please enter your name.', title: 'Required');
      return;
    }
    if (email.isEmpty) {
      showAppErrorSnackbar('Please enter your email.', title: 'Required');
      return;
    }
    if (comments.isEmpty) {
      showAppErrorSnackbar(
        'Please describe your issue or feedback.',
        title: 'Required',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _repo.submitFeedbackApi({
        'user_id': _userId.isNotEmpty ? _userId : null,
        'name': name,
        'email': email,
        'comments': comments,
      });

      if (!mounted) return;

      final message = response['message']?.toString() ?? '';
      if (message == 'Inserted') {
        if (mounted) setState(() => _isSubmitting = false);
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAppSuccessSnackbar(
            'Thank you! Our support team will respond within 1–2 business days.',
          );
        });
        return;
      } else {
        showAppErrorSnackbar(
          message.isNotEmpty ? message : 'Something went wrong',
        );
      }
    } catch (error) {
      if (!mounted) return;
      showAppErrorSnackbar(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JebbyFlowBackButton(onTap: _handleBack),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Provide Feedback',
                  style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tell us what we can improve.',
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedbackBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;
        final textWidth = bannerWidth * 0.56;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                _feedbackBannerAsset,
                width: bannerWidth,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              Positioned(
                left: 20,
                top: 25,
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Voice Matters',
                      style: _nunito(
                        size: 24,
                        weight: FontWeight.w800,
                        color: _titleDark,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your thoughts with us. Every little suggestion makes a difference.',
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w500,
                        color: const Color(0xFF4E5E74),
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: _nunito(
        size: 15,
        weight: FontWeight.w500,
        color: _fieldPlaceholderColor,
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _fieldIcon(IconData icon) {
    return Icon(icon, size: 20, color: AppColors.jebbyBlue);
  }

  Widget _labeledField({
    required IconData icon,
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _fieldIcon(icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: _nunito(size: 16, weight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        field,
      ],
    );
  }

  Widget _feedbackFormCard() {
    final fieldStyle = _nunito(
      size: 15,
      weight: FontWeight.w500,
      color: _fieldValueColor,
      height: 1.35,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _labeledField(
            icon: Icons.person_outline,
            label: 'Name',
            field: TextField(
              controller: _nameController,
              enabled: !_isSubmitting,
              style: fieldStyle,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(hintText: 'Your name'),
            ),
          ),
          const SizedBox(height: 18),
          _labeledField(
            icon: Icons.mail_outline,
            label: 'Email',
            field: TextField(
              controller: _emailController,
              enabled: !_isSubmitting,
              style: fieldStyle,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(hintText: 'you@example.com'),
            ),
          ),
          const SizedBox(height: 18),
          _labeledField(
            icon: Icons.chat_bubble_outline,
            label: 'Message',
            field: TextField(
              controller: _commentsController,
              enabled: !_isSubmitting,
              style: fieldStyle,
              maxLines: 6,
              minLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: _fieldDecoration(
                hintText: 'Describe your issue or inquiry',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _pageHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _feedbackBanner(),
                    const SizedBox(height: 16),
                    _feedbackFormCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.jebbyBlue,
                    disabledBackgroundColor:
                        AppColors.jebbyBlue.withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit Feedback',
                          style: _nunito(
                            size: 17,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
