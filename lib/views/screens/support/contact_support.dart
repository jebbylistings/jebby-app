import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/screens/support/provide_feedback.dart';
import 'package:jebby/views/widgets/jebby_flow_back_button.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  @override
  Widget build(BuildContext context) {
    return const _ContactSupportContent();
  }
}

class _ContactSupportContent extends StatelessWidget {
  const _ContactSupportContent();

  static const String _bannerAsset = 'assets/images/support-banner.png';
  static const String _supportEmail = 'support@jebbylistings.com';
  static const double _horizontalPadding = 20;
  static const Color _titleDark = Color(0xFF1A1A1A);
  static const Color _cardBorder = Color(0xFFE3E6EC);

  static TextStyle _nunito({
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

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    showAppSnackbar('Copied', 'Support email copied to clipboard.');
  }

  void _openProvideFeedback() {
    Get.to(() => const ProvideFeedbackScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_horizontalPadding, 8, _horizontalPadding, 0),
              child: _pageHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  20,
                  _horizontalPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _supportBanner(),
                    const SizedBox(height: 28),
                    Text(
                      'How can we help?',
                      style: _nunito(size: 20, weight: FontWeight.w800, height: 1.25),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the easiest way to reach our team.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _inAppSupportCard(),
                    const SizedBox(height: 16),
                    _emailSupportCard(),
                    const SizedBox(height: 20),
                    _commitmentFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  'Contact Support',
                  style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Have a question or need help? We\'re here for you.',
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

  Widget _supportBanner() {
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
                _bannerAsset,
                width: bannerWidth,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              Positioned(
                left: 20,
                top: 40,
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need a hand?',
                      style: _nunito(
                        size: 24,
                        weight: FontWeight.w800,
                        color: _titleDark,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our team is here to make your Jebby experience a great one.',
                      style: _nunito(
                        size: 14,
                        weight: FontWeight.w500,
                        color: const Color(0xFF4E5E74),
                        height: 1.35,
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

  static const Color _footerTextMuted = Color(0xFF64748B);

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
  }

  Widget _supportIconCircle(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.jebbySoftBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 26, color: AppColors.jebbyBlue),
    );
  }

  Widget _cardTitleRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _supportIconCircle(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _nunito(size: 18, weight: FontWeight.w800, height: 1.25),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _infoFooter({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 20, color: AppColors.jebbyBlue),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _numberedStep(int number, String label, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.jebbyBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: _nunito(
                size: 14,
                weight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: _nunito(
                size: 15,
                weight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inAppSupportCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProvideFeedback,
        borderRadius: BorderRadius.circular(16),
        child: _whiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cardTitleRow(
                icon: Icons.chat_outlined,
                title: 'In-app support',
                subtitle: 'Get help right inside the app.',
              ),
              const SizedBox(height: 18),
              _numberedStep(1, 'Open the menu'),
              _numberedStep(2, 'Tap Provide Feedback'),
              _numberedStep(3, 'Tell us what you need', isLast: true),
              const SizedBox(height: 16),
              _infoFooter(
                child: Text(
                  'We\'ll reply as soon as possible.',
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w600,
                    color: _footerTextMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailSupportCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardTitleRow(
            icon: Icons.mail_outline_rounded,
            title: 'Email Support',
            subtitle: 'Email us anytime.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppColors.earnerInfoBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _supportEmail,
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.0,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _copyEmail,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Include your name and a few details about your issue.',
            style: _nunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _infoFooter(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Response time: ',
                    style: _nunito(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.jebbyBlue,
                      height: 1.35,
                    ),
                  ),
                  TextSpan(
                    text: '1–2 business days',
                    style: _nunito(
                      size: 14,
                      weight: FontWeight.w600,
                      color: _footerTextMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commitmentFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.earnerBannerBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text.rich(
        TextSpan(
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            color: AppColors.jebbyBlue,
            height: 1.55,
          ),
          children: [
            const TextSpan(text: 'At '),
            TextSpan(
              text: 'JEBBY',
              style: _nunito(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.jebbyBlue,
              ),
            ),
            const TextSpan(
              text:
                  ', we are committed to providing you with the best rental experience possible. '
                  'If you have any questions, concerns, or need assistance with our service, '
                  'please don\'t hesitate to reach out to our dedicated support team. '
                  'We\'re here to help you!',
            ),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
