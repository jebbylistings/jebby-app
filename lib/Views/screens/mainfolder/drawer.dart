import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/screens/agreements/Aboutapp.dart';
import 'package:jebby/Views/screens/agreements/insuranceAndIndemnifications.dart';
import 'package:jebby/Views/screens/agreements/privacyPolicy.dart';
import 'package:jebby/Views/screens/agreements/rentalAgreement.dart';
import 'package:jebby/Views/screens/agreements/CopyrightPolicy.dart';
import 'package:jebby/Views/screens/agreements/termination.dart';
import 'package:jebby/Views/screens/agreements/termsAndConditions.dart';
import 'package:jebby/Views/screens/agreements/transportAndInstallationPolicy.dart';
import 'package:jebby/Views/screens/agreements/usagePolicyAndLimitations.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/home/Favourites.dart';
import 'package:jebby/Views/screens/home/MyOrders.dart';
import 'package:jebby/Views/screens/home/MyTransactions.dart';
import 'package:jebby/Views/screens/home/ReturnProduct.dart';
import 'package:jebby/Views/screens/shared/Chat.dart';
import 'package:jebby/Views/screens/mainfolder/homemain.dart';
import 'package:jebby/Views/screens/profile/userprofile.dart';
import 'package:jebby/Views/screens/shared/Setting.dart';
import 'package:jebby/Views/screens/vendors/MyOrders.dart';
import 'package:jebby/Views/screens/vendors/ReturnProduct.dart';
import 'package:jebby/Views/screens/vendors/MyTransactions.dart';
import 'package:jebby/Views/screens/vendors/vendorhome.dart';
import 'package:jebby/Views/screens/onboarding/start_earning_button.dart';
import 'package:jebby/Views/widgets/role_switcher_card.dart';
import 'package:jebby/Views/support/contactsupport.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/respository/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/onboarding_controller.dart';
import '../../../view_model/user_view_model.dart';
import '../../controller/bottomcontroller.dart';

class DrawerScreen extends StatefulWidget {
  final VoidCallback? onCloseDrawer;
  final String stack;

  DrawerScreen({Key? key, this.onCloseDrawer, this.stack = "home"})
    : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  bool onboardingCompleted = false;

  // String userName = "";
  // String userEmail = "";
  // bool checkLogin = false;
  var shaka;
  final _myRepo = AuthRepository();

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
    final usp = context.read<UserViewModel>();
    usp.getUpdatedUser();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          getProductsApi(id);
          role = value.role.toString();

          // Also update the UserViewModel to ensure consistency
          final usp = context.read<UserViewModel>();
          if (usp.role != value.role.toString()) {
            usp.setRole(value.role.toString());
          }

          _loadOnboardingController();

