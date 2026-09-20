import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';

/// Shared layout for CMS-style pages (About, Terms, Contact Support, API HTML policies).
class CmsPageShell extends StatelessWidget {
  const CmsPageShell({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;

  static const double horizontalPadding = 20;
  static const String _fontFamily = 'Nunito';

  static TextStyle _nunito({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.jebbyTextPrimary,
      height: height,
    );
  }

  static TextStyle headingLarge() => _nunito(
        size: 22,
        weight: FontWeight.w800,
        height: 1.25,
      );

  static TextStyle headingSection() => _nunito(
        size: 18,
        weight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle bodyParagraph() => _nunito(
        size: 16,
        weight: FontWeight.w600,
        color: const Color(0xFF374151),
        height: 1.55,
      );

  static Widget paddedScroll({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        32,
      ),
      child: child,
    );
  }

  static Widget sectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
    );
  }

  /// Scroll area for API-loaded HTML (terms, privacy, rental policies, etc.).
  static Widget htmlPolicyScroll({
    required bool isLoading,
    required bool isError,
    required bool emptyData,
    required String? html,
    String emptyMessage = 'Unable to load content. Please try again later.',
  }) {
    return paddedScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.jebbyBlue,
                  strokeWidth: 2.4,
                ),
              ),
            )
          else if (isError || emptyData || html == null || html.isEmpty)
            Text(emptyMessage, style: bodyParagraph())
          else
            Html(
              data: html,
              style: htmlStyles(),
            ),
        ],
      ),
    );
  }

  /// Styling for [Html] from `flutter_html` to match plain CMS text pages.
  static Map<String, Style> htmlStyles() {
    return {
      'body': Style(
        margin: Margins.zero,
        fontSize: FontSize(16),
        color: const Color(0xFF374151),
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        lineHeight: const LineHeight(1.55),
      ),
      'p': Style(
        margin: Margins.only(bottom: 12),
        fontSize: FontSize(16),
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        lineHeight: const LineHeight(1.55),
      ),
      'h1': Style(
        fontSize: FontSize(22),
        fontWeight: FontWeight.w800,
        color: AppColors.jebbyTextPrimary,
        margin: Margins.only(bottom: 12, top: 4),
        fontFamily: _fontFamily,
      ),
      'h2': Style(
        fontSize: FontSize(18),
        fontWeight: FontWeight.w800,
        color: AppColors.jebbyTextPrimary,
        margin: Margins.only(bottom: 10, top: 20),
        fontFamily: _fontFamily,
      ),
      'h3': Style(
        fontSize: FontSize(17),
        fontWeight: FontWeight.w800,
        color: AppColors.jebbyTextPrimary,
        margin: Margins.only(bottom: 8, top: 14),
        fontFamily: _fontFamily,
      ),
      'li': Style(
        fontSize: FontSize(16),
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        lineHeight: const LineHeight(1.5),
        margin: Margins.only(bottom: 6),
      ),
      'strong': Style(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w800,
      ),
      'b': Style(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w800,
      ),
      'ul': Style(
        margin: Margins.only(bottom: 12),
      ),
      'ol': Style(
        margin: Margins.only(bottom: 12),
      ),
      'a': Style(
        color: AppColors.jebbyBlue,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
      ),
    };
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _nunito(
                    size: 28,
                    weight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: _nunito(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
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
        onTap: () => Get.back(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _pageHeader(),
            ),
            const SizedBox(height: 20),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
