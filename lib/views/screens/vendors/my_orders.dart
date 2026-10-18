import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
import 'package:jebby/views/screens/reservations/rental_request_review.dart';
import 'package:jebby/views/screens/reservations/reservation_detail.dart';
import 'package:provider/provider.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/order_status.dart';
import '../../../models/user_model.dart';
import '../../../constants/app_url.dart';
import 'package:jebby/repositories/api_repository.dart';
import '../../../view_models/user_view_model.dart';

class VendorMyOrdersScreen extends StatefulWidget {
  const VendorMyOrdersScreen({super.key});

  @override
  State<VendorMyOrdersScreen> createState() => _VendorMyOrdersScreenState();
}

class _VendorMyOrdersScreenState extends State<VendorMyOrdersScreen> {
  static const String _emptyPlaceholderAsset =
      'assets/images/myorders-placeholder.png';
  static const String _ordersBannerAsset = 'assets/images/my-orders-banner.png';

  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _badgeActiveBg = AppColors.jebbySoftBlue;
  static const Color _badgeActiveFg = AppColors.jebbyBlue;
  static const Color _badgePendingBg = AppColors.primaryColorLight;
  static const Color _badgePendingFg = AppColors.jebbyAccentOrange;
  static const Color _badgeCompletedBg = Color(0xFFDCFCE7);
  static const Color _badgeCompletedFg = Color(0xFF16A34A);
  static const Color _badgeNeutralBg = AppColors.jebbySoftBlue;
  static const Color _badgeNeutralFg = AppColors.jebbyTextMuted;
  /// 0 = All, 1 = Requests (booking requested), 2 = Active (in progress), 3 = Completed
  int selectedTab = 0;

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

