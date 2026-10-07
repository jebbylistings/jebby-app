import 'package:flutter/material.dart';
import 'package:jebby/constants/color.dart';

class LoaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.jebbyBlue,
        backgroundColor: AppColors.jebbySoftBlue,
        strokeWidth: 2.5,
      ),
    );
  }
}
