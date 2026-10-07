import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/handoff_window.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/utils/listing_handoff_summary.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/view_models/listing_form_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/handoff_hub_screens.dart';
import 'package:jebby/views/screens/vendors/listing/listing_kit.dart';
import 'package:jebby/views/screens/vendors/listing/location_hub_screens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Widget _listingPhotoMissingPlaceholder() {
  return Container(
    color: Colors.grey.shade200,
    alignment: Alignment.center,
    child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade500),
  );
}

Widget _listingPhotoPreviewWidget(ListingPhotoRef photo) {
  if (photo.kind == ListingPhotoKind.local) {
    final file = File(photo.path);
    if (!file.existsSync()) {
      return _listingPhotoMissingPlaceholder();
    }
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _listingPhotoMissingPlaceholder(),
    );
  }
  final url = ProfileImage.resolveUrl(AppUrl.baseUrlM, photo.path);
  if (url != null) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _listingPhotoMissingPlaceholder(),
    );
  }
  return _listingPhotoMissingPlaceholder();
}

Widget _listingItemSummaryCard(
  ListingFormController c, {
  String? subtitle,
}) {
  final name = c.draft.name.trim().isEmpty ? 'Your item' : c.draft.name.trim();
  final photos = c.draft.photos;
  ListingPhotoRef? previewPhoto;
  if (photos.isNotEmpty) {
    for (final p in photos) {
      if (p.isCover) {
        previewPhoto = p;
        break;
      }
    }
    previewPhoto ??= photos.first;
  }
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.earnerInfoBlue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (previewPhoto != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: _listingPhotoPreviewWidget(previewPhoto),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: onboardingNunito(size: 16, weight: FontWeight.w800),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
      ],
    ),
  );
}

void _syncTextController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );
}

class ListingPhotosBasicsStep extends StatefulWidget {
  const ListingPhotosBasicsStep({super.key});

  @override
  State<ListingPhotosBasicsStep> createState() => _ListingPhotosBasicsStepState();
}

