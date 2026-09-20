import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/utils/earner_navigation.dart';
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

  static const Color _badgeActiveBg = AppColors.jebbySoftBlue;
  static const Color _badgeActiveFg = AppColors.jebbyBlue;
  static const Color _badgeCompletedBg = AppColors.earnerInfoBlue;
  static const Color _badgeCompletedFg = AppColors.jebbyBlue;
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

  int? _actionLoadingOrderId;
  String? _actionLoadingKind;

  static const Color _labelGrey = Color(0xFF72747A);
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

  Future<bool> _confirmVendorBookingAction({
    required String title,
    required String message,
    required String confirmLabel,
    Color confirmColor = AppColors.primaryColor,
  }) async {
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
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _titleDark,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _labelGrey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: _labelGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                confirmLabel,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: confirmColor,
                ),
              ),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Widget _actionButtonChild(bool loading, String label) {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    return Text(
      label,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Future<void> _approveBooking(dynamic orderId, String productName) async {
    final id = int.tryParse(orderId.toString());
    if (id == null) return;

    final name = productName.trim();
    final confirmed = await _confirmVendorBookingAction(
      title: 'Approve booking?',
      message: name.isNotEmpty && name != 'null'
          ? 'Accept this rental request for "$name"? The renter will be asked to complete payment.'
          : 'Accept this rental request? The renter will be asked to complete payment.',
      confirmLabel: 'Approve',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _actionLoadingOrderId = id;
      _actionLoadingKind = 'approve';
    });
    try {
      final ok = await ApiRepository.shared.acceptVendorBooking(id);
      if (ok && mounted) {
        ApiRepository.shared.getVenodorOrders(sourceId.toString(), (List) {
          if (mounted) setState(() {});
        }, (error) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingOrderId = null;
          _actionLoadingKind = null;
        });
      }
    }
  }

  Future<void> _declineBooking(dynamic orderId, String productName) async {
    final id = int.tryParse(orderId.toString());
    if (id == null) return;

    final name = productName.trim();
    final confirmed = await _confirmVendorBookingAction(
      title: 'Decline booking?',
      message: name.isNotEmpty && name != 'null'
          ? 'Decline the rental request for "$name"? The renter will be notified.'
          : 'Decline this rental request? The renter will be notified.',
      confirmLabel: 'Decline',
      confirmColor: Colors.red.shade700,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _actionLoadingOrderId = id;
      _actionLoadingKind = 'decline';
    });
    try {
      final ok = await ApiRepository.shared.declineVendorBooking(
        id,
        reason: 'Order Declined',
      );
      if (ok && mounted) {
        ApiRepository.shared.getVenodorOrders(sourceId.toString(), (List) {
          if (mounted) setState(() {});
        }, (error) {});
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingOrderId = null;
          _actionLoadingKind = null;
        });
      }
    }
  }

  Future<void> _openReservation(dynamic orderId) async {
    final id = int.tryParse(orderId.toString());
    if (id == null) return;
    await Get.to(() => ReservationDetailScreen(orderId: id));
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
    final orderIdInt = int.tryParse(orderId.toString());
    final approving =
        orderIdInt != null &&
        _actionLoadingOrderId == orderIdInt &&
        _actionLoadingKind == 'approve';
    final declining =
        orderIdInt != null &&
        _actionLoadingOrderId == orderIdInt &&
        _actionLoadingKind == 'decline';
    final busy = orderIdInt != null && _actionLoadingOrderId == orderIdInt;
    return _VendorOrderCardShell(
      badgeLabel: OrderStatus.renterBadgeLabel(OrderStatus.bookingRequested),
      badgeBg: _badgeActiveBg,
      badgeFg: _badgeActiveFg,
      displayPrice: price,
      title: productName,
      metaLine: 'Requested by $renter · Return due: $due',
      imageUrl: _imageUrl(productImage),
      onHeaderTap: () => _openReservation(orderId),
      actionRow: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: busy ? null : () => _approveBooking(orderId, productName),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.jebbyBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.jebbyBlue.withValues(alpha: 0.7),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _actionButtonChild(approving, 'Approve'),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: busy ? null : () => _declineBooking(orderId, productName),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _actionButtonChild(declining, 'Decline'),
              ),
            ),
          ),
        ],
      ),
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
                  'My orders',
                  style: _nunito(
                    size: 28,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage bookings for your items.',
                  style: _nunito(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.2,
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

  Widget _filterChips() {
    return Row(
      children: [
        Expanded(child: _filterChip(label: 'All', index: 0)),
        const SizedBox(width: 6),
        Expanded(child: _filterChip(label: 'Requests', index: 1)),
        const SizedBox(width: 6),
        Expanded(child: _filterChip(label: 'Active', index: 2)),
        const SizedBox(width: 6),
        Expanded(child: _filterChip(label: 'Completed', index: 3)),
      ],
    );
  }

  Widget _filterChip({required String label, required int index}) {
    final selected = selectedTab == index;
    return Material(
      color: selected ? AppColors.jebbyBlue : AppColors.jebbySoftBlue,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => setState(() => selectedTab = index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
      return DateFormat('d/M/yyyy').format(DateTime.parse(raw));
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
      return _VendorOrderCardShell(
        badgeLabel: 'COMPLETED',
        badgeBg: _badgeCompletedBg,
        badgeFg: _badgeCompletedFg,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        metaLine: 'Completed · Return was ${_formatVendorDate(end)}',
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: () => _openReservation(orderId),
      );
    }

    if (OrderStatus.isTerminal(status)) {
      final rejected = OrderStatus.isRejected(status);
      return _VendorOrderCardShell(
        badgeLabel: OrderStatus.renterBadgeLabel(status),
        badgeBg: _badgeNeutralBg,
        badgeFg: _badgeNeutralFg,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        metaLine: rejected
            ? 'Declined · ${_formatVendorDate(start)} – ${_formatVendorDate(end)}'
            : 'Cancelled · ${_formatVendorDate(start)} – ${_formatVendorDate(end)}',
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: () => _openReservation(orderId),
      );
    }

    if (OrderStatus.isVendorActiveTab(status)) {
      void openReservation() => _openReservation(orderId);

      return _VendorOrderCardShell(
        badgeLabel: OrderStatus.renterBadgeLabel(status),
        badgeBg: _badgeActiveBg,
        badgeFg: _badgeActiveFg,
        displayPrice: _displayPrice(data.totalPrice),
        title: productName,
        metaLine:
            'Requested by $renter · Return due: ${_formatVendorDate(end)}',
        imageUrl: _imageUrl(data.productImage),
        onHeaderTap: openReservation,
        actionRow: SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            onPressed: openReservation,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.jebbyBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Open reservation',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    final cancelled = OrderStatus.isCancelled(status);
    final rejected = OrderStatus.isRejected(status);
    final terminal = cancelled || rejected;
    return _VendorOrderCardShell(
      badgeLabel: OrderStatus.renterBadgeLabel(status),
      badgeBg: terminal ? _badgeNeutralBg : _badgeActiveBg,
      badgeFg: terminal ? _badgeNeutralFg : _badgeActiveFg,
      displayPrice: _displayPrice(data.totalPrice),
      title: productName,
      metaLine: 'Requested by $renter · Return due: ${_formatVendorDate(end)}',
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 20),
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

/// Order row layout aligned with renter [MyOrdersScreen] `_RenterOrderCard`.
class _VendorOrderCardShell extends StatelessWidget {
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeFg;
  final String displayPrice;
  final String title;
  final String metaLine;
  final String imageUrl;
  final VoidCallback onHeaderTap;
  final Widget? actionRow;

  const _VendorOrderCardShell({
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeFg,
    required this.displayPrice,
    required this.title,
    required this.metaLine,
    this.imageUrl = '',
    required this.onHeaderTap,
    this.actionRow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onHeaderTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: imageUrl.isEmpty
                          ? ColoredBox(
                              color: const Color(0xFFF5F5F5),
                              child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                            )
                          : CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => ColoredBox(
                                color: const Color(0xFFF5F5F5),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.jebbyBlue.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => ColoredBox(
                                color: const Color(0xFFF5F5F5),
                                child: Icon(Icons.chair_outlined, color: Colors.grey.shade500),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$$displayPrice',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badgeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: badgeFg,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metaLine,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9A9AA1),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (actionRow != null) ...[
                const SizedBox(height: 14),
                actionRow!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
