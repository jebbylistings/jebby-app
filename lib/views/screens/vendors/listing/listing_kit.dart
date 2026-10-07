import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';

class ListingStepLabels {
  static const totalSteps = 5;
  static const labels = [
    'Photos & basics',
    'Category & condition',
    'Pricing',
    'Pickup & availability',
    'Review',
  ];

  static String stepCaption(int step) {
    final i = step.clamp(1, totalSteps);
    return 'Step $i of $totalSteps · ${labels[i - 1]}';
  }
}

class ListingStepProgressBar extends StatelessWidget {
  final int currentStep;

  const ListingStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(ListingStepLabels.totalSteps, (index) {
        final step = index + 1;
        final active = step <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.jebbyBlue
                    : AppColors.jebbySoftBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ListingStepShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? stepNumber;
  final Widget body;
  final Widget? bottomBar;
  final VoidCallback? onBack;
  final bool bodyScrollable;
  final Color? subtitleColor;

  const ListingStepShell({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.stepNumber,
    required this.body,
    this.bottomBar,
    this.onBack,
    this.bodyScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      title: title,
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      headerDivider: stepNumber != null,
      onBack: onBack,
      bodyScrollable: bodyScrollable,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stepNumber != null) ...[
            ListingStepProgressBar(currentStep: stepNumber!),
            const SizedBox(height: 10),
            Text(
              ListingStepLabels.stepCaption(stepNumber!),
              textAlign: TextAlign.center,
              style: onboardingNunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (bodyScrollable) body else Expanded(child: body),
        ],
      ),
      bottomBar: bottomBar,
    );
  }
}

/// Handoff mock switch — blue when on; taupe thumb + pale track when off.
class ListingHandoffSwitch extends StatelessWidget {
  static const Color offThumb = Color(0xFF8B7E7E);
  static const Color offTrack = Color(0xFFF4EBEB);

  final bool value;
  final ValueChanged<bool>? onChanged;

