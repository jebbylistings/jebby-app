import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/controller/bottomcontroller.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/agreements/JebbyAbout.dart';
import 'package:jared/Views/screens/agreements/privacyPolicy.dart';
import 'package:jared/Views/screens/auth/login.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:jared/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../../helper/global.dart';
import '../agreements/termsAndConditions.dart';
import '../mainfolder/drawer.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  bool switchnot = true;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final bottomctrl = Get.put(BottomController());

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchnot = prefs.getBool('notifiction') == true
          ? false
          : prefs.getBool('notifiction') == null
              ? false
              : true;
      print("noti ${prefs.getBool('notifiction')}");
    });
  }

  void set(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifiction', !value);
    print("noti ${prefs.getBool('notifiction')}");
    print("time ${prefs.getBool('time')}");
    setState(() {
      noti = !value;
      print("noti ${noti}");
    });
  }

  @override
  void initState() {
    getData();
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final authViewMode = Provider.of<AuthViewModel>(context);
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.transparent,key: _key,
      key: _key,

      // drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
            // _key.currentState!.openDrawer();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => MyProfileScreen());
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

      body: Container(
        width: double.infinity,
        child: (Column(
          children: [
            SizedBox(height: res_height * 0.03),
            cardbox('Notifications'),
            Card2(
              "About App",
              () {
                Get.to(
                  () => AboutScreen(),
                );
              },
            ),
            Card2("Privacy Policy", () {
              Get.to(
                () => PrivacyPolicy(),
              );
            }),
            Card2("Terms & Conditions", () {
              Get.to(
                () => TermsAndCondition(),
              );
            }),

            Card2("Delete Account", () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Color(0xff000000B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(0),
                  actionsPadding: EdgeInsets.all(0),
                  actions: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: 340,
                          height: 270,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Color(0xffFEB038)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 70,
                              ),
                              Text(
                                "Delete Account",
                                style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Are you sure you want to Delete your Account?",
                                  style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                          ),
                                          color: Colors.white),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                        Map data = {"id": sharedPreferences.getString('id'), "role": sharedPreferences.getString('role')};
                                        authViewMode.DeleteAccount(data, context);
                                      },
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color: Colors.white),
                                        child: Center(
                                          child: Text(
                                            "Yes",
                                            style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            top: -20,
                            child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffFEB038)),
                                child: Center(
                                    child: Image.asset(
                                  "assets/slicing/smile@3x.png",
                                  scale: 5,
                                ))))
                      ],
                    ),
                  ],
                ),
              );
            }),
            SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Color(0xff000000B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(0),
                    actionsPadding: EdgeInsets.all(0),
                    actions: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            width: 320,
                            height: 222,
                            decoration: BoxDecoration(
                                // border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffFEB038)),
                            child: ListView(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 67,
                                    ),
                                    Text(
                                      "Add To Cart",
                                      style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Item added to your cart",
                                      style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                                    ),
                                    // 15.verticalSpace,
                                    // Container(
                                    //   width: 270.w,
                                    //   height: 50.h,
                                    //   child: Text(
                                    //     "You will be contacted by the Owner via direct message to confirm!",
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //       fontFamily: "Inter, Regular",
                                    //       fontSize: 15.sp,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 32,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 160,
                                          height: 55,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                // bottomRight:
                                                //     Radius.circular(10.r),
                                              ),
                                              color: Colors.white),
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
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
                                          child: Container(
                                            width: 160,
                                            height: 55,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  // bottomLeft:
                                                  //     Radius.circular(10.r),
                                                  bottomRight: Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                "Logout",
                                                style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                // Container(
                                //   width: 357.w,
                                //   height: 59.h,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.only(
                                //       topLeft: Radius.circular(10.r),
                                //       topRight: Radius.circular(10.r),
                                //     ),
                                //     gradient: LinearGradient(
                                //       begin: Alignment.bottomRight,
                                //       end: Alignment.bottomLeft,
                                //       colors: [
                                //         Color(0xff00006A),
                                //         Color(0xff4B4BFF)
                                //       ],
                                //     ),
                                //   ),
                                //   child: Row(
                                //     children: [
                                //       SizedBox(
                                //         width: 145.w,
                                //       ),
                                //       Text(
                                //         "Note",
                                //         style: TextStyle(
                                //           fontSize: 16.sp,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         width: 110.w,
                                //       ),
                                //       GestureDetector(
                                //         onTap: () {
                                //           Get.back();
                                //         },
                                //         child: Icon(
                                //           Icons.close,
                                //           color: Colors.white,
                                //           size: 25,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                // SizedBox(
                                //   height: 10.h,
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 20),
                                //   child: Column(children: [
                                //     Text(
                                //       "This kind of sensitive information are used by our company just to verify users. Once users get verified such information will be allowed to terminate by users themselves from our system for protecting users privacy data from unethical act. Our slogan No privacy data meaning nothing to worry about leak, hack and crack...",
                                //       textAlign: TextAlign.center,
                                //       style: TextStyle(
                                //           fontSize: 12.sp,
                                //           color: Colors.black),
                                //     ),
                                //     SizedBox(
                                //       height: 50.h,
                                //     ),
                                //     GestureDetector(
                                //       onTap: () {
                                //         Get.to(() => licensephotoupload());
                                //       },
                                //       child: Container(
                                //         width: 250.w,
                                //         height: 59.h,
                                //         decoration: BoxDecoration(
                                //           border: Border.all(
                                //               color: Colors.white),
                                //           borderRadius:
                                //               BorderRadius.circular(10.r),
                                //           color: Color(0xff00006A),
                                //         ),
                                //         child: Center(
                                //           child: Text(
                                //             "Continue",
                                //             style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: 16.sp),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ]),
                                // )
                              ],
                            ),
                          ),
                          Positioned(
                              top: -20,
                              // left: 100,
                              child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffFEB038)),
                                  child: Center(
                                      child: Image.asset(
                                    "assets/slicing/smile@3x.png",
                                    scale: 5,
                                  ))))
                        ],
                      ),
                    ],
                  ),
                );
              },
              child: InkWell(
                onTap: () async {
                  setState() {
                    notiTimer().timer?.cancel();
                  }

                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                  final userPrefernece = Provider.of<UserViewModel>(context, listen: false);
                  userPrefernece.remove().then((value) {
                    Get.offAll(() => LoginScreen());
                  });
                  sp.userSignOut().then((value) {
                    print("SOME wORK");
                    Get.offAll(() => LoginScreen());
                  }).catchError((e) {
                    if (kDebugMode) {}
                  });
                },
                child: Container(
                  width: 363,
                  height: 52,
                  decoration: BoxDecoration(
                      color: Color(0xFF4285F4),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Logout",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // cardbox('Sounds'),
            // cardbox('Language'),
            SizedBox(height: res_height * 0.37),
          ],
        )),
      ),
    );
  }

  cardbox(
    txt,
  ) {
    double res_width = MediaQuery.of(context).size.width;
    return Container(
      width: 363,
      decoration: BoxDecoration(
          color: kprimaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          )),
      // child: Card(
      // color: kprimaryColor,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6, left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              txt,
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                activeColor: Colors.white,
                trackColor: Colors.white,
                thumbColor: switchnot ? Color(0xffc6c6c6) : Color(0xff00ff01),
                value: switchnot,
                onChanged: (value) {
                  setState(() {
                    switchnot = value;
                  });
                  set(value);
                },
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }

  Card2(
    Txts,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 363,
            height: 52,
            decoration: BoxDecoration(
                color: kprimaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Txts,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
