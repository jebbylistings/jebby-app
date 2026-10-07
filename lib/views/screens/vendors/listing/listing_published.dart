import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_illustrations.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';
import 'package:jebby/views/screens/vendors/my_products.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';
import 'package:jebby/views/screens/vendors/product_details.dart';

class ListingPublishedScreen extends StatefulWidget {
  final String listingName;
  final String pricePerDay;
  final String locationLabel;
  final ListingPhotoRef? coverPhoto;
  final String? productId;

  const ListingPublishedScreen({
    super.key,
    required this.listingName,
    this.pricePerDay = '',
    this.locationLabel = '',
    this.coverPhoto,
    this.productId,
  });

  @override
  State<ListingPublishedScreen> createState() => _ListingPublishedScreenState();
}

class _ListingPublishedScreenState extends State<ListingPublishedScreen> {
  bool _payoutSetupComplete = false;
  bool _loadingPayout = true;

  @override
  void initState() {
    super.initState();
    _loadPayoutFlag();
  }

  Future<void> _loadPayoutFlag() async {
    final controller = ensureOnboardingController();
    await controller.refreshStripeStatus();
    final response = controller.lastStripeStatusResponse;
    if (!mounted) return;
    setState(() {
      _payoutSetupComplete = response != null &&
          StripeRequirementFields.payoutSetupCompleteForBookings(response);
      _loadingPayout = false;
    });
  }

  String get _priceLine {
    final raw = widget.pricePerDay.trim();
    if (raw.isEmpty) return '— / day';
    final value = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (value == null) return '\$$raw / day';
    final text = value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(2);
    return '\$$text / day';
  }

  String get _locationDetail {
    final loc = widget.locationLabel.trim();
    if (loc.isEmpty) return 'Location not set';
    return loc;
  }

  String get _metaLine => '$_priceLine · $_locationDetail';

  void _goToMyListings() {
    Get.offAll(() => MyProductsScreen(side: false));
  }

  void _finishPayoutSetup() {
    Get.offAll(() => const VendorMyTransactionsScreen());
  }

  Widget _photoPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 28),
    );
  }

  Widget _coverPhoto() {
    final photo = widget.coverPhoto;
    if (photo == null) return _photoPlaceholder();
    if (photo.kind == ListingPhotoKind.local) {
      final file = File(photo.path);
      if (!file.existsSync()) return _photoPlaceholder();
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(),
      );
    }
    final url = ProfileImage.resolveUrl(AppUrl.baseUrlM, photo.path);
    if (url == null) return _photoPlaceholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _photoPlaceholder(),
    );
  }

  void _openListingDetail() {
    final id = widget.productId;
    if (id == null || id.isEmpty) return;
    Get.to(() => VendorProductDetailScreen(id: id));
  }

  @override
  Widget build(BuildContext context) {
    final needsPayout = !_loadingPayout && !_payoutSetupComplete;
    final statusLabel = needsPayout
        ? 'Published · Booking unavailable'
        : 'Published · Ready for bookings';

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OnboardingIllustration(
                      assetPath: 'assets/images/listing-success.png',
                      height: 240,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your item is listed!',
                      textAlign: TextAlign.center,
                      style: onboardingNunito(size: 24, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      needsPayout
                          ? 'Your listing is live. Finish payouts to enable bookings.'
                          : 'Your listing is live and ready for bookings.',
                      textAlign: TextAlign.center,
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.productId != null ? _openListingDetail : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE3E6EC)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: _coverPhoto(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.listingName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: onboardingNunito(
                                          size: 16,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _metaLine,
                                        style: onboardingNunito(
                                          size: 13,
                                          weight: FontWeight.w600,
                                          color: AppColors.jebbyTextMuted,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: needsPayout
                                                  ? const Color(0xFF22C55E)
                                                  : const Color(0xFF22C55E),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              statusLabel,
                                              style: onboardingNunito(
                                                size: 13,
                                                weight: FontWeight.w600,
                                                color: AppColors.jebbyTextMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.jebbyTextMuted
                                      .withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (needsPayout) ...[
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE3E6EC),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE3E6EC)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              OnboardingIllustrationAsset.stripeLogo,
                              height: 22,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Text(
                                'stripe',
                                style: onboardingNunito(
                                  size: 18,
                                  weight: FontWeight.w800,
                                  color: const Color(0xFF635BFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Finish payout setup to accept bookings and get paid.',
                                style: onboardingNunito(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.jebbyTextMuted,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  if (needsPayout)
                    OnboardingPrimaryButton(
                      label: 'Finish payout setup',
                      onPressed: _finishPayoutSetup,
                    )
                  else
                    OnboardingPrimaryButton(
                      label: 'View my listings',
                      onPressed: _goToMyListings,
                    ),
                  const SizedBox(height: 10),
                  OnboardingSecondaryButton(
                    label: 'List another item',
                    onPressed: () => Get.offAll(
                      () => const CreateListingScreen(popToProductsOnBack: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
