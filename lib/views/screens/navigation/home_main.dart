import 'dart:async';
import 'package:jebby/views/screens/home/filter.dart';
import 'package:jebby/views/screens/shared/chat.dart';
import 'package:jebby/constants/color.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottom_nav_controller.dart';
import 'package:jebby/views/screens/navigation/app_drawer.dart';
import 'package:jebby/views/screens/home/featured_categories.dart';
import 'package:jebby/views/screens/home/home.dart';
import 'package:jebby/views/screens/shared/settings.dart';
import 'package:jebby/views/screens/profile/user_profile.dart';
import 'package:jebby/views/screens/shared/notifications.dart';
import 'package:jebby/views/screens/vendors/vendor_home.dart';
import 'package:jebby/views/screens/vendors/listing/create_listing.dart';
import 'package:jebby/repositories/api_repository.dart';
import 'package:jebby/utils/profile_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/provider/sign_in_provider.dart';
import '../../../models/user_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../view_models/reservation_view_model.dart';
import '../../../view_models/user_view_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bottomctrl = Get.put(BottomNavController());
  num activeIndex = 0;


  var screens = [
    HomeScreen(),
    FilterScreen(),
    FeaturedCategoriesScreen(),
    NotificationsScreen(),
    SettingsScreen(),
    MessagesScreen(),
  ];

  int _inboxUnread = 0;

  Widget _buildEarnerScreen(int index) {
    switch (index) {
      case 1:
        return const UserProfileScreen();
      case 4:
        return SettingsScreen();
      case 5:
        return const MessagesScreen();
      case 0:
      default:
        return const VendorHomeScreen();
    }
  }

  Future<void> _openEarnerListItem() async {
    await Get.to(() => const CreateListingScreen());
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();
  String? ids;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  bool isNotific = true;

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('time') == false) {
      cancelTimer();
      return;
    }

    cancelTimer();
    notiTimer().timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (token == null ||
          token == "" ||
          role == "" ||
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

  cancelTimer() {
    notiTimer().cancelTimer();
  }

  @override
  void initState() {
    func();
    getData();
    profileData(context);
    super.initState();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  void func() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("time", true);
    check();
  }

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;

  void profileData(BuildContext context) async {
    final usp = context.read<UserViewModel>();
    usp
        .getUser()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          getProductsApi(id.toString());
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          getChatHistory();
        })
        .onError((error, stackTrace) {});
  }

  void getChatHistory() {
    final userId = id;
    if (userId == null || userId.isEmpty) return;
    ApiRepository.shared.chatsHistory(
      userId,
      (payload) {
        if (!mounted) return;
        final chats = payload.data ?? [];
        var total = 0;
        for (final chat in chats) {
          total += chat.count ?? 0;
        }
        setState(() => _inboxUnread = total);
      },
      (error) {},
    );
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getNotifications() {
    ApiRepository.shared.notifications(
      id,
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isEmpty = true;
              isLoading = false;
              isError = false;
            });
          } else {
            setState(() {
              isEmpty = false;
              isLoading = false;
              isError = false;
            });
          }
        }
      },
      (error) {
        if (error != null && mounted) {
          setState(() {
            isEmpty = false;
            isLoading = true;
            isError = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final isProviderMode = userViewModel.isEarnMode;


    Future.delayed(const Duration(seconds: 1), () {});

    return Scaffold(
      key: bottomctrl.mainScaffoldKey,
      extendBody: true,
      drawer: Consumer<UserViewModel>(
        builder: (context, usp, _) => AppDrawerScreen.buildMainDrawer(
          context,
          key: ValueKey('main-drawer-${usp.isGuestUser}-${usp.role}-${usp.isEarnMode}'),
        ),
      ),
      body: GetBuilder<BottomNavController>(
        init: bottomctrl,
        builder: (_) {
          activeIndex = bottomctrl.navigationBarIndexValue;
          if (isProviderMode) {
            return _buildEarnerScreen(activeIndex.toInt());
          }
          return screens[bottomctrl.navigationBarIndexValue];
        },
      ),
      bottomNavigationBar:
          isProviderMode
              ? bottomForEarner()
              : (userViewModel.isGuestUser
                    ? bottomForGuest()
                    : bottomForUser(userName)),
    );
  }

  static const double _footerBarHeight = 64;
  static const double _footerFabSize = 60;
  static const double _footerCenterGapWidth = _footerFabSize + 4;
  /// Extra inset between side tabs and center List Item slot (earner only).
  static const double _earnerFooterFabSideGap = 12;
  static const double _footerNavIconSize = 28;
  static const double _footerLabelFontSize = 12.5;
  static const Color _footerInactive = Color(0xFFB5B5B5);
  static const Color _footerLabelActive = Color(0xFF2C2C2C);

  TextStyle _footerTextStyle(
    bool selected, {
    Color? activeAccent,
    Color? activeLabelColor,
  }) =>
      GoogleFonts.inter(
        fontSize: _footerLabelFontSize,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        height: 1.15,
        color: selected
            ? (activeLabelColor ?? activeAccent ?? _footerLabelActive)
            : _footerInactive,
      );

  Color _footerIconColor(bool selected, {Color? activeAccent}) => selected
      ? (activeAccent ?? AppColors.primaryColor)
      : _footerInactive;

  Widget _footerNavTap({
    required Widget icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? activeAccent,
    Color? activeLabelColor,
    bool suppressRipple = false,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: _footerTextStyle(
            selected,
            activeAccent: activeAccent,
            activeLabelColor: activeLabelColor,
          ),
        ),
      ],
    );

    if (suppressRipple) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }

  static const Color _earnerFooterAccent = AppColors.jebbyBlue;

  Widget _footerSearchSlot() {
    return _footerNavTap(
      icon: Image.asset(
        'assets/images/searchnew_tab.png',
        width: _footerNavIconSize,
        height: _footerNavIconSize,
        color: _footerIconColor(activeIndex == 1),
      ),
      label: 'Search',
      selected: activeIndex == 1,
      onTap: () {
        bottomctrl.navBarChange(1);
        setState(() => activeIndex = 1);
      },
    );
  }

  Widget _footerDockedFab() {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      color: AppColors.primaryColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          bottomctrl.navBarChange(2);
          setState(() => activeIndex = 2);
        },
        child: const SizedBox(
          width: _footerFabSize,
          height: _footerFabSize,
          child: Icon(
            Icons.grid_view_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _footerProfileSlot() {
    return _footerNavTap(
      suppressRipple: true,
      activeAccent: _earnerFooterAccent,
      activeLabelColor: _earnerFooterAccent,
      icon: Icon(
        Icons.person_outline_rounded,
        size: _footerNavIconSize,
        color: _footerIconColor(activeIndex == 1, activeAccent: _earnerFooterAccent),
      ),
      label: 'Profile',
      selected: activeIndex == 1,
      onTap: () {
        bottomctrl.navBarChange(1);
        setState(() => activeIndex = 1);
      },
    );
  }

  Widget _footerEarnerMessagesSlot() {
    return _footerNavTap(
      suppressRipple: true,
      activeAccent: _earnerFooterAccent,
      activeLabelColor: _earnerFooterAccent,
      icon: SizedBox(
        width: _footerNavIconSize,
        height: _footerNavIconSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Icon(
                Icons.chat_outlined,
                size: _footerNavIconSize,
                color: _footerIconColor(
                  activeIndex == 5,
                  activeAccent: _earnerFooterAccent,
                ),
              ),
            ),
            if (_inboxUnread > 0)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    _inboxUnread > 9 ? '9+' : '$_inboxUnread',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: 'Messages',
      selected: activeIndex == 5,
      onTap: () {
        setState(() => activeIndex = 5);
        bottomctrl.navBarChange(5);
        getChatHistory();
      },
    );
  }

  Widget _earnerDockedFab() {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      color: _earnerFooterAccent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _openEarnerListItem,
        child: const SizedBox(
          width: _footerFabSize,
          height: _footerFabSize,
          child: Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  /// Center gap label — FAB is docked separately like renter categories button.
  Widget _footerListItemLabelSlot() {
    return SizedBox(
      width: _footerCenterGapWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _footerNavIconSize),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'List Item',
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: _footerLabelFontSize,
                fontWeight: FontWeight.w600,
                height: 1.15,
                color: _earnerFooterAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomForEarner() {
    final size = MediaQuery.sizeOf(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final paintHeight = _footerBarHeight + bottomPad;

    return SizedBox(
      height: _footerBarHeight + 22 + bottomPad,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: paintHeight,
            child: CustomPaint(
              painter: JebbyFooterBarPainter(),
              size: Size(size.width, paintHeight),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad,
            height: _footerBarHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _footerNavTap(
                      suppressRipple: true,
                      activeAccent: _earnerFooterAccent,
                      activeLabelColor: _earnerFooterAccent,
                      icon: Icon(
                        Icons.home_outlined,
                        size: _footerNavIconSize,
                        color: _footerIconColor(
                          activeIndex == 0,
                          activeAccent: _earnerFooterAccent,
                        ),
                      ),
                      label: 'Home',
                      selected: activeIndex == 0,
                      onTap: () {
                        bottomctrl.navBarChange(0);
                        setState(() => activeIndex = 0);
                        context.read<ReservationViewModel>().loadActionRequired();
                      },
                    ),
                  ),
                  Expanded(child: _footerProfileSlot()),
                  const SizedBox(width: _earnerFooterFabSideGap),
                  _footerListItemLabelSlot(),
                  const SizedBox(width: _earnerFooterFabSideGap),
                  Expanded(child: _footerEarnerMessagesSlot()),
                  Expanded(
                    child: _footerNavTap(
                      suppressRipple: true,
                      activeAccent: _earnerFooterAccent,
                      activeLabelColor: _earnerFooterAccent,
                      icon: Icon(
                        Icons.settings_outlined,
                        size: _footerNavIconSize,
                        color: _footerIconColor(
                          activeIndex == 4,
                          activeAccent: _earnerFooterAccent,
                        ),
                      ),
                      label: 'Settings',
                      selected: activeIndex == 4,
                      onTap: () {
                        setState(() => activeIndex = 4);
                        bottomctrl.navBarChange(4);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad + _footerBarHeight - (_footerFabSize * 0.75),
            child: Center(child: _earnerDockedFab()),
          ),
        ],
      ),
    );
  }

  Widget bottomForUser(userName) {
    final size = MediaQuery.sizeOf(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final paintHeight = _footerBarHeight + bottomPad;

    return SizedBox(
      height: _footerBarHeight + 22 + bottomPad,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: paintHeight,
            child: CustomPaint(
              painter: JebbyFooterBarPainter(),
              size: Size(size.width, paintHeight),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad,
            height: _footerBarHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _footerNavTap(
                        icon: Image.asset(
                          'assets/images/home_footer.png',
                          width: _footerNavIconSize,
                          height: _footerNavIconSize,
                          color: _footerIconColor(activeIndex == 0),
                        ),
                        label: 'Home',
                        selected: activeIndex == 0,
                        onTap: () {
                          bottomctrl.navBarChange(0);
                          setState(() => activeIndex = 0);
                          context.read<ReservationViewModel>().loadActionRequired();
                        },
                      ),
                    ),
                    Expanded(child: _footerSearchSlot()),
                    const SizedBox(width: _footerFabSize + 4),
                    Expanded(
                      child: _footerNavTap(
                        icon: Image.asset(
                          'assets/images/chaticon.png',
                          width: _footerNavIconSize,
                          height: _footerNavIconSize,
                          color: _footerIconColor(activeIndex == 5),
                        ),
                        label: 'Chat',
                        selected: activeIndex == 5,
                        onTap: () {
                          setState(() => activeIndex = 5);
                          bottomctrl.navBarChange(5);
                        },
                      ),
                    ),
                    Expanded(
                      child: _footerNavTap(
                        icon: Image.asset(
                          'assets/images/settingicon.png',
                          width: _footerNavIconSize,
                          height: _footerNavIconSize,
                          color: _footerIconColor(activeIndex == 4),
                        ),
                        label: 'Settings',
                        selected: activeIndex == 4,
                        onTap: () {
                          setState(() => activeIndex = 4);
                          bottomctrl.navBarChange(4);
                        },
                      ),
                    ),
                  ],
                ),
            ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPad + _footerBarHeight - (_footerFabSize * 0.75),
              child: Center(child: _footerDockedFab()),
            ),
          ],
        ),
    );
  }

  Widget bottomForGuest() {
    final size = MediaQuery.sizeOf(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final paintHeight = _footerBarHeight + bottomPad;

    return SizedBox(
      height: _footerBarHeight + 22 + bottomPad,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: paintHeight,
            child: CustomPaint(
              painter: JebbyFooterBarPainter(),
              size: Size(size.width, paintHeight),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad,
            height: _footerBarHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  children: [
                    Expanded(
                      child: _footerNavTap(
                        icon: Icon(
                          Icons.home_rounded,
                          size: _footerNavIconSize,
                          color: _footerIconColor(activeIndex == 0),
                        ),
                        label: 'Home',
                        selected: activeIndex == 0,
                        onTap: () {
                          bottomctrl.navBarChange(0);
                          setState(() => activeIndex = 0);
                          context.read<ReservationViewModel>().loadActionRequired();
                        },
                      ),
                    ),
                    const SizedBox(width: _footerFabSize + 4),
                    Expanded(
                      child: _footerNavTap(
                        icon: Icon(
                          Icons.search_rounded,
                          size: _footerNavIconSize,
                          color: _footerIconColor(activeIndex == 1),
                        ),
                        label: 'Search',
                        selected: activeIndex == 1,
                        onTap: () {
                          bottomctrl.navBarChange(1);
                          setState(() => activeIndex = 1);
                        },
                      ),
                    ),
                  ],
              ),
            ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPad + _footerBarHeight - (_footerFabSize * 0.75),
              child: Center(child: _footerDockedFab()),
            ),
          ],
        ),
    );
  }

  var imagesapi = "";
  var nameapi = "";
  var locationapi = "";
  var emailapi = "";

  Future getProductsApi(String ids) async {
    final row = await ApiRepository.shared.fetchUserProfileRow(ids);
    if (row == null) return;

    if (mounted) {
      setState(() {
        imagesapi = ProfileImage.sanitizePath(row['profile_image']?.toString());
        nameapi = row['name']?.toString() ?? '';
        emailapi = row['email']?.toString() ?? '';
        locationapi = row['address']?.toString() ?? '';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      prefs.setString('fullname', row['name']?.toString() ?? '');
      prefs.setString('email', row['email']?.toString() ?? '');
      prefs.setString(
        'profileImage',
        ProfileImage.sanitizePath(row['profile_image']?.toString()),
      );
      prefs.setString('address', row['address']?.toString() ?? '');
      prefs.setString('latitude', row['latitude']?.toString() ?? '');
      prefs.setString('longitude', row['longitude']?.toString() ?? '');
      prefs.setString('phoneNumber', row['phone_number']?.toString() ?? '');
    });
  }
}

/// White bar with a subtle top shadow and convex center bump for the docked FAB.
class JebbyFooterBarPainter extends CustomPainter {
  JebbyFooterBarPainter({
    this.topFlatY = 5,
    this.bumpPeakY = -30,
  });

  final double topFlatY;
  final double bumpPeakY;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(0, topFlatY);
    path.lineTo(w * 0.36, topFlatY);
    path.quadraticBezierTo(w * 0.40, topFlatY, w * 0.44, topFlatY - 20);
    path.quadraticBezierTo(w * 0.50, bumpPeakY, w * 0.56, topFlatY - 20);
    path.quadraticBezierTo(w * 0.60, topFlatY, w * 0.64, topFlatY);
    path.lineTo(w, topFlatY);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawShadow(path, const Color(0x33000000), 6, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant JebbyFooterBarPainter oldDelegate) =>
      oldDelegate.topFlatY != topFlatY || oldDelegate.bumpPeakY != bumpPeakY;
}
