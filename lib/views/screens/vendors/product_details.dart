import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';
import 'package:jebby/views/screens/agreements/insurance_and_indemnifications.dart';
import 'package:jebby/views/screens/agreements/rental_agreement.dart';
import 'package:jebby/views/screens/agreements/terms_and_conditions.dart';
import 'package:jebby/views/screens/agreements/transport_and_installation_policy.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';
import 'package:jebby/views/screens/vendors/my_products.dart';
import 'package:jebby/views/screens/shared/reviews.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/overlay_support.dart';
import 'package:jebby/utils/show_snackbar.dart';
import '../../../models/get_reviews_by_product_id_model.dart' as review_model;

import 'package:jebby/repositories/api_repository.dart';

TextStyle _nunito({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

class VendorProductDetailScreen extends StatefulWidget {
  final dynamic id;

  VendorProductDetailScreen({this.id});

  @override
  State<VendorProductDetailScreen> createState() =>
      _VendorProductDetailScreenState();
}

class _VendorProductDetailScreenState extends State<VendorProductDetailScreen> {
  static const Color _accent = AppColors.jebbyBlue;
  static const Color _labelGrey = Color(0xFF72747A);
  static const Color _bodyGrey = Color(0xFF6D6D75);
  static const Color _titleDark = Color(0xFF1B1B1F);

  static const Color _starAccent = Color(0xFFF6AE02);
  static const Color _starInactive = Color(0xFFC6C8CF);
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _ratingBarTrack = Color(0xFFF0F3F8);
  static const Color _conditionTeal = Color(0xFF10B981);
  static const Color _conditionTealBg = Color(0xFFDDF1EE);
  static const Color _deletePinkBg = Color(0xFFFFEBEE);
  static const double _sheetTopRadius = 36;
  static const double _sheetOverlap = 36;
  static const double _heroParallaxFactor = 0.45;
  static const double _maxPullDownExtent = 120;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  double _heroSwipeDragDelta = 0;
  int _carouselIndex = 0;

  String dropdownValue = 'One';
  bool isLoading = true;
  bool isError = false;
  bool emptyProdData = false;
  late var prodID;
  List imagesList = [];
  List imagesListID = [];
  var categoryID = null;
  var subCategoryID = null;
  var name = null;
  var price = null;
  var conditionRating = '';
  var description = null;
  var product_id = null;
  var images = null;
  var imageID = null;
  bool editVisibility = false;
  var length = "";
  var stars = "";
  var delivery_charges = null;
  int _reviewTotalFromApi = -1;
  bool _ratingReviewsExpanded = true;
  bool _serviceAgreementsExpanded = false;
  bool _reviewsDistributionLoaded = false;
  Map<int, double> _ratingDistribution = const {
    5: 0.0,
    4: 0.0,
    3: 0.0,
    2: 0.0,
    1: 0.0,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getProducts(widget.id.toString());
  }

  void _onScroll() {
    final next = _scrollController.offset;
    if (next == _scrollOffset) return;
    setState(() => _scrollOffset = next);
  }

  double _heroImageHeight(double screenHeight) => screenHeight * 0.36;

  /// Rubber-band pull at the top (negative scroll offset).
  double get _pullDownExtent =>
      math.min(_maxPullDownExtent, math.max(0.0, -_scrollOffset));

  double _heroScrollTranslateY() {
    if (_scrollOffset <= 0) return 0;
    return -_scrollOffset * _heroParallaxFactor;
  }

  double _parallaxImageLayerHeight(double screenHeight) {
    final imageH = _heroImageHeight(screenHeight);
    final heroHeight = imageH + _pullDownExtent;
    return heroHeight + imageH * _heroParallaxFactor;
  }

  /// Region above the sheet overlap where horizontal swipes should hit the PageView.
  double _heroSwipeHeight(double screenHeight) {
    final imageH = _heroImageHeight(screenHeight);
    final band = math.max(0.0, imageH - _sheetOverlap + _pullDownExtent);
    return (band - _scrollOffset).clamp(0.0, band);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDeleteProduct() async {
    final listingName = name?.toString().trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete listing?',
            style: _nunito(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _titleDark,
            ),
          ),
          content: Text(
            listingName != null && listingName.isNotEmpty
                ? 'Are you sure you want to delete "$listingName"? This cannot be undone.'
                : 'Are you sure you want to delete this listing? This cannot be undone.',
            style: _nunito(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _bodyGrey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: _nunito(
                  fontWeight: FontWeight.w600,
                  color: _labelGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: _nunito(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    Loader.show();
    try {
      final error = await ApiRepository.shared.deleteProductsById(prodID);
      if (!mounted) return;
      if (error == null) {
        Get.offAll(() => MyProductsScreen(side: false));
      } else {
        showAppErrorSnackbar(error);
      }
    } finally {
      Loader.hide();
    }
  }

  void getProducts(id) {
    setState(() {
      isLoading = true;
      isError = false;
      emptyProdData = false;
      imagesList = [];
      imagesListID = [];
    });

    ApiRepository.shared.getProductsById(
      (list) => {
        if (this.mounted)
          {
            if (list.data!.length == 0)
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  prodID =
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data![0]
                          .productId
                          .toString();
                }),
              }
            else
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  prodID =
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data![0]
                          .productId
                          .toString();
                }),
                for (
                  int i = 0;
                  i <
                      ApiRepository
                          .shared
                          .getProductsByIdList!
                          .data![1]
                          .images!
                          .length;
                  i++
                )
                  {
                    imagesList.add(
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data?[1]
                          .images?[i]
                          .path,
                    ),
                    imagesListID.add(
                      ApiRepository
                          .shared
                          .getProductsByIdList
                          ?.data?[1]
                          .images?[i]
                          .id,
                    ),
                  },
                categoryID =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .categoryId,
                subCategoryID =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .subcategoryId,
                name = ApiRepository.shared.getProductsByIdList?.data![0].name,
                price =
                    ApiRepository.shared.getProductsByIdList!.data![0].price
                        .toString(),
                conditionRating =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .conditionRating
                        ?.toString() ??
                    '',
                description =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .description,
                product_id =
                    ApiRepository
                        .shared
                        .getProductsByIdList
                        ?.data![0]
                        .productId,
                length =
                    ApiRepository.shared.getProductsByIdList!.data![0].length
                        .toString(),
                stars =
                    ApiRepository.shared.getProductsByIdList!.data![0].stars
                        .toString(),
                delivery_charges =
                    ApiRepository
                        .shared
                        .getProductsByIdList!
                        .data![0]
                        .delivery_charges
                        .toString(),
                _loadRatingDistribution(widget.id.toString()),
                images = imagesList,
                imageID = imagesListID,
                setState(() {
                  editVisibility = true;
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              isLoading = false;
              isError = true;
            }),
          },
      },
      id,
    );
  }

  double get _avgRating => double.tryParse(stars.toString())?.clamp(0, 5) ?? 0;

  int get _reviewCount =>
      _reviewTotalFromApi >= 0
          ? _reviewTotalFromApi
          : (int.tryParse(length.toString()) ?? 0);

  String _conditionDisplayLabel(String raw) {
    final key = raw.trim().toLowerCase();
    switch (key) {
      case 'excellent':
        return 'Excellent condition';
      case 'good':
        return 'Good condition';
      case 'fair':
        return 'Fair condition';
      default:
        if (key.isEmpty) return '';
        return '${key[0].toUpperCase()}${key.substring(1)} condition';
    }
  }

  void _loadRatingDistribution(String productId) {
    ApiRepository.shared.reviewsByProductId(productId, (
      review_model.GetAllReviewsByProductId list,
    ) {
      final data = list.data ?? const <review_model.Data>[];
      final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final r in data) {
        final s = r.stars ?? 0;
        if (s >= 1 && s <= 5) counts[s] = counts[s]! + 1;
      }
      final distribution =
          data.isEmpty
              ? const {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0}
              : {
                5: counts[5]! / data.length,
                4: counts[4]! / data.length,
                3: counts[3]! / data.length,
                2: counts[2]! / data.length,
                1: counts[1]! / data.length,
              };
      if (!mounted) return;
      setState(() {
        _reviewTotalFromApi = list.totalreviews ?? data.length;
        _ratingDistribution = distribution;
        _reviewsDistributionLoaded = true;
      });
    }, (_) {
      if (!mounted) return;
      setState(() => _reviewsDistributionLoaded = true);
    });
  }

  bool get _productReviewsEmpty =>
      _reviewsDistributionLoaded && _reviewCount == 0;

  void _openProductReviewsScreen() {
    if (prodID == null || stars.toString().isEmpty) return;
    Get.to(
      () => ReviewsScreen(
        stars: stars,
        reviewsLenght: length.toString(),
        prodID: prodID,
      ),
    );
  }

  /// Same as `MyProducts.productCard`: `Icons.star` / `Icons.star_border`,
  /// `_accent` / `_starInactive`, rounded fill count.
  Widget _myProductsStyleStars(double rating, {double size = 18}) {
    final filledStars = (rating.isNaN ? 0.0 : rating).round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < filledStars;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            active ? Icons.star : Icons.star_border,
            color: active ? _starAccent : _starInactive,
            size: size,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final conditionLabel = _conditionDisplayLabel(conditionRating);
    final carouselCount = imagesList.isEmpty ? 1 : imagesList.length;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.jebbyBlue),
              )
              : isError
              ? Center(
                child: Text(
                  'Error Loading Product',
                  style: _nunito(fontSize: 16, color: _bodyGrey),
                ),
              )
              : Stack(
                children: [
                  _buildParallaxHeroPageView(height, carouselCount),
                  _buildParallaxScrollView(
                    height,
                    conditionLabel,
                    carouselCount,
                  ),
                  _buildHeroSwipeOverlay(height, carouselCount),
                  _buildHeroBackButton(),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      color: AppColors.jebbyBackground,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _deletePinkBg,
                                    foregroundColor: const Color(0xFFE53935),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _confirmAndDeleteProduct,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  label: Text(
                                    'Delete',
                                    style: _nunito(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.jebbyBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.to(
                                      () => CreateListingScreen(
                                        editProductId: product_id?.toString(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  label: Text(
                                    'Edit Product',
                                    style: _nunito(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _conditionBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 11),
      decoration: BoxDecoration(
        color: _conditionTealBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gpp_good_outlined, size: 22, color: _conditionTeal),
          const SizedBox(width: 8),
          Text(
            label,
            style: _nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _conditionTeal,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRatingBarRow(int stars, double value) {
    final fraction = value.clamp(0.0, 1.0);
    final percent = (fraction * 100).round();
    final hasFill = percent > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$stars',
              textAlign: TextAlign.center,
              style: _nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 14, color: _starAccent),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: _ratingBarTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.jebbyBlue),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: _nunito(
                fontSize: 13,
                fontWeight: hasFill ? FontWeight.w800 : FontWeight.w600,
                color: hasFill
                    ? AppColors.jebbyTextPrimary
                    : AppColors.jebbyTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productReviewsEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/noreviews.png',
            width: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            textAlign: TextAlign.center,
            style: _nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: AppColors.jebbyTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Renter reviews will appear here.',
            textAlign: TextAlign.center,
            style: _nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRatingsSummaryBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 118,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _avgRating.toStringAsFixed(1),
                        style: _nunito(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jebbyTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_reviewCount Review${_reviewCount == 1 ? '' : 's'}',
                        style: _nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _myProductsStyleStars(_avgRating, size: 18),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(width: 1, color: _cardBorder),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _productRatingBarRow(5, _ratingDistribution[5] ?? 0),
                        _productRatingBarRow(4, _ratingDistribution[4] ?? 0),
                        _productRatingBarRow(3, _ratingDistribution[3] ?? 0),
                        _productRatingBarRow(2, _ratingDistribution[2] ?? 0),
                        _productRatingBarRow(1, _ratingDistribution[1] ?? 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _openProductReviewsScreen,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.jebbyBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'View More',
                style: _nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceAgreementsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(
                () => _serviceAgreementsExpanded = !_serviceAgreementsExpanded,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.jebbySoftBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Service Agreements',
                        style: _nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jebbyTextPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _serviceAgreementsExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: AppColors.jebbyTextMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_serviceAgreementsExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
              child: Column(
                children: [
                  _agreementRow(
                    'Rental Agreement',
                    () => Get.to(() => RentalAgreementScreen()),
                  ),
                  _agreementRow(
                    'Terms & Conditions',
                    () => Get.to(() => TermsAndConditionsScreen()),
                  ),
                  _agreementRow(
                    'Insurance & Indemnifications Policy',
                    () => Get.to(() => InsuranceAndIndemnificationsScreen()),
                  ),
                  _agreementRow(
                    'Transportation & Installation Policy',
                    () => Get.to(() => TransportAndInstallationPolicyScreen()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _productRatingsReviewsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(
                () => _ratingReviewsExpanded = !_ratingReviewsExpanded,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.jebbySoftBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_outline_rounded,
                        size: 22,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ratings & Reviews',
                        style: _nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.jebbyTextPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _ratingReviewsExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: AppColors.jebbyTextMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_ratingReviewsExpanded) ...[
            if (!_reviewsDistributionLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.jebbyBlue,
                    strokeWidth: 2.4,
                  ),
                ),
              )
            else if (_productReviewsEmpty)
              _productReviewsEmptyState()
            else
              _productRatingsSummaryBody(),
          ],
        ],
      ),
    );
  }

  Widget _buildParallaxHeroPageView(double screenHeight, int carouselCount) {
    final imageH = _heroImageHeight(screenHeight);
    final heroHeight = imageH + _pullDownExtent;
    final imageLayerHeight = _parallaxImageLayerHeight(screenHeight);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: heroHeight,
      child: IgnorePointer(
        child: ClipRect(
          child: Transform.translate(
            offset: Offset(0, _heroScrollTranslateY()),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildHeroPageView(carouselCount, imageLayerHeight),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProductImageGallery() async {
    if (imagesList.isEmpty) return;
    final urls =
        imagesList.map((e) => AppUrl.baseUrlM + e.toString()).toList();
    final initial = _carouselIndex.clamp(0, urls.length - 1);

    final indexOnClose = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => _VendorProductImageGalleryScreen(
              imageUrls: urls,
              initialIndex: initial,
            ),
      ),
    );

    if (!mounted || indexOnClose == null) return;
    if (indexOnClose == _carouselIndex) return;
    setState(() => _carouselIndex = indexOnClose);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(indexOnClose);
    }
  }

  Widget _buildHeroSwipeOverlay(double screenHeight, int carouselCount) {
    final swipeH = _heroSwipeHeight(screenHeight);
    if (swipeH <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: swipeH,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _openProductImageGallery,
        onHorizontalDragStart: (_) => _heroSwipeDragDelta = 0,
        onHorizontalDragUpdate: (details) {
          _heroSwipeDragDelta += details.delta.dx;
        },
        onHorizontalDragEnd: (details) {
          if (!_pageController.hasClients || carouselCount <= 1) {
            _heroSwipeDragDelta = 0;
            return;
          }
          final velocity = details.primaryVelocity ?? 0;
          final goNext = velocity < -120 || _heroSwipeDragDelta < -36;
          final goPrev = velocity > 120 || _heroSwipeDragDelta > 36;
          if (goNext) {
            final next = (_carouselIndex + 1).clamp(0, carouselCount - 1);
            if (next != _carouselIndex) {
              _pageController.animateToPage(
                next,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              );
            }
          } else if (goPrev) {
            final prev = (_carouselIndex - 1).clamp(0, carouselCount - 1);
            if (prev != _carouselIndex) {
              _pageController.animateToPage(
                prev,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              );
            }
          }
          _heroSwipeDragDelta = 0;
        },
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildHeroBackButton() {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 14, top: 10),
          child: Material(
            color: AppColors.lightBlue,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.back(),
              customBorder: const CircleBorder(),
              splashColor: AppColors.jebbyBlue.withValues(alpha: 0.16),
              highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.08),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxScrollView(
    double screenHeight,
    String conditionLabel,
    int carouselCount,
  ) {
    final imageH = _heroImageHeight(screenHeight);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IgnorePointer(
                child: SizedBox(height: imageH - _sheetOverlap),
              ),
              _buildVendorContentSheet(conditionLabel, carouselCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselIndicators(int carouselCount) {
    if (carouselCount <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(carouselCount, (i) {
        final active = _carouselIndex == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 8 : 6,
          height: active ? 8 : 6,
          decoration: BoxDecoration(
            color: active ? _accent : const Color(0xFFC6C8CF),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildVendorContentSheet(String conditionLabel, int carouselCount) {
    final topPadding = carouselCount > 1 ? 14.0 : 36.0;

    return Material(
      color: AppColors.jebbyBackground,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(_sheetTopRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarouselIndicators(carouselCount),
            if (carouselCount > 1) const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toString(),
                        style: _nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _titleDark,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _myProductsStyleStars(_avgRating, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_avgRating.toStringAsFixed(1)} ($_reviewCount Reviews)',
                            style: _nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: _labelGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rental Price',
                      style: _nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _labelGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$$price',
                      style: _nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _titleDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              description.toString(),
              style: _nunito(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: _bodyGrey,
                height: 1.45,
              ),
            ),
            if (conditionLabel.isNotEmpty) ...[
              const SizedBox(height: 16),
              _conditionBadge(conditionLabel),
            ],
            const SizedBox(height: 24),
            _serviceAgreementsCard(),
            const SizedBox(height: 18),
            _productRatingsReviewsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPageView(int carouselCount, double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _carouselIndex = i),
        itemCount: carouselCount,
        itemBuilder: (context, index) {
          if (imagesList.isEmpty) {
            return ColoredBox(
              color: Colors.grey.shade300,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey.shade600,
              ),
            );
          }
          return CachedNetworkImage(
            imageUrl: AppUrl.baseUrlM + imagesList[index].toString(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
          );
        },
      ),
    );
  }

  Widget _agreementRow(String title, VoidCallback onTap) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(
        title,
        style: _nunito(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: _titleDark,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: Colors.grey.shade500,
      ),
      onTap: onTap,
    );
  }

  itmBox({img, tx, dx, rt, rv, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {},
      child: Container(
        width: res_width * 0.44,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: res_height * 0.2,
                decoration: BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: '$img',
                    fit: BoxFit.fill,
                    placeholder:
                        (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) =>
                            Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.005),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tx', style: TextStyle(fontSize: 11)),
                    SizedBox(height: res_height * 0.006),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          _myProductsStyleStars(
                            double.tryParse(rt.toString()) ?? 0,
                            size: 16,
                          ),
                          Text(
                            '($rv) Reviews',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Double-tap toggles fit ↔ one zoom step (no multi-step default cycle).
PhotoViewScaleState _vendorGalleryDoubleTapScaleCycle(
  PhotoViewScaleState actual,
) {
  if (actual == PhotoViewScaleState.initial) {
    return PhotoViewScaleState.covering;
  }
  return PhotoViewScaleState.initial;
}

class _VendorProductImageGalleryScreen extends StatefulWidget {
  const _VendorProductImageGalleryScreen({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_VendorProductImageGalleryScreen> createState() =>
      _VendorProductImageGalleryScreenState();
}

class _VendorProductImageGalleryScreenState
    extends State<_VendorProductImageGalleryScreen> {
  late final PageController _pageController;
  late int _index;
  double _swipeDownDy = 0;
  double _swipeDownDx = 0;
  bool _dismissTriggered = false;
  bool _imageZoomedForDismiss = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(_index);
  }

  void _resetSwipeTracking() {
    _swipeDownDy = 0;
    _swipeDownDx = 0;
    _dismissTriggered = false;
  }

  bool _isSwipeDownDismiss() {
    return _swipeDownDy > 40 && _swipeDownDy > _swipeDownDx;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _close,
          ),
          title: Text(
            '${_index + 1} / ${widget.imageUrls.length}',
            style: _nunito(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _resetSwipeTracking(),
          onPointerMove: (event) {
            if (_dismissTriggered || _imageZoomedForDismiss) return;
            _swipeDownDx += event.delta.dx.abs();
            _swipeDownDy += event.delta.dy;
            if (_isSwipeDownDismiss()) {
              _dismissTriggered = true;
              _close();
            }
          },
          onPointerUp: (_) => _resetSwipeTracking(),
          onPointerCancel: (_) => _resetSwipeTracking(),
          child: PageView.builder(
            controller: _pageController,
            physics: _imageZoomedForDismiss
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (i) => setState(() {
              _index = i;
              _imageZoomedForDismiss = false;
              _resetSwipeTracking();
            }),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, i) {
              return PhotoView(
                imageProvider: CachedNetworkImageProvider(
                  widget.imageUrls[i],
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                scaleStateCycle: _vendorGalleryDoubleTapScaleCycle,
                scaleStateChangedCallback: (state) {
                  final zoomed = state != PhotoViewScaleState.initial;
                  if (_imageZoomedForDismiss != zoomed) {
                    setState(() => _imageZoomedForDismiss = zoomed);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
