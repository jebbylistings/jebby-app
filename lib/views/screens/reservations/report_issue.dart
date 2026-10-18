import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../utils/show_snackbar.dart';
import '../../../view_models/reservation_view_model.dart';
import '../../widgets/jebby_flow_back_button.dart';
import '../onboarding/onboarding_kit.dart';
import '../vendors/listing/listing_kit.dart';
import 'reservation_flow_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  final int orderId;
  final String? phase;

  const ReportIssueScreen({super.key, required this.orderId, this.phase});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const Color _cardBorder = Color(0xFFE8E8EC);
  static const int _maxDescriptionLength = 1000;
  static const int _maxPhotos = 3;

  static const List<MapEntry<String, String>> _categories = [
    MapEntry('damage', 'Item is damaged'),
    MapEntry('missing_item', 'Missing accessories'),
    MapEntry('other', "Item isn't working properly"),
    MapEntry('no_show', 'Late return / not on time'),
    MapEntry('other_issue', 'Other'),
  ];

  ReservationFlowTheme get _theme => ReservationFlowTheme(widget.phase ?? 'pickup');

  String _category = 'damage';
  final _descriptionController = TextEditingController();
  final List<File> _photos = [];
  bool _submitting = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String get _apiCategory => _category == 'other_issue' ? 'other' : _category;

  bool get _canAddPhoto => _photos.length < _maxPhotos;

  @override
  Widget build(BuildContext context) {
    final noteLength = _descriptionController.text.length;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _pageHeader(),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: _cardBorder),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tell us what happened',
                      style: onboardingNunito(size: 22, weight: FontWeight.w800, height: 1.15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share the details so we can better understand the issues.',
                      style: onboardingNunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Choose an issue',
                      style: onboardingNunito(size: 16, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    ..._categories.map((entry) => _categoryOption(entry.key, entry.value)),
                    const SizedBox(height: 20),
                    Text(
                      'Add photos (optional)',
                      style: onboardingNunito(size: 16, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    _photoSection(),
                    const SizedBox(height: 24),
                    Text(
                      'Tell us more (optional)',
                      style: onboardingNunito(size: 16, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      minLines: 5,
                      maxLength: _maxDescriptionLength,
                      enabled: !_submitting,
                      onChanged: (_) => setState(() {}),
                      style: onboardingNunito(size: 15, weight: FontWeight.w600, height: 1.45),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        hintText: 'Describe the issue in detail...',
                        hintStyle: onboardingNunito(
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                          height: 1.45,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _theme.accent, width: 1.5),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '$noteLength/$_maxDescriptionLength',
                          style: onboardingNunito(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoBanner(),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: _theme.primaryButton(),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit Report'),
                  ),
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
        JebbyFlowBackButton(onTap: Get.back),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report an Issue',
                  style: onboardingNunito(size: 22, weight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  "We're here to help",
                  style: onboardingNunito(
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

  Widget _categoryOption(String value, String label) {
    return InkWell(
      onTap: _submitting
          ? null
          : () => setState(() => _category = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _category,
              activeColor: AppColors.jebbyBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: _submitting
                  ? null
                  : (next) => setState(() => _category = next ?? value),
            ),
            Expanded(
              child: Text(
                label,
                style: onboardingNunito(size: 16, weight: FontWeight.w600, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._photos.map(
            (file) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(file, width: 88, height: 88, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: _submitting ? null : () => setState(() => _photos.remove(file)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_canAddPhoto)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DottedBorder(
                  color: AppColors.jebbyBlue,
                  strokeWidth: 2,
                  dashPattern: const [7, 5],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(14),
                  child: Material(
                    color: AppColors.earnerInfoBlue,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _submitting ? null : _pickPhoto,
                      borderRadius: BorderRadius.circular(14),
                      splashColor: AppColors.jebbyBlue.withValues(alpha: 0.18),
                      highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
                      child: const SizedBox(
                        width: 88,
                        height: 88,
                        child: Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.jebbyBlue,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: _submitting ? null : _pickPhoto,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Add photos',
                    style: onboardingNunito(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.jebbyBlue,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.jebbySoftBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: AppColors.jebbyBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "We'll review your report and contact you or the other person if we need more details",
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (!_canAddPhoto) {
      showAppErrorSnackbar('You can add up to $_maxPhotos photos.');
      return;
    }
    final source = await showListingPhotoSourceSheet(
      context,
      title: 'Add issue photo',
      takePhotoLabel: 'Take a photo',
      galleryLabel: 'Choose from gallery',
    );
    if (source == null || !mounted) return;

    XFile? image;
    try {
      image = await _picker.pickImage(source: source, imageQuality: 85);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final cameraUnavailable = source == ImageSource.camera &&
          (e.code == 'camera_access_denied' ||
              e.code == 'camera_unavailable' ||
              e.message?.toLowerCase().contains('camera') == true);
      if (cameraUnavailable) {
        showAppErrorSnackbar('Camera unavailable. Choose a photo from your library instead.');
      } else {
        showAppErrorSnackbar('Unable to add photo. Please try again.');
      }
      return;
    }

    if (image == null || !mounted) return;
    if (!_canAddPhoto) return;
    final picked = File(image.path);
    setState(() => _photos.add(picked));
  }

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      showAppErrorSnackbar('Please add at least one photo.', title: 'Required');
      return;
    }
    setState(() => _submitting = true);
    final vm = context.read<ReservationViewModel>();
    final ok = await vm.reportDispute(
      widget.orderId,
      phase: widget.phase,
      category: _apiCategory,
      description: _descriptionController.text.trim(),
      photos: _photos,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Get.back(result: true);
    } else if (vm.error != null && vm.error!.isNotEmpty) {
      showAppErrorSnackbar(vm.error!);
    }
  }
}
