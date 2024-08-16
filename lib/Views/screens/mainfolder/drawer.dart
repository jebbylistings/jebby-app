import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart' as d;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/agreements/Aboutapp.dart';
import 'package:jared/Views/screens/agreements/insuranceAndIndemnifications.dart';
import 'package:jared/Views/screens/agreements/privacyPolicy.dart';
import 'package:jared/Views/screens/agreements/rentalAgreement.dart';
import 'package:jared/Views/screens/agreements/termLength.dart';
import 'package:jared/Views/screens/agreements/termination.dart';
import 'package:jared/Views/screens/agreements/termsAndConditions.dart';
import 'package:jared/Views/screens/agreements/transportAndInstallationPolicy.dart';
import 'package:jared/Views/screens/agreements/usagePolicyAndLimitations.dart';
import 'package:jared/Views/screens/auth/login.dart';
import 'package:jared/Views/screens/home/Favourites.dart';
import 'package:jared/Views/screens/home/Messages(32).dart';
import 'package:jared/Views/screens/home/MyOrders.dart';
import 'package:jared/Views/screens/home/returnproduct.dart';
import 'package:jared/Views/screens/home/setting.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:jared/Views/screens/vendors/orderrequest.dart';
import 'package:jared/Views/screens/vendors/productreturn.dart';
import 'package:jared/Views/screens/vendors/renterProfile.dart';
import 'package:jared/Views/screens/vendors/transactionlist.dart';
import 'package:jared/Views/support/FAQs.dart';
import 'package:jared/Views/support/contactsupport.dart';
import 'package:jared/Views/support/providerfeedback.dart';
import 'package:jared/respository/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../../controller/bottomcontroller.dart';

class DrawerScreen extends StatefulWidget {
  final VoidCallback? onCloseDrawer;

