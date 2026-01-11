import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jebby/Views/screens/home/Filter.dart';
import 'package:jebby/Views/screens/home/Messages(32).dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/controller/bottomcontroller.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/helper/global.dart';
import 'package:jebby/Views/screens/home/category.dart';
import 'package:jebby/Views/screens/home/home.dart';
import 'package:jebby/Views/screens/home/messages.dart';
import 'package:http/http.dart' as http;

import 'package:jebby/Views/screens/home/setting.dart';
import 'package:jebby/Views/screens/vendors/ProductList.dart';
import 'package:jebby/Views/screens/vendors/notification.dart';
import 'package:jebby/Views/screens/vendors/vendorhome.dart';
import 'package:jebby/res/app_url.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/auth_view_model.dart';
import '../../../view_model/user_view_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bottomctrl = Get.put(BottomController());
  num activeIndex = 0;

  // String userName = "";

  var screens = [
    HomeScreen(),
    // FavouriteScreen(),
    FilterScreeen(),
    Category(),
    MessageScreen(),
    Settings(),
    MessagesScreen(),
  ];

  var screensVendor = [
    VendrosHomeScreen(),
    ProductListScreen(side: true),
    // Settings(),
    ProductListScreen(side: true),
    // Category(),
    VendorNotifications(),
    Settings(),
    MessagesScreen(),
    // OrderRequestScreen(),
    // RenterProfile(),
  ];

  Future<UserModel> getUserDate() => UserViewModel().getUser();
  String? ids;

  Future getData() async {
    final sp = context.read<SignInProvider>();
    //  final sps = context.watch<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  bool isNotific = true;

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

  @override
  void initState() {
    //  noti == true ? timer =  new Timer.periodic(Duration(seconds: 5), (_) => getNotifications()) : null;
    // timer =  new Timer.periodic(Duration(seconds: 5), (_) => getNotifications());
    func();
    getData();
    profileData(context);
    // getUserName();
    // check();
    super.initState();
  }

  // void getUserName()  async {
  //   if(userName == "Guest" || userName.isEmpty) {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     String _name = sharedPreferences.getString('fullname') ?? "";
  //     setState(() {
  //
  //       userName = _name;
  //     });
  //   }
  // }

  void dispose() {
    super.dispose();

    timer.cancel();
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
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          getProductsApi(id.toString());
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          // getNotifications();
        })
        .onError((error, stackTrace) {});
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
        if (error != null) {
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

    // State variable for delayed condition check

    Future.delayed(const Duration(seconds: 1), () {});

    //  sp.role=="null" ? role="1":role="1";
    //role= sp.role.toString();
    return Scaffold(
      extendBody: true,
      body: GetBuilder<BottomController>(
        builder: (controller) {
          activeIndex = controller.navigationBarIndexValue;
          return (loginType == "user")
              ? screens[bottomctrl.navigationBarIndexValue]
              : screensVendor[bottomctrl.navigationBarIndexValue];
        },
      ),
      bottomNavigationBar:
          role != "Guest" ? bottomForUser(userName) : bottomForGuest(),
    );
  }

  Widget bottomForUser(userName) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: 70,
      // color: Colors.white,
      child: Stack(
        // clipBehavior: Clip.none,
        children: [
         // CustomPaint(size: Size(size.width, 80), painter: BNBCustomPainter()),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                //boxShadow: [...]
            ),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              backgroundColor: kprimaryColor,
              child: Image.asset('assets/newpacks/menuicon.png', width: 27),
              elevation: 0,
              onPressed: () {
                bottomctrl.navBarChange(2);
              },
            ),
          ),
          Container(
            width: size.width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset(
                        'assets/newpacks/home.png',
                        width: 25,
                        height: 25,
                        color:
                            activeIndex == 0
                                ? AppColors.primaryColor
                                : Colors.grey.shade500,
                      ),
                      onTap: () {
                        bottomctrl.navBarChange(0);
                        setState(() {
                          activeIndex = 0;
                        });
                      },

                      // splashColor: Colors.grey.shade500,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color:
                            activeIndex == 0
                                ? Colors.black
                                : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                role == "0" || role == "Guest"
                    ?
                    // IconButton(
                    //     icon: Icon(Icons.search, color: Colors.grey.shade500),
                    //     // Image.asset(
                    //     //   'assets/slicing/heart.png',
                    //     //   width: 20,
                    //     // ),
                    //     onPressed: () {
                    //       // bottomctrl.navBarChange(2);
                    //       Get.to(() => FilterScreeen());
                    //     },
                    //   )
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => FilterScreeen());
                          },
                          child: Image.asset(
                            'assets/newpacks/searchnew.png',
                            width: 25,
                            height: 25,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          'Search',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset(
                        'assets/newpacks/searchnew.png',
                        width: 25,
                        height: 25,
                        color:
                        activeIndex == 1
                            ? AppColors.primaryColor
                            : Colors.grey.shade500,
                      ),
                      onTap: () {
                        bottomctrl.navBarChange(1);
                        setState(() {
                          activeIndex = 1;
                        });
                      },

                      // splashColor: Colors.grey.shade500,
                    ),
                    Text(
                      'Search',
                      style: TextStyle(
                        color:
                        activeIndex == 1
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                // IconButton(
                //       icon: Icon(
                //         activeIndex == 1
                //             ? Icons.filter_alt
                //             : Icons.filter_alt_outlined,
                //         color:
                //             activeIndex == 1
                //                 ? AppColors.primaryColor
                //                 : Colors.grey.shade500,
                //         size: 30,
                //       ),
                //       onPressed: () {
                //         setState(() {
                //           activeIndex = 1;
                //         });
                //         bottomctrl.navBarChange(1);
                //       },
                //     ),
                Container(width: size.width * 0.20),
                Stack(
                  children: [
                    // Positioned(
                    //     top: 2,
                    //     right: 6,
                    //     child:
                    //         // Consumer<ApiRepository>(builder: (context, value, child){
                    //         //   return Text(value.notificationLoader == false ? "" :
                    //         //   value.getNotificationModelList!.unseen.toString() == "0" ? "":
                    //         //   value.getNotificationModelList!.unseen.toString()
                    //         //   );
                    //         // },),
                    //         Text(
                    //       isLoading
                    //           ? ""
                    //           : ApiRepository.shared.getNotificationModelList!.unseen.toString() == "0"
                    //               ? ""
                    //               : ApiRepository.shared.getNotificationModelList!.unseen.toString(),
                    //       style: TextStyle(color: Colors.white),
                    //     )
                    //     ),
                    Visibility(
                      visible: role != "Guest",
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Image.asset(
                              'assets/newpacks/chaticon.png',
                              width: 25,
                              height: 25,
                              color:
                                  activeIndex == 5
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade500,
                            ),
                            onTap: () {
                              if (role != "Guest") {
                                setState(() {
                                  activeIndex = 5;
                                });
                                bottomctrl.navBarChange(5);
                              } else {
                                Utils.toastMessage(
                                  "Not Available For Guest User",
                                );
                              }
                            },

                            // splashColor: Colors.grey.shade500,
                          ),
                          Text(
                            'Chat',
                            style: TextStyle(
                              color:
                                  activeIndex == 5
                                      ? Colors.black
                                      : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     activeIndex == 5 ? Icons.chat : Icons.chat_outlined,
                      //     // color:
                      //     //     role != "Guest"
                      //     //         ? const Color.fromARGB(218, 255, 255, 255)
                      //     //         : Color(0xFF808080),
                      //     color:
                      //         activeIndex == 5
                      //             ? AppColors.primaryColor
                      //             : Colors.grey.shade500,
                      //   ),
                      //   // Image.asset(
                      //   //   'assets/slicing/notifications.png',
                      //   //   width: 20,
                      //   // ),
                      //   //todo
                      //   onPressed: () {
                      //     // role == "0" ?
                      //     // Get.to(MessagesScreen())
                      //     // Get.to(() => MessageScreen()) :
                      //     // bottomctrl.navBarChange(3);
                      //     // Get.to(() => MessagesScreen());
                      //     if (role != "Guest") {
                      //       setState(() {
                      //         activeIndex = 5;
                      //       });
                      //       bottomctrl.navBarChange(5);
                      //     } else {
                      //       Utils.toastMessage("Not Available For Guest User");
                      //     }
                      //   },
                      // ),
                    ),
                  ],
                ),
                role == "1"
                    ?
                // IconButton(
                //       icon: Icon(
                //         activeIndex == 4
                //             ? Icons.settings
                //             : Icons.settings_outlined,
                //
                //         // color:
                //         //     role != "Guest"
                //         //         ? const Color.fromARGB(218, 255, 255, 255)
                //         //         : Color(0xFF808080),
                //         color:
                //             activeIndex == 4
                //                 ? AppColors.primaryColor
                //                 : Colors.grey.shade500,
                //       ),
                //       // icon: Icon(
                //       //   Icons.person_sharp,
                //       //   color: Colors.white,
                //       //   size: 30,
                //       // ),
                //       onPressed: () {
                //         if (role != "Guest") {
                //           setState(() {
                //             activeIndex = 4;
                //           });
                //           bottomctrl.navBarChange(4);
                //         } else {
                //           Utils.toastMessage("Not Available For Guest User");
                //         }
                //       },
                //     )

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset(
                        'assets/newpacks/settingicon.png',
                        width: 25,
                        height: 25,
                        color:
                        activeIndex == 4
                            ? AppColors.primaryColor
                            : Colors.grey.shade500,
                      ),
                      onTap: () {
                        if (role != "Guest") {
                          setState(() {
                            activeIndex = 4;
                          });
                          bottomctrl.navBarChange(4);
                        } else {
                          Utils.toastMessage("Not Available For Guest User");
                        }
                      },

                      // splashColor: Colors.grey.shade500,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color:
                        activeIndex == 4
                            ? Colors.black
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                )
                    : (role != "Guest")
                    ? GestureDetector(
                  onTap: (){


                    setState(() {
                      activeIndex = 4;
                    });
                    bottomctrl.navBarChange(4);
                  },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Image.asset(
                              'assets/newpacks/settingicon.png',
                              width: 25,
                              height: 25,
                              color:
                                  activeIndex == 4
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade500,
                            ),
                            onTap: () {
                              setState(() {
                                activeIndex = 4;
                              });
                              bottomctrl.navBarChange(4);
                            },

                            // splashColor: Colors.grey.shade500,
                          ),
                          Text(
                            'Settings',
                            style: TextStyle(
                              color:
                                  activeIndex == 4
                                      ? Colors.black
                                      : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    // IconButton(
                    //       icon: Icon(
                    //         activeIndex == 4
                    //             ? Icons.settings
                    //             : Icons.settings_outlined,
                    //         // color:
                    //         //     role != "Guest"
                    //         //         ? const Color.fromARGB(218, 255, 255, 255)
                    //         //         : Color(0xFF808080),
                    //         color:
                    //             activeIndex == 4
                    //                 ? AppColors.primaryColor
                    //                 : Colors.grey.shade500,
                    //       ),
                    //       onPressed: () {
                    //         if (role != "Guest") {
                    //           setState(() {
                    //             activeIndex = 4;
                    //           });
                    //           bottomctrl.navBarChange(4);
                    //         } else {
                    //           Utils.toastMessage("Not Available For Guest User");
                    //         }
                    //       },
                    //     )
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 60,
                        height: 20,
                        child: SizedBox.shrink(),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomForGuest() {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: 70,
      child: Stack(
        // clipBehavior: Clip.none,
        children: [
          CustomPaint(size: Size(size.width, 80), painter: BNBCustomPainter()),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              backgroundColor: kprimaryColor,
              child: Image.asset('assets/slicing/layer.png', width: 27),
              elevation: 0,
              onPressed: () {
                bottomctrl.navBarChange(2);
              },
            ),
          ),
          Container(
            width: size.width,
            height: 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: const Color.fromARGB(218, 255, 255, 255),
                    size: 30,
                  ),
                  onPressed: () {
                    bottomctrl.navBarChange(0);
                  },
                  splashColor: Colors.white,
                ),
                Container(width: size.width * 0.20),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: const Color.fromARGB(218, 255, 255, 255),
                  ),
                  // Image.asset(
                  //   'assets/slicing/heart.png',
                  //   width: 20,
                  // ),
                  onPressed: () {
                    // bottomctrl.navBarChange(2);
                    Get.to(() => FilterScreeen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  var imagesapi = "null";
  var nameapi = "null";
  var locationapi = "null";
  var emailapi = "null";
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  ////////
  Future getProductsApi(String ids) async {
    final response = await http.get(
      Uri.parse('${Url}/UserProfileGetById/${ids}'),
    );
    var data = jsonDecode(response.body.toString());

    if (data["data"].length != 0) {}

    if (data["data"].length != 0) {
      setState(() {
        imagesapi = data["data"][0]["image"].toString();
        nameapi = data["data"][0]["name"].toString();
        //_nameController.text=data["data"][0]["name"].toString();
        emailapi = data["data"][0]["email"].toString();
        locationapi = data["data"][0]["address"].toString();
      });
    }
    if (response.statusCode == 200) {
      SharedPreferences updatePrefrences =
          await SharedPreferences.getInstance();
      if (data["data"].length != 0) {
        setState(() {
          updatePrefrences.setString(
            'fullname',
            data["data"][0]["name"].toString(),
          );
          updatePrefrences.setString(
            'email',
            data["data"][0]["email"].toString(),
          );
          updatePrefrences.setString(
            'image',
            data["data"][0]["image"].toString(),
          );
          updatePrefrences.setString(
            'address',
            data["data"][0]["address"].toString(),
          );
          updatePrefrences.setString(
            'latitude',
            data["data"][0]["latitude"].toString(),
          );
          updatePrefrences.setString(
            'longitude',
            data["data"][0]["longitude"].toString(),
          );
          updatePrefrences.setString(
            'number',
            data["data"][0]["number"].toString(),
          );
        });
      }

      return data;
    } else {
      return "No data";
    }
  }

  /////////////////////////////////
  Future getCategoryList() async {
    final response = await http.get(Uri.parse(AppUrl.categoryGetUrl));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      return data;
    } else {
      return "No data";
    }
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        new Paint()
          //..color = Color(0xFF4285F4)
          ..color = Color(0xFFffffff)
          ..style = PaintingStyle.fill;

    Path path = Path();
    // path.moveTo(0, 20);
    path.moveTo(0, 0); // -> start at top left
    // path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.lineTo(size.width * 0.35, 0); // -> move to middle left
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(
      Offset(size.width * 0.60, 20),
      radius: Radius.circular(20.0),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    // path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, 0); // -> move from middle right to top right
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    // path.lineTo(0, 20);
    path.close(); // -> close path, same as path.lineTo(0, 0)
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
