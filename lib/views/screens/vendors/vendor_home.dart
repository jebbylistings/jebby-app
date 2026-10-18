import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/get_all_orders_by_vendor_id_model.dart'
    as vendor_orders;
import 'package:jebby/models/get_all_products_by_vendor_id_model.dart'
    as vendor_products;
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/listing_publish_state.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:jebby/models/stripe_requirement_fields.dart';
import 'package:jebby/view_models/onboarding_controller.dart';
import 'package:jebby/views/screens/navigation/bottom_nav_controller.dart';
import 'package:jebby/views/screens/shared/notifications.dart';
import 'package:jebby/views/screens/vendors/my_orders.dart';
import 'package:jebby/views/screens/vendors/my_products.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user_model.dart';
import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/order_status.dart';
import '../../../view_models/user_view_model.dart';
import '../../widgets/reservation_action_card.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final BottomNavController _bottomNav = Get.find<BottomNavController>();

  static const String _heroBannerAsset = 'assets/images/feedback-banner.png';
  static const Color _cardBorder = Color(0xFFE3E6EC);
  static const Color _trendGreen = Color(0xFF16A34A);

  String? token;
  String sourceId = '';
  String? fullname;
  String? email;
  String? role;
  String? profileAddress;

  var profile = <dynamic>[];

  int _liveListings = 0;
  int _draftListings = 0;
  int _orderRequests = 0;
  int _orderActive = 0;
  int _transactionActivityCount = 0;

  double _totalEarnings = 0;
  double _earningsTrendPercent = 0;
  bool _earningsTrendPositive = true;
  List<double> _earningsSparkline = List<double>.filled(7, 0);

  bool isLoadingNotifications = true;
  bool isErrorNotifications = false;

  Future<void> getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    await usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData(BuildContext context) {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          await getProductsApi(sourceId);
          await _refreshListingStats();
          loadOrderStats();
          await _refreshPayoutFlagsFromStripe();
          getNotifications();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  Future<void> getProductsApi(String id) async {
    try {
      final row = await ApiRepository.shared.fetchUserProfileRow(id);
      if (row == null) return;

      final apiAddress = row['address']?.toString() ?? '';
      final apiName = row['name']?.toString() ?? '';
      if (mounted) {
        setState(() {
          profileAddress = apiAddress;
          if (apiName.isNotEmpty) fullname = apiName;
        });
      }

      final body = await ApiRepository.shared.fetchUserProfileBody(id);
      if (body != null && mounted) {
        setState(() {
          profile = body['data'] ?? [];
        });
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('address', apiAddress);
      if (apiName.isNotEmpty) prefs.setString('fullname', apiName);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Future<void> _refreshListingStats() async {
    var products = <vendor_products.Data>[];
    if (sourceId.trim().isNotEmpty) {
      try {
        final list = await ApiRepository.shared.getAllVendorProductsByID(
          (_) {},
          (_) {},
          sourceId,
        );
        products = list.data ?? [];
      } catch (_) {}
    }

    final counts = await ListingPublishState.vendorHomeCountsAsync(products);
    if (!mounted) return;
    setState(() {
      _liveListings = counts.live;
      _draftListings = counts.draft;
    });
  }

  void loadOrderStats() {
    if (sourceId.trim().isEmpty) return;
    ApiRepository.shared.getVenodorOrders(sourceId, (list) {
      if (!mounted) return;
      _applyOrderStats(list.data ?? []);
    }, (error) {});
  }

  void _applyOrderStats(List<vendor_orders.Data> orders) {
    var requests = 0;
    var active = 0;
    var activity = 0;
    for (final order in orders) {
      if (OrderStatus.isNewBooking(order.orderStatus)) requests++;
      if (OrderStatus.isVendorActiveTab(order.orderStatus)) active++;
      if (OrderStatus.showOnEarnerTransactionsList(order.orderStatus) &&
          _isOrderTransactionInCurrentMonth(order)) {
        activity++;
      }
    }

    final earnings = _computeEarningsMetrics(orders);

    setState(() {
      _orderRequests = requests;
      _orderActive = active;
      _transactionActivityCount = activity;
      _totalEarnings = earnings.total;
      _earningsTrendPercent = earnings.trendPercent;
      _earningsTrendPositive = earnings.trendPositive;
      _earningsSparkline = earnings.sparkline;
    });
  }

  bool _countsTowardTotalEarnings(String? status) {
    final normalized = OrderStatus.normalize(status);
    return normalized == OrderStatus.completed ||
        normalized == OrderStatus.disputeWindow24h;
  }

  DateTime? _orderEarningsDate(vendor_orders.Data order) {
    final raw = order.completedAt ?? order.updatedAt ?? order.createdAt;
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool _isOrderTransactionInCurrentMonth(vendor_orders.Data order) {
    final date = _orderEarningsDate(order);
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  double _orderDollars(vendor_orders.Data order) =>
      (order.totalPrice ?? 0).toDouble();

  ({
    double total,
    double trendPercent,
    bool trendPositive,
    List<double> sparkline,
  })
  _computeEarningsMetrics(List<vendor_orders.Data> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Start = today.subtract(const Duration(days: 6));
    final prev7Start = today.subtract(const Duration(days: 13));
    final prev7End = today.subtract(const Duration(days: 7));

    var total = 0.0;
    var last7 = 0.0;
    var prev7 = 0.0;
    final daily = List<double>.filled(7, 0);

    for (final order in orders) {
      if (!_countsTowardTotalEarnings(order.orderStatus)) continue;
      final amount = _orderDollars(order);
      total += amount;

      final date = _orderEarningsDate(order);
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);

      if (!day.isBefore(last7Start) && !day.isAfter(today)) {
        last7 += amount;
        final index = day.difference(last7Start).inDays.clamp(0, 6);
        daily[index] += amount;
      } else if (!day.isBefore(prev7Start) && day.isBefore(prev7End)) {
        prev7 += amount;
      }
    }

    double trendPercent = 0;
    var trendPositive = true;
    if (prev7 > 0) {
      trendPercent = ((last7 - prev7) / prev7) * 100;
      trendPositive = trendPercent >= 0;
    } else if (last7 > 0) {
      trendPercent = 100;
      trendPositive = true;
    }

    final maxDay = daily.reduce(math.max);
    final sparkline =
        maxDay <= 0
            ? List<double>.filled(7, 0.15)
            : daily.map((v) => (v / maxDay).clamp(0.08, 1.0)).toList();

    return (
      total: total,
      trendPercent: trendPercent.abs(),
      trendPositive: trendPositive,
      sparkline: sparkline,
    );
  }

  void seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  void getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
      (_) {
        if (mounted) {
          setState(() {
            isLoadingNotifications = false;
            isErrorNotifications = false;
          });
        }
      },
      (error) {
        if (error != null && mounted) {
          setState(() {
            isLoadingNotifications = false;
            isErrorNotifications = true;
          });
        }
      },
    );
  }

  void check() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('time') == false) {
      cancelTimer();
      return;
    }

    cancelTimer();
    notiTimer().timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (token == null ||
          token == '' ||
          role == '' ||
          role == null ||
          prefs.getBool('time') != true) {
        cancelTimer();
      } else {
        prefs.getBool('notifiction') == true
            ? getNotifications()
            : prefs.getBool('notifiction') == null
            ? getNotifications()
            : null;
      }
    });
  }

  void cancelTimer() {
    notiTimer().cancelTimer();
  }

  void func() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('time', true);
    check();
  }

  @override
  void initState() {
    super.initState();
    _loadPayoutFlags();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
      if (mounted) profileData(context);
    });
    func();
  }

  @override
  void dispose() {
    notiTimer().timer?.cancel();
    super.dispose();
  }

  String get _greetingName {
    final name = fullname?.trim() ?? '';
    if (name.isEmpty || name == 'null') return 'there';
    return name;
  }

  String get _publicLocation =>
      PublicLocation.cityStateLineOr(profileAddress, 'Add your location');

  int get _notificationBadge {
    final unseen = ApiRepository.shared.getNotificationModelList?.unseen;
    if (unseen == null || unseen == 0) return 0;
    return unseen;
  }

  bool _identityVerified = false;
  bool _payoutsEnabled = false;
  bool _payoutInReview = false;

  Future<void> _loadPayoutFlags() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _identityVerified = prefs.getBool('is_identity_verified') ?? false;
      _payoutsEnabled = prefs.getBool('payouts_enabled') ?? false;
    });
  }

  Future<void> _refreshPayoutFlagsFromStripe() async {
    if (sourceId.trim().isEmpty) return;
    final controller = ensureOnboardingController();
    await controller.ensureUserSession();
    if (controller.userId.isEmpty || controller.userId != sourceId) {
      await controller.loadAndReconcile(
        userId: sourceId,
        name: fullname,
        email: email,
      );
    } else {
      await controller.refreshStripeStatus();
    }
    if (!mounted) return;

    final response = controller.lastStripeStatusResponse;
    setState(() {
      _payoutsEnabled = controller.payoutsEnabled;
      if (controller.state.isIdentityComplete) {
        _identityVerified = true;
      }
      _payoutInReview =
          !_payoutsEnabled &&
          response != null &&
          StripeRequirementFields.shouldShowPayoutInReview(response);
    });
  }

  bool _shouldShowPayoutSetupBanner() {
    if (!_identityVerified || _payoutsEnabled || _payoutInReview) {
      return false;
    }
    return true;
  }

  Widget _payoutSetupBanner() {
    return Material(
      color: AppColors.earnerInfoBlue,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async {
          await Get.to(() => const VendorMyTransactionsScreen());
          if (mounted) await _refreshPayoutFlagsFromStripe();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
                  color: AppColors.jebbyBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Listings can be published, but bookings need payout setup. Finish in Transactions.',
                  style: _nunito(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.jebbyTextPrimary,
                    height: 1.35,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.jebbyBlue),
            ],
          ),
        ),
      ),
    );
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

  Widget _earnTagline() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: _nunito(
          size: 14,
          weight: FontWeight.w700,
          color: AppColors.jebbyTextPrimary,
        ),
        children: const [
          TextSpan(text: 'Rent '),
          TextSpan(
            text: '•',
            style: TextStyle(color: AppColors.jebbyAccentOrange),
          ),
          TextSpan(text: ' Earn '),
          TextSpan(
            text: '•',
            style: TextStyle(color: AppColors.jebbyAccentOrange),
          ),
          TextSpan(text: ' Repeat'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jebbyBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 20),
              _heroBanner(),
            const SizedBox(height: 14),
            if (_shouldShowPayoutSetupBanner()) ...[
              _payoutSetupBanner(),
              const SizedBox(height: 14),
            ],
            _totalEarningsCard(),
            const ReservationActionCard(outerPadding: EdgeInsets.only(top: 14)),
            const SizedBox(height: 20),
            Text(
              'Your business',
              style: _nunito(
                size: 20,
                weight: FontWeight.w800,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _businessCard(),
            const SizedBox(height: 12),
            _rentingSoonBanner(),
            const SizedBox(height: 20),
            Center(child: _earnTagline()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _appBarCircleButton(
          onTap: () => _bottomNav.openMainDrawer(),
          child: Image.asset(
            'assets/images/mingcute_menu-fill.png',
            width: 18,
            height: 18,
            color: AppColors.jebbyTextPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Earner dashboard',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: _nunito(
                size: 22,
                weight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ),
        _notificationHeaderButton(),
      ],
    );
  }

  Widget _notificationHeaderButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _appBarCircleButton(
          onTap: () {
            seenNotification();
            Get.to(() => const NotificationsScreen(isVendor: true));
          },
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.jebbyBlue,
            size: 22,
          ),
        ),
        if (!isLoadingNotifications &&
            !isErrorNotifications &&
            _notificationBadge > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.jebbyAccentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _notificationBadge > 9 ? '9+' : '$_notificationBadge',
                style: _nunito(
                  size: 10,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _appBarCircleButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: AppColors.jebbySoftBlue,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.jebbyBlue.withValues(alpha: 0.12),
        highlightColor: AppColors.jebbyBlue.withValues(alpha: 0.06),
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }

  Widget _heroBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;
        final textWidth = bannerWidth * 0.58;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                _heroBannerAsset,
                width: bannerWidth,
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
              ),
              Positioned(
                left: 18,
                top: 22,
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey, $_greetingName',
                      style: _nunito(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your things. Their\nnext adventure.',
                      style: _nunito(
                        size: 22,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyNavy,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.jebbyBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _publicLocation,
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w900,
                              color: AppColors.jebbyTextMuted,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _totalEarningsCard() {
    final trendPrefix = _earningsTrendPositive ? '+' : '-';
    final trendLabel =
        '${trendPrefix}${_earningsTrendPercent.toStringAsFixed(1)}% vs last 7 days';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.jebbySoftBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.jebbyBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earnings',
                  style: _nunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_totalEarnings.toStringAsFixed(2)}',
                  style: _nunito(
                    size: 26,
                    weight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _earningsTrendPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color:
                          _earningsTrendPositive
                              ? _trendGreen
                              : AppColors.jebbyAccentOrange,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        trendLabel,
                        style: _nunito(
                          size: 12,
                          weight: FontWeight.w700,
                          color:
                              _earningsTrendPositive
                                  ? _trendGreen
                                  : AppColors.jebbyAccentOrange,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            height: 52,
            child: CustomPaint(
              painter: _EarningsSparklinePainter(
                points: _earningsSparkline,
                lineColor: AppColors.jebbyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _businessRow(
            icon: Icons.sell_outlined,
            iconColor: AppColors.jebbyBlue,
            iconBackground: AppColors.jebbySoftBlue,
            title: 'Listings',
            subtitle: '$_liveListings live · $_draftListings draft',
            onTap: () async {
              await Get.to(() => MyProductsScreen(side: false));
              if (mounted) await _refreshListingStats();
            },
            showDivider: true,
          ),
          _businessRow(
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.jebbyBlue,
            iconBackground: AppColors.jebbySoftBlue,
            title: 'Rentals',
            subtitle: '$_orderRequests requests · $_orderActive active',
            onTap: () => Get.to(() => const VendorMyOrdersScreen()),
            showDivider: true,
          ),
          _businessRow(
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.jebbyBlue,
            iconBackground: AppColors.jebbySoftBlue,
            title: 'Transactions',
            subtitle:
                _transactionActivityCount == 0
                    ? 'No transactions yet'
                    : '$_transactionActivityCount recent',
            onTap: () async {
              await Get.to(() => const VendorMyTransactionsScreen());
              if (mounted) {
                loadOrderStats();
                await _refreshPayoutFlagsFromStripe();
              }
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _businessRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: _nunito(
                            size: 17,
                            weight: FontWeight.w800,
                            color: AppColors.jebbyTextPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: _nunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.jebbyTextMuted,
                              height: 1.2,
                            ),
                          )
                        else
                          const SizedBox(height: 17),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _rentingSoonBanner() {
    return Material(
      color: AppColors.earnerBannerBlue,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Get.to(() => MyProductsScreen(side: false)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.jebbyBlue.withValues(alpha: 0.85),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rentals are coming soon',
                      style: _nunito(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.jebbyNavy,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'People can already browse and save your listings.',
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
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsSparklinePainter extends CustomPainter {
  _EarningsSparklinePainter({required this.points, required this.lineColor});

  final List<double> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.22),
              lineColor.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dx = size.width / (points.length - 1);
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - (points[i].clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EarningsSparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
