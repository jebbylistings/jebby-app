import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/helper/global.dart';
import 'package:jebby/Views/screens/mainfolder/drawer.dart';
import 'package:jebby/Views/screens/vendors/OrderReq.dart';
import 'package:jebby/Views/screens/vendors/ProductList.dart';
import 'package:jebby/Views/screens/vendors/notification.dart';
import 'package:jebby/Views/screens/vendors/renterProfile.dart';
import 'package:jebby/Views/screens/vendors/transactionlist.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class VendrosHomeScreen extends StatefulWidget {
  const VendrosHomeScreen({Key? key}) : super(key: key);

  @override
  State<VendrosHomeScreen> createState() => _VendrosHomeScreenState();
}

class _VendrosHomeScreenState extends State<VendrosHomeScreen> {
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
    getUserDate()
        .then((value) async {
          setState(() {
            token = value.token.toString();
            sourceId = value.id.toString();
            fullname = value.name.toString();
            email = value.email.toString();
            role = value.role.toString();
          });
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  Widget profileCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          /// USER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),

                SizedBox(height: 5),

                Text(
                  fullname ?? "Loading...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Row(
                  children: [
                    Icon(Icons.email, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email ?? "",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                Text(role ?? "", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          /// PROFILE IMAGE
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40),
          ),
        ],
      ),
    );
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  bool isLoading1 = true;
  bool isError1 = false;
  bool isEmpty1 = false;

  getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
      (List) {
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
      },
      (error) {
        if (error != null) {
          setState(() {
            isEmpty1 = false;
            isLoading1 = true;
            isError1 = true;
          });
        }
      },
    );
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool('time') == false
        ? notiTimer().timer?.cancel()
        : notiTimer().timer =
            prefs.getBool('time') == false
                ? notiTimer().timer?.cancel()
                : new Timer.periodic(Duration(seconds: 5), (_) {
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
    notiTimer().timer.cancel();
    notiTimer().timer = null;
  }

  void dispose() {
    super.dispose();

    timer.cancel();
  }

  void func() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("time", true);
    check();
  }

  void initState() {
    super.initState();
    getData();
    profileData(context);
    func();
  }

  Widget featureCard(title, subtitle, icon) {
    return GestureDetector(
      onTap: () {
        if (title == "Products") {
          Get.to(() => ProductListScreen(side: false));
        } else {
          Get.to(() => OrderRequestScreen());
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(icon, height: 45),
                Icon(Icons.arrow_forward_ios_sharp, color: Colors.black,size: 20,)
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("View all", style: TextStyle(color: Colors.orange)),
      ],
    );
  }

  Widget todayItem(name, date, amount) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.pink.shade50,
        child: Icon(Icons.arrow_upward, color: Colors.red),
      ),
      title: Text(name),
      subtitle: Text(date),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: TextStyle(color: Colors.red)),
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("PAID", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget notificationItem(title, subtitle, time) {
    return ListTile(
      leading: CircleAvatar(radius: 5, backgroundColor: Colors.orange),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time),
    );
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

        drawer: DrawerScreen(stack: "vendor"),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Home',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
          ),
          leading: InkWell(
            onTap: () {
              _key.currentState!.openDrawer();
            },
            borderRadius: BorderRadius.circular(50),
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
                    padding: const EdgeInsets.only(
                      top: 18.0,
                      bottom: 18.0,
                      right: 7,
                    ),
                    child: Icon(Icons.notifications_none, color: Colors.black),
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
                    : ApiRepository.shared.getNotificationModelList!.unseen
                            .toString() ==
                        "0"
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
                              : ApiRepository
                                      .shared
                                      .getNotificationModelList!
                                      .unseen
                                      .toString() ==
                                  "0"
                              ? ""
                              : ApiRepository
                                  .shared
                                  .getNotificationModelList!
                                  .unseen
                                  .toString(),
                          // style: TextStyle(color: Colors.white),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => RenterProfile());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 19.0,
                  vertical: 18.0,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SEARCH BAR
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search by Product, Orders e.t.c",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                /// PROFILE CARD
                profileCard(),

                SizedBox(height: 20),

                /// FEATURE BOXES
                Row(
                  children: [
                    Expanded(
                      child: featureCard(
                        "Products",
                        "Manage Products",
                        "assets/newpacks/myproducts.png",
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: featureCard(
                        "My Order",
                        "Track your rentals.",
                        "assets/newpacks/myorders1.png",
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                /// TODAY SECTION
                sectionHeader("Today"),

                todayItem("John Doe", "Aug 10, 2025", "-\$200.00"),
                todayItem("John Doe", "Aug 10, 2025", "-\$200.00"),
                todayItem("Mary Jane", "Aug 27, 2025", "-\$10.33"),

                SizedBox(height: 25),

                /// NOTIFICATIONS
                sectionHeader("Latest Notifications"),

                notificationItem(
                  "Admin",
                  "You've got a new rental request for your...",
                  "8:12 PM",
                ),
                notificationItem(
                  "Transfer Failed",
                  "Your \$300 transfer to Emily Lee could not be...",
                  "8:12 PM",
                ),
              ],
            ),
          ),
        ),
        // body: SingleChildScrollView(
        //   child: Container(
        //     width: double.infinity,
        //     child: Column(
        //       children: [
        //         SizedBox(height: res_height * 0.015),
        //         Container(
        //           width: res_width * 0.9,
        //           child: Center(
        //             child: Wrap(
        //               spacing: 15,
        //               runSpacing: 15,
        //               children: [
        //                 contBox(
        //                   txt: "Profile",
        //                   img: 'assets/slicing/user_thick.png',
        //                 ),
        //                 contBox(
        //                   txt: "Product",
        //                   img:
        //                       'assets/slicing/Icon awesome-shopping-basket@3x.png',
        //                 ),
        //                 contBox(txt: "Orders", img: 'assets/slicing/layer.png'),
        //                 contBox(
        //                   txt: "Transactions",
        //                   img: 'assets/slicing/swap.png',
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
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
              borderRadius: BorderRadius.all(Radius.circular(18)),
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
          SizedBox(height: 6),
          Text("$txt", style: TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}
