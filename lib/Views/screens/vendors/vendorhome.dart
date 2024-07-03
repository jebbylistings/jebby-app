import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/helper/global.dart';
import 'package:jared/Views/screens/mainfolder/drawer.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/Views/screens/vendors/OrderReq.dart';
import 'package:jared/Views/screens/vendors/ProductList.dart';
import 'package:jared/Views/screens/vendors/notification.dart';
import 'package:jared/Views/screens/vendors/renterProfile.dart';
import 'package:jared/Views/screens/vendors/transactionlist.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../../controller/bottomcontroller.dart';

class VendrosHomeScreen extends StatefulWidget {
  const VendrosHomeScreen({Key? key}) : super(key: key);

  @override
  State<VendrosHomeScreen> createState() => _VendrosHomeScreenState();
}

class _VendrosHomeScreenState extends State<VendrosHomeScreen> {
  @override
  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate().then((value) async {
      token = value.token.toString();
      sourceId = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      print("Source ID: ${sourceId}");
      print("role: ${role}");
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  bool isLoading1 = true;
  bool isError1 = false;
  bool isEmpty1 = false;
  getNotifications() {
    ApiRepository.shared.notifications(sourceId, (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isEmpty1 = true;
            isLoading1 = false;
            isError1 = false;
          });
        } else {
          setState(() {
            isEmpty1 = false;
            isLoading1 = false;
            isError1 = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          isEmpty1 = false;
          isLoading1 = true;
          isError1 = true;
        });
      }
    });
  }

  void check() async {
    print("Function check ");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool('time') == false
        ? notiTimer().timer?.cancel()
        : notiTimer().timer = prefs.getBool('time') == false
            ? notiTimer().timer?.cancel()
            : new Timer.periodic(Duration(seconds: 5), (_) {
                print("timer ---- ${prefs.getBool('notifiction')}");
                print("token ---- ${token}");
                if (token == null || token == "" || role == "" || role == null || prefs.getBool('time') != true) {
                  print("last token ${token}");
                  print("time ${prefs.getBool("time")}");
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
    notiTimer().timer.cancel();
    notiTimer().timer = null;
    print("timerrr ${notiTimer().timer}");
  }

  void dispose() {
    super.dispose();
    print("disposed");
    timer.cancel();
  }

  void func() async {
    print("bool start");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('time'));
    prefs.setBool("time", true);
    check();
  }

  void initState() {
    super.initState();
    getData();
    profileData(context);
    func();
  }
final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("assets/slicing/bg2.jpg"),
          //   fit: BoxFit.cover,
          // ),
          ),
      child: Scaffold(
        // backgroundColor: Colors.transparent,key: _key,
        key: _key,

        drawer: DrawerScreen(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
          ),
          leading: GestureDetector(
            onTap: () {
              _key.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Container(
                child: Image.asset('assets/slicing/hamburger.png'),
              ),
            ),
          ),
          actions: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    seenNotification();
                    Get.to(() => VendorNotifications());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 18.0, right: 7),
                    child: Container(
                      child: Image.asset('assets/slicing/notification.png'),
                    ),
                  ),
                ),
                // IconButton(
                //   icon: Icon(
                //     Icons.notifications,
                //     color: Colors.black,
                //   ),
                //   onPressed: () {
                //     Get.to(() => VendorNotifications());
                //   },
                // ),
                isLoading1
                    ? SizedBox()
                    : 
                    ApiRepository.shared.getNotificationModelList!.unseen.toString() == "0"
                        ? SizedBox()
                        : Positioned(
                            top: 4,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: kprimaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                isLoading1
                                    ? ""
                                    : ApiRepository.shared.getNotificationModelList!.unseen.toString() == "0"
                                        ? ""
                                        : ApiRepository.shared.getNotificationModelList!.unseen.toString(),
                                // style: TextStyle(color: Colors.white),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => RenterProfile());
              },
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: Container(
                  child: Image.asset('assets/slicing/avatar.png'),
                ),
              ),
            )
          ],
        ),

        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: res_height * 0.015,
                ),
                Container(
                  width: res_width * 0.9,
                  child: Center(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        contBox(txt: "Profile", img: 'assets/slicing/user.png'),
                        contBox(txt: "Product", img: 'assets/slicing/Icon awesome-shopping-basket@3x.png'),
                        contBox(txt: "Orders", img: 'assets/slicing/layer.png'),
                        contBox(txt: "Transactions", img: 'assets/slicing/swap.png'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  contBox({txt, img}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (txt == "Orders") {
          Get.to(() => OrderRequestScreen());
        }
        if (txt == "Transactions") {
          Get.to(() => TransactionListScreen());
        }
        if (txt == "Product") {
          // final bottomcontroller = Get.put(BottomController());
          // bottomcontroller.navBarChange(1);
          // Get.to(() => MainScreen());
          Get.to(() => ProductListScreen(side: false));
        }
        if (txt == "Profile") {
          Get.to(() => RenterProfile());
        }
      },
      child: Column(
        children: [
          Container(
            width: res_width * 0.4,
            height: res_height * 0.2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              color: kprimaryColor,
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  offset: Offset(2, 1), // Shadow position
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: res_width * 0.135,
                  child: Image.asset(
                    '$img',
                    // height: 10,
                    // width: 10,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            "$txt",
            style: TextStyle(fontSize: 17),
          )
        ],
      ),
    );
  }
}