  DrawerScreen({Key? key, this.onCloseDrawer}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
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
    getUserDate().then((value) async {
      token = value.token.toString();
      id = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      getProductsApi(id);
      role = value.role.toString();
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  void _showSuccessAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: Text('You have successfully become a provider'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(darkBlue),
                  )),
            ],
          );
        });
  }

  final bottomctrl = Get.put(BottomController());

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();

    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double baseWidth = 428;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: (fullname != null && fullname == "Guest") ? getGuestDrawer(res_width, res_height, ffem) : getNormalDrawer(res_width, res_height, ffem),
    );
  }

  Widget getGuestDrawer(double res_width, double res_height, double ffem) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();

    return Container(
        width: res_width * 0.85,
        height: res_height,
        decoration:
            BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                SizedBox(height: res_height * 0.04),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      usp.image.toString() == "null"
                          ? sp.imageUrl.toString() == "null"
                              ? CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                              : CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}"))
                          : CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                "${Url}${usp.image}",
                              )),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usp.name == "null"
                                ? sp.name.toString() == "null"
                                    ? "user name"
                                    : sp.name.toString()
                                : usp.name.toString(),
                            style: TextStyle(fontSize: 26, color: Colors.black),
                          ),
                          Text(usp.email.toString() == "null" ? sp.name.toString() : sp.email.toString(),
                              style: TextStyle(fontFamily: '', fontSize: 15, color: Colors.black))
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: res_height * 0.04),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 1;
                      });
                      if (bottomctrl.navigationBarIndexValue != 0) {
                        bottomctrl.navBarChange(0);
                      } else {
                        bottomctrl.navBarChange(2);
                      }
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 1 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Home",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 4;
                      });
                      Get.to(MyOrdersScreen());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 4 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "My Orders",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),

                SizedBox(
                  height: 15,
                ),

                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 6;
                      });
                      Get.to(ReturnProductScreen());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 6 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Return Product",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),

                SizedBox(
                  height: 15,
                ),
                Container(
                    width: res_width * 0.75,
                    height: res_height * 0.059,
                    decoration: BoxDecoration(
                        color: Colors.transparent, borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                    child: Container(
                        width: res_width * 0.4,
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                                style: TextStyle(fontSize: 23 * ffem, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ))),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 10;
                      });
                      Get.to(() => TermsAndCondition());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 10 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.library_books,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Terms & Conditions",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 11;
                      });
                      Get.to(() => PrivacyPolicy());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 11 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Privacy Policy",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                // SizedBox(
                //   height: res_height * 0.05,
                // ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 12;
                      });
                      Get.to(TermLength());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 12 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Copyright Policy",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 13;
                      });
                      Get.to(RentalAgreement());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 13 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Rental Agreement",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 14;
                      });
                      Get.to(usagePolicyAndLimitations());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 14 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Usage Policy & Limitations",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 15;
                      });
                      Get.to(InsuranceAndIndemnification());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 15 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Insurance & Indemnifications Policy",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 16;
                      });
                      Get.to(TransportAndInstallationPolicy());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 16 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Transportation & Installation Policy",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 17;
                      });
                      Get.to(AboutAppScreen());
                    },
                    child: Container(
                        width: res_width * 0.7,
                        height: res_height * 0.039,
                        decoration: BoxDecoration(
                            color: shaka == 17 ? Color(0xFF4285F4) : Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Maintenance & Warranties",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: res_width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shaka = 18;
                      });
                      Get.to(Termination());
                    },
                    child: Container(
                      width: res_width * 0.7,
                      height: res_height * 0.039,
                      decoration: BoxDecoration(
                          color: shaka == 18 ? Color(0xFF4285F4) : Colors.transparent,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                      child: Container(
                        width: res_width * 0.4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.view_list_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Termination",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
              ]),

              ///settings start here
              Column(
                children: [
                  Container(
                    width: res_width * 0.9,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                          width: 0.2,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        setState(() {
                          // timer.cancel();
                          sharedPreferences.setString('token', "");
                          sharedPreferences.setString('role', "");
                          print("cancelled");
                        });
                        sharedPreferences.setBool("time", false);
                        // setState(() {
                        //   timer.cancel();
                        //   // super.initState();
                        // });
                        final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                        userPrefernece.remove().then((value) {
                          // Get.offAll(() => LoginScreen());
                        });
                        sp.userSignOut().then((value) {
                          print("SOME wORK");
                          Get.to(() => LoginScreen());
                        }).catchError((e) {
                          if (kDebugMode) {}
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 7),
                        child: Row(
                          children: [
                            Icon(
                              Icons.login_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(fontSize: 18 * ffem, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 99,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget getNormalDrawer(double res_width, double res_height, double ffem) {
    final sp = context.watch<SignInProvider>();
    final usp = context.watch<UserViewModel>();
    // Retrieve the current text scale factor from the MediaQuery
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: res_width * 0.85,
      decoration:
          BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),
      child: SingleChildScrollView(
          child: role == "1"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: res_height * 0.04),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          usp.image.toString() == "null"
                              ? sp.imageUrl.toString() == "null"
                                  ? CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                                  : CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}"))
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    "https://api.jebbylistings.com${usp.image}",
                                  )),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: res_width * 0.55,
                                child: Text(
                                  getText(usp, sp),
                                  style: TextStyle(fontSize: 26 * textScaleFactor, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              getText(usp, sp).contains('+')
                                  ? Container()
                                  : SizedBox(
                                      width: res_width * 0.55,
                                      child: Text(
                                        (usp.email.toString() == "null" || usp.email.toString().contains("Phone"))
                                            ? usp.phoneNumber.toString()
                                            : usp.email.toString(),
                                        style: TextStyle(fontSize: 15 * textScaleFactor, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    (usp.role == "0" || sp.role == "0")
                        ? Center(
                            child: ElevatedButton(
                                onPressed: () async {
                                  _myRepo.updateRoleApi({"role": "1", "email": usp.email ?? sp.email}).then((value) async {
                                    if (value["status"] == 200) {
                                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                                      setState(() {
                                        sharedPreferences.setString('role', "1");
                                      });

                                      getData();
                                      Get.back();
                                      widget.onCloseDrawer?.call();
                                      _showSuccessAlert(context);
                                      // final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                                      // userPrefernece.saveUser()
                                    }
                                  });
                                },
                                child: Text(
                                  'Become Provider',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    textStyle: TextStyle(fontSize: 16),
                                    backgroundColor: darkBlue)),
                          )
                        : SizedBox(),
                    SizedBox(height: res_height * 0.04),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 1;
                          });
                          print("bottomctrl.navigationBarIndexValue ${bottomctrl.navigationBarIndexValue}");
                          if (bottomctrl.navigationBarIndexValue != 0) {
                            bottomctrl.navBarChange(0);
                          } else {
                            Get.back();
                          }
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 1 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.home_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Home",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Account",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 23 * ffem, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 2;
                          });
                          Get.to(() => RenterProfile());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 2 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Profile",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 3;
                          });
                          Get.to(MessagesScreen());
                          // if (bottomctrl.navigationBarIndexValue != 3) {
                          //   bottomctrl.navBarChange(3);
                          // } else {
                          //   Get.back();
                          // }
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 3 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Chat",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 4;
                          });
                          Get.to(OrderRequests());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 4 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "My Orders List",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 5;
                          });
                          Get.to(TransactionListScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 5 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.save_as,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Transaction List",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 6;
                          });
                          Get.to(ProductReturnScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 6 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Return Product",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Support",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 23 * ffem, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => FAQs());
                          setState(() {
                            shaka = 7;
                          });
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                // color: Colors.transparent,
                                color: shaka == 7 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.question_mark,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "FAQs",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 8;
                          });
                          Get.to(() => ContactSupport());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 8 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Contact Support",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 9;
                          });
                          Get.to(ProviderFeedback());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 9 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Provide Feedback",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Legal",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 23 * ffem, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 10;
                          });
                          Get.to(() => TermsAndCondition());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 10 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.library_books,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Terms & Conditions",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 11;
                          });
                          Get.to(() => PrivacyPolicy());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 11 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Privacy Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 12;
                          });
                          Get.to(TermLength());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 12 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Copyright Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 13;
                          });
                          Get.to(RentalAgreement());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 13 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Rental Agreement",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 14;
                          });
                          Get.to(usagePolicyAndLimitations());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 14 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Usage Policy & Limitations",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 15;
                          });
                          Get.to(InsuranceAndIndemnification());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 15 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Insurance & Indemnifications Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 16;
                          });
                          Get.to(TransportAndInstallationPolicy());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 16 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Transportation & Installation Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor * ffem, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 17;
                          });
                          Get.to(AboutAppScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 17 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Maintenance & Warranties",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 18;
                          });
                          Get.to(Termination());
                        },
                        child: Container(
                          width: res_width * 0.7,
                          height: res_height * 0.039,
                          decoration: BoxDecoration(
                              color: shaka == 18 ? Color(0xFF4285F4) : Colors.transparent,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                          child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width: res_width * 0.681,
                                      child: Text(
                                        "Termination",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 19;
                          });
                          Get.to(() => Settings());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 19 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: GestureDetector(
                              // onTap: () {
                              //   Get.to(Settings());
                              // },
                              child: Container(
                                  width: res_width * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, bottom: 5),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          SizedBox(
                                            width: res_width * 0.681,
                                            child: Text(
                                              "Settings",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                          setState(() {
                            sharedPreferences.setString('token', "");
                            sharedPreferences.setString('role', "");
                            print("cancelled");
                          });

                          sharedPreferences.setBool("time", false);

                          final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                          userPrefernece.remove().then((value) {
                            sharedPreferences.clear();

                            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                            // Get.offAll(() => LoginScreen());
                          });
                          sp.userSignOut().then((value) {
                            print("SOME wORK");

                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                            // Get.to(() => LoginScreen());
                            notiTimer().timer?.cancel();
                          }).catchError((e) {
                            if (kDebugMode) {}
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 7),
                          child: Row(
                            children: [
                              Icon(
                                Icons.login_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: res_width * 0.681,
                                child: Text(
                                  "Logout",
                                  style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 99,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: res_height * 0.06),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          usp.image.toString() == "null"
                              ? sp.imageUrl.toString() == "null"
                                  ? CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                                  : CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}"))
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    "https://api.jebbylistings.com${usp.image}",
                                  )),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: res_width * 0.55,
                                child: Text(
                                  getText(usp, sp),
                                  style: TextStyle(fontSize: 26 * textScaleFactor, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              getText(usp, sp).contains('+')
                                  ? Container()
                                  : SizedBox(
                                      width: res_width * 0.55,
                                      child: Text(
                                        (usp.email.toString() == "null" || usp.email.toString().contains("Phone"))
                                            ? usp.phoneNumber.toString()
                                            : usp.email.toString(),
                                        style: TextStyle(fontSize: 15 * textScaleFactor, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: res_height * 0.01),
                    (usp.role == "0" || sp.role == "0")
                        ? Center(
                            child: ElevatedButton(
                                onPressed: () async {
                                  _myRepo.updateRoleApi({"role": "1", "email": usp.email ?? sp.email}).then((value) async {
                                    if (value["status"] == 200) {
                                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                                      setState(() {
                                        sharedPreferences.setString('role', "1");
                                      });

                                      getData();
                                      Get.back();
                                      widget.onCloseDrawer?.call();
                                      _showSuccessAlert(context);
                                      // final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                                      // userPrefernece.saveUser()
                                    }
                                  });
                                },
                                child: Text(
                                  'Become Provider',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    textStyle: TextStyle(fontSize: 16),
                                    backgroundColor: darkBlue)),
                          )
                        : SizedBox(),
                    SizedBox(height: res_height * 0.04),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
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
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 1 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.home_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Home",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
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
                                      style: TextStyle(fontSize: 23 * textScaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 2;
                          });
                          Get.to(() => MyProfileScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 2 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Profile",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 3;
                          });
                          Get.to(MessagesScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 3 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Chat",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 4;
                          });
                          Get.to(MyOrdersScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 4 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "My Orders",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 5;
                          });
                          Get.to(() => FavouriteScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 5 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.save_as,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "My Wishlist",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 6;
                          });
                          Get.to(ReturnProductScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 6 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Return Product",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: role == 1 ? 10 : 0,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Support",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 23 * textScaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 7;
                          });
                          Get.to(() => FAQs());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 7 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.question_mark,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "FAQs",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 8;
                          });
                          Get.to(() => ContactSupport());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 8 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Contact Support",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 9;
                          });
                          Get.to(ProviderFeedback());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 9 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Provide Feedback",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                        width: res_width * 0.7,
                        height: res_height * 0.059,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Legal",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 23 * textScaleFactor, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 10;
                          });
                          Get.to(() => TermsAndCondition());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 10 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.library_books,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Terms & Conditions",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 11;
                          });
                          Get.to(() => PrivacyPolicy());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 11 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Privacy Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 12;
                          });
                          Get.to(TermLength());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 12 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Copyright Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 13;
                          });
                          Get.to(RentalAgreement());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 13 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.list_alt,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Rental Agreement",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 14;
                          });
                          Get.to(usagePolicyAndLimitations());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 14 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Usage Policy & Limitations",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 15;
                          });
                          Get.to(InsuranceAndIndemnification());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 15 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Insurance & Indemnifications Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 16;
                          });
                          Get.to(TransportAndInstallationPolicy());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 16 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Transportation & Installation Policy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 17;
                          });
                          Get.to(AboutAppScreen());
                        },
                        child: Container(
                            width: res_width * 0.7,
                            height: res_height * 0.039,
                            decoration: BoxDecoration(
                                color: shaka == 17 ? Color(0xFF4285F4) : Colors.transparent,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: Container(
                                width: res_width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        SizedBox(
                                          width: res_width * 0.681,
                                          child: Text(
                                            "Maintenance & Warranties",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            shaka = 18;
                          });
                          Get.to(Termination());
                        },
                        child: Container(
                          width: res_width * 0.7,
                          height: res_height * 0.039,
                          decoration: BoxDecoration(
                              color: shaka == 18 ? Color(0xFF4285F4) : Colors.transparent,
                              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                          child: Container(
                            width: res_width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.view_list_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width: res_width * 0.681,
                                      child: Text(
                                        "Termination",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              shaka = 19;
                            });
                            if (bottomctrl.navigationBarIndexValue != 4) {
                              bottomctrl.navBarChange(4);
                            } else {
                              Get.back();
                            }
                          },
                          child: Container(
                              width: res_width * 0.7,
                              height: res_height * 0.039,
                              decoration: BoxDecoration(
                                  color: shaka == 19 ? Color(0xFF4285F4) : Colors.transparent,
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                              child: GestureDetector(
                                child: Container(
                                    width: res_width * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, bottom: 5),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: res_width * 0.681,
                                              child: Text(
                                                "Settings",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: res_width * 0.9,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                          setState(() {
                            sharedPreferences.setString('token', "");
                            sharedPreferences.setString('role', "");
                            print("cancelled");
                          });

                          sharedPreferences.setBool("time", false);

                          final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                          userPrefernece.remove().then((value) {
                            sharedPreferences.clear();
                          });
                          sp.userSignOut().then((value) {
                            print("SOME wORK");

                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
                            notiTimer().timer?.cancel();
                          }).catchError((e) {
                            if (kDebugMode) {}
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 7),
                          child: Row(
                            children: [
                              Icon(
                                Icons.login_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: res_width * 0.681,
                                child: Text(
                                  "Logout",
                                  style: TextStyle(fontSize: 18 * textScaleFactor, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: res_height * 0.095,
                    ),
                  ],
                )),
    );
  }

  var imagesapi = "null";
  var nameapi = "null";
  var emailapi = "user email";
  var datalength;

  Future getProductsApi(id) async {
    final response = await http.get(Uri.parse('${Url}/UserProfileGetById/${id}'));
    var data = jsonDecode(response.body.toString());
    datalength = data["data"].length;
    if (data["data"].length != 0) {}

    if (data["data"].length != 0) {
      if (mounted) {
        setState(() {
          imagesapi = data["data"][0]["image"].toString();
          nameapi = data["data"][0]["name"].toString();
          emailapi = data["data"][0]["email"].toString();
        });
      }
    }

    if (response.statusCode == 200) {
      return data;
    } else {
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
