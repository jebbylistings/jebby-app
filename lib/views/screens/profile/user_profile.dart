import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/utils/api_datetime.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:provider/provider.dart';

import '../../../models/get_all_reviews_by_vendor_id_model.dart'
    as vendor_reviews;
import '../../../models/user_model.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../../view_models/user_view_model.dart';
import '../home/my_orders.dart';
import '../vendors/my_orders.dart';
import '../vendors/my_products.dart';
import '../shared/reviews.dart';
import '../../widgets/jebby_flow_back_button.dart';
import 'edit_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final dynamic vendorID;
  final dynamic vendorName;
  final dynamic vendorImage;
  final dynamic vendorBackImage;
  final dynamic vendorAddress;

  /// When true (e.g. pushed from drawer), shows the header back affordance.
  /// Bottom-nav profile tab should leave this false/null.
  final bool? showBackButton;

  const UserProfileScreen({
    super.key,
    this.vendorID,
    this.vendorName,
    this.vendorImage,
    this.vendorBackImage,
    this.vendorAddress,
    this.showBackButton,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color _cardBorder = Color(0xFFE3E6EC);

  String Url = AppUrl.baseUrlM;

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  bool _isCurrentUserProfile = false;

  var imagesapi = "";
  var back_image_api = "";
  var addressapi = "";
  var phoneapi = "";

  bool isLoading = true;
  bool isEmpty = false;
  bool _ratingBreakdownExpanded = true;
  List<vendor_reviews.Data> _vendorReviews = [];
  String? _reviewsLoadedForVendorId;

  static const double _earnerCoverHeight = 132;
  static const double _earnerAvatarRadius = 44;
  static const double _profileLocationMaxWidth = 300;

  int productsCount = 0;
  int ordersCount = 0;

  /// Earner metrics (listings + vendor orders + reviews received). Renter mode uses rental orders + reviews written.
  bool _showEarnerMetrics = true;
  bool? _lastLoadedEarnerMetrics;

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  bool _resolveEarnerMetrics(BuildContext context) {
    if (widget.vendorID != null) return true;
    return context.read<UserViewModel>().isEarnMode;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      profileData(showEarnerMetrics: _resolveEarnerMetrics(context));
    });
  }

  @override
  void didUpdateWidget(UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldVendor = oldWidget.vendorID?.toString();
    final newVendor = widget.vendorID?.toString();
    if (oldVendor != newVendor) {
      profileData(showEarnerMetrics: _resolveEarnerMetrics(context));
    }
  }

  void profileData({required bool showEarnerMetrics}) async {
    getUserDate().then((value) {
      final currentUserId = value.id.toString();
      final targetVendorId =
          widget.vendorID == null ? currentUserId : widget.vendorID.toString();

      setState(() {
        token = value.token.toString();
        id = targetVendorId;
        _isCurrentUserProfile = targetVendorId == currentUserId;
        _showEarnerMetrics = showEarnerMetrics;
        _lastLoadedEarnerMetrics = showEarnerMetrics;
        fullname = widget.vendorName == null
            ? value.name.toString()
            : widget.vendorName.toString();
        email = value.email.toString();
        role = value.role.toString();
        isLoading = true;
        isEmpty = false;
        _vendorReviews = [];
        _reviewsLoadedForVendorId = null;
        ordersCount = 0;
        if (!showEarnerMetrics) {
          productsCount = 0;
        }
        if (widget.vendorImage != null) {
          imagesapi = ProfileImage.sanitizePath(widget.vendorImage.toString());
        }
        if (widget.vendorBackImage != null) {
          back_image_api =
              ProfileImage.sanitizePath(widget.vendorBackImage.toString());
        }
      });

      getReviewsFor(
        targetVendorId,
        earnerReviewsReceived: showEarnerMetrics,
      );
      getProductsApi(targetVendorId);

      if (showEarnerMetrics) {
        ApiRepository.shared.getAllVendorProductsByID(
          (list) {
            if (mounted) setState(() => productsCount = list.data?.length ?? 0);
          },
          (e) {},
          targetVendorId,
        );
        ApiRepository.shared.getVenodorOrders(
          targetVendorId,
          (list) {
            if (mounted) setState(() => ordersCount = list.data?.length ?? 0);
          },
          (e) {},
          updateCache: widget.vendorID == null,
        );
      } else {
        ApiRepository.shared.getAllOrdersByUserId(
          targetVendorId,
          (list) {
            if (mounted) {
              setState(() => ordersCount = list.data?.length ?? 0);
            }
          },
          (e) {},
        );
      }
    });
  }

  void getReviewsFor(
    String profileId, {
    required bool earnerReviewsReceived,
  }) {
    if (mounted) {
      setState(() => isLoading = true);
    }

    void onSuccess(vendor_reviews.GetAllReviewsByVendorId list) {
      if (!mounted || id != profileId) return;
      final rows = list.data ?? [];
      setState(() {
        isLoading = false;
        isEmpty = rows.isEmpty;
        _vendorReviews = rows;
        _reviewsLoadedForVendorId = profileId;
      });
    }

    void onError(dynamic error) {
      if (!mounted || id != profileId) return;
      setState(() {
        isLoading = false;
        isEmpty = true;
        _vendorReviews = [];
        _reviewsLoadedForVendorId = profileId;
      });
    }

    if (earnerReviewsReceived) {
      ApiRepository.shared.reviewsByVendorId(profileId, onSuccess, onError);
    } else {
      ApiRepository.shared.reviewsByUserId(profileId, onSuccess, onError);
    }
  }

  bool get _reviewsReadyForCurrentProfile =>
      id != null && _reviewsLoadedForVendorId == id;

  List<vendor_reviews.Data> get _currentVendorReviews =>
      _reviewsReadyForCurrentProfile ? _vendorReviews : const [];

  int get _reviewsCount {
    if (!_reviewsReadyForCurrentProfile) return 0;
    return _vendorReviews.length;
  }

  double get _averageRating {
    if (!_reviewsReadyForCurrentProfile || _vendorReviews.isEmpty) {
      return 0.0;
    }
    int sum = 0;
    for (var r in _vendorReviews) {
      sum += r.stars ?? 0;
    }
    return sum / _vendorReviews.length;
  }

  Map<int, double> _ratingDistribution() {
    final data = _currentVendorReviews;
    final total = data.length;
    if (total == 0) return {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var r in data) {
      final s = r.stars ?? 0;
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

  static const Color _starAccent = Color(0xFFF6AE02);
  static const Color _starInactive = Color(0xFFC6C8CF);

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

  bool _canShowBack() {
    if (widget.vendorID != null) return true;
    return widget.showBackButton ?? false;
  }

  String? _displayLocationRaw() {
    String? raw;
    if (widget.vendorAddress != null &&
        widget.vendorAddress.toString().trim().isNotEmpty) {
      raw = widget.vendorAddress.toString().trim();
    } else if (addressapi.trim().isNotEmpty && addressapi != 'null') {
      raw = addressapi.trim();
    }
    return raw;
  }

  String? _publicLocationLine() {
    final raw = _displayLocationRaw();
    if (raw == null || raw.isEmpty) return null;
    return PublicLocation.cityStateLine(raw);
  }

  String? _earnerHeroLocation({required bool isOwnProfile}) {
    return _publicLocationLine();
  }

  Future<void> _openEditProfile() async {
    final updated = await Get.to(() => const EditProfileScreen());
    if (updated == true && mounted) {
      await _reloadAfterEdit();
    }
  }

  Widget _profileSummaryStars(double rating, {double size = 20}) {
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

  bool _isOwnRenterProfile(BuildContext context) {
    if (!_isCurrentUserProfile || widget.vendorID != null) return false;
    return !context.watch<UserViewModel>().isEarnMode;
  }

  bool _isOwnProfileView() =>
      _isCurrentUserProfile && widget.vendorID == null;

  @override
  Widget build(BuildContext context) {
    final earnerMetrics = _resolveEarnerMetrics(context);
    if (widget.vendorID == null && _isCurrentUserProfile) {
      context.watch<UserViewModel>();
      if (_lastLoadedEarnerMetrics != null &&
          _lastLoadedEarnerMetrics != earnerMetrics) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            profileData(showEarnerMetrics: earnerMetrics);
          }
        });
      }
    }

    return _buildEarnerProfileScaffold(isOwnProfile: _isOwnProfileView());
  }

  Widget _buildEarnerProfileScaffold({
    required bool isOwnProfile,
  }) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _earnerProfileHeader(isOwnProfile: isOwnProfile),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  isOwnProfile ? 16 : 16 + bottomSafe,
                ),
                child: _buildEarnerProfileBody(isOwnProfile: isOwnProfile),
              ),
            ),
            if (isOwnProfile)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _earnerEditProfileButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _earnerEditProfileButton() {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _openEditProfile,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.jebbyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white),
        label: Text(
          'Edit Profile',
          style: _nunito(
            size: 16,
            weight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _earnerProfileHeader({required bool isOwnProfile}) {
    final showBack = _canShowBack();

    final subtitle = isOwnProfile
        ? (_showEarnerMetrics
            ? 'Your listings, orders, and reviews in one place.'
            : 'Your rental orders and reviews in one place.')
        : 'See this earner\'s listings, orders, and reviews.';

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOwnProfile ? 'My Profile' : 'Profile',
          style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
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
    );

    if (!showBack) {
      return titleBlock;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JebbyFlowBackButton(onTap: () => Get.back()),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: titleBlock,
          ),
        ),
      ],
    );
  }

  bool get _hasCoverBanner {
    if (ProfileImage.isValidPath(back_image_api)) return true;
    return ProfileImage.isValidPath(widget.vendorBackImage?.toString());
  }

  String? _coverBannerUrl() {
    if (ProfileImage.isValidPath(back_image_api)) {
      return ProfileImage.resolveUrl(Url, back_image_api);
    }
    if (ProfileImage.isValidPath(widget.vendorBackImage?.toString())) {
      return ProfileImage.resolveUrl(Url, widget.vendorBackImage.toString());
    }
    return null;
  }

  String _profileImagePath() {
    if (ProfileImage.isValidPath(imagesapi)) return imagesapi;
    return ProfileImage.sanitizePath(widget.vendorImage?.toString());
  }

  Widget _earnerAvatarRing({double? radius}) {
    final r = radius ?? _earnerAvatarRadius;
    return ProfileImage.blueRingAvatar(
      radius: r,
      baseUrl: Url,
      imagePath: _profileImagePath(),
    );
  }

  Widget _earnerNameAndLocation(String? location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fullname ?? '',
          textAlign: TextAlign.center,
          style: _nunito(size: 22, weight: FontWeight.w800, height: 1.15),
        ),
        if (location != null && location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.min(
                  _profileLocationMaxWidth,
                  MediaQuery.sizeOf(context).width - 40,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  style: _nunito(
                    size: 14,
                    weight: FontWeight.w500,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                  children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.jebbyBlue,
                        ),
                      ),
                    ),
                    TextSpan(text: location),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEarnerProfileHero(String? location) {
    if (_hasCoverBanner) {
      final coverUrl = _coverBannerUrl();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: _earnerCoverHeight,
                  width: double.infinity,
                  child: coverUrl == null
                      ? ColoredBox(
                          color: AppColors.earnerBannerBlue,
                          child: Center(child: _earnerAvatarRing()),
                        )
                      : Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return ColoredBox(
                              color: AppColors.earnerBannerBlue,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.jebbyBlue,
                                  strokeWidth: 2.4,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return ColoredBox(
                              color: AppColors.earnerBannerBlue,
                              child: Center(child: _earnerAvatarRing()),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                bottom: -(_earnerAvatarRadius + 3.5),
                child: _earnerAvatarRing(),
              ),
            ],
          ),
          SizedBox(height: _earnerAvatarRadius + 3.5 + 12),
          _earnerNameAndLocation(location),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.earnerBannerBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _earnerAvatarRing(),
          const SizedBox(height: 14),
          _earnerNameAndLocation(location),
        ],
      ),
    );
  }

  Widget _buildEarnerProfileBody({required bool isOwnProfile}) {
    final location = _earnerHeroLocation(isOwnProfile: isOwnProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEarnerProfileHero(location),
        const SizedBox(height: 16),
        _earnerStatsCard(isOwnProfile: isOwnProfile),
        const SizedBox(height: 16),
        _earnerReviewsSection(),
        const SizedBox(height: 8),
      ],
    );
  }

  static const double _earnerStatDividerVerticalInset = 16;

  Widget _earnerStatsCardDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _earnerStatDividerVerticalInset,
      ),
      child: Container(width: 1, color: _cardBorder),
    );
  }

  Widget _earnerStatsCard({required bool isOwnProfile}) {
    final isOwnRenter = _isOwnRenterProfile(context);
    final hideListings = isOwnProfile && widget.vendorID == null && !_showEarnerMetrics;

    final ordersTile = Expanded(
      child: _earnerStatTile(
        icon: Icons.inventory_2_outlined,
        count: '$ordersCount',
        label: 'Orders',
        onTap: isOwnProfile
            ? () => Get.to(
                  isOwnRenter
                      ? () => const MyOrdersScreen()
                      : () => const VendorMyOrdersScreen(),
                )
            : null,
      ),
    );

    final reviewsTile = Expanded(
      child: _earnerStatTile(
        icon: Icons.star_outline_rounded,
        iconSize: 30,
        count: '$_reviewsCount',
        label: 'Reviews',
        onTap: _canOpenReviewsScreen ? _openReviewsScreen : null,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: IntrinsicHeight(
        child: hideListings
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ordersTile,
                  _earnerStatsCardDivider(),
                  reviewsTile,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _earnerStatTile(
                      icon: Icons.description_outlined,
                      count: '$productsCount',
                      label: 'Listings',
                      onTap: isOwnProfile && !isOwnRenter
                          ? () => Get.to(() => MyProductsScreen(side: false))
                          : null,
                    ),
                  ),
                  _earnerStatsCardDivider(),
                  ordersTile,
                  _earnerStatsCardDivider(),
                  reviewsTile,
                ],
              ),
      ),
    );
  }

  Widget _earnerStatTile({
    required IconData icon,
    required String count,
    required String label,
    double iconSize = 24,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.jebbySoftBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppColors.jebbyBlue),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: _nunito(
              size: 26,
              weight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: _nunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.2,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.jebbyTextMuted,
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _earnerReviewsEmptyState() {
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
            style: _nunito(size: 18, weight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            _showEarnerMetrics
                ? 'Renter reviews will appear here.'
                : 'Reviews you share after rentals will appear here.',
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

  bool get _canOpenReviewsScreen {
    final profileId = id?.toString().trim();
    return profileId != null && profileId.isNotEmpty;
  }

  void _openReviewsScreen() {
    final profileId = id?.toString().trim();
    if (!_canOpenReviewsScreen || profileId == null) return;

    Get.to(
      () => ReviewsScreen(
        vendorID: _showEarnerMetrics ? profileId : null,
        userID: _showEarnerMetrics ? null : profileId,
        stars: _averageRating.toString(),
        reviewsLenght: _reviewsCount.toString(),
      ),
    )?.then((_) {
      if (!mounted || id == null) return;
      getReviewsFor(
        id!,
        earnerReviewsReceived: _showEarnerMetrics,
      );
    });
  }

  Widget _earnerReviewsSection() {
    final reviews = _currentVendorReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _earnerRatingsSummaryCard(),
        if (_reviewsReadyForCurrentProfile && !isLoading && !isEmpty) ...[
          const SizedBox(height: 12),
          for (var i = 0; i < reviews.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _earnerReviewCard(
              profileUserId: _showEarnerMetrics
                  ? reviews[i].userId
                  : reviews[i].vendorId,
              name: reviews[i].userName?.toString() ??
                  (_showEarnerMetrics ? 'Renter' : 'Earner'),
              description: reviews[i].description?.toString() ?? '',
              stars: double.tryParse(reviews[i].stars?.toString() ?? '') ?? 0,
              dateStr: _timeAgo(reviews[i].createdAt),
              profileImage: reviews[i].profileImage,
            ),
          ],
        ],
      ],
    );
  }

  Widget _earnerRatingsSummaryCard() {
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
                () => _ratingBreakdownExpanded = !_ratingBreakdownExpanded,
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
                        style: _nunito(size: 17, weight: FontWeight.w800),
                      ),
                    ),
                    Icon(
                      _ratingBreakdownExpanded
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
          if (_ratingBreakdownExpanded) ...[
            if (isLoading || !_reviewsReadyForCurrentProfile)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.jebbyBlue,
                    strokeWidth: 2.4,
                  ),
                ),
              )
            else if (isEmpty)
              _earnerReviewsEmptyState()
            else
              Padding(
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
                                  _averageRating.toStringAsFixed(1),
                                  style: _nunito(
                                    size: 40,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_reviewsCount Review${_reviewsCount == 1 ? '' : 's'}',
                                  style: _nunito(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: AppColors.jebbyTextMuted,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _profileSummaryStars(_averageRating, size: 18),
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
                                  _earnerRatingBarRow(
                                    5,
                                    _ratingDistribution()[5] ?? 0.0,
                                  ),
                                  _earnerRatingBarRow(
                                    4,
                                    _ratingDistribution()[4] ?? 0.0,
                                  ),
                                  _earnerRatingBarRow(
                                    3,
                                    _ratingDistribution()[3] ?? 0.0,
                                  ),
                                  _earnerRatingBarRow(
                                    2,
                                    _ratingDistribution()[2] ?? 0.0,
                                  ),
                                  _earnerRatingBarRow(
                                    1,
                                    _ratingDistribution()[1] ?? 0.0,
                                  ),
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
                        onPressed: _openReviewsScreen,
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
                            size: 14,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
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
    )?.then((_) {
      if (!mounted) return;
      final vendorId = id;
      if (vendorId != null && vendorId.isNotEmpty) {
        getReviewsFor(
          vendorId,
          earnerReviewsReceived: _showEarnerMetrics,
        );
      }
    });
  }

  Widget _earnerReviewCard({
    required int? profileUserId,
    required String name,
    required String description,
    required double stars,
    required String dateStr,
    String? profileImage,
  }) {
    void openProfile() => _openReviewerProfile(
          userId: profileUserId,
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
                    baseUrl: Url,
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
              _earnerReviewRatingBadge(stars),
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

  Widget _earnerReviewRatingBadge(double stars) {
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

  static const Color _ratingBarTrack = Color(0xFFF0F3F8);

  Widget _earnerRatingBarRow(int stars, double value) {
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

  Future<void> _reloadAfterEdit() async {
    if (!_isCurrentUserProfile || id == null) return;

    final usp = context.read<UserViewModel>();
    await usp.getUpdatedUser();
    await getProductsApi(id!);
    if (!mounted) return;

    setState(() {
      fullname = usp.name ?? fullname;
    });
  }

  Future getProductsApi(dynamic profileId) async {
    final row = await ApiRepository.shared.fetchUserProfileRow(profileId.toString());
    if (row == null || !mounted) return;

    setState(() {
      final profileImage = row['profile_image']?.toString().trim() ?? '';
        imagesapi = ProfileImage.sanitizePath(profileImage);
      final coverImage = row['cover_image']?.toString().trim() ?? '';
        back_image_api = ProfileImage.sanitizePath(coverImage);
      final apiRole = row['role']?.toString();
        if (apiRole != null && apiRole.trim().isNotEmpty) {
          role = apiRole;
        }
      addressapi = row['address']?.toString() ?? '';
      phoneapi = row['phone_number']?.toString() ?? '';
    });
  }
}

