import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/views/screens/onboarding/onboarding_illustrations.dart';

TextStyle onboardingNunito({
  double size = 15,
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

class OnboardingShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomBar;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double titleFontSize;
  final double subtitleFontSize;
  final Color? subtitleColor;
  final bool headerDivider;
  final bool bodyScrollable;

  /// When false with [showBackButton], title/subtitle align to the leading edge (no back-button gap).
  final bool headerLeadingInset;

  const OnboardingShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bottomBar,
    this.showBackButton = true,
    this.onBack,
    this.titleFontSize = 22,
    this.subtitleFontSize = 14,
    this.subtitleColor,
    this.headerDivider = false,
    this.bodyScrollable = true,
    this.headerLeadingInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final showsHeader = showBackButton ||
        title.trim().isNotEmpty ||
        (subtitle != null && subtitle!.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showsHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: showBackButton
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OnboardingBackButton(onTap: onBack ?? () => Get.back()),
                          const SizedBox(width: 12),
                          Expanded(child: _headerTitleColumn()),
                        ],
                      )
                    : _headerTitleColumn(
                        padding: headerLeadingInset
                            ? const EdgeInsets.only(left: 4)
                            : EdgeInsets.zero,
                      ),
              ),
            if (headerDivider)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
            Expanded(
              child: bodyScrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: body,
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: body,
                    ),
            ),
            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerTitleColumn({EdgeInsetsGeometry padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: onboardingNunito(
                size: titleFontSize,
                weight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: onboardingNunito(
                size: subtitleFontSize,
                weight: FontWeight.w600,
                color: subtitleColor ?? AppColors.jebbyTextMuted,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Scrollable form content with primary actions pinned above the safe area bottom.
class OnboardingEmbeddedFormLayout extends StatelessWidget {
  final Widget scrollChild;
  final Widget bottomBar;

  const OnboardingEmbeddedFormLayout({
    super.key,
    required this.scrollChild,
    required this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: scrollChild,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: bottomBar,
        ),
      ],
    );
  }
}

class _OnboardingBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OnboardingBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 2),
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
}

enum OnboardingPillKind {
  verificationInProgress,
  identityVerified,
  actionNeeded,
  payoutsEnabled,
  payoutInProgress,
}

class OnboardingStatusPill extends StatelessWidget {
  final OnboardingPillKind kind;
  final String? labelOverride;

