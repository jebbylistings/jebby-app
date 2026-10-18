import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';

/// Shared layout for CMS-style pages (About, Terms, Contact Support, API HTML policies).
class CmsPageShell extends StatelessWidget {
  const CmsPageShell({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.lastUpdatedLabel,
    this.screenHeaderTitle,
  });

  /// Document or page name (e.g. Privacy Policy). Shown under [screenHeaderTitle] when set.
  final String title;
  final String? subtitle;
  /// e.g. `Last updated: October 5, 2026` — shown as a pill under the title.
  final String? lastUpdatedLabel;
  /// Top screen heading (legal flows use `Legal`).
  final String? screenHeaderTitle;
  final Widget body;

  static const double horizontalPadding = 20;
  static const double _backButtonSize = 40;
  static const double _headerTitleGap = 12;
  static const double _headerToDocumentGap = 28;
  static const double _documentTitleToChipGap = 16;
  static const double _headerBlockToCardGap = 24;
  /// Indents document title + chip slightly right of the back button (less than header title).
  static const double _documentBlockLeftInset = 8;
  static const String _fontFamily = 'Nunito';

  static const TextHeightBehavior _headerTextHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

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

  static String? formatLastUpdatedLabel(String? updatedAt) {
    final raw = updatedAt?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw).toLocal();
      return 'Last updated: ${DateFormat('MMMM d, yyyy').format(dt)}';
    } catch (_) {
      return null;
    }
  }

  static TextStyle headingLarge() => _nunito(
        size: 22,
        weight: FontWeight.w800,
        height: 1.25,
      );

  static TextStyle headingSection() => _nunito(
        size: 17,
        weight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle bodyParagraph() => _nunito(
        size: 15,
        weight: FontWeight.w600,
        color: const Color(0xFF4B5563),
        height: 1.55,
      );

  static EdgeInsets get _cardScrollPadding =>
      const EdgeInsets.fromLTRB(22, 22, 22, 28);

  static Widget paddedScroll({required Widget child}) {
    return SingleChildScrollView(
      padding: _cardScrollPadding,
      child: child,
    );
  }

  static Widget sectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
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
    return SingleChildScrollView(
      padding: _cardScrollPadding,
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
        fontSize: FontSize(15),
        color: const Color(0xFF4B5563),
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        lineHeight: const LineHeight(1.55),
      ),
      'p': Style(
        margin: Margins.only(bottom: 14),
        fontSize: FontSize(15),
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
        fontSize: FontSize(17),
        fontWeight: FontWeight.w800,
        color: AppColors.jebbyTextPrimary,
        margin: Margins.only(bottom: 10, top: 4),
        fontFamily: _fontFamily,
      ),
      'h3': Style(
        fontSize: FontSize(16),
        fontWeight: FontWeight.w800,
        color: AppColors.jebbyTextPrimary,
        margin: Margins.only(bottom: 8, top: 12),
        fontFamily: _fontFamily,
      ),
      'hr': Style(
        margin: Margins.symmetric(vertical: 20),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
      ),
      'li': Style(
        fontSize: FontSize(15),
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

  Widget _lastUpdatedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: _nunito(
          size: 13,
          weight: FontWeight.w700,
          color: AppColors.jebbyBlue,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _pageHeader() {
    final chipLabel = lastUpdatedLabel?.trim();
    final legacySubtitle = subtitle?.trim();
    final header = (screenHeaderTitle?.trim().isNotEmpty == true)
        ? screenHeaderTitle!.trim()
        : title;
    final showDocumentTitle = screenHeaderTitle != null &&
        screenHeaderTitle!.trim().isNotEmpty &&
        title.trim() != header;

    final documentAndMeta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDocumentTitle)
          Text(
            title,
            style: _nunito(
              size: 26,
              weight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        if (chipLabel != null && chipLabel.isNotEmpty) ...[
          SizedBox(height: showDocumentTitle ? _documentTitleToChipGap : 0),
          _lastUpdatedChip(chipLabel),
        ] else if (legacySubtitle != null && legacySubtitle.isNotEmpty) ...[
          SizedBox(height: showDocumentTitle ? 8 : 0),
          Text(
            legacySubtitle,
            style: _nunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _backButtonSize,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _backButton(),
              const SizedBox(width: _headerTitleGap),
              Expanded(
                child: Text(
                  header,
                  textHeightBehavior: _headerTextHeight,
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDocumentTitle ||
            (chipLabel != null && chipLabel.isNotEmpty) ||
            (legacySubtitle != null && legacySubtitle.isNotEmpty)) ...[
          const SizedBox(height: _headerToDocumentGap),
          Padding(
            padding: EdgeInsets.only(
              left: screenHeaderTitle?.trim().isNotEmpty == true
                  ? _documentBlockLeftInset
                  : 0,
              top: 8
            ),
            child: documentAndMeta,
          ),
        ],
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
          width: _backButtonSize,
          height: _backButtonSize,
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

  Widget _contentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: body,
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 0),
              child: _pageHeader(),
            ),
            const SizedBox(height: _headerBlockToCardGap),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
                child: _contentCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
