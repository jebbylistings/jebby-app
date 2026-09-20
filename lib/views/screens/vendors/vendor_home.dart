import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/public_location.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/views/screens/navigation/app_drawer.dart';
import 'package:jebby/views/screens/shared/notifications.dart';
import 'package:jebby/views/screens/vendors/add_product.dart';
import 'package:jebby/views/screens/vendors/my_orders.dart';
import 'package:jebby/views/screens/vendors/my_products.dart';
import 'package:jebby/views/screens/vendors/my_transactions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user_model.dart';
import '../../../services/provider/sign_in_provider.dart';
import '../../../utils/order_status.dart';
import '../../../view_models/user_view_model.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

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
          loadListingStats();
          loadOrderStats();
          getNotifications();
          await _loadDraftCount();
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

  Future<void> _loadDraftCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _draftListings = prefs.getBool('listing_draft_active') == true ? 1 : 0;
    });
  }

  void loadListingStats() {
    if (sourceId.trim().isEmpty) return;
    ApiRepository.shared.getAllVendorProductsByID(
      (list) {
        if (!mounted) return;
        setState(() {
          _liveListings = list.data?.length ?? 0;
        });
      },
      (error) {},
      sourceId,
    );
  }

  void loadOrderStats() {
    if (sourceId.trim().isEmpty) return;
    ApiRepository.shared.getVenodorOrders(
      sourceId,
      (list) {
        if (!mounted) return;
        final orders = list.data ?? [];
        var requests = 0;
        var active = 0;
        for (final order in orders) {
          if (OrderStatus.isNewBooking(order.orderStatus)) requests++;
          if (OrderStatus.isVendorActiveTab(order.orderStatus)) active++;
        }
        setState(() {
          _orderRequests = requests;
          _orderActive = active;
        });
      },
      (error) {},
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

  String get _firstName {
    final name = fullname?.trim() ?? '';
    if (name.isEmpty) return 'there';
    return name.split(RegExp(r'\s+')).first;
  }

  String get _publicLocation =>
      PublicLocation.cityStateLineOr(profileAddress, 'Add your location');

  int get _notificationBadge {
    final unseen = ApiRepository.shared.getNotificationModelList?.unseen;
    if (unseen == null || unseen == 0) return 0;
    return unseen;
  }

  void _openAddListing() {
    if (profile.isEmpty) {
      showAppErrorSnackbar('Complete your profile', title: 'Required');
      return;
    }
    Get.to(() => const AddProductScreen(popToHomeOnBack: true));
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _key,
      drawer: Consumer<UserViewModel>(
        builder: (context, usp, _) => AppDrawerScreen(
          key: ValueKey('drawer-${usp.role}'),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Earning',
          style: _nunito(
            size: 20,
            weight: FontWeight.w800,
            color: AppColors.jebbyTextPrimary,
          ),
        ),
        leading: InkWell(
          onTap: () => _key.currentState?.openDrawer(),
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Image.asset(
              'assets/images/mingcute_menu-fill.png',
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  seenNotification();
                  Get.to(() => const NotificationsScreen(isVendor: true));
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.jebbyBlue,
                  size: 26,
                ),
              ),
              if (!isLoadingNotifications &&
                  !isErrorNotifications &&
                  _notificationBadge > 0)
                Positioned(
                  top: 8,
                  right: 8,
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 88 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _greetingBanner(),
            const SizedBox(height: 12),
            _listItemButton(),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Center(child: _earnTagline()),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _greetingBanner() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.earnerBannerBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/beachview.png',
              width: 180,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 124, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hey, $_firstName.',
                  style: _nunito(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your things.\nTheir next\nadventure.',
                  style: _nunito(
                    size: 24,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyNavy,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
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
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
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
  }

  Widget _listItemButton() {
    const radius = 14.0;
    return Material(
      color: AppColors.jebbyBlue,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: _openAddListing,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'List an item',
                style: _nunito(
                  size: 17,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _businessCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        children: [
          _businessRow(
            icon: Icons.sell_outlined,
            iconColor: AppColors.jebbyBlue,
            iconBackground: AppColors.jebbySoftBlue,
            title: 'Listings',
            subtitle: '$_liveListings live · $_draftListings draft',
            onTap: () => Get.to(() => MyProductsScreen(side: false)),
            showDivider: true,
          ),
          _businessRow(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.jebbyAccentOrange,
            iconBackground: AppColors.earnerOrangeSoft,
            title: 'Orders',
            subtitle: '$_orderRequests requests · $_orderActive active',
            onTap: () => Get.to(() => const VendorMyOrdersScreen()),
            showDivider: true,
          ),
          _businessRow(
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.jebbyBlue,
            iconBackground: AppColors.jebbySoftBlue,
            title: 'Transactions',
            onTap: () => Get.to(() => VendorMyTransactionsScreen()),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.earnerBannerBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: AppColors.jebbyBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renting opens soon',
                  style: _nunito(
                    size: 16,
                    weight: FontWeight.w800,
                    color: AppColors.jebbyNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'People can browse and save your live items.',
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
        ],
      ),
    );
  }
}