  const OnboardingStatusPill({
    super.key,
    required this.kind,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon, String label) = switch (kind) {
      OnboardingPillKind.verificationInProgress => (
          AppColors.earnerInfoBlue,
          AppColors.jebbyBlue,
          Icons.schedule_rounded,
          'Verification in progress',
        ),
      OnboardingPillKind.identityVerified => (
          const Color(0xFFE8F7EE),
          const Color(0xFF1B7A3A),
          Icons.check_circle_outline,
          'Identity verified',
        ),
      OnboardingPillKind.actionNeeded => (
          AppColors.earnerOrangeSoft,
          AppColors.jebbyAccentOrange,
          Icons.error_outline_rounded,
          'Action needed',
        ),
      OnboardingPillKind.payoutsEnabled => (
          const Color(0xFFE8F7EE),
          const Color(0xFF1B7A3A),
          Icons.account_balance_outlined,
          'Payouts enabled',
        ),
      OnboardingPillKind.payoutInProgress => (
          AppColors.earnerInfoBlue,
          AppColors.jebbyBlue,
          Icons.hourglass_top_rounded,
          'Payout setup in progress',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            labelOverride ?? label,
            style: onboardingNunito(
              size: 13,
              weight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingTaskCard extends StatelessWidget {
  static const Color _completeCheckGreen = Color(0xFF52B788);
  static const Color _completeCheckBg = Color(0xFFEDF7F1);

  final IconData icon;
  final String title;
  final String subtitle;
  final String? detailSubtitle;
  final bool isComplete;
  final bool isNextAction;
  final VoidCallback? onTap;
  final double subtitleFontSize;
  final bool showTrailingIcons;
  final bool circularIcon;

  const OnboardingTaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.detailSubtitle,
    this.isComplete = false,
    this.isNextAction = false,
    this.onTap,
    this.subtitleFontSize = 14,
    this.showTrailingIcons = true,
    this.circularIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isNextAction && !isComplete
        ? AppColors.earnerOrangeSoft
        : Colors.white;
    final border = isNextAction && !isComplete
        ? AppColors.jebbyAccentOrange.withValues(alpha: 0.35)
        : const Color(0xFFE3E6EC);
    final iconBg = isNextAction && !isComplete
        ? AppColors.primaryColorLight
        : AppColors.jebbySoftBlue;
    final iconFg = isNextAction && !isComplete
        ? AppColors.jebbyAccentOrange
        : AppColors.jebbyBlue;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: circularIcon ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      circularIcon ? null : BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconFg, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: onboardingNunito(
                        size: 17,
                        weight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: onboardingNunito(
                        size: subtitleFontSize,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.3,
                      ),
                    ),
                    if (detailSubtitle != null &&
                        detailSubtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detailSubtitle!,
                        style: onboardingNunito(
                          size: subtitleFontSize,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showTrailingIcons)
                if (isComplete) ...[
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _completeCheckBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 20,
                      color: _completeCheckGreen,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.jebbyTextMuted.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ] else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isNextAction
                        ? AppColors.jebbyAccentOrange
                        : AppColors.jebbyTextMuted.withValues(alpha: 0.7),
                    size: 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingIllustration extends StatelessWidget {
  final String assetPath;
  final double height;

  const OnboardingIllustration({
    super.key,
    required this.assetPath,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
          height: height,
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}

class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.jebbyBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  if (loadingLabel != null && loadingLabel!.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      loadingLabel!,
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              )
            : Text(
                label,
                style: onboardingNunito(
                  size: 16,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class OnboardingSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const OnboardingSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.jebbySoftBlue,
          foregroundColor: AppColors.jebbyBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: onboardingNunito(
            size: 16,
            weight: FontWeight.w800,
            color: AppColors.jebbyBlue,
          ),
        ),
      ),
    );
  }
}

class OnboardingInfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const OnboardingInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.jebbyBlue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.jebbyBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: onboardingNunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingLockNote extends StatelessWidget {
  final String message;

  const OnboardingLockNote({
    super.key,
    this.message = 'Secured by Stripe',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: AppColors.jebbyTextMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: onboardingNunito(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingStripePayoutTrustCard extends StatelessWidget {
  const OnboardingStripePayoutTrustCard({super.key});

  static const _bullets = [
    'Fast, secure payouts',
    'Your info is private',
    'Bank-level security',
    'Trusted by millions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jebby partners with Stripe for secure payouts.',
            style: onboardingNunito(size: 16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _bullets.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: AppColors.jebbyBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _bullets[i],
                    style: onboardingNunito(
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingStripeConnectPrivacyFooter extends StatelessWidget {
  final VoidCallback? onStripePrivacy;

  const OnboardingStripeConnectPrivacyFooter({
    super.key,
    this.onStripePrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'You can review what you share before connecting.',
          textAlign: TextAlign.center,
          style: onboardingNunito(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onStripePrivacy,
          child: Text(
            'Stripe Privacy',
            textAlign: TextAlign.center,
            style: onboardingNunito(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.jebbyBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPrivacyLinks extends StatelessWidget {
  final VoidCallback? onStripePrivacy;
  final VoidCallback? onJebbyPrivacy;

  const OnboardingPrivacyLinks({
    super.key,
    this.onStripePrivacy,
    this.onJebbyPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Stripe's financial partners",
          textAlign: TextAlign.center,
          style: onboardingNunito(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onStripePrivacy,
              child: Text(
                'Stripe Privacy',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 1,
                height: 14,
                color: const Color(0xFFC6C8CF),
              ),
            ),
            GestureDetector(
              onTap: onJebbyPrivacy,
              child: Text(
                'Jebby Privacy',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Convenience re-export for screens.
class OnboardingAssets {
  OnboardingAssets._();
  static const intro = OnboardingIllustrationAsset.intro;
  static const verificationInProgress =
      OnboardingIllustrationAsset.verificationInProgress;
  static const addressActionNeeded =
      OnboardingIllustrationAsset.addressActionNeeded;
  static const identityVerified = OnboardingIllustrationAsset.identityVerified;
  static const payoutChooser = OnboardingIllustrationAsset.payoutChooser;
  static const connectBank = OnboardingIllustrationAsset.connectBank;
  static const listingPublished = OnboardingIllustrationAsset.listingPublished;
  static const allSet = OnboardingIllustrationAsset.allSet;
}