          if (mounted) {
            setState(() {});
          }
        })
        .onError((error, stackTrace) {});
  }

  Future<void> _loadOnboardingController() async {
    final userId = id;
    if (userId == null || userId.isEmpty) return;

    final controller = ensureOnboardingController();
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phoneNumber');

    await controller.loadAndReconcile(
      userId: userId,
      name: fullname,
      email: email,
      phone: phone,
    );

    if (mounted) {
      setState(() {
        onboardingCompleted =
            prefs.getBool('identity_verified') ?? false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ensureOnboardingController();
    getData();
    profileData(context);
    _loadOnboardingStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh role data when dependencies change
    profileData(context);
    _loadOnboardingStatus(); // Refresh onboarding status
  }

  void _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool newOnboardingCompleted = prefs.getBool('identity_verified') ?? false;

    setState(() {
      onboardingCompleted = newOnboardingCompleted;
    });
  }

  bool _roleSwitchInProgress = false;

  Future<void> _switchRole(BuildContext context, {required bool toEarn}) async {
    final usp = context.read<UserViewModel>();
    final sp = context.read<SignInProvider>();
    final currentIsEarn = usp.role == "1";
    if (currentIsEarn == toEarn || _roleSwitchInProgress) return;

    setState(() => _roleSwitchInProgress = true);
    final role = toEarn ? "1" : "0";

    try {
      final response = await _myRepo.updateRoleApi({
        "role": role,
        "email": usp.email ?? sp.email,
      });
      if (response["status"] == 200) {
        final sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('role', role);
        usp.setRole(role);
        sp.saveDataToSharedPreferences();
        Get.snackbar(
          'Mode switched',
          toEarn ? 'Switched to Earn Mode' : 'Switched to Rent Mode',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        if (toEarn) {
          Get.offAll(() => VendrosHomeScreen());
        } else {
          Get.offAll(() => MainScreen());
        }
      }
    } catch (error) {
      print("Error updating role: $error");
    } finally {
      if (mounted) {
        setState(() => _roleSwitchInProgress = false);
      }
    }
  }

  Widget _buildRoleModeSection(UserViewModel usp, double resWidth) {
    if (usp.role != "1" && !onboardingCompleted) {
      return const StartEarningButton();
    }
    return SizedBox(
      width: resWidth * 0.75,
      child: RoleSwitcherCard(
        isEarnMode: usp.role == "1",
        isLoading: _roleSwitchInProgress,
        onModeChanged: (toEarn) => _switchRole(context, toEarn: toEarn),
      ),
    );
  }

  final bottomctrl = Get.put(BottomController());

  void _openProviderChat(BuildContext context) {
    Navigator.of(context).pop();
    Get.to(() => const MessagesScreen(showBackButton: true));
  }

  void _openRenterChat(BuildContext context) {
    bottomctrl.navBarChange(5);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Refresh onboarding status when drawer is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOnboardingStatus();
    });

    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double baseWidth = 428;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          (fullname != null && fullname == "Guest")
              ? getGuestDrawer(res_width, res_height, ffem)
              : getNormalDrawer(res_width, res_height, ffem),
    );
  }

  Widget getGuestDrawer(double res_width, double res_height, double ffem) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    return Container(
      width: res_width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: res_height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Get.back(),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/newpacks/close-circle.png',
                          color: Colors.black,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        isLoadingImage
                            ? CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            )
                            : imagesapi != "null" && imagesapi.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: "${Url}${imagesapi}",
                              imageBuilder:
                                  (context, imageProvider) => CircleAvatar(
                                    radius: 40,
                                    backgroundImage: imageProvider,
                                  ),
                              placeholder:
                                  (context, url) => CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey[200],
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => CircleAvatar(
                                    radius: 40,
                                    backgroundImage: AssetImage(
                                      "assets/slicing/blankuser.jpeg",
                                    ),
                                  ),
                            )
                            : CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                "assets/slicing/blankuser.jpeg",
                              ),
                            ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usp.name == "null"
                                  ? sp.name.toString() == "null"
                                      ? "Guest"
                                      : sp.name.toString()
                                  : usp.name.toString(),
                              style: TextStyle(
                                fontSize: 26 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              usp.email.toString() == "null"
                                  ? sp.email.toString()
                                  : sp.email.toString(),
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: res_height * 0.04),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 1);
                  if (bottomctrl.navigationBarIndexValue != 0) {
                    bottomctrl.navBarChange(0);
                  } else {
                    bottomctrl.navBarChange(2);
                  }
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/home.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: res_width * 0.7,
                child: Divider(color: Colors.grey.shade300),
              ),
              Container(
                width: res_width * 0.7,
                height: res_height * 0.059,
                child: Row(
                  children: [
                    Text(
                      "Legal",
                      style: TextStyle(
                        fontSize: 15 * textScaleFactor,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 10);
                  Get.to(() => TermsAndCondition());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 11);
                  Get.to(() => PrivacyPolicy());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/note-text.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SizedBox(
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 12);
                  Get.to(CopyrightPolicy());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/note-text.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Copyright Policy",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 13);
                  Get.to(RentalAgreement());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/note-text.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Rental Agreement",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 14);
                  Get.to(usagePolicyAndLimitations());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Usage Policy & Limitations",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 15);
                  Get.to(InsuranceAndIndemnification());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Insurance & Indemnifications Policy",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 16);
                  Get.to(TransportAndInstallationPolicy());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Transportation & Installation Policy",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 17);
                  Get.to(AboutAppScreen());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Maintenance & Warranties",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  setState(() => shaka = 18);
                  Get.to(Termination());
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/menu-board.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Termination",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: res_width * 0.7,
                child: Divider(color: Colors.grey.shade300),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  setState(() {
                    sharedPreferences.setString('token', "");
                    sharedPreferences.setString('role', "");
                  });
                  sharedPreferences.setBool("time", false);
                  final userPrefernece = Provider.of<UserViewModel>(
                    context,
                    listen: false,
                  );
                  userPrefernece.remove().then((value) {});
                  sp
                      .userSignOut()
                      .then((value) {
                        Get.to(() => LoginScreen());
                      })
                      .catchError((e) {
                        if (kDebugMode) {}
                      });
                },
                child: Container(
                  width: res_width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/newpacks/logout.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 15 * textScaleFactor,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.095),
            ],
          ),
        ),
      ),
    );
  }

  Widget getNormalDrawer(double res_width, double res_height, double ffem) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();
    // Retrieve the current text scale factor from the MediaQuery
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    return Container(
      width: res_width * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child:
            role == "1"
                ? Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: res_height * 0.06),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () {
                                Get.back();
                                widget.onCloseDrawer?.call();
                              },
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/newpacks/close-circle.png',
                                  color: Colors.black,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingImage
                              ? CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                              : imagesapi != "null" && imagesapi.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: "${Url}${imagesapi}",
                                imageBuilder:
                                    (context, imageProvider) => CircleAvatar(
                                      radius: 40,
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder:
                                    (context, url) => CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[200],
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage(
                                        "assets/slicing/blankuser.jpeg",
                                      ),
                                    ),
                              )
                              : CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  "assets/slicing/blankuser.jpeg",
                                ),
                              ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: res_width * 0.55,
                                child: Text(
                                  getText(usp, sp),
                                  style: TextStyle(
                                    fontSize: 26 * textScaleFactor,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              getText(usp, sp).contains('+')
                                  ? Container()
                                  : SizedBox(
                                    width: res_width * 0.55,
                                    child: Text(
                                      (usp.email.toString() == "null" ||
                                              usp.email.toString().contains(
                                                "Phone",
                                              ))
                                          ? usp.phoneNumber.toString()
                                          : usp.email.toString(),
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRoleModeSection(usp, res_width),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 1;
                          });
                          if (bottomctrl.navigationBarIndexValue != 0) {
                            bottomctrl.navBarChange(0);
                          } else {
                            Get.back();
                            widget.onCloseDrawer?.call();
                          }
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/home.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Home",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            Text(
                              "Account",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 2;
                          });
                          Get.to(() => RenterProfile());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/frame.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Profile",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 3;
                          });
                          _openProviderChat(context);
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/messages.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Chat",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 4;
                          });
                          Get.to(const OrderRequestScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/book.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "My Orders",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 5;
                          });
                          Get.to(TransactionListScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/dollar-circle.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "My Transactions",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 6;
                          });
                          Get.to(ProductReturnScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/bag-tick.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Return Product",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            Text(
                              "Support",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 9;
                          });
                          Get.to(() => ContactSupport());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/message-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Provide Feedback",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            Text(
                              "Legal",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 10;
                          });
                          Get.to(() => TermsAndCondition());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Terms & Conditions",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 11;
                          });
                          Get.to(() => PrivacyPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Privacy Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 12;
                          });
                          Get.to(CopyrightPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Copyright Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 13;
                          });
                          Get.to(RentalAgreement());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Rental Agreement",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 14;
                          });
                          Get.to(usagePolicyAndLimitations());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Usage Policy & Limitations",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 15;
                          });
                          Get.to(InsuranceAndIndemnification());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Insurance & Indemnifications Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 16;
                          });
                          Get.to(TransportAndInstallationPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Transportation & Installation Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 17;
                          });
                          Get.to(AboutAppScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Maintenance & Warranties",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 18;
                          });
                          Get.to(Termination());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Termination",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 19;
                          });
                          Get.back();
                          widget.onCloseDrawer?.call();
                          Get.to(() => const Settings());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/setting-2.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Settings",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();

                          setState(() {
                            sharedPreferences.setString('token', "");
                            sharedPreferences.setString('role', "");
                          });

                          sharedPreferences.setBool("time", false);

                          final userPrefernece = Provider.of<UserViewModel>(
                            context,
                            listen: false,
                          );
                          userPrefernece.remove().then((value) {
                            sharedPreferences.clear();
                          });
                          sp
                              .userSignOut()
                              .then((value) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                                notiTimer().timer?.cancel();
                              })
                              .catchError((e) {
                                if (kDebugMode) {}
                              });
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/logout.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: res_height * 0.095),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: res_height * 0.06),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () {
                                Get.back();
                              },
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  'assets/newpacks/close-circle.png',
                                  color: Colors.black,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingImage
                              ? CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                              : imagesapi != "null" && imagesapi.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: "${Url}${imagesapi}",
                                imageBuilder:
                                    (context, imageProvider) => CircleAvatar(
                                      radius: 40,
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder:
                                    (context, url) => CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[200],
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage(
                                        "assets/slicing/blankuser.jpeg",
                                      ),
                                    ),
                              )
                              : CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  "assets/slicing/blankuser.jpeg",
                                ),
                              ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: res_width * 0.55,
                                child: Text(
                                  getText(usp, sp),
                                  style: TextStyle(
                                    fontSize: 26 * textScaleFactor,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              getText(usp, sp).contains('+')
                                  ? Container()
                                  : SizedBox(
                                    width: res_width * 0.55,
                                    child: Text(
                                      (usp.email.toString() == "null" ||
                                              usp.email.toString().contains(
                                                "Phone",
                                              ))
                                          ? usp.phoneNumber.toString()
                                          : usp.email.toString(),
                                      style: TextStyle(
                                        fontSize: 15 * textScaleFactor,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRoleModeSection(usp, res_width),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 1;
                          });
                          if (bottomctrl.navigationBarIndexValue != 0) {
                            bottomctrl.navBarChange(0);
                          } else {
                            Get.back();
                            widget.onCloseDrawer?.call();
                          }
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 5),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/home.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Home",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      // SizedBox(height: 10),
                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            // Icon(
                            //   Icons.home_outlined,
                            //   color: Colors.white,
                            // ),
                            // SizedBox(
                            //   width: 20,
                            // ),
                            Text(
                              "Account",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 2;
                          });
                          Get.to(() => MyProfileScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/frame.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Profile",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),

                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 3;
                      //       });
                      //       Get.to(MessagesScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 3
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(Icons.chat, color: Colors.white),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Chat",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 3;
                          });
                          _openRenterChat(context);
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/messages.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Chat",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 4;
                          });
                          Get.to(() => MyOrdersScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/book.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "My Orders",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 5;
                          });
                          Get.to(() => FavouriteScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/heart-edit.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "My Wishlist",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 6;
                          });
                          Get.to(() => ReturnProductScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/bag-tick.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Return Product",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 7;
                          });
                          Get.to(() => MyTransactionsScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/dollar-circle.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "My Transactions",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      // SizedBox(height: 10),
                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            // Icon(
                            //   Icons.home_outlined,
                            //   color: Colors.white,
                            // ),
                            // SizedBox(
                            //   width: 20,
                            // ),
                            Text(
                              "Support",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 9;
                          });
                          Get.to(() => ContactSupport());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/message-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Provide Feedback",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        child: Row(
                          children: [
                            // Icon(
                            //   Icons.home_outlined,
                            //   color: Colors.white,
                            // ),
                            // SizedBox(
                            //   width: 20,
                            // ),
                            Text(
                              "Legal",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15 * textScaleFactor,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 10;
                          });
                          Get.to(() => TermsAndCondition());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/menu-board.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Terms & Conditions",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 11;
                          });
                          Get.to(() => PrivacyPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Privacy Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 12;
                          });
                          Get.to(() => CopyrightPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Copyright Policy",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 13;
                          });
                          Get.to(() => RentalAgreement());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Rental Agreement",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 14;
                          });
                          Get.to(() => usagePolicyAndLimitations());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Usage Policy & Limitations",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 15;
                          });
                          Get.to(() => InsuranceAndIndemnification());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Insurance & Indemnifications",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 16;
                          });
                          Get.to(() => TransportAndInstallationPolicy());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Transportation & Installation...",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 17;
                          });
                          Get.to(() => AboutAppScreen());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Maintainence & Warranties",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 18;
                          });
                          Get.to(() => Termination());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/note-text.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Termination",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),
                      Container(
                        width: res_width * 0.7,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 19;
                          });
                          Get.back();
                          widget.onCloseDrawer?.call();
                          Get.to(() => const Settings());
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/setting-2.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Settings",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();

                          setState(() {
                            sharedPreferences.setString('token', "");
                            sharedPreferences.setString('role', "");
                          });

                          sharedPreferences.setBool("time", false);

                          final userPrefernece = Provider.of<UserViewModel>(
                            context,
                            listen: false,
                          );
                          userPrefernece.remove().then((value) {
                            sharedPreferences.clear();
                          });
                          sp
                              .userSignOut()
                              .then((value) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                                notiTimer().timer?.cancel();
                              })
                              .catchError((e) {
                                if (kDebugMode) {}
                              });
                        },
                        child: Container(
                          width: res_width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/newpacks/logout.png',
                                  color: Colors.black,
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Logout",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 15 * textScaleFactor,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 150),

                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 4;
                      //       });
                      //       Get.to(MyOrdersScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 4
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.list_alt_rounded,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "My Orders",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 5;
                      //       });
                      //       Get.to(() => FavouriteScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 5
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(Icons.save_as, color: Colors.white),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "My Wishlist",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 6;
                      //       });
                      //       Get.to(ReturnProductScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 6
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.list_alt_rounded,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Return Product",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 7;
                      //       });
                      //       Get.to(() => MyTransactionsScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 7
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.receipt_long,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "My Transactions",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: role == 1 ? 10 : 0),
                      // SizedBox(height: 15),
                      // Container(
                      //   width: res_width * 0.7,
                      //   height: res_height * 0.059,
                      //   decoration: BoxDecoration(
                      //     color: Colors.transparent,
                      //     borderRadius: BorderRadius.only(
                      //       topRight: Radius.circular(20),
                      //       bottomRight: Radius.circular(20),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     width: res_width * 0.4,
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(left: 20),
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: Row(
                      //           children: [
                      //             Text(
                      //               "Support",
                      //               textAlign: TextAlign.left,
                      //               style: TextStyle(
                      //                 fontSize: 23 * textScaleFactor,
                      //                 color: Colors.white,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 9;
                      //       });
                      //       Get.to(() => ContactSupport());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 9
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.list_alt_rounded,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Provide Feedback",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.white,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // SizedBox(height: 15),
                      // Container(
                      //   width: res_width * 0.7,
                      //   height: res_height * 0.059,
                      //   decoration: BoxDecoration(
                      //     color: Colors.transparent,
                      //     borderRadius: BorderRadius.only(
                      //       topRight: Radius.circular(20),
                      //       bottomRight: Radius.circular(20),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     width: res_width * 0.4,
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(left: 20),
                      //       child: Align(
                      //         alignment: Alignment.centerLeft,
                      //         child: Row(
                      //           children: [
                      //             Text(
                      //               "Legal",
                      //               textAlign: TextAlign.left,
                      //               style: TextStyle(
                      //                 fontSize: 23 * textScaleFactor,
                      //                 color: Colors.white,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 10;
                      //       });
                      //       Get.to(() => TermsAndCondition());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 10
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.library_books,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Terms & Conditions",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 5),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 11;
                      //       });
                      //       Get.to(() => PrivacyPolicy());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 11
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(Icons.list_alt, color: Colors.white),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Privacy Policy",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 12;
                      //       });
                      //       Get.to(CopyrightPolicy());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 12
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(Icons.list_alt, color: Colors.white),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Copyright Policy",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 13;
                      //       });
                      //       Get.to(RentalAgreement());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 13
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(left: 20),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(Icons.list_alt, color: Colors.white),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Rental Agreement",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 14;
                      //       });
                      //       Get.to(usagePolicyAndLimitations());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 14
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.view_list_outlined,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Usage Policy & Limitations",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 15;
                      //       });
                      //       Get.to(InsuranceAndIndemnification());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 15
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.view_list_outlined,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Insurance & Indemnifications Policy",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 16;
                      //       });
                      //       Get.to(TransportAndInstallationPolicy());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 16
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.view_list_outlined,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Transportation & Installation Policy",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 17;
                      //       });
                      //       Get.to(AboutAppScreen());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 17
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.view_list_outlined,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Maintenance & Warranties",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         shaka = 18;
                      //       });
                      //       Get.to(Termination());
                      //     },
                      //     child: Container(
                      //       width: res_width * 0.7,
                      //       height: res_height * 0.041,
                      //       decoration: BoxDecoration(
                      //         color:
                      //             shaka == 18
                      //                 ? Color(0xFF4285F4)
                      //                 : Colors.transparent,
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(20),
                      //           bottomRight: Radius.circular(20),
                      //         ),
                      //       ),
                      //       child: Container(
                      //         width: res_width * 0.4,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(
                      //             left: 20,
                      //             bottom: 5,
                      //           ),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Row(
                      //               children: [
                      //                 Icon(
                      //                   Icons.view_list_outlined,
                      //                   color: Colors.white,
                      //                 ),
                      //                 SizedBox(width: 20),
                      //                 SizedBox(
                      //                   width: res_width * 0.681,
                      //                   child: Text(
                      //                     "Termination",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       fontSize: 15 * textScaleFactor,
                      //                       color: Colors.black,
                      //                     ),
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 60),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border(
                      //         bottom: BorderSide(color: Colors.white, width: 0.2),
                      //       ),
                      //     ),
                      //     child: GestureDetector(
                      //       onTap: () {
                      //         setState(() {
                      //           shaka = 19;
                      //         });
                      //         if (bottomctrl.navigationBarIndexValue != 4) {
                      //           bottomctrl.navBarChange(4);
                      //         } else {
                      //           Get.back();
                      //         }
                      //       },
                      //       child: Container(
                      //         width: res_width * 0.7,
                      //         height: res_height * 0.041,
                      //         decoration: BoxDecoration(
                      //           color:
                      //               shaka == 19
                      //                   ? Color(0xFF4285F4)
                      //                   : Colors.transparent,
                      //           borderRadius: BorderRadius.only(
                      //             topRight: Radius.circular(20),
                      //             bottomRight: Radius.circular(20),
                      //           ),
                      //         ),
                      //         child: GestureDetector(
                      //           child: Container(
                      //             width: res_width * 0.4,
                      //             child: Padding(
                      //               padding: const EdgeInsets.only(
                      //                 left: 20,
                      //                 bottom: 5,
                      //               ),
                      //               child: Align(
                      //                 alignment: Alignment.centerLeft,
                      //                 child: Row(
                      //                   children: [
                      //                     Icon(
                      //                       Icons.settings,
                      //                       color: Colors.white,
                      //                     ),
                      //                     SizedBox(width: 20),
                      //                     SizedBox(
                      //                       width: res_width * 0.681,
                      //                       child: Text(
                      //                         "Settings",
                      //                         textAlign: TextAlign.left,
                      //                         style: TextStyle(
                      //                           fontSize: 15 * textScaleFactor,
                      //                           color: Colors.black,
                      //                         ),
                      //                         overflow: TextOverflow.ellipsis,
                      //                         maxLines: 1,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   width: res_width * 0.9,
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(color: Colors.white, width: 0.2),
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //     onTap: () async {
                      //       SharedPreferences sharedPreferences =
                      //           await SharedPreferences.getInstance();
                      //
                      //       setState(() {
                      //         sharedPreferences.setString('token', "");
                      //         sharedPreferences.setString('role', "");
                      //       });
                      //
                      //       sharedPreferences.setBool("time", false);
                      //
                      //       final userPrefernece = Provider.of<UserViewModel>(
                      //         context,
                      //         listen: false,
                      //       );
                      //       userPrefernece.remove().then((value) {
                      //         sharedPreferences.clear();
                      //       });
                      //       sp
                      //           .userSignOut()
                      //           .then((value) {
                      //             Navigator.pushAndRemoveUntil(
                      //               context,
                      //               MaterialPageRoute(
                      //                 builder: (context) => LoginScreen(),
                      //               ),
                      //               (route) => false,
                      //             );
                      //             notiTimer().timer?.cancel();
                      //           })
                      //           .catchError((e) {
                      //             if (kDebugMode) {}
                      //           });
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(left: 20, bottom: 7),
                      //       child: Row(
                      //         children: [
                      //           Icon(Icons.login_outlined, color: Colors.white),
                      //           SizedBox(width: 20),
                      //           SizedBox(
                      //             width: res_width * 0.681,
                      //             child: Text(
                      //               "Logout",
                      //               style: TextStyle(
                      //                 fontSize: 15 * textScaleFactor,
                      //                 color: Colors.black,
                      //               ),
                      //               overflow: TextOverflow.ellipsis,
                      //               maxLines: 1,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: res_height * 0.095),
                    ],
                  ),
                ),
      ),
    );
  }

  var imagesapi = "null";
  var nameapi = "null";
  var emailapi = "user email";
  var datalength;
  bool isLoadingImage = true;

  Future getProductsApi(id) async {
    try {
      final response = await http.get(
        Uri.parse('${Url}/UserProfileGetById/${id}'),
      );
      var data = jsonDecode(response.body.toString());
      datalength = data["data"].length;

      if (data["data"].length != 0) {
        if (mounted) {
          setState(() {
            imagesapi = data["data"][0]["image"].toString();
            nameapi = data["data"][0]["name"].toString();
            emailapi = data["data"][0]["email"].toString();
            isLoadingImage = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingImage = false;
          });
        }
      }

      if (response.statusCode == 200) {
        return data;
      } else {
        if (mounted) {
          setState(() {
            isLoadingImage = false;
          });
        }
        return "No data";
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingImage = false;
        });
      }
      return "No data";
    }
  }
}

String getText(usp, sp) {
  if (usp.name == "null") {
    if (sp.name.toString() == "null") {
      return "user name";
    } else if (sp.phoneNumber.toString() != "null") {
      return sp.phoneNumber.toString();
    } else {
      return sp.name.toString();
    }
  } else {
    if (usp.name.toString() == "") {
      return usp.phoneNumber.toString();
    } else {
      return usp.name.toString();
    }
  }
}
