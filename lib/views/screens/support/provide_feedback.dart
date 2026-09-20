import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/views/widgets/cms_page_shell.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/auth_repository.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvideFeedbackScreen extends StatefulWidget {
  const ProvideFeedbackScreen({super.key});

  @override
  State<ProvideFeedbackScreen> createState() => _ProvideFeedbackScreenState();
}

class _ProvideFeedbackScreenState extends State<ProvideFeedbackScreen> {
  static const Color _fieldFill = Color(0xFFF7F7F9);

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

  @override
  Widget build(BuildContext context) {
    return CmsPageShell(
      title: 'Provide Feedback',
      subtitle: 'Tell us what we can improve.',
      body: CmsPageShell.paddedScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Describe your issue, question, or suggestion below. Our support team will review your message and respond as soon as possible.',
              style: _nunito(
                size: 16,
                weight: FontWeight.w600,
                color: const Color(0xFF374151),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            _fieldLabel('Name'),
            _textField(
              controller: _nameController,
              hint: 'Your name',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _fieldLabel('Email'),
            _textField(
              controller: _emailController,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _fieldLabel('Message'),
            _textField(
              controller: _commentsController,
              hint: 'Describe your issue or inquiry…',
              maxLines: 6,
              minLines: 5,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 28),
            SizedBox(
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
                    borderRadius: BorderRadius.circular(26),
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
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: _nunito(size: 14, weight: FontWeight.w700),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int? maxLines = 1,
    int? minLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      enabled: !_isSubmitting,
      style: _nunito(size: 15, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _nunito(
          size: 15,
          weight: FontWeight.w600,
          color: const Color(0xFF8F9098),
        ),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.jebbyBlue, width: 1.5),
        ),
      ),
    );
  }
}
