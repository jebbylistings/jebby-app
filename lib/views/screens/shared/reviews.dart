import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jebby/constants/app_url.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/api_datetime.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/views/screens/profile/user_profile.dart';

/// Product or vendor reviews list. Opened from product detail and profile flows.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    this.stars,
    this.reviewsLenght,
    this.prodID,
    this.vendorID,
    this.userID,
  });

  final dynamic stars;
  final dynamic reviewsLenght;
  final dynamic prodID;
  final dynamic vendorID;
  final dynamic userID;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const String _reviewsBannerAsset =
      'assets/images/reviews-banner.png';
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _ratingBarTrack = Color(0xFFF0F3F8);
  static const Color _starAccent = Color(0xFFF6AE02);
  static const Color _starInactive = Color(0xFFC6C8CF);
  static const Color _titleDark = Color(0xFF1A1A1A);

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  bool get _isVendorMode {
    final vendorId = widget.vendorID?.toString().trim() ?? '';
    return vendorId.isNotEmpty;
  }

  bool get _isRenterAuthorMode {
    final userId = widget.userID?.toString().trim() ?? '';
    return userId.isNotEmpty;
  }

  List<dynamic> get _reviewRows {
    if (_isVendorMode || _isRenterAuthorMode) {
      return ApiRepository.shared.getAllReviewsByVendorIdModelList?.data ?? [];
    }
    return ApiRepository.shared.getReviewsByProductIdModelList?.data ?? [];
  }

  void getReviews() {
    void onSuccess(dynamic list) {
      if (!mounted) return;
      setState(() {
        isEmpty = list.data?.isEmpty ?? true;
        isLoading = false;
        isError = false;
      });
    }

    void onError(dynamic error) {
      if (!mounted || error == null) return;
      setState(() {
        isEmpty = false;
        isLoading = false;
        isError = true;
      });
    }

    if (_isRenterAuthorMode) {
      ApiRepository.shared.reviewsByUserId(
        widget.userID.toString(),
        onSuccess,
        onError,
      );
      return;
    }

    if (_isVendorMode) {
      ApiRepository.shared.reviewsByVendorId(
        widget.vendorID.toString(),
        onSuccess,
        onError,
      );
      return;
    }

    ApiRepository.shared.reviewsByProductId(
      widget.prodID.toString(),
      onSuccess,
      onError,
    );
  }

  @override
  void initState() {
    super.initState();
    getReviews();
  }

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

  static String _timeAgo(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    final d = parseApiDateTime(createdAt);
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year${diff.inDays >= 730 ? 's' : ''} ago';
    }
    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month${diff.inDays >= 60 ? 's' : ''} ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  void _openReviewerProfile({
    required int? userId,
    required String name,
    String? profileImage,
  }) {
    final idStr = userId?.toString().trim();
    if (idStr == null || idStr.isEmpty) return;

    Get.to(
      () => UserProfileScreen(
        vendorID: idStr,
        vendorName: name,
        vendorImage: profileImage,
        showBackButton: true,
      ),
      preventDuplicates: false,
    );
  }

  Widget _pageHeader() {
    final subtitle = _isRenterAuthorMode
        ? 'Reviews you have shared as a renter.'
        : _isVendorMode
            ? 'See all feedback for this earner.'
            : 'See ratings and feedback for this item.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviews',
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: _nunito(
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

  Widget _reviewsBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;
        final textWidth = bannerWidth * 0.56;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                _reviewsBannerAsset,
                width: bannerWidth,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              Positioned(
                left: 20,
                top: 25,
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Honest reviews.\nReal experiences.',
                      style: _nunito(
                        size: 24,
                        weight: FontWeight.w800,
                        color: _titleDark,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'See what others think.',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w500,
                        color: const Color(0xFF4E5E74),
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _backButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleBack,
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(
          width: 40,
          height: 40,
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

  Widget _summaryStars(double rating, {double size = 18}) {
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

  Map<int, double> _ratingDistribution(List<dynamic> reviews) {
    final total = reviews.length;
    if (total == 0) {
      return {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
    }
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final s = int.tryParse(r.stars?.toString() ?? '') ?? 0;
      if (s >= 1 && s <= 5) counts[s] = counts[s]! + 1;
    }
    return {
      5: counts[5]! / total,
      4: counts[4]! / total,
      3: counts[3]! / total,
      2: counts[2]! / total,
      1: counts[1]! / total,
    };
  }

  double _averageFromReviews(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      return (double.tryParse(widget.stars.toString()) ?? 0).clamp(0, 5);
    }
    var sum = 0.0;
    var count = 0;
    for (final r in reviews) {
      final s = double.tryParse(r.stars?.toString() ?? '');
      if (s != null && s >= 0) {
        sum += s;
        count++;
      }
    }
    if (count == 0) {
      return (double.tryParse(widget.stars.toString()) ?? 0).clamp(0, 5);
    }
    return (sum / count).clamp(0, 5);
  }

  Widget _distributionBarRow(int stars, double value) {
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
                size: 13,
                weight: FontWeight.w600,
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
                size: 13,
                weight: hasFill ? FontWeight.w800 : FontWeight.w600,
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

  Widget _compactSummary({
    required double avgRating,
    required int totalReviews,
    required List<dynamic> reviews,
  }) {
    if (totalReviews <= 0 && reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = reviews.isNotEmpty ? reviews.length : totalReviews;
    final distribution = _ratingDistribution(reviews);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                    size: 24,
                    color: AppColors.jebbyBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rating summary',
                    style: _nunito(size: 17, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: _cardBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
            child: IntrinsicHeight(
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
                          avgRating.toStringAsFixed(1),
                          style: _nunito(size: 40, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count Review${count == 1 ? '' : 's'}',
                          style: _nunito(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _summaryStars(avgRating, size: 18),
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
                          _distributionBarRow(5, distribution[5] ?? 0),
                          _distributionBarRow(4, distribution[4] ?? 0),
                          _distributionBarRow(3, distribution[3] ?? 0),
                          _distributionBarRow(2, distribution[2] ?? 0),
                          _distributionBarRow(1, distribution[1] ?? 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewsEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/noreviews.png',
            width: 220,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            textAlign: TextAlign.center,
            style: _nunito(size: 18, weight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            _isRenterAuthorMode
                ? 'Reviews you share after rentals will appear here.'
                : _isVendorMode
                    ? 'Renter reviews will appear here.'
                    : 'Reviews for this listing will appear here.',
            textAlign: TextAlign.center,
            style: _nunito(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRatingBadge(double stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.jebbySoftBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.jebbyBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            stars.toStringAsFixed(1),
            style: _nunito(
              size: 13,
              weight: FontWeight.w800,
              color: AppColors.jebbyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard({
    required int? userId,
    required String name,
    required String description,
    required double stars,
    required String dateStr,
    String? profileImage,
  }) {
    void openProfile() => _openReviewerProfile(
          userId: userId,
          name: name,
          profileImage: profileImage,
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: openProfile,
                  customBorder: const CircleBorder(),
                  child: ProfileImage.circularAvatar(
                    radius: 22,
                    baseUrl: AppUrl.baseUrlM,
                    imagePath: ProfileImage.sanitizePath(profileImage),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: openProfile,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: _nunito(
                                size: 16,
                                weight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                dateStr,
                                style: _nunito(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.jebbyTextMuted,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _reviewRatingBadge(stars),
            ],
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description.trim(),
              style: _nunito(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextPrimary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reviewList(List<dynamic> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _reviewCard(
            userId: _isRenterAuthorMode
                ? reviews[i].vendorId
                : reviews[i].userId,
            name: reviews[i].userName?.toString() ??
                (_isRenterAuthorMode ? 'Earner' : 'Renter'),
            description: reviews[i].description?.toString() ?? '',
            stars: double.tryParse(reviews[i].stars?.toString() ?? '') ?? 0,
            dateStr: _timeAgo(reviews[i].createdAt?.toString()),
            profileImage: reviews[i].profileImage?.toString(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviewRows;
    final double avgRating = _averageFromReviews(reviews);
    final int totalReviews = reviews.isNotEmpty
        ? reviews.length
        : (int.tryParse(widget.reviewsLenght.toString()) ?? 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _pageHeader(),
                const SizedBox(height: 16),
                _reviewsBanner(),
                const SizedBox(height: 16),
                if (isError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Some error occurred while loading reviews.',
                      textAlign: TextAlign.center,
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                  )
                else if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.jebbyBlue,
                      ),
                    ),
                  )
                else if (isEmpty)
                  _reviewsEmptyState()
                else ...[
                  _compactSummary(
                    avgRating: avgRating,
                    totalReviews: totalReviews,
                    reviews: reviews,
                  ),
                  const SizedBox(height: 16),
                  _reviewList(reviews),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
