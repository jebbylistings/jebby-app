import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/app_url.dart';
import 'package:jebby/utils/api_datetime.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../../view_models/user_view_model.dart';
import '../home/favourites.dart';
import '../home/my_orders.dart';
import '../vendors/my_orders.dart';
import '../vendors/my_products.dart';
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
  bool _ratingBreakdownExpanded = false;

  static const double _earnerCoverHeight = 108;
  static const double _earnerAvatarRadius = 48;

  int productsCount = 0;
  int ordersCount = 0;

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  @override
  void initState() {
    super.initState();
    profileData();
  }

  void profileData() async {
    getUserDate().then((value) {
      final currentUserId = value.id.toString();
      final targetVendorId =
          widget.vendorID == null ? currentUserId : widget.vendorID.toString();

      setState(() {
        token = value.token.toString();
        id = targetVendorId;
        _isCurrentUserProfile = targetVendorId == currentUserId;
        fullname = widget.vendorName == null
            ? value.name.toString()
            : widget.vendorName.toString();
        email = value.email.toString();
        role = value.role.toString();
        if (widget.vendorImage != null) {
          imagesapi = ProfileImage.sanitizePath(widget.vendorImage.toString());
        }
        if (widget.vendorBackImage != null) {
          back_image_api =
              ProfileImage.sanitizePath(widget.vendorBackImage.toString());
        }
      });

      getReviewsFor(targetVendorId);
      getProductsApi(targetVendorId);

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
    });
  }

  void getReviewsFor(String vendorId) {
    ApiRepository.shared.reviewsByVendorId(
      vendorId,
      (list) {
        if (mounted) {
          setState(() {
            isLoading = false;
            isEmpty = list.data!.isEmpty;
          });
        }
      },
      (error) {},
    );
  }

  int get _reviewsCount {
    final list = ApiRepository.shared.getAllReviewsByVendorIdModelList;
    return list?.totalreviews ?? list?.data?.length ?? 0;
  }

  double get _averageRating {
    final data = ApiRepository.shared.getAllReviewsByVendorIdModelList?.data;
    if (data == null || data.isEmpty) return 0.0;
    int sum = 0;
    for (var r in data) {
      sum += r.stars ?? 0;
    }
    return sum / data.length;
  }

  Map<int, double> _ratingDistribution() {
    final data = ApiRepository.shared.getAllReviewsByVendorIdModelList?.data;
    final total = data?.length ?? 0;
    if (total == 0) return {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var r in data!) {
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

  bool _isOwnEarnerProfile(BuildContext context) {
    if (!_isCurrentUserProfile || widget.vendorID != null) return false;
    final usp = context.watch<UserViewModel>();
    return usp.isEarnMode || int.tryParse((role ?? '').trim()) == 1;
  }

  bool _isVendorProfileView(BuildContext context) {
    if (widget.vendorID != null) return true;
    if (_isCurrentUserProfile) {
      return _isOwnEarnerProfile(context);
    }
    return int.tryParse((role ?? '').trim()) == 1;
  }

  bool _canShowBack() {
    if (widget.vendorID != null) return true;
    return widget.showBackButton ?? false;
  }

  String? _displayLocation() {
    String? raw;
    if (widget.vendorAddress != null &&
        widget.vendorAddress.toString().trim().isNotEmpty) {
      raw = widget.vendorAddress.toString().trim();
    } else if (addressapi.trim().isNotEmpty && addressapi != 'null') {
      raw = addressapi.trim();
    }
    if (raw == null) return null;
    return PublicLocation.cityStateLine(raw) ?? raw;
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

  @override
  Widget build(BuildContext context) {
    final roleInt = int.tryParse((role ?? '').toString().trim());
    final isOwnEarner = _isOwnEarnerProfile(context);
    final showRenterUi =
        _isCurrentUserProfile && !isOwnEarner && roleInt != 1;

    if (_isVendorProfileView(context)) {
      return _buildEarnerProfileScaffold(isOwnProfile: isOwnEarner);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(50),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          _isCurrentUserProfile ? "My Profile" : "Profile",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_isCurrentUserProfile)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openEditProfile,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(Icons.edit, color: Colors.blue, size: 20),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: showRenterUi ? _buildUserProfileBody() : _buildLegacyProviderBody(),
    );
  }

  Widget _buildEarnerProfileScaffold({required bool isOwnProfile}) {
    const footerClearance = 24.0;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _earnerProfileHeader(isOwnProfile: isOwnProfile),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  footerClearance + bottomSafe,
                ),
                child: _buildEarnerProfileBody(isOwnProfile: isOwnProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earnerProfileHeader({required bool isOwnProfile}) {
    final showBack = _canShowBack();

    final title = Text(
      isOwnProfile ? 'Earner profile' : 'Profile',
      style: _nunito(size: 28, weight: FontWeight.w800, height: 1.1),
    );

    final editButton = isOwnProfile
        ? TextButton(
            onPressed: _openEditProfile,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.jebbyBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Edit profile',
              style: _nunito(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.jebbyBlue,
              ),
            ),
          )
        : null;

    if (!showBack) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          if (editButton != null) editButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _earnerBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                if (editButton != null) editButton,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _earnerBackButton() {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Get.back(),
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
    final imagePath = _profileImagePath();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.jebbySoftBlue,
            AppColors.jebbyBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: r,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: r - 3,
          backgroundImage: ProfileImage.avatarProvider(Url, imagePath),
        ),
      ),
    );
  }

  Widget _earnerNameAndLocation(String? location) {
    return Column(
      children: [
        Text(
          fullname ?? '',
          textAlign: TextAlign.center,
          style: _nunito(size: 26, weight: FontWeight.w800, height: 1.15),
        ),
        if (location != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.jebbyBlue,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location,
                  textAlign: TextAlign.center,
                  style: _nunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                  ),
                ),
              ),
            ],
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
                bottom: -42,
                child: _earnerAvatarRing(),
              ),
            ],
          ),
          const SizedBox(height: 50),
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
    final location = _displayLocation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEarnerProfileHero(location),
        const SizedBox(height: 16),
        _earnerStatsCard(isOwnProfile: isOwnProfile),
        const SizedBox(height: 24),
        Text(
          'Ratings & reviews',
          style: _nunito(size: 20, weight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _earnerReviewsSection(),
      ],
    );
  }

  Widget _earnerStatsCard({required bool isOwnProfile}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _earnerStatTile(
              icon: Icons.description_outlined,
              iconColor: AppColors.jebbyBlue,
              count: '$productsCount',
              label: 'Listings',
              showChevron: isOwnProfile,
              onTap: isOwnProfile
                  ? () => Get.to(() => MyProductsScreen(side: false))
                  : null,
            ),
          ),
          Container(width: 1, height: 56, color: _cardBorder),
          Expanded(
            child: _earnerStatTile(
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.jebbyBlue,
              count: '$ordersCount',
              label: 'Orders',
              showChevron: isOwnProfile,
              onTap: isOwnProfile
                  ? () => Get.to(() => const VendorMyOrdersScreen())
                  : null,
            ),
          ),
          Container(width: 1, height: 56, color: _cardBorder),
          Expanded(
            child: _earnerStatTile(
              icon: Icons.star_outline_rounded,
              iconColor: AppColors.jebbyBlue,
              count: '$_reviewsCount',
              label: 'Reviews',
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnerStatTile({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 8),
        Text(
          count,
          style: _nunito(size: 24, weight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
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
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.jebbyTextMuted,
              ),
            ],
          ],
        ),
      ],
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

  Widget _earnerReviewsSection() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.jebbyBlue,
            strokeWidth: 2.4,
          ),
        ),
      );
    }

    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.jebbySoftBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.reviews_outlined,
                size: 32,
                color: AppColors.jebbyBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: _nunito(size: 20, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Renter reviews will appear here.',
              textAlign: TextAlign.center,
              style: _nunito(
                size: 15,
                weight: FontWeight.w600,
                color: AppColors.jebbyTextMuted,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    final reviewLabel =
        '$_reviewsCount review${_reviewsCount == 1 ? '' : 's'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: _nunito(
                                size: 18,
                                weight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(
                                  text: _averageRating.toStringAsFixed(1),
                                ),
                                TextSpan(
                                  text: ' ',
                                ),
                                TextSpan(
                                  text: '★',
                                  style: _nunito(
                                    size: 18,
                                    weight: FontWeight.w800,
                                    color: AppColors.jebbyBlue,
                                  ),
                                ),
                                TextSpan(
                                  text: ' · $reviewLabel',
                                  style: _nunito(
                                    size: 18,
                                    weight: FontWeight.w700,
                                    color: AppColors.jebbyTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          _ratingBreakdownExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          size: 22,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_ratingBreakdownExpanded) ...[
                Divider(height: 1, color: _cardBorder),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      _ratingRow(5, _ratingDistribution()[5] ?? 0.0),
                      _ratingRow(4, _ratingDistribution()[4] ?? 0.0),
                      _ratingRow(3, _ratingDistribution()[3] ?? 0.0),
                      _ratingRow(2, _ratingDistribution()[2] ?? 0.0),
                      _ratingRow(1, _ratingDistribution()[1] ?? 0.0),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ApiRepository
                .shared.getAllReviewsByVendorIdModelList!.data!.length,
            itemBuilder: (context, index) {
              final data = ApiRepository
                  .shared.getAllReviewsByVendorIdModelList!.data![index];
              return reviewItem(
                data.userName.toString(),
                data.description.toString(),
                double.parse(data.stars.toString()),
                dateStr: _timeAgo(data.createdAt),
                blueTheme: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyProviderBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: !ProfileImage.isValidPath(back_image_api)
                        ? Image.asset("assets/images/placeholder.png", fit: BoxFit.cover)
                        : Image.network(
                            ProfileImage.resolveUrl(Url, back_image_api)!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Image.asset(
                                "assets/images/placeholder.png",
                                fit: BoxFit.cover,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/placeholder.png",
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.blue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: ProfileImage.avatarProvider(
                          Url,
                          imagesapi,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              fullname ?? "",
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              (widget.vendorAddress != null && widget.vendorAddress.toString().trim().isNotEmpty)
                  ? widget.vendorAddress.toString()
                  : (email ?? ""),
              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(child: statItem("assets/images/myproducts.png", "$productsCount", "PRODUCTS")),
                  Container(width: 1, height: 50, color: Colors.grey.shade300),
                  Expanded(child: statItem("assets/images/myorders1.png", "$ordersCount", "ORDERS")),
                  Container(width: 1, height: 50, color: Colors.grey.shade300),
                  Expanded(child: statItem("assets/images/rating1.png", "$_reviewsCount", "REVIEWS")),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ratings & Reviews", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_averageRating.toStringAsFixed(2), style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text("$_reviewsCount Review${_reviewsCount == 1 ? '' : 's'}", style: GoogleFonts.inter(fontSize: 14)),
                          const SizedBox(height: 8),
                          _profileSummaryStars(_averageRating),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _ratingRow(5, _ratingDistribution()[5] ?? 0.0),
                            _ratingRow(4, _ratingDistribution()[4] ?? 0.0),
                            _ratingRow(3, _ratingDistribution()[3] ?? 0.0),
                            _ratingRow(2, _ratingDistribution()[2] ?? 0.0),
                            _ratingRow(1, _ratingDistribution()[1] ?? 0.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primaryColor)))
                      : isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text("No Reviews", style: GoogleFonts.inter(color: Colors.grey)),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: ApiRepository.shared.getAllReviewsByVendorIdModelList!.data!.length,
                              itemBuilder: (context, index) {
                                var data = ApiRepository.shared.getAllReviewsByVendorIdModelList!.data![index];
                                return reviewItem(
                                  data.userName.toString(),
                                  data.description.toString(),
                                  double.parse(data.stars.toString()),
                                  dateStr: _timeAgo(data.createdAt),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statItem(icon, number, title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, height: 28),
        const SizedBox(height: 8),
        Text(number, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _ratingRow(int stars, double value) {
    final pct = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text("$stars★", style: GoogleFonts.inter(fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(AppColors.jebbyBlue),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text("$pct%", style: GoogleFonts.inter(fontSize: 12))),
        ],
      ),
    );
  }

  Widget reviewItem(
    String name,
    String desc,
    double stars, {
    String? dateStr,
    bool blueTheme = false,
  }) {
    final timeAgo = dateStr ?? '';
    final badgeBg =
        blueTheme ? AppColors.jebbySoftBlue : Colors.amber.shade100;
    final badgeStarColor = blueTheme ? AppColors.jebbyBlue : Colors.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, size: 22, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: badgeStarColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                stars.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: blueTheme
                                      ? AppColors.jebbyBlue
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (timeAgo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(timeAgo, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildRenterAvatar(),
          const SizedBox(height: 12),
          Text(
            "Verified User",
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xff8F9098)),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _infoRow(Icons.person, "Name", fullname ?? ""),
                _infoRow(Icons.email, "Email Address", email ?? ""),
                // _infoRow(Icons.phone, "Mobile Number", phoneapi.isNotEmpty && phoneapi != "null" ? phoneapi : "—"),
                _infoRow(Icons.location_on, "My Address", addressapi.isNotEmpty ? addressapi : "—"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _actionCard(
                imagename: 'mywishlist.png',
                iconColor: Colors.red,
                title: "My Wishlist",
                subtitle: "Items you love.",
                onTap: () => Get.to(() => FavouritesScreen()),
              ),
              const SizedBox(width: 12),
              _actionCard(
                imagename: 'myorders.png',
                iconColor: Colors.brown,
                title: "My Orders",
                subtitle: "Track your rentals.",
                onTap: () => Get.to(() => MyOrdersScreen()),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRenterAvatar() {
    return ProfileImage.circularAvatar(
      radius: 55,
      baseUrl: Url,
      imagePath: imagesapi,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff8F9098)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xff8F9098),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String imagename,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/$imagename",
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xff8F9098),
                ),
              ),
            ],
          ),
        ),
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