class _ListingPhotosBasicsStepState extends State<ListingPhotosBasicsStep> {
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final c = Get.find<ListingFormController>();
    _name = TextEditingController(text: c.draft.name);
    _description = TextEditingController(text: c.draft.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        _syncTextController(_name, c.draft.name);
        _syncTextController(_description, c.draft.description);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Make more of what you own.',
              style: onboardingNunito(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Help renters picture the possibilities',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text('Photos', style: onboardingNunito(weight: FontWeight.w800)),
            const SizedBox(height: 12),
            _photosSection(context, c),
            const SizedBox(height: 20),
            const OnboardingFieldLabel('What are you listing', muted: true),
            OnboardingTextField(
              controller: _name,
              hint: 'Beach Umbrella',
              fillColor: Colors.white,
              onChanged: (v) {
                c.draft.name = v;
                c.markDirty();
              },
            ),
            const SizedBox(height: 16),
            const OnboardingFieldLabel('Tell renters about your item', muted: true),
            OnboardingTextField(
              controller: _description,
              hint:
                  'What\'s it great for? Mention useful details, what\'s included, and any wear',
              fillColor: Colors.white,
              minLines: 4,
              maxLines: 8,
              onChanged: (v) {
                c.draft.description = v;
                c.markDirty();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _photosSection(BuildContext context, ListingFormController c) {
    final photos = c.draft.photos;
    final canAddMore = photos.length < ListingDraft.maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photos.isEmpty && canAddMore)
          _largeAddPhoto(context, c)
        else if (photos.isNotEmpty) ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...List.generate(
                photos.length,
                (i) => _photoTile(context, c, i),
              ),
              if (canAddMore) _compactAddPhotoTile(context, c),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Add ${ListingDraft.minPhotos}-${ListingDraft.maxPhotos} photos. Show the whole item, different angles, and any wear. Tap a photo to edit.',
          style: onboardingNunito(
            size: 13,
            color: AppColors.jebbyTextMuted,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(BuildContext context, ListingFormController c) async {
    final source = await showListingPhotoSourceSheet(context);
    if (source != null) await c.pickPhoto(source);
  }

  Widget _compactAddPhotoTile(BuildContext context, ListingFormController c) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickPhoto(context, c),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.earnerInfoBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.jebbyBlue, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.jebbyBlue, size: 28),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: onboardingNunito(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _largeAddPhoto(BuildContext context, ListingFormController c) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickPhoto(context, c),
        borderRadius: BorderRadius.circular(16),
        child: DottedBorder(
          color: AppColors.jebbyBlue,
          strokeWidth: 2,
          dashPattern: const [7, 5],
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          stackFit: StackFit.passthrough,
          child: Container(
            width: double.infinity,
            height: 112,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.earnerInfoBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.jebbyBlue,
                  size: 32,
                ),
                const SizedBox(height: 6),
                Text(
                  'Add photo',
                  style: onboardingNunito(
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.jebbyBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoTile(BuildContext context, ListingFormController c, int index) {
    final photo = c.draft.photos[index];
    Widget image;
    image = _listingPhotoPreviewWidget(photo);
    return GestureDetector(
      onTap: () async {
        final action = await showListingPhotoActionsSheet(
          context,
          photoIndex: index,
          totalPhotos: c.draft.photos.length,
          preview: SizedBox(height: 160, width: double.infinity, child: image),
        );
        if (action == null) return;
        switch (action) {
          case ListingPhotoAction.makeCover:
            c.setCover(index);
          case ListingPhotoAction.replace:
            final source = await showListingPhotoSourceSheet(context);
            if (source != null) await c.replacePhoto(index, source);
          case ListingPhotoAction.remove:
            c.removePhoto(index);
        }
        await c.persistDraft();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 100, height: 100, child: image),
          ),
          if (photo.isCover)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.jebbyBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Cover',
                  style: onboardingNunito(size: 10, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ListingCategoryConditionStep extends StatelessWidget {
  const ListingCategoryConditionStep({super.key});

  static const _conditionOptions = [
    ('excellent', 'Excellent', 'Minimal or no visible wear.'),
    ('good', 'Good', 'Some visible wear; works as expected.'),
    ('fair', 'Fair', 'Noticeable wear; works as expected.'),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Lets get to know your item',
              style: onboardingNunito(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Help renters choose with confidence.',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            _listingItemSummaryCard(
              c,
              subtitle: c.draft.description.trim(),
            ),
            const SizedBox(height: 20),
            _pickerField(
              context,
              label: 'Category',
              value: c.draft.categoryName.isEmpty ? 'Choose category' : c.draft.categoryName,
              onTap: () async {
                final names = c.categories.map((e) => e['name'] as String).toList();
                final picked = await showListingChoiceSheet(
                  context,
                  title: 'Choose a category',
                  options: names,
                  selected: c.draft.categoryName.isEmpty ? null : c.draft.categoryName,
                  loadFailed: c.categoriesFailed,
                  onRetry: c.loadCategories,
                );
                if (picked == null) return;
                final match = c.categories.firstWhere((e) => e['name'] == picked);
                c.draft.categoryId = match['id'] as String;
                c.draft.categoryName = picked;
                c.draft.subcategoryId = '';
                c.draft.subcategoryName = '';
                await c.loadSubcategories(c.draft.categoryId);
                c.markDirty();
                c.update();
              },
            ),
            const SizedBox(height: 12),
            _pickerField(
              context,
              label: 'Subcategory',
              value: c.draft.subcategoryName.isEmpty ? 'Choose subcategory' : c.draft.subcategoryName,
              onTap: () async {
                if (c.draft.categoryId.isEmpty) return;
                final names = c.subcategories.map((e) => e['name'] as String).toList();
                final picked = await showListingChoiceSheet(
                  context,
                  title: 'Choose a subcategory',
                  options: names,
                  selected: c.draft.subcategoryName.isEmpty ? null : c.draft.subcategoryName,
                  loadFailed: c.subcategoriesFailed,
                  onRetry: () => c.loadSubcategories(c.draft.categoryId),
                );
                if (picked == null) return;
                final match = c.subcategories.firstWhere((e) => e['name'] == picked);
                c.draft.subcategoryId = match['id'] as String;
                c.draft.subcategoryName = picked;
                c.markDirty();
                c.update();
              },
            ),
            const SizedBox(height: 24),
            Text(
              'What condition is it in?',
              style: onboardingNunito(size: 18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ..._conditionOptions.map((entry) {
              final key = entry.$1;
              final title = entry.$2;
              final subtitle = entry.$3;
              final selected = c.draft.conditionRating == key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: selected ? AppColors.jebbySoftBlue : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () {
                      c.draft.conditionRating = key;
                      c.markDirty();
                      c.update();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.jebbyBlue
                              : const Color(0xFFE3E6EC),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: _conditionRadio(selected: selected),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: onboardingNunito(
                                    weight: FontWeight.w700,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: onboardingNunito(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: AppColors.jebbyTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            Text(
              'Describe any wear and show it in your photos.',
              style: onboardingNunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _conditionRadio({required bool selected}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.jebbyBlue : const Color(0xFFC6C8CF),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.jebbyBlue,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Widget _pickerField(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value.startsWith('Choose ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingFieldLabel(label, muted: true),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE3E6EC)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: onboardingNunito(
                        weight: FontWeight.w600,
                        color: isPlaceholder
                            ? AppColors.jebbyTextMuted
                            : AppColors.jebbyTextPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more, color: AppColors.jebbyTextMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Digits and at most one decimal point (blocks letters and symbols).
class _DecimalMoneyInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || _pattern.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

class ListingPricingStep extends StatefulWidget {
  const ListingPricingStep({super.key});

  @override
  State<ListingPricingStep> createState() => _ListingPricingStepState();
}

class _ListingPricingStepState extends State<ListingPricingStep> {
  late final TextEditingController _price;
  late final TextEditingController _deposit;

  @override
  void initState() {
    super.initState();
    final c = Get.find<ListingFormController>();
    _price = TextEditingController(text: c.draft.pricePerDay);
    _deposit = TextEditingController(text: c.draft.securityDeposit);
  }

  @override
  void dispose() {
    _price.dispose();
    _deposit.dispose();
    super.dispose();
  }

  String _categorySubtitle(ListingFormController c) {
    final parts = <String>[
      if (c.draft.categoryName.isNotEmpty) c.draft.categoryName,
      if (c.draft.subcategoryName.isNotEmpty) c.draft.subcategoryName,
    ];
    return parts.join(' · ');
  }

  Widget _moneyField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hint = '0.00',
    String? suffixText,
  }) {
    final suffixStyle = onboardingNunito(
      size: 14,
      weight: FontWeight.w600,
      color: AppColors.jebbyTextMuted,
    );
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_DecimalMoneyInputFormatter()],
      onChanged: onChanged,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1B1B1F),
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF8F9098),
        ),
        prefixText: '\$',
        prefixStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1B1B1F),
        ),
        suffixText: suffixText,
        suffixStyle: suffixText != null ? suffixStyle : null,
        filled: true,
        fillColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        _syncTextController(_price, c.draft.pricePerDay);
        _syncTextController(_deposit, c.draft.securityDeposit);
        final categoryLine = _categorySubtitle(c);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set your price.',
              style: onboardingNunito(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose a daily rate that works for you.',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            _listingItemSummaryCard(
              c,
              subtitle: categoryLine.isEmpty ? null : categoryLine,
            ),
            const SizedBox(height: 20),
            const OnboardingFieldLabel('Price per day', muted: true),
            _moneyField(
              controller: _price,
              hint: '5.00',
              onChanged: (v) {
                c.draft.pricePerDay = v;
                c.markDirty();
              },
              suffixText: '/ day',
            ),
            const SizedBox(height: 16),
            const OnboardingFieldLabel('Security deposit (optional)', muted: true),
            _moneyField(
              controller: _deposit,
              onChanged: (v) {
                c.draft.securityDeposit = v;
                c.markDirty();
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Helps cover damage or loss. Leave at \$0 if you don\'t want to require a deposit. Set to \$0 for no deposit.',
              style: onboardingNunito(
                size: 13,
                color: AppColors.jebbyTextMuted,
                weight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

String _compactBlockedDatesRange(List<String> blockedKeys) {
  if (blockedKeys.isEmpty) return '';
  final dates = blockedKeys.map(DateTime.parse).toList()..sort();
  final start = dates.first;
  final end = dates.last;
  if (dates.length == 1) {
    return DateFormat('MMM d').format(start);
  }
  if (start.month == end.month && start.year == end.year) {
    final month = DateFormat('MMM').format(start);
    return '$month ${start.day}-${end.day}';
  }
  final startLabel = DateFormat('MMM d').format(start);
  final endLabel = DateFormat('MMM d').format(end);
  return '$startLabel - $endLabel';
}

String _listingAvailabilityHubValue(ListingDraft draft) {
  final blocked = draft.availability.blockedDates;
  if (blocked.isEmpty) {
    return 'Available unless you block dates.';
  }
  final count = blocked.length;
  final countLabel = '$count blocked date${count == 1 ? '' : 's'}';
  final range = _compactBlockedDatesRange(blocked);
  if (range.isEmpty) return countLabel;
  return '$countLabel · $range';
}

String _advanceNoticeHubLabel(int hours) {
  if (hours == 1) return "1 hour's notice";
  return "$hours hours' notice";
}

const _reviewDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _conditionReviewLabel(String key) {
  const labels = {
    'excellent': 'Excellent condition',
    'good': 'Good condition',
    'fair': 'Fair condition',
  };
  if (labels.containsKey(key)) return labels[key]!;
  if (key.isEmpty) return 'Condition not set';
  final label = key[0].toUpperCase() + key.substring(1);
  return '$label condition';
}

String _reviewCompactHandoffRange(HandoffWindow window) {
  final start = HandoffWindow.formatClock(window.startTime);
  final end = HandoffWindow.formatClock(window.endTime);
  final startParts = start.split(' ');
  final endParts = end.split(' ');
  if (startParts.length >= 2 &&
      endParts.length >= 2 &&
      startParts[1] == endParts[1]) {
    final startHour = startParts[0].replaceAll(':00', '');
    final endHour = endParts[0].replaceAll(':00', '');
    return '$startHour-$endHour ${startParts[1]}';
  }
  return window.displayRange;
}

String _formatReviewDayIndices(List<int> days) {
  if (days.isEmpty) return '';
  final sorted = [...days]..sort();
  final runs = <List<int>>[];
  var run = [sorted.first];
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == run.last + 1) {
      run.add(sorted[i]);
    } else {
      runs.add(run);
      run = [sorted[i]];
    }
  }
  runs.add(run);

  String runLabel(List<int> chunk) {
    if (chunk.length == 1) return _reviewDayLabels[chunk.first];
    if (chunk.length == 2) {
      return '${_reviewDayLabels[chunk.first]} & ${_reviewDayLabels[chunk.last]}';
    }
    return '${_reviewDayLabels[chunk.first]}-${_reviewDayLabels[chunk.last]}';
  }

  return runs.map(runLabel).join(' & ');
}

List<String> _reviewHandoffScheduleLines(HandoffSchedule schedule) {
  final activeDays = schedule.weekdays.toList()..sort();
  if (activeDays.isEmpty) return const ['No handoff times set'];

  final groups = <String, List<int>>{};
  for (final day in activeDays) {
    final windows = schedule.windowsForDay(day);
    final signature = windows
        .map((w) => '${w.startTime}_${w.endTime}')
        .join(';');
    groups.putIfAbsent(signature, () => []).add(day);
  }

  final entries = groups.entries.toList()
    ..sort((a, b) => a.value.first.compareTo(b.value.first));

  return entries.map((entry) {
    final days = entry.value..sort();
    final windows = schedule.windowsForDay(days.first);
    final hours =
        windows.map(_reviewCompactHandoffRange).join(' · ');
    return '${_formatReviewDayIndices(days)}: $hours';
  }).toList();
}

String _reviewBlockedDatesLine(ListingDraft draft) {
  final blocked = draft.availability.blockedDates;
  if (blocked.isEmpty) return 'No blocked dates';
  final count = blocked.length;
  final countLabel = '$count blocked date${count == 1 ? '' : 's'}';
  final range = _compactBlockedDatesRange(blocked);
  if (range.isEmpty) return countLabel;
  return '$countLabel · $range';
}

String _pickupDeliveryReviewLabel(DeliveryOptions delivery) {
  if (delivery.offersPickup && delivery.offersDelivery) {
    return 'Pickup + delivery';
  }
  if (delivery.offersDelivery) return 'Delivery only';
  if (delivery.offersPickup) return 'Pickup only';
  return 'Not set';
}

String? _deliveryReviewSubline(DeliveryOptions delivery) {
  if (!delivery.offersDelivery) return null;
  final fee = double.tryParse(delivery.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  final feeLabel =
      fee <= 0 ? 'Free delivery & retrieval' : '\$${fee.toStringAsFixed(2)} delivery & retrieval';
  final miles = delivery.deliveryRadiusMiles.trim().isEmpty
      ? '10'
      : delivery.deliveryRadiusMiles.trim();
  return '$feeLabel · Within $miles mi';
}

String _reviewDepositLabel(String raw) {
  final value = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  if (value <= 0) return 'No security deposit';
  final text = value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(2);
  return '\$$text security deposit';
}

String _reviewPriceLine(String raw) {
  final value = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
  if (value == null || raw.trim().isEmpty) return '— / day';
  final text = value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(2);
  return '\$$text / day';
}

List<String> _rentalRulesReviewLines(RentalRules rules) {
  final notice = _advanceNoticeHubLabel(rules.advanceNoticeHours);
  final turnaround = rules.turnaroundHours <= 0
      ? 'No extra time after returns'
      : '${rules.turnaroundHours} hour${rules.turnaroundHours == 1 ? '' : 's'} after each return';
  final String lengthLine;
  if (rules.minRentalDays == null && rules.maxRentalDays == null) {
    lengthLine = 'No custom rental length limits';
  } else if (rules.minRentalDays != null && rules.maxRentalDays != null) {
    lengthLine =
        '${rules.minRentalDays}–${rules.maxRentalDays} day rental length';
  } else if (rules.minRentalDays != null) {
    lengthLine = 'Minimum ${rules.minRentalDays} day rental';
  } else {
    lengthLine = 'Maximum ${rules.maxRentalDays} day rental';
  }
  return [notice, turnaround, lengthLine];
}

Widget _reviewEditButton(VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
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
  );
}

class _ReviewSetupRow extends StatelessWidget {
  final IconData icon;
  final List<String> lines;
  final String? subline;

  const _ReviewSetupRow({
    required this.icon,
    required this.lines,
    this.subline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: AppColors.jebbyBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                if (subline != null && subline!.trim().isNotEmpty)
                  Text(
                    subline!,
                    style: onboardingNunito(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListingHandoffAvailabilityStep extends StatelessWidget {
  const ListingHandoffAvailabilityStep({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final location = c.draft.location;
        final loc = location.publicCityState.isEmpty
            ? 'Not set'
            : location.publicCityState;
        final locationSubtitle = location.line1.trim().isEmpty
            ? 'Add a pickup address'
            : 'Saved pickup address';
        final availabilityValue = _listingAvailabilityHubValue(c.draft);
        final noticeLabel =
            _advanceNoticeHubLabel(c.draft.rentalRules.advanceNoticeHours);
        final handoffLabels = handoffTimesHubLabels(c.draft.handoffSchedule);
        final delivery = c.draft.delivery;
        final handoffSummary = delivery.offersPickup && delivery.offersDelivery
            ? 'Pickup + delivery'
            : delivery.offersDelivery
                ? 'Delivery only'
                : 'Pickup only';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Renting, on your terms.',
              style: onboardingNunito(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Make sure these details work for you.',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            ListingHubRow(
              icon: Icons.location_on_outlined,
              title: 'Item location',
              value: loc,
              subtitle: locationSubtitle,
              onTap: () => Get.to(() => const ListingItemLocationScreen()),
            ),
            const SizedBox(height: 10),
            ListingHubRow(
              icon: Icons.calendar_month_outlined,
              title: 'Item availability',
              value: availabilityValue,
              subtitle: noticeLabel,
              onTap: () => Get.to(() => const ListingItemAvailabilityScreen()),
            ),
            const SizedBox(height: 10),
            ListingHubRow(
              icon: Icons.schedule_outlined,
              title: 'Handoff times',
              value: handoffLabels.value,
              subtitle: handoffLabels.subtitle,
              onTap: () => Get.to(() => const ListingHandoffTimesScreen()),
            ),
            const SizedBox(height: 10),
            ListingHubRow(
              icon: Icons.local_shipping_outlined,
              title: 'Pickup & delivery',
              value: handoffSummary,
              subtitle: delivery.offersDelivery
                  ? '${delivery.deliveryRadiusMiles} mi · \$${delivery.deliveryFee} fee'
                  : null,
              onTap: () => Get.to(() => const ListingPickupDeliveryScreen()),
            ),
            const SizedBox(height: 16),
            Text(
              'Your exact pickup address is only shown to renters with a confirmed booking.',
              textAlign: TextAlign.center,
              style: onboardingNunito(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ListingReviewStep extends StatelessWidget {
  final void Function(int step) onEditStep;

  const ListingReviewStep({super.key, required this.onEditStep});

  Widget _reviewItemCard(ListingDraft d, VoidCallback onEdit) {
    final name = d.name.trim().isEmpty ? 'Your item' : d.name.trim();
    final categoryParts = <String>[
      if (d.categoryName.trim().isNotEmpty) d.categoryName.trim(),
      if (d.subcategoryName.trim().isNotEmpty) d.subcategoryName.trim(),
    ];
    final categoryLine = categoryParts.join(' · ');

    ListingPhotoRef? previewPhoto;
    if (d.photos.isNotEmpty) {
      for (final p in d.photos) {
        if (p.isCover) {
          previewPhoto = p;
          break;
        }
      }
      previewPhoto ??= d.photos.first;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (previewPhoto != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _listingPhotoPreviewWidget(previewPhoto),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
                if (categoryLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    categoryLine,
                    style: onboardingNunito(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _conditionReviewLabel(d.conditionRating),
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          _reviewEditButton(onEdit),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final d = c.draft;
        final locationLabel = d.location.publicCityState.trim().isEmpty
            ? 'Location not set'
            : d.location.publicCityState.trim();
        final handoffLines = _reviewHandoffScheduleLines(d.handoffSchedule);
        final deliverySubline = _deliveryReviewSubline(d.delivery);
        final rulesLines = _rentalRulesReviewLines(d.rentalRules);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ready to go live?',
              style: onboardingNunito(size: 22, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Review your setup. Adjust what you need.',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _reviewItemCard(d, () => onEditStep(1)),
            const SizedBox(height: 12),
            ListingSummaryCard(
              title: 'Your price',
              onEdit: () => onEditStep(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reviewPriceLine(d.pricePerDay),
                    style: onboardingNunito(size: 20, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _reviewDepositLabel(d.securityDeposit),
                    style: onboardingNunito(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.jebbyTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListingSummaryCard(
              title: 'Your setup',
              onEdit: () => onEditStep(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReviewSetupRow(
                    icon: Icons.location_on_outlined,
                    lines: [locationLabel],
                  ),
                  _ReviewSetupRow(
                    icon: Icons.calendar_month_outlined,
                    lines: [_reviewBlockedDatesLine(d)],
                  ),
                  _ReviewSetupRow(
                    icon: Icons.calendar_month_outlined,
                    lines: handoffLines,
                  ),
                  _ReviewSetupRow(
                    icon: Icons.local_shipping_outlined,
                    lines: [_pickupDeliveryReviewLabel(d.delivery)],
                    subline: deliverySubline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListingSummaryCard(
              title: 'Rental rules',
              onEdit: () => Get.to(() => const ListingRentalRulesScreen()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rulesLines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.jebbyBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            line,
                            style: onboardingNunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
