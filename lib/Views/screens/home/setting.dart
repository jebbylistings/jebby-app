import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/controller/bottomcontroller.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/agreements/JebbyAbout.dart';
import 'package:jebby/Views/screens/agreements/privacyPolicy.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/profile/editprofile.dart';
import 'package:jebby/Views/screens/profile/myprofile.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';
import '../../helper/global.dart';
import '../agreements/termsAndConditions.dart';

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

  var imagesapi = "null";
  var nameapi = "null";
  var emailapi = "user email";
  var datalength;
  bool isLoadingImage = true;

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  Future<UserModel> getUserDate() => UserViewModel().getUser();

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

          if (mounted) {
            setState(() {});
          }
        })
        .onError((error, stackTrace) {});
  }

  bool switchnot = true;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final bottomctrl = Get.put(BottomController());

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchnot =
          prefs.getBool('notifiction') == true
              ? false
              : prefs.getBool('notifiction') == null
              ? false
              : true;
    });
  }

  void set(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifiction', !value);
    setState(() {
      noti = !value;
    });
  }

  // @override
  // void initState() {
  //   getData();
  //   check();
  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
    // _loadOnboardingStatus();
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

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final authViewMode = Provider.of<AuthViewModel>(context);
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    final usp = context.watch<UserViewModel>();
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    return Scaffold(
      // backgroundColor: Colors.transparent,key: _key,
      backgroundColor: AppColors.greyColor,
      key: _key,

      // drawer: DrawerScreen(),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      //   title: Text(
      //     'Settings',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.black,
      //       fontSize: 19,
      //     ),
      //   ),
      //   leading: InkWell(
      //     onTap: () {
      //       bottomctrl.navBarChange(0);
      //       Get.back();
      //       // _key.currentState!.openDrawer();
      //     },
      //     borderRadius: BorderRadius.circular(50),
      //     child: Icon(Icons.arrow_back, color: Colors.black),
      //   ),
      //   actions: [
      //     GestureDetector(
      //       onTap: () {
      //         Get.to(() => MyProfileScreen());
      //       },
      //       child: Padding(
      //         padding: const EdgeInsets.all(19.0),
      //         child: Icon(Icons.person_outline, color: Colors.black, size: 25),
      //       ),
      //     ),
      //   ],
      // ),
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.greyColor),

      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: (Column(
            children: [
              // SizedBox(height: res_height * 0.03),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isLoadingImage
                      ? CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
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

                  Text(
                    getText(usp, sp),
                    style: TextStyle(
                      fontSize: 26 * textScaleFactor,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  getText(usp, sp).contains('+')
                      ? Container()
                      : Text(
                        (usp.email.toString() == "null" ||
                                usp.email.toString().contains("Phone"))
                            ? usp.phoneNumber.toString()
                            : usp.email.toString(),
                        style: TextStyle(
                          fontSize: 15 * textScaleFactor,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                ],
              ),
              SizedBox(height: 25),
              Image.asset(
                width: res_width * 0.9,
                "assets/newpacks/becomeprovider.png",
              ),
              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Card2(Icons.person, "Edit Profile", () {
                        Get.to(() => EditProfile());
                      }),
                      Card2(Icons.lock, "Change Password", () {
                        Get.to(() => EditProfile());
                      }),

                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      cardbox('Notification Settings'),
                      Card2(Icons.info, "About App", () {
                        Get.to(() => AboutScreen());
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Card2(Icons.description, "Terms & Conditions", () {
                        Get.to(() => TermsAndCondition());
                      }),
                      Card2(Icons.security, "Privacy & Security", () {
                        Get.to(() => PrivacyPolicy());
                      }),
                      Card2(Icons.warning, "Delete Account", () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
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
                                    width: res_width * 0.8,
                                    height: res_height * 0.3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(0xffFEB038),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(height: res_height * 0.07),
                                        Text(
                                          "Delete Account",
                                          style: TextStyle(
                                            fontFamily: "Inter, Bold",
                                            fontSize: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            "Are you sure you want to Delete your Account?",
                                            style: TextStyle(
                                              fontFamily: "Inter, Regular",
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 32,
                                        // ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                        fontFamily:
                                                        "Inter, Regular",
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  SharedPreferences
                                                  sharedPreferences =
                                                  await SharedPreferences.getInstance();
                                                  Map data = {
                                                    "id": sharedPreferences
                                                        .getString('id'),
                                                    "role": sharedPreferences
                                                        .getString('role'),
                                                  };
                                                  authViewMode.DeleteAccount(
                                                    data,
                                                    context,
                                                  );
                                                },
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Yes",
                                                      style: TextStyle(
                                                        fontFamily:
                                                        "Inter, Regular",
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xffFEB038),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/slicing/smile@3x.png",
                                          scale: 5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
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
                                        color: Color(0xffFEB038),
                                      ),
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              SizedBox(height: 67),
                                              Text(
                                                "Add To Cart",
                                                style: TextStyle(
                                                  fontFamily: "Inter, Bold",
                                                  fontSize: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "Item added to your cart",
                                                style: TextStyle(
                                                  fontFamily: "Inter, Regular",
                                                  fontSize: 19,
                                                  color: Colors.white,
                                                ),
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
                                              SizedBox(height: 32),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 160,
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(
                                                          10,
                                                        ),
                                                        // bottomRight:
                                                        //     Radius.circular(10.r),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                            fontFamily:
                                                            "Inter, Regular",
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      SharedPreferences
                                                      sharedPreferences =
                                                      await SharedPreferences.getInstance();
                                                      setState(() {
                                                        // timer.cancel();
                                                        sharedPreferences.setString(
                                                          'token',
                                                          "",
                                                        );
                                                        sharedPreferences.setString(
                                                          'role',
                                                          "",
                                                        );
                                                      });

                                                      sharedPreferences.setBool(
                                                        "time",
                                                        false,
                                                      );
                                                      // setState(() {
                                                      //   timer.cancel();
                                                      //   // super.initState();
                                                      // });
                                                      final userPrefernece =
                                                      Provider.of<
                                                          UserViewModel
                                                      >(context, listen: false);
                                                      userPrefernece.remove().then((
                                                          value,
                                                          ) {
                                                        // Get.offAll(() => LoginScreen());
                                                      });
                                                      sp
                                                          .userSignOut()
                                                          .then((value) {
                                                        Get.to(
                                                              () => LoginScreen(),
                                                        );
                                                      })
                                                          .catchError((e) {
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
                                                          bottomRight:
                                                          Radius.circular(10),
                                                        ),
                                                        color: Colors.white,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Logout",
                                                          style: TextStyle(
                                                            fontFamily:
                                                            "Inter, Regular",
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffFEB038),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            "assets/slicing/smile@3x.png",
                                            scale: 5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        child: InkWell(
                          onTap: () async {
                            final userPrefernece = Provider.of<UserViewModel>(
                              context,
                              listen: false,
                            );
                            userPrefernece.remove().then((value) {
                              Get.offAll(() => LoginScreen());
                            });
                            sp
                                .userSignOut()
                                .then((value) {
                              Get.offAll(() => LoginScreen());
                            })
                                .catchError((e) {
                              if (kDebugMode) {}
                            });
                          },
                          child: Container(height: 52,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.logout, color: AppColors.primaryColor),
                                    SizedBox(width: 10),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),




              // cardbox('Sounds'),
              // cardbox('Language'),
              SizedBox(height: res_height * 0.13),
            ],
          )),
        ),
      ),
    );
  }

  cardbox(txt) {
    return Container(
      width: 363,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      // child: Card(
      // color: kprimaryColor,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppColors.primaryColor),
              SizedBox(width: 10),
              Text(
                txt,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Transform.scale(
          //   scale: 0.8,
          //   child: CupertinoSwitch(
          //     activeTrackColor: Colors.white,
          //     inactiveTrackColor: Colors.white,
          //     thumbColor: switchnot ? Color(0xffc6c6c6) : Color(0xff00ff01),
          //     value: switchnot,
          //     onChanged: (value) {
          //       setState(() {
          //         switchnot = value;
          //       });
          //       set(value);
          //     },
          //   ),
          // ),
        ],
      ),
      // ),
    );
  }

  Card2(icon, Txts, VoidCallback onTap) {
    return Column(
      children: [
        SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 363,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryColor),
                SizedBox(width: 10),
                Text(
                  Txts,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
