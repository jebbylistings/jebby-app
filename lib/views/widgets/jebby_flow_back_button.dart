import 'package:flutter/material.dart';

import '../../constants/color.dart';

/// Soft-blue circular back control (inspection / reservation flow header).
class JebbyFlowBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const JebbyFlowBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
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
