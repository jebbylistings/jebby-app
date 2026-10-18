import 'package:flutter/material.dart';
import 'package:jebby/constants/color.dart';

class EarnMemberBanner extends StatelessWidget {
  static const String _shopIconAsset = 'assets/images/store.png';

  final VoidCallback? onTap;

  const EarnMemberBanner({super.key, this.onTap});

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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFdee9fc),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  _shopIconAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.jebbyBlue,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Earning',
                      style: _nunito(
                        size: 18,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyBlue,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set up your Earner account in a few easy steps, then put your items to work.',
                      style: _nunito(
                        size: 12,
                        weight: FontWeight.w500,
                        color: AppColors.jebbyTextMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.jebbyTextMuted.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