  void _handleBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      EarnerNavigation.goHome();
    }
  }

  EdgeInsets _listBottomPadding(BuildContext context) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 24,
    );
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  static const Color _titleDark = Color(0xFF1A1A1A);

  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = '';
  String? fullname;
  String? email;
  String? role;

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          getNewOrders();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  void getNewOrders() {
    ApiRepository.shared.getVenodorOrders(
      sourceId,
      (List) {
        if (mounted) {
          if (List.data!.isEmpty) {
            setState(() {
              isLoading = false;
              isEmpty = true;
              isError = false;
            });
          } else {
            setState(() {
              isLoading = false;
              isError = false;
              isEmpty = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      },
    );
  }

  Future<void> _openReservation(dynamic orderId) async {
    final id = int.tryParse(orderId.toString());
    if (id == null) return;
    await Get.to(() => ReservationDetailScreen(orderId: id));
    if (!mounted || sourceId.isEmpty) return;
    getNewOrders();
  }

  Future<void> _openRentalRequest(dynamic orderId) async {
    final id = int.tryParse(orderId.toString());
    if (id == null) return;
    await Get.to(() => RentalRequestReviewScreen(orderId: id));
    if (!mounted || sourceId.isEmpty) return;
    getNewOrders();
  }

  Widget _vendorNewOrderRequestCard({
    required String productName,
    required String renterName,
    required String? productImage,
    required dynamic orderId,
    required String id,
    required String price,
    required String start,
    required String end,
    required String email,
    required String location,
  }) {
    final due = _formatVendorDate(end);
    final renter = renterName.trim().isNotEmpty && renterName != 'null' ? renterName : 'Renter';
    void openRequest() => _openRentalRequest(orderId);
    return _VendorOrderCardShell(
      badgeLabel: 'Request Pending',
      badgeBg: _badgePendingBg,
      badgeFg: _badgePendingFg,
      badgeIcon: Icons.schedule_rounded,
      displayPrice: price,
      title: productName,
      renterName: renter,
      returnDueLabel: due,
      imageUrl: _imageUrl(productImage),
      onHeaderTap: openRequest,
      actionRow: _viewRequestButton(openRequest),
    );
  }

  Widget _pageHeader() {
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
                  'My Rentals',
                  style: _nunito(
                    size: 22,
                    weight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage bookings for your items.',
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

  int _countRequests() =>
      _allOrders().where((e) => OrderStatus.isNewBooking(e.orderStatus)).length;

  int _countActive() => _allOrders()
      .where((e) => OrderStatus.isVendorActiveTab(e.orderStatus))
      .where((e) => !OrderStatus.isNewBooking(e.orderStatus))
      .length;

  int _countPast() =>
      _allOrders().where((e) => OrderStatus.isCompleted(e.orderStatus)).length;

  String _filterChipLabel(int index) {
    switch (index) {
      case 1:
        final n = _countRequests();
        return n > 0 ? 'Request ($n)' : 'Request';
      case 2:
        final n = _countActive();
        return n > 0 ? 'Active ($n)' : 'Active';
      case 3:
        final n = _countPast();
        return n > 0 ? 'Past ($n)' : 'Past';
      default:
        return 'All';
    }
  }

  Widget _earningsBanner() {
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
                _ordersBannerAsset,
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
                      'Your Items, Your\nEarnings',
                      style: _nunito(
                        size: 24,
                        weight: FontWeight.w800,
                        color: _titleDark,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your rentals and watch your earnings grow.',
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

  Widget _filterChips() {
    return Row(
      children: [
        Expanded(child: _filterChip(index: 0)),
        const SizedBox(width: 8),
        Expanded(child: _filterChip(index: 1)),
        const SizedBox(width: 8),
        Expanded(child: _filterChip(index: 2)),
        const SizedBox(width: 8),
        Expanded(child: _filterChip(index: 3)),
      ],
    );
  }

  Widget _filterChip({required int index}) {
    final selected = selectedTab == index;
    final label = _filterChipLabel(index);
    return Material(
      color: selected ? AppColors.jebbyBlue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: _cardBorder),
      ),
      child: InkWell(
        onTap: () => setState(() => selectedTab = index),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: _nunito(
              size: 13,
              weight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.jebbyTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryOrderCardButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.jebbyBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: _nunito(size: 15, weight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Widget _viewRequestButton(VoidCallback onPressed) {
    return _primaryOrderCardButton(
      onPressed: onPressed,
      label: 'View request',
      icon: Icons.receipt_long_outlined,
    );
  }

  Widget _openReservationButton(VoidCallback onPressed) {
    return _primaryOrderCardButton(
      onPressed: onPressed,
      label: 'Open reservation',
      icon: Icons.calendar_today_outlined,
    );
  }

  Widget _emptyState({
    required String title,
    required String message,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    _emptyPlaceholderAsset,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.event_seat_outlined,
                      size: 120,
                      color: AppColors.jebbyBlue.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: _nunito(
                      size: 22,
                      weight: FontWeight.w800,
                      color: AppColors.jebbyTextPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
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
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _allOrders() {
    return ApiRepository.shared.getAllOrdersByVenodrIdList?.data ?? [];
  }

  String _formatVendorDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _displayPrice(dynamic totalPrice) {
    if (totalPrice == null) return '0';
    return totalPrice.toString();
  }

  String _imageUrl(String? path) {
    final p = path?.trim() ?? '';
    if (p.isEmpty) return '';
    if (p.toLowerCase().startsWith('http')) return p;
    final base = AppUrl.baseUrlM.endsWith('/') ? AppUrl.baseUrlM : '${AppUrl.baseUrlM}/';
    final rel = p.startsWith('/') ? p.substring(1) : p;
    return '$base$rel';
  }

  String _productTitle(dynamic productName, dynamic productId) {
    final name = productName?.toString().trim();
    if (name != null && name.isNotEmpty && name != 'null') return name;
    return 'Product #${productId ?? ''}';
  }

  Widget _buildTabContent() {
    if (isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Something went wrong while loading orders.',
            textAlign: TextAlign.center,
            style: _nunito(
              size: 15,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
        ),
      );
    }
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.jebbyBlue,
          strokeWidth: 2.4,
        ),
      );
    }

    final tabOrders = _ordersForSelectedTab();
    if (tabOrders.isEmpty) {
      return _emptyState(
        title: 'No orders yet',
        message: 'Booking requests will appear here when renting opens.',
      );
    }

    return _ordersList(tabOrders);
  }

  List<dynamic> _ordersForSelectedTab() {
    final all = _allOrders();
    switch (selectedTab) {
      case 0:
        return all;
      case 1:
        return all.where((e) => OrderStatus.isNewBooking(e.orderStatus)).toList();
      case 2:
        return all.where((e) => OrderStatus.isVendorActiveTab(e.orderStatus)).toList();
      default:
        return all.where((e) => OrderStatus.isCompleted(e.orderStatus)).toList();
    }
  }

  Widget _ordersList(List<dynamic> list) {
    return ListView.separated(
      padding: _listBottomPadding(context),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildVendorOrderCard(list[index]),
    );
  }


  Widget _buildVendorOrderCard(dynamic data) {
    final status = data.orderStatus?.toString();
    final productName = _productTitle(data.productName, data.productId);
    final renterName = data.name.toString();
    final price = data.totalPrice.toString();
    final start = data.rentalStartDate.toString();
    final end = data.rentalEndDate.toString();
    final id = data.productId.toString();
    final orderId = data.id;
    final email = data.email.toString();
    final location = data.location.toString();
    final renter =
        renterName.trim().isNotEmpty && renterName != 'null' ? renterName : 'Renter';

    if (OrderStatus.isNewBooking(status)) {
      return _vendorNewOrderRequestCard(
        productName: productName,
        renterName: renterName,
        productImage: data.productImage,
        orderId: orderId,
        id: id,
        price: price,
        start: start,
        end: end,
        email: email,
        location: location,
      );
    }

    if (OrderStatus.isCompleted(status)) {
      void openReservation() => _openReservation(orderId);
      return _VendorOrderCardShell(
        badgeLabel: 'Completed',
        badgeBg: _badgeCompletedBg,
        badgeFg: _badgeCompletedFg,
        badgeIcon: Icons.check_circle_outline_rounded,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        renterName: renter,
        returnDueLabel: _formatVendorDate(end),
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: openReservation,
        actionRow: _openReservationButton(openReservation),
      );
    }

    if (OrderStatus.isTerminal(status)) {
      final rejected = OrderStatus.isRejected(status);
      return _VendorOrderCardShell(
        badgeLabel: rejected ? 'Declined' : 'Cancelled',
        badgeBg: _badgeNeutralBg,
        badgeFg: _badgeNeutralFg,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        renterName: renter,
        returnDueLabel: _formatVendorDate(end),
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: () => _openReservation(orderId),
      );
    }

    if (OrderStatus.isVendorActiveTab(status)) {
      void openReservation() => _openReservation(orderId);

      return _VendorOrderCardShell(
        badgeLabel: 'Active',
        badgeBg: _badgeActiveBg,
        badgeFg: _badgeActiveFg,
        badgeIcon: Icons.check_circle_outline_rounded,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        renterName: renter,
        returnDueLabel: _formatVendorDate(end),
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: openReservation,
        actionRow: _openReservationButton(openReservation),
      );
    }

    return _VendorOrderCardShell(
      badgeLabel: OrderStatus.renterBadgeLabel(status),
      badgeBg: _badgeActiveBg,
      badgeFg: _badgeActiveFg,
      displayPrice: _displayPrice(data.totalPrice),
      title: productName,
      renterName: renter,
      returnDueLabel: _formatVendorDate(end),
      imageUrl: _imageUrl(data.productImage),
      onHeaderTap: () => _openReservation(orderId),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  void activate() {
    super.activate();
    if (sourceId.isNotEmpty) {
      getNewOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 16),
              _earningsBanner(),
              const SizedBox(height: 16),
              _filterChips(),
              const SizedBox(height: 16),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Image is a square whose side matches the measured details column height.
class _VendorOrderCardHeader extends StatefulWidget {
  const _VendorOrderCardHeader({
    required this.thumbnail,
    required this.details,
    this.gap = 12,
    this.minThumbSide = 80,
  });

  final Widget thumbnail;
  final Widget details;
  final double gap;
  final double minThumbSide;

  @override
  State<_VendorOrderCardHeader> createState() => _VendorOrderCardHeaderState();
}

class _VendorOrderCardHeaderState extends State<_VendorOrderCardHeader> {
  final GlobalKey _detailsKey = GlobalKey();
  double _thumbSide = 96;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_syncThumbSide);
  }

  @override
  void didUpdateWidget(covariant _VendorOrderCardHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_syncThumbSide);
  }

  void _syncThumbSide(_) {
    final box = _detailsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final next = box.size.height < widget.minThumbSide
        ? widget.minThumbSide
        : box.size.height;
    if ((next - _thumbSide).abs() > 0.5 && mounted) {
      setState(() => _thumbSide = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: _thumbSide,
            height: _thumbSide,
            child: widget.thumbnail,
          ),
        ),
        SizedBox(width: widget.gap),
        Expanded(
          child: KeyedSubtree(
            key: _detailsKey,
            child: widget.details,
          ),
        ),
      ],
    );
  }
}

class _VendorOrderCardShell extends StatelessWidget {
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeFg;
  final IconData? badgeIcon;
  final String displayPrice;
  final String title;
  final String renterName;
  final String returnDueLabel;
  final String imageUrl;
  final VoidCallback onHeaderTap;
  final Widget? actionRow;

  const _VendorOrderCardShell({
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeFg,
    this.badgeIcon,
    required this.displayPrice,
    required this.title,
    required this.renterName,
    required this.returnDueLabel,
    this.imageUrl = '',
    required this.onHeaderTap,
    this.actionRow,
  });

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

  Widget _metaRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.jebbyTextMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _nunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _VendorMyOrdersScreenState._cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onHeaderTap,
              borderRadius: BorderRadius.circular(12),
              child: _VendorOrderCardHeader(
                thumbnail: _productThumbnail(),
                details: _orderDetailsColumn(),
              ),
            ),
            if (actionRow != null) ...[
              const SizedBox(height: 14),
              actionRow!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _orderDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusBadge(),
        const SizedBox(height: 8),
        Text(
          '\$$displayPrice',
          style: _nunito(
            size: 22,
            weight: FontWeight.w800,
            color: AppColors.jebbyBlue,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: _nunito(size: 16, weight: FontWeight.w800, height: 1.25),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _metaRow(
          icon: Icons.person_outline_rounded,
          text: 'Requested by $renterName',
        ),
        const SizedBox(height: 4),
        _metaRow(
          icon: Icons.calendar_today_outlined,
          text: 'Return due: $returnDueLabel',
        ),
      ],
    );
  }

  Widget _productThumbnail() {
    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isEmpty)
            Center(
              child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
            )
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.jebbyBlue.withValues(alpha: 0.6),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Center(
                child: Icon(Icons.chair_outlined, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(badgeIcon, size: 14, color: badgeFg),
            const SizedBox(width: 4),
          ],
          Text(
            badgeLabel,
            style: _nunito(size: 12, weight: FontWeight.w700, color: badgeFg),
          ),
        ],
      ),
    );
  }
}