  const ListingHandoffSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static SwitchThemeData themeData() {
    return SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.jebbyBlue;
        }
        return offThumb;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.jebbyBlue.withValues(alpha: 0.35);
        }
        return offTrack;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return offThumb;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwitchTheme(
      data: themeData(),
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}

class ListingHubRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const ListingHubRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E6EC)),
          ),
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.jebbySoftBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: onboardingNunito(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.jebbyTextMuted),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class ListingSummaryCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  const ListingSummaryCard({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Edit',
                    style: onboardingNunito(
                      size: 14,
                      weight: FontWeight.w800,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

Future<bool?> showListingDiscardDialog(BuildContext context) {
  const destructiveRed = Color(0xFFDC2626);

  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 12,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.earnerInfoBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_note_outlined,
                    size: 26,
                    color: AppColors.jebbyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Discard changes?',
                textAlign: TextAlign.center,
                style: onboardingNunito(size: 19, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Your changes haven\'t been saved.',
                textAlign: TextAlign.center,
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              OnboardingPrimaryButton(
                label: 'Keep editing',
                onPressed: () => Navigator.pop(ctx, false),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: destructiveRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Discard changes',
                  style: onboardingNunito(
                    size: 15,
                    weight: FontWeight.w800,
                    color: destructiveRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

const Color _listingSheetDividerColor = Color(0xFFE3E6EC);

Widget _listingSheetDivider() => const Divider(
      height: 1,
      thickness: 1,
      color: _listingSheetDividerColor,
    );

Future<ImageSource?> showListingPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              'Add a photo',
              textAlign: TextAlign.center,
              style: onboardingNunito(size: 18, weight: FontWeight.w800),
            ),
          ),
          _listingSheetDivider(),
          _listingPhotoSourceRow(
            ctx,
            icon: Icons.photo_camera_outlined,
            label: 'Take photo',
            source: ImageSource.camera,
          ),
          _listingSheetDivider(),
          _listingPhotoSourceRow(
            ctx,
            icon: Icons.photo_outlined,
            label: 'Choose from photos',
            source: ImageSource.gallery,
          ),
          _listingSheetDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Material(
              color: AppColors.jebbySoftBlue,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.pop(ctx),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
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

Widget _listingPhotoSourceRow(
  BuildContext ctx, {
  required IconData icon,
  required String label,
  required ImageSource source,
}) {
  return Material(
    color: Colors.white,
    child: InkWell(
      onTap: () => Navigator.pop(ctx, source),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _sheetIcon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: onboardingNunito(size: 16, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _sheetIcon(IconData icon) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.jebbySoftBlue,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
  );
}

enum ListingPhotoAction { makeCover, replace, remove }

Future<ListingPhotoAction?> showListingPhotoActionsSheet(
  BuildContext context, {
  required int photoIndex,
  required int totalPhotos,
  required Widget preview,
}) {
  return showModalBottomSheet<ListingPhotoAction>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Photo ${photoIndex + 1} of $totalPhotos',
                style: onboardingNunito(size: 18, weight: FontWeight.w800),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: preview,
            ),
          ),
          const SizedBox(height: 16),
          _listingSheetDivider(),
          _listingPhotoActionRow(
            ctx,
            icon: Icons.image_outlined,
            label: 'Make cover photo',
            action: ListingPhotoAction.makeCover,
          ),
          _listingSheetDivider(),
          _listingPhotoActionRow(
            ctx,
            icon: Icons.sync,
            label: 'Replace photo',
            action: ListingPhotoAction.replace,
          ),
          _listingSheetDivider(),
          _listingPhotoActionRow(
            ctx,
            icon: Icons.delete_outline,
            label: 'Remove photo',
            action: ListingPhotoAction.remove,
            destructive: true,
          ),
          _listingSheetDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Material(
              color: AppColors.jebbySoftBlue,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.pop(ctx),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Center(
                    child: Text(
                      'Done',
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
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

Widget _listingPhotoActionRow(
  BuildContext ctx, {
  required IconData icon,
  required String label,
  required ListingPhotoAction action,
  bool destructive = false,
}) {
  final iconColor = destructive ? Colors.red : AppColors.jebbyBlue;
  final textColor = destructive ? Colors.red : AppColors.jebbyTextPrimary;
  return Material(
    color: Colors.white,
    child: InkWell(
      onTap: () => Navigator.pop(ctx, action),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: destructive ? Colors.red.shade50 : AppColors.jebbySoftBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: onboardingNunito(
                  size: 16,
                  weight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<String?> showListingChoiceSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
  bool loadFailed = false,
  VoidCallback? onRetry,
}) async {
  if (loadFailed) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              "We couldn't load options.",
              style: onboardingNunito(size: 16, weight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            OnboardingPrimaryButton(
              label: 'Try again',
              onPressed: () {
                Navigator.pop(ctx);
                onRetry?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  var current = selected;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.82;
          const headerBlock = 118.0;
          const footerBlock = 82.0;
          const rowBlock = 53.0;
          final intrinsicHeight =
              headerBlock + options.length * rowBlock + footerBlock;
          final sheetHeight = math.min(intrinsicHeight, maxSheetHeight);
          return SafeArea(
            child: SizedBox(
              height: sheetHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: onboardingNunito(size: 18, weight: FontWeight.w800),
                    ),
                  ),
                  _listingSheetDivider(),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => _listingSheetDivider(),
                      itemBuilder: (context, index) {
                        final opt = options[index];
                        final picked = opt == current;
                        return Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => setState(() => current = opt),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: onboardingNunito(
                                        size: 16,
                                        weight: picked
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: picked
                                            ? AppColors.jebbyBlue
                                            : AppColors.jebbyTextPrimary,
                                      ),
                                    ),
                                  ),
                                  if (picked)
                                    Icon(
                                      Icons.check,
                                      color: AppColors.jebbyBlue,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _listingSheetDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Material(
                      color: AppColors.jebbySoftBlue,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Center(
                            child: Text(
                              'Done',
                              style: onboardingNunito(
                                size: 16,
                                weight: FontWeight.w800,
                                color: AppColors.jebbyBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  return current;
}

/// Highlight row drawn *behind* [CupertinoPicker] wheels. Do not use a solid
/// [CupertinoPicker.selectionOverlay] — it paints on top and hides the value.
Widget _listingTimeWheelHighlightRow() {
  return IgnorePointer(
    child: Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.jebbySoftBlue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ),
  );
}

TextStyle _listingTimeWheelItemStyle() {
  return onboardingNunito(
    size: 20,
    weight: FontWeight.w700,
    color: AppColors.jebbyTextPrimary,
  );
}

Widget _listingSheetHeaderTextAction({
  required String label,
  required VoidCallback onTap,
  required TextStyle textStyle,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
      highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(label, style: textStyle),
      ),
    ),
  );
}

Future<TimeOfDay?> showListingTimeWheelSheet(
  BuildContext context, {
  required String title,
  required TimeOfDay initial,
}) async {
  var hour = initial.hour;
  var minute = initial.minute;
  var isAm = hour < 12;
  var hour12 = hour % 12;
  if (hour12 == 0) hour12 = 12;

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (ctx) {
      final actionStyle = onboardingNunito(
        size: 16,
        weight: FontWeight.w800,
        color: AppColors.jebbyBlue,
      );

      return SafeArea(
        top: false,
        child: SizedBox(
          height: 340,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DCE6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Row(
                  children: [
                    _listingSheetHeaderTextAction(
                      label: 'Cancel',
                      textStyle: actionStyle,
                      onTap: () => Navigator.pop(ctx),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: onboardingNunito(
                          size: 17,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _listingSheetHeaderTextAction(
                      label: 'Done',
                      textStyle: actionStyle,
                      onTap: () {
                        var h24 = hour12 % 12;
                        if (!isAm) h24 += 12;
                        Navigator.pop(
                          ctx,
                          TimeOfDay(hour: h24, minute: minute),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _listingTimeWheelHighlightRow(),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: hour12 - 1,
                              ),
                              itemExtent: 44,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) => hour12 = i + 1,
                              children: List.generate(
                                12,
                                (i) => Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: _listingTimeWheelItemStyle(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: minute,
                              ),
                              itemExtent: 44,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (m) => minute = m,
                              children: List.generate(
                                60,
                                (i) => Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: _listingTimeWheelItemStyle(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: isAm ? 0 : 1,
                              ),
                              itemExtent: 44,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) => isAm = i == 0,
                              children: [
                                Center(
                                  child: Text(
                                    'AM',
                                    style: _listingTimeWheelItemStyle(),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'PM',
                                    style: _listingTimeWheelItemStyle(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
