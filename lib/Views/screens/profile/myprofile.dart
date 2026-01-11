import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../view_model/user_view_model.dart';
import '../../../model/user_model.dart';
import '../home/Favourites.dart';
import '../home/MyOrders.dart';
import '../profile/editprofile.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool isPrivate = false;

  //   //HomeViewViewModel homeViewViewModel = HomeViewViewModel();
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  var imagesapi = "null";
  var nameapi = "null";
  var back_image_api = "null";

  ////////
  Future getProductsApi(id) async {
    final response = await http.get(
      Uri.parse('${Url}/UserProfileGetById/${id}'),
    );
    var data = jsonDecode(response.body.toString());
    if (data["data"].length != 0) {}
    setState(() {
      if (data["data"].length != 0) {
        imagesapi = data["data"][0]["image"].toString();
        nameapi = data["data"][0]["name"].toString();
        back_image_api = data["data"][0]["back_image"].toString();
      }
    });
    if (response.statusCode == 200) {
      return data;
    } else {
      return "No data";
    }
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
          getProductsApi(id);
          fullname = value.name.toString();

          email = value.email.toString();
          role = value.role.toString();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// ---------------- PROFILE AVATAR ----------------
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      sp.imageUrl == null || sp.imageUrl.toString() == "null"
                          ? null
                          : CachedNetworkImageProvider(sp.imageUrl!),
                  child:
                      sp.imageUrl == null || sp.imageUrl.toString() == "null"
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              "Verified User",
              style: TextStyle(fontSize: 14, color: Color(0xff8F9098)),
            ),

            const SizedBox(height: 20),

            /// ---------------- PRIVACY TOGGLE ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Set Profile Picture as Private",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  Switch(
                    value: isPrivate,
                    onChanged: (val) {
                      setState(() {
                        isPrivate = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ---------------- USER INFO CARD ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person, "Name", fullname ?? ""),
                  _infoRow(Icons.email, "Email Address", email ?? ""),
                  _infoRow(Icons.phone, "Mobile Number", "Phone"),
                  _infoRow(Icons.location_on, "My Address", "Address"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ---------------- ACTION CARDS ----------------
            Row(
              children: [
                _actionCard(
                  imagename: 'mywishlist.png',
                  iconColor: Colors.red,
                  title: "My Wishlist",
                  subtitle: "Items you love.",
                  onTap: () => Get.to(() => FavouriteScreen()),
                ),
                const SizedBox(width: 12),
                _actionCard(
                  imagename: 'myorders.png',
                  iconColor: Colors.brown,
                  title: "My Order",
                  subtitle: "Track your rentals.",
                  onTap: () => Get.to(() => MyOrdersScreen()),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// ---------------- REUSABLE WIDGETS ----------------

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xff8F9098)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff8F9098),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String imagename,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/newpacks/$imagename',
                    height: 30,
                    width: 30,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
//
// import 'package:get/get.dart';
// import 'package:jebby/Views/helper/colors.dart';
// import 'package:jebby/Views/screens/home/Favourites.dart';
// import 'package:jebby/Views/screens/home/MyOrders.dart';
// import 'package:jebby/Views/screens/mainfolder/homemain.dart';
// // import 'package:jebby/screens/home/profile/editprofile.dart';
// import 'package:jebby/Views/screens/profile/editprofile.dart';
// import 'package:jebby/model/user_model.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Services/provider/sign_in_provider.dart';
// import '../../../view_model/user_view_model.dart';
//
// class MyProfileScreen extends StatefulWidget {
//   const MyProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MyProfileScreen> createState() => _MyProfileScreenState();
// }
//
// class _MyProfileScreenState extends State<MyProfileScreen> {
//   ///Instance of Provider Get
//   //HomeViewViewModel homeViewViewModel = HomeViewViewModel();
//   String Url = dotenv.env['baseUrlM'] ?? 'No url found';
//
//   Future getData() async {
//     final sp = context.read<SignInProvider>();
//     sp.getDataFromSharedPreferences();
//   }
//
//   Future<UserModel> getUserDate() => UserViewModel().getUser();
//   @override
//   void initState() {
//     super.initState();
//     getData();
//     profileData(context);
//   }
//
//   String? token;
//   String? id;
//   String? fullname;
//   String? email;
//   String? role;
//   void profileData(BuildContext context) async {
//     getUserDate()
//         .then((value) async {
//           token = value.token.toString();
//           id = value.id.toString();
//           getProductsApi(id);
//           fullname = value.name.toString();
//
//           email = value.email.toString();
//           role = value.role.toString();
//         })
//         .onError((error, stackTrace) {
//           if (kDebugMode) {}
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // change read to watch!!!!
//     //
//     final sp = context.watch<SignInProvider>();
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'My Profile',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//             fontSize: 19,
//           ),
//         ),
//         leading: InkWell(
//           onTap: () {
//             Get.to(() => MainScreen());
//           },
//           borderRadius: BorderRadius.circular(50),
//           child: Icon(Icons.arrow_back, color: Colors.black),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.all(19.0),
//             child: GestureDetector(
//               onTap: () {
//                 Get.off(() => EditProfile());
//               },
//               child: Container(
//                 child: Image.asset('assets/slicing/Group 63@3x.png'),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: res_width * 0.9,
//                   child: Column(
//                     children: [
//                       SizedBox(height: res_height * 0.02),
//                       Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           Container(
//                             width: 400,
//                             height: 136,
//                             decoration: BoxDecoration(),
//                             child:
//                                 imagesapi == "null"
//                                     ? sp.imageUrl.toString() == "null"
//                                         ? Image.asset(
//                                           "assets/slicing/blankuser.jpeg",
//                                           fit: BoxFit.cover,
//                                         )
//                                         : CachedNetworkImage(
//                                           imageUrl: "${sp.imageUrl}",
//                                           fit: BoxFit.cover,
//                                           placeholder:
//                                               (context, url) => Center(
//                                                 child:
//                                                     CircularProgressIndicator(),
//                                               ),
//                                           errorWidget:
//                                               (context, url, error) => Icon(
//                                                 Icons.error,
//                                                 color: Colors.red,
//                                               ),
//                                         )
//                                     : CachedNetworkImage(
//                                       imageUrl: "${Url}${back_image_api}",
//                                       fit: BoxFit.cover,
//                                       placeholder:
//                                           (context, url) => Center(
//                                             child: CircularProgressIndicator(),
//                                           ),
//                                       errorWidget:
//                                           (context, url, error) => Icon(
//                                             Icons.error,
//                                             color: Colors.red,
//                                           ),
//                                     ),
//                             //  imagesapi == "null"
//                             //     ? Image.asset(
//                             //         'assets/slicing/userblankpng.png',
//                             //         fit: BoxFit.cover,
//                             //       )
//                             //     : Image.network(
//                             //         "${Url}${imagesapi}",
//                             //         fit: BoxFit.cover,
//                             //       ),
//                           ),
//                           Positioned(
//                             left: 15,
//                             bottom: -20,
//                             child: Container(
//                               child:
//                                   imagesapi == "null"
//                                       ? sp.imageUrl.toString() == "null"
//                                           ? CircleAvatar(
//                                             radius: 40,
//                                             backgroundImage: AssetImage(
//                                               "assets/slicing/blankuser.jpeg",
//                                             ),
//                                           )
//                                           : CircleAvatar(
//                                             radius: 40,
//                                             backgroundColor: Colors.grey[200],
//                                             child: CachedNetworkImage(
//                                               imageUrl: "${sp.imageUrl}",
//                                               imageBuilder:
//                                                   (context, imageProvider) =>
//                                                       CircleAvatar(
//                                                         radius: 40,
//                                                         backgroundImage:
//                                                             imageProvider,
//                                                       ),
//                                               placeholder:
//                                                   (context, url) =>
//                                                       CircularProgressIndicator(), // Placeholder widget
//                                               errorWidget:
//                                                   (context, url, error) => Icon(
//                                                     Icons.error,
//                                                     size: 40,
//                                                   ), // Error widget
//                                             ),
//                                           )
//                                       : CircleAvatar(
//                                         radius: 40,
//                                         backgroundColor: Colors.grey[200],
//                                         child: CachedNetworkImage(
//                                           imageUrl: "${Url}${imagesapi}",
//                                           imageBuilder:
//                                               (context, imageProvider) =>
//                                                   CircleAvatar(
//                                                     radius: 40,
//                                                     backgroundImage:
//                                                         imageProvider,
//                                                   ),
//                                           placeholder:
//                                               (context, url) =>
//                                                   CircularProgressIndicator(), // Placeholder widget
//                                           errorWidget:
//                                               (context, url, error) => Icon(
//                                                 Icons.error,
//                                                 size: 40,
//                                               ), // Error widget
//                                         ),
//                                       ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: res_height * 0.04),
//                       Row(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   getProductsApi(id);
//                                 },
//                                 child: Container(
//                                   width: res_width * 0.9,
//                                   child: Text(
//                                     // fullname.toString(),
//                                     nameapi == "null"
//                                         ? sp.name.toString() == "null"
//                                             ? fullname.toString()
//                                             : sp.name.toString()
//                                         : nameapi.toString(),
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 30,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 "Verified User",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               // Text(
//                               //   "1024 Reservation | 278 For Rents",
//                               //   style: TextStyle(fontSize: 16, color: Colors.grey),
//                               // ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Wrap(
//                         alignment: WrapAlignment.start,
//                         runSpacing: 20,
//                         spacing: 5,
//                         children: [
//                           Wraper(
//                             "assets/slicing/Path 180@3x.png",
//                             "My Wishlist",
//                             () {
//                               Get.to(() => FavouriteScreen());
//                               // final bottomcontroller = Get.put(BottomController());
//                               // bottomcontroller.navBarChange(1);
//                               // Get.to(() => MainScreen());
//                             },
//                           ),
//                           // Wraper(
//                           //   "assets/slicing/Group 352@3x.png",
//                           //   "Following",
//                           //   () {
//                           //     Get.to(() => FollowingStoresScreen());
//                           //     ;
//                           //   },
//                           // ),
//                           Wraper(
//                             "assets/slicing/Group 353@3x.png",
//                             "My Order",
//                             () {
//                               Get.to(() => MyOrdersScreen());
//                             },
//                           ),
//                           // Wraper(
//                           //   "assets/slicing/Path 163@3x.png",
//                           //   "Payment ",
//                           //   () {
//                           //     Get.toNamed("/TermsAndConditionsScreen");
//                           //   },
//                           // ),
//                           // Wraper(
//                           //   "assets/slicing/Path 165@3x.png",
//                           //   "Sphipping",
//                           //   () {
//                           //     Get.to(() => ShippingAddressScreen());
//                           //   },
//                           // ),
//                           // Wraper(
//                           //   "assets/slicing/Group 353@3x.png",
//                           //   "Tracking",
//                           //   () {
//                           //     Get.to(() => TrackMyOrdersScreen());
//                           //   },
//                           // ),
//                         ],
//                       ),
//                       SizedBox(height: res_height * 0.03),
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.center,
//                       //   children: [
//                       //     GestureDetector(
//                       //       onTap: () {
//                       //         onTap:
//                       //         () {
//                       //           // Get.to(() => RecorderScreen());
//                       //         };
//                       //       },
//                       //       child: GestureDetector(
//                       //         onTap: () {
//                       //           Get.to(() => OrderHistoryScreen());
//                       //         },
//                       //         child: Container(
//                       //           height: res_height * 0.04,
//                       //           width: res_width * 0.42,
//                       //           child: Center(
//                       //             child: Text(
//                       //               'My Recent Orrders',
//                       //               style: TextStyle(
//                       //                 fontWeight: FontWeight.bold,
//                       //                 fontSize: 12,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //           decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(8)),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //     SizedBox(
//                       //       width: res_width * 0.02,
//                       //     ),
//                       //     Container(
//                       //       height: res_height * 0.04,
//                       //       width: res_width * 0.42,
//                       //       child: Center(
//                       //         child: Text(
//                       //           'Recieve Orders',
//                       //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
//                       //         ),
//                       //       ),
//                       //       decoration: BoxDecoration(
//                       //           // color: kprimaryColor,
//                       //           borderRadius: BorderRadius.circular(8),
//                       //           border: Border.all(
//                       //             width: 0.6,
//                       //             color: kprimaryColor,
//                       //           )),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height: res_height * 0.02,
//                       // ),
//                       // GestureDetector(
//                       //   onTap: () {
//                       //     // Get.to(() => ProductDetailScreen());
//                       //   },
//                       //   child: Container(
//                       //     child: GestureDetector(
//                       //       onTap: () {
//                       //         // Get.to(() => ProductDetailScreen());
//                       //       },
//                       //       child: Wrap(
//                       //         spacing: 5,
//                       //         runSpacing: 8,
//                       //         children: [
//                       //           itmBox(
//                       //               img: 'assets/slicing/Layer 4@3x.png',
//                       //               dx: '\$ 7000',
//                       //               rv: '(2.9k Reveiws)',
//                       //               tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                       //               rt: '4.9'),
//                       //           itmBox(
//                       //               img: 'assets/slicing/Layer 4@3x.png',
//                       //               dx: '\$ 9000',
//                       //               rv: '(2.9k Reveiws)',
//                       //               tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                       //               rt: '4.9'),
//
//                       //           // itmBox(
//                       //           //     img: 'assets/slicing/h.jpg',
//                       //           //     dx: '\$ 9000',
//                       //           //     rv: '(2.9k Reveiws)',
//                       //           //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                       //           //     rt: '4.9'),
//                       //         ],
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   itmBox({img, tx, dx, rt, rv}) {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return GestureDetector(
//       onTap: () {
//         // Get.to(() => ProductDetailScreen());
//       },
//       child: Container(
//         width: res_width * 0.442,
//         // height: res_height * 0.35,
//         decoration: BoxDecoration(
//           color: Color.fromARGB(255, 244, 244, 244),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         // child: Padding(
//         //   padding: const EdgeInsets.only(
//         //       bottom: 120, left: 10, right: 10, top: 10),
//         child: Padding(
//           padding: const EdgeInsets.all(13.0),
//           child: Column(
//             children: [
//               Container(
//                 height: res_height * 0.2,
//                 decoration: BoxDecoration(),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   child: Image.asset('$img', fit: BoxFit.fill),
//                 ),
//               ),
//               SizedBox(height: res_height * 0.005),
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('$tx', style: TextStyle(fontSize: 11)),
//                     SizedBox(height: res_height * 0.006),
//                     Text(
//                       '$dx',
//                       style: TextStyle(fontSize: 11),
//                       textAlign: TextAlign.left,
//                     ),
//                     Row(
//                       children: [
//                         Icon(Icons.star, size: 11, color: kprimaryColor),
//                         Icon(Icons.star, size: 11, color: kprimaryColor),
//                         Icon(Icons.star, size: 11, color: kprimaryColor),
//                         Icon(Icons.star, size: 11, color: kprimaryColor),
//                         Icon(Icons.star, size: 11),
//                         Text('$rt ', style: TextStyle(fontSize: 11)),
//                         Text(
//                           '$rv',
//                           style: TextStyle(fontSize: 9, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Wraper(img, txt, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 100,
//         height: 90,
//         decoration: BoxDecoration(
//           color: Color(0xFF4285F4),
//           borderRadius: BorderRadius.all(Radius.circular(5)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(img, scale: 3),
//             SizedBox(height: 10),
//             Text(
//               txt,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   var imagesapi = "null";
//   var nameapi = "null";
//   var back_image_api = "null";
//
//   ////////
//   Future getProductsApi(id) async {
//     final response = await http.get(
//       Uri.parse('${Url}/UserProfileGetById/${id}'),
//     );
//     var data = jsonDecode(response.body.toString());
//     if (data["data"].length != 0) {}
//     setState(() {
//       if (data["data"].length != 0) {
//         imagesapi = data["data"][0]["image"].toString();
//         nameapi = data["data"][0]["name"].toString();
//         back_image_api = data["data"][0]["back_image"].toString();
//       }
//     });
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       return "No data";
//     }
//   }
// }
//
// // ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// // import 'dart:convert';
// // import 'dart:developer';
//
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:jebby/Views/controller/bottomcontroller.dart';
// // import 'package:jebby/Views/helper/colors.dart';
// // import 'package:jebby/Views/screens/auth/ProductDetail.dart';
// // import 'package:jebby/Views/screens/home/MyOrders.dart';
// // import 'package:jebby/Views/screens/home/TrackMyOrders.dart';
// // import 'package:jebby/Views/screens/home/orderHistory.dart';
// // import 'package:jebby/Views/screens/mainfolder/homemain.dart';
// // import 'package:jebby/Views/screens/profile/editprofile.dart';
// // import 'package:jebby/data/response/status.dart';
// // import 'package:jebby/view_model/user_view_model.dart';
// // import 'package:http/http.dart' as http;
//
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:shimmer/shimmer.dart';
//
// // import '../../../Services/provider/sign_in_provider.dart';
// // import '../../../model/user_model.dart';
// // import '../../../view_model/home_view_model.dart';
// // import '../home/FollowingStores.dart';
// // import '../home/ShippingAddress.dart';
//
// // class MyProfileScreen extends StatefulWidget {
// //   final String? id;
// //   const MyProfileScreen({Key? key,  this.id}) : super(key: key);
//
// //   @override
// //   State<MyProfileScreen> createState() => _MyProfileScreenState();
// // }
//
// // class _MyProfileScreenState extends State<MyProfileScreen> {
// //   String id = "0";
// //   Future<UserModel> getUserDate() => UserViewModel().getUser();
//
// //   void profileData(BuildContext context) async {
// //     getUserDate().then((value) async {
// //       setState(() {
// //        id = value.id.toString();
// //       });
// //     }).onError((error, stackTrace) {
// //     });
// //   }
// //   HomeViewViewModel homeViewViewModel = HomeViewViewModel();
//
// //   Future getData() async {
// //     final sp = context.read<SignInProvider>();
// //     sp.getDataFromSharedPreferences();
// //     final usp = context.read<UserViewModel>();
// //     usp.getUser();
// //    final SharedPreferences sharedPrefrecnces=await SharedPreferences.getInstance();
// //     String? getId =await sharedPrefrecnces.getString("id");
// //     log(getId.toString());
// //     homeViewViewModel.changeProfileDataApi(getId);
// //   }
//
// //   // Future getDataFromSharedPreferences() async {
// //   //   final usp = context.watch<UserViewModel>();
// //   //   log("//////////////////usp.id.toString()" + usp.id.toString());
// //   //   id = usp.id.toString();
// //   //   homeViewViewModel.changeProfileDataApi(428);
// //   // }
//
// //   @override
// //   void initState() {
// //     getData();
// //     profileData(context);
// //     log(" data check for my profile pagewill be change ${widget.id}");
// //    // homeViewViewModel.changeProfileDataApi(434);
// //     final usp = context.read<UserViewModel>();
// //     usp.getUpdatedUser();
//
// //     super.initState();
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     // change read to watch!!!!
// //     final sp = context.watch<SignInProvider>();
// //     final usp = context.watch<UserViewModel>();
// //     double res_width = MediaQuery.of(context).size.width;
// //     double res_height = MediaQuery.of(context).size.height;
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         centerTitle: true,
// //         title: Text(
// //           'My Profile',
// //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
// //         ),
// //         leading: GestureDetector(
// //           onTap: () {
// //             Get.back();
// //           },
// //           child: Icon(
// //             Icons.arrow_back_ios,
// //             color: Colors.grey,
// //           ),
// //         ),
// //         actions: [
// //           Padding(
// //             padding: EdgeInsets.all(19.0),
// //             child: GestureDetector(
// //               onTap: () {
// //                 Get.to(() => EditProfile());
// //               },
// //               child: Container(
// //                 child: Image.asset('assets/slicing/Group 63@3x.png'),
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //       body: ChangeNotifierProvider<HomeViewViewModel>(
// //         create: (context) => homeViewViewModel,
// //         child: Consumer<HomeViewViewModel>(builder: (context, value, child) {
// //           switch (value.changeProfileData.status) {
// //             case Status.LOADING:
// //               return
// //                   //Center(child: CircularProgressIndicator());
// //                   Shimmer.fromColors(
// //                 baseColor: Colors.grey.shade700,
// //                 highlightColor: Colors.grey.shade100,
// //                 child: Container(
// //                   width: double.infinity,
// //                   child: SingleChildScrollView(
// //                     child: Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 20),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Container(
// //                             width: res_width * 0.9,
// //                             child: Column(
// //                               children: [
// //                                 SizedBox(
// //                                   height: res_height * 0.02,
// //                                 ),
// //                                 Stack(
// //                                   clipBehavior: Clip.none,
// //                                   children: [
// //                                     Container(
// //                                       width: 400,
// //                                       height: 136,
// //                                       decoration: BoxDecoration(),
// //                                       child: Container(
// //                                         height: 10,
// //                                         width: 50,
// //                                         color: Colors.white,
// //                                       ),
// //                                       // Image.network("${Url}" + profileValues.image.toString(), fit: BoxFit.cover),
// //                                     ),
// //                                     Positioned(
// //                                         left: 15,
// //                                         bottom: -20,
// //                                         child: Container(
// //                                           child: CircleAvatar(
// //                                             radius: 40,
// //                                             child: Container(
// //                                               height: 10,
// //                                               width: 50,
// //                                               color: Colors.white,
// //                                             ),
// //                                             //  backgroundImage: NetworkImage("${Url}${profileValues.image.toString()}")),
// //                                           ),
// //                                         ))
// //                                   ],
// //                                 ),
// //                                 SizedBox(
// //                                   height: res_height * 0.04,
// //                                 ),
// //                                 Row(
// //                                   children: [
// //                                     Column(
// //                                       crossAxisAlignment: CrossAxisAlignment.start,
// //                                       children: [
// //                                         Container(
// //                                           height: 10,
// //                                           width: 50,
// //                                           color: Colors.white,
// //                                         ),
// //                                         // Text(
// //                                         // // sp.name.toString() == "null" ? profileValues.name.toString() : sp.name.toString(),
// //                                         //   //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
// //                                         // ),
// //                                         SizedBox(
// //                                           height: 8,
// //                                         ),
// //                                         Text(
// //                                           "Verified User",
// //                                           style: TextStyle(fontSize: 16, color: Colors.grey),
// //                                         ),
// //                                         SizedBox(
// //                                           height: 8,
// //                                         ),
// //                                         Text(
// //                                           "1024 Reservation | 278 For Rents",
// //                                           style: TextStyle(fontSize: 16, color: Colors.grey),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(
// //                                   height: 10,
// //                                 ),
// //                                 Wrap(
// //                                   alignment: WrapAlignment.start,
// //                                   runSpacing: 20,
// //                                   spacing: 5,
// //                                   children: [
// //                                     Wraper(
// //                                       "assets/slicing/Path 180@3x.png",
// //                                       "Wish List",
// //                                       () {
// //                                         final bottomcontroller = Get.put(BottomController());
// //                                         bottomcontroller.navBarChange(1);
// //                                         Get.to(() => MainScreen());
// //                                       },
// //                                     ),
// //                                     Wraper(
// //                                       "assets/slicing/Group 352@3x.png",
// //                                       "Following",
// //                                       () {
// //                                         Get.to(() => FollowingStoresScreen());
// //                                         ;
// //                                       },
// //                                     ),
// //                                     Wraper(
// //                                       "assets/slicing/Group 353@3x.png",
// //                                       "My Order",
// //                                       () {
// //                                         Get.to(() => MyOrdersScreen());
// //                                       },
// //                                     ),
// //                                     Wraper(
// //                                       "assets/slicing/Path 163@3x.png",
// //                                       "Payment ",
// //                                       () {
// //                                         // Get.toNamed("/TermsAndConditionsScreen");
// //                                       },
// //                                     ),
// //                                     Wraper(
// //                                       "assets/slicing/Path 165@3x.png",
// //                                       "Sphipping",
// //                                       () {
// //                                         Get.to(() => ShippingAddressScreen());
// //                                       },
// //                                     ),
// //                                     Wraper(
// //                                       "assets/slicing/Group 353@3x.png",
// //                                       "Tracking",
// //                                       () {
// //                                         Get.to(() => TrackMyOrdersScreen());
// //                                       },
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(
// //                                   height: res_height * 0.03,
// //                                 ),
// //                                 Row(
// //                                   mainAxisAlignment: MainAxisAlignment.center,
// //                                   children: [
// //                                     GestureDetector(
// //                                       onTap: () {
// //                                         onTap:
// //                                         () {
// //                                           // Get.to(() => RecorderScreen());
// //                                         };
// //                                       },
// //                                       child: GestureDetector(
// //                                         onTap: () {
// //                                           Get.to(() => OrderHistoryScreen());
// //                                         },
// //                                         child: Container(
// //                                           height: res_height * 0.04,
// //                                           width: res_width * 0.42,
// //                                           child: Center(
// //                                             child: Text(
// //                                               'My Recent Orrders',
// //                                               style: TextStyle(
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontSize: 12,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                           decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(8)),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     SizedBox(
// //                                       width: res_width * 0.02,
// //                                     ),
// //                                     Container(
// //                                       height: res_height * 0.04,
// //                                       width: res_width * 0.42,
// //                                       child: Center(
// //                                         child: Text(
// //                                           'Recieve Orders',
// //                                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
// //                                         ),
// //                                       ),
// //                                       decoration: BoxDecoration(
// //                                           // color: kprimaryColor,
// //                                           borderRadius: BorderRadius.circular(8),
// //                                           border: Border.all(
// //                                             width: 0.6,
// //                                             color: kprimaryColor,
// //                                           )),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 SizedBox(
// //                                   height: res_height * 0.02,
// //                                 ),
// //                                 GestureDetector(
// //                                   onTap: () {
// //                                     Get.to(() => ProductDetailScreen());
// //                                   },
// //                                   child: Container(
// //                                     child: GestureDetector(
// //                                       onTap: () {
// //                                         Get.to(() => ProductDetailScreen());
// //                                       },
// //                                       child: Wrap(
// //                                         spacing: 5,
// //                                         runSpacing: 8,
// //                                         children: [
// //                                           itmBox(
// //                                               img: 'assets/slicing/Layer 4@3x.png',
// //                                               dx: '\$ 7000',
// //                                               rv: '(2.9k Reveiws)',
// //                                               tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                               rt: '4.9'),
// //                                           itmBox(
// //                                               img: 'assets/slicing/Layer 4@3x.png',
// //                                               dx: '\$ 9000',
// //                                               rv: '(2.9k Reveiws)',
// //                                               tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                               rt: '4.9'),
//
// //                                           // itmBox(
// //                                           //     img: 'assets/slicing/h.jpg',
// //                                           //     dx: '\$ 9000',
// //                                           //     rv: '(2.9k Reveiws)',
// //                                           //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                           //     rt: '4.9'),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 SizedBox(
// //                                   height: 40,
// //                                 )
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             case Status.ERROR:
// //               return Center(child: Text(value.changeProfileData.message.toString()));
// //             case Status.COMPLETED:
// //             getProductsApi(usp.id);
// //               var profileValues; //= value.changeProfileData.data!.data![0];
//
// //               var profileValuesforcheck = value.changeProfileData.data!.data!;
//
// //               if (profileValuesforcheck.length != 0) {
//
// //                   profileValues = value.changeProfileData.data!.data![0];
//
// //               }
//
// //               return Container(
// //                 width: double.infinity,
// //                 child: SingleChildScrollView(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Container(
// //                           width: res_width * 0.9,
// //                           child: Column(
// //                             children: [
// //                               SizedBox(
// //                                 height: res_height * 0.02,
// //                               ),
// //                               Stack(
// //                                 clipBehavior: Clip.none,
// //                                 children: [
// //                                   Container(
// //                                     width: 400,
// //                                     height: 136,
// //                                     decoration: BoxDecoration(),
// //                                     child:
//
// //                                     sp.imageUrl.toString() == "null"
// //                                     ? usp.image.toString() == "null"
// //                                         ? Image.asset("assets/slicing/blankuser.jpeg", fit: BoxFit.cover)
// //                                         : Image.network("${Url}${ back_image_api}", fit: BoxFit.cover)
// //                                     : Image.network("${sp.imageUrl}", fit: BoxFit.cover),),
// //                                   Positioned(
// //                                     left: 15,
// //                                     bottom: -20,
// //                                     child: Container(
// //                                       child:
// //                                        sp.imageUrl.toString() == "null"
// //                                 ? usp.image.toString() == "null"
// //                                     ? CircleAvatar(radius: 40, child: Center(child: CircularProgressIndicator()),// backgroundImage: AssetImage("assets/slicing/blankuser.jpeg")
// //                                     )
// //                                 : CircleAvatar(
// //                                     radius: 40,
// //                                     backgroundImage: NetworkImage("${Url}${usp.image}"))
// //                                     : CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}")),
//
// //                                       ///////////////
// //                                       // profileValuesforcheck.length == 0
// //                                       //     ? sp.name.toString() == "null"? CircleAvatar(radius: 40, backgroundImage: AssetImage("assets/slicing/blankuser.jpeg")):CircleAvatar(radius: 40, backgroundImage: NetworkImage("${sp.imageUrl}"))
// //                                       //     : CircleAvatar(
// //                                       //         radius: 40,
// //                                       //         backgroundImage: NetworkImage("${Url}${profileValues.image.toString()}")),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(
// //                                 height: res_height * 0.04,
// //                               ),
// //                               Row(
// //                                 children: [
// //                                   Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       Text(
// //                                         profileValuesforcheck.length == 0
// //                                             ? sp.name.toString() == "null"
// //                                                 ? usp.name.toString()
// //                                                 : sp.name.toString()
// //                                             : profileValues.name.toString(),
// //                                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
// //                                       ),
// //                                       SizedBox(
// //                                         height: 8,
// //                                       ),
// //                                       Text(
// //                                         "Verified User",
// //                                         style: TextStyle(fontSize: 16, color: Colors.grey),
// //                                       ),
// //                                       SizedBox(
// //                                         height: 8,
// //                                       ),
// //                                       Text(
// //                                         "1024 Reservation | 278 For Rents",
// //                                         style: TextStyle(fontSize: 16, color: Colors.grey),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(
// //                                 height: 10,
// //                               ),
// //                               Wrap(
// //                                 alignment: WrapAlignment.start,
// //                                 runSpacing: 20,
// //                                 spacing: 5,
// //                                 children: [
// //                                   Wraper(
// //                                     "assets/slicing/Path 180@3x.png",
// //                                     "Wish List",
// //                                     () {
// //                                       final bottomcontroller = Get.put(BottomController());
// //                                       bottomcontroller.navBarChange(1);
// //                                       Get.to(() => MainScreen());
// //                                     },
// //                                   ),
// //                                   Wraper(
// //                                     "assets/slicing/Group 352@3x.png",
// //                                     "Following",
// //                                     () {
// //                                       Get.to(() => FollowingStoresScreen());
// //                                       ;
// //                                     },
// //                                   ),
// //                                   Wraper(
// //                                     "assets/slicing/Group 353@3x.png",
// //                                     "My Order",
// //                                     () {
// //                                       Get.to(() => MyOrdersScreen());
// //                                     },
// //                                   ),
// //                                   Wraper(
// //                                     "assets/slicing/Path 163@3x.png",
// //                                     "Payment ",
// //                                     () {
// //                                       // Get.toNamed("/TermsAndConditionsScreen");
// //                                     },
// //                                   ),
// //                                   Wraper(
// //                                     "assets/slicing/Path 165@3x.png",
// //                                     "Sphipping",
// //                                     () {
// //                                       Get.to(() => ShippingAddressScreen());
// //                                     },
// //                                   ),
// //                                   Wraper(
// //                                     "assets/slicing/Group 353@3x.png",
// //                                     "Tracking",
// //                                     () {
// //                                       Get.to(() => TrackMyOrdersScreen());
// //                                     },
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(
// //                                 height: res_height * 0.03,
// //                               ),
// //                               Row(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   GestureDetector(
// //                                     onTap: () {
// //                                       onTap:
// //                                       () {
// //                                         // Get.to(() => RecorderScreen());
// //                                       };
// //                                     },
// //                                     child: GestureDetector(
// //                                       onTap: () {
// //                                         Get.to(() => OrderHistoryScreen());
// //                                       },
// //                                       child: Container(
// //                                         height: res_height * 0.04,
// //                                         width: res_width * 0.42,
// //                                         child: Center(
// //                                           child: Text(
// //                                             'My Recent Orrders',
// //                                             style: TextStyle(
// //                                               fontWeight: FontWeight.bold,
// //                                               fontSize: 12,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(8)),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   SizedBox(
// //                                     width: res_width * 0.02,
// //                                   ),
// //                                   Container(
// //                                     height: res_height * 0.04,
// //                                     width: res_width * 0.42,
// //                                     child: Center(
// //                                       child: Text(
// //                                         'Recieve Orders',
// //                                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
// //                                       ),
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                         // color: kprimaryColor,
// //                                         borderRadius: BorderRadius.circular(8),
// //                                         border: Border.all(
// //                                           width: 0.6,
// //                                           color: kprimaryColor,
// //                                         )),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(
// //                                 height: res_height * 0.02,
// //                               ),
// //                               GestureDetector(
// //                                 onTap: () {
// //                                   Get.to(() => ProductDetailScreen());
// //                                 },
// //                                 child: Container(
// //                                   child: GestureDetector(
// //                                     onTap: () {
// //                                       Get.to(() => ProductDetailScreen());
// //                                     },
// //                                     child: Wrap(
// //                                       spacing: 5,
// //                                       runSpacing: 8,
// //                                       children: [
// //                                         itmBox(
// //                                             img: 'assets/slicing/Layer 4@3x.png',
// //                                             dx: '\$ 7000',
// //                                             rv: '(2.9k Reveiws)',
// //                                             tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                             rt: '4.9'),
// //                                         itmBox(
// //                                             img: 'assets/slicing/Layer 4@3x.png',
// //                                             dx: '\$ 9000',
// //                                             rv: '(2.9k Reveiws)',
// //                                             tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                             rt: '4.9'),
//
// //                                         // itmBox(
// //                                         //     img: 'assets/slicing/h.jpg',
// //                                         //     dx: '\$ 9000',
// //                                         //     rv: '(2.9k Reveiws)',
// //                                         //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                         //     rt: '4.9'),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(
// //                                 height: 40,
// //                               )
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
//
// //             default:
// //           }
// //           return Container();
// //         }),
// //       ),
// //     );
// //   }
//
// //   itmBox({img, tx, dx, rt, rv}) {
// //     double res_width = MediaQuery.of(context).size.width;
// //     double res_height = MediaQuery.of(context).size.height;
// //     return GestureDetector(
// //       onTap: () {
// //         Get.to(() => ProductDetailScreen());
// //       },
// //       child: Container(
// //         width: res_width * 0.442,
// //         // height: res_height * 0.35,
// //         decoration: BoxDecoration(
// //           color: Color.fromARGB(255, 244, 244, 244),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         // child: Padding(
// //         //   padding: const EdgeInsets.only(
// //         //       bottom: 120, left: 10, right: 10, top: 10),
// //         child: Padding(
// //           padding: const EdgeInsets.all(13.0),
// //           child: Column(
// //             children: [
// //               Container(
// //                 height: res_height * 0.2,
// //                 decoration: BoxDecoration(),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.all(
// //                     Radius.circular(10),
// //                   ),
// //                   child: Image.asset(
// //                     '$img',
// //                     fit: BoxFit.fill,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(
// //                 height: res_height * 0.005,
// //               ),
// //               Container(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       '$tx',
// //                       style: TextStyle(fontSize: 11),
// //                     ),
// //                     SizedBox(
// //                       height: res_height * 0.006,
// //                     ),
// //                     Text(
// //                       '$dx',
// //                       style: TextStyle(fontSize: 11),
// //                       textAlign: TextAlign.left,
// //                     ),
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(Icons.star, size: 11),
// //                         Text(
// //                           '$rt ',
// //                           style: TextStyle(fontSize: 11),
// //                         ),
// //                         Text(
// //                           '$rv',
// //                           style: TextStyle(
// //                             fontSize: 9,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
//
// //   Wraper(
// //     img,
// //     txt,
// //     VoidCallback onTap,
// //   ) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         width: 88,
// //         height: 84,
// //         decoration: BoxDecoration(color: Color(0xff321A08), borderRadius: BorderRadius.all(Radius.circular(5))),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Image.asset(
// //               img,
// //               scale: 3,
// //             ),
// //             SizedBox(
// //               height: 5,
// //             ),
// //             Text(
// //               txt,
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //   var imagesapi = "null";
// //   var nameapi = "null";
// //   var locationapi = "null";
// //   var emailapi = "null";
// //   var back_image_api = "null";
// //    Future getProductsApi(id) async {
// //     final response = await http.get(Uri.parse('${Url}/UserProfileGetById/${id}'));
// //     var data = jsonDecode(response.body.toString());
// //     log(data.toString());
// //     if (data["data"].length != 0) {
// //       log(data["data"][0]["id"].toString());
// //     }
//
// //       if (data["data"].length != 0) {
//
// //         imagesapi = data["data"][0]["image"].toString();
// //         nameapi = data["data"][0]["name"].toString();
//
// //         emailapi = data["data"][0]["email"].toString();
//
// //         back_image_api = data["data"][0]["back_image"].toString();
//
// //       }
//
// //     if (response.statusCode == 200) {
// //       return data;
// //     } else {
// //       return "No data";
// //     }
// //   }
// // }
//
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// // import 'dart:developer';
//
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:jebby/Views/controller/bottomcontroller.dart';
// // import 'package:jebby/Views/helper/colors.dart';
// // import 'package:jebby/Views/screens/auth/ProductDetail.dart';
// // import 'package:jebby/Views/screens/home/Favourites.dart';
// // import 'package:jebby/Views/screens/home/MyOrders.dart';
// // import 'package:jebby/Views/screens/home/TrackMyOrders.dart';
// // import 'package:jebby/Views/screens/home/orderHistory.dart';
// // import 'package:jebby/Views/screens/mainfolder/homemain.dart';
// // import 'package:jebby/Views/screens/profile/editprofile.dart';
// // import 'package:jebby/view_model/home_view_model.dart';
// // import 'package:provider/provider.dart';
//
// // import '../../../Services/provider/sign_in_provider.dart';
// // import '../../../view_model/user_view_model.dart';
// // import '../home/FollowingStores.dart';
// // import '../home/ShippingAddress.dart';
//
// // class MyProfileScreen extends StatefulWidget {
// //   const MyProfileScreen({Key? key}) : super(key: key);
//
// //   @override
// //   State<MyProfileScreen> createState() => _MyProfileScreenState();
// // }
//
// // class _MyProfileScreenState extends State<MyProfileScreen> {
// //   HomeViewViewModel home_view_model=HomeViewViewModel();
// //   dynamic updatedProfile;
//
// //   @override
// //   void initState() {
// //     super.initState();
// //     getData();
// //   }
//
// //    Future getData() async {
// //     final sp = context.read<SignInProvider>();
// //     sp.getDataFromSharedPreferences();
// //  final usp = Provider.of<UserViewModel>(context,listen: false);
// // usp.getUser();
// //     sp.getDataFromSharedPreferences();
// //    // final UsharePref = context.watch<UserViewModel>();
// //    log("//////////////////"+usp.id.toString());
//
// //    updatedProfile= home_view_model.updateProfileData(usp.id.toString());
//
// //   }
//
// //   itmBox({img, tx, dx, rt, rv}) {
// //     double res_width = MediaQuery.of(context).size.width;
// //     double res_height = MediaQuery.of(context).size.height;
// //     return GestureDetector(
// //       onTap: () {
// //         Get.to(() => ProductDetailScreen());
// //       },
// //       child: Container(
// //         width: res_width * 0.442,
// //         // height: res_height * 0.35,
// //         decoration: BoxDecoration(
// //           color: Color.fromARGB(255, 244, 244, 244),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         // child: Padding(
// //         //   padding: const EdgeInsets.only(
// //         //       bottom: 120, left: 10, right: 10, top: 10),
// //         child: Padding(
// //           padding: const EdgeInsets.all(13.0),
// //           child: Column(
// //             children: [
// //               Container(
// //                 height: res_height * 0.2,
// //                 decoration: BoxDecoration(),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.all(
// //                     Radius.circular(10),
// //                   ),
// //                   child: Image.asset(
// //                     '$img',
// //                     fit: BoxFit.fill,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(
// //                 height: res_height * 0.005,
// //               ),
// //               Container(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       '$tx',
// //                       style: TextStyle(fontSize: 11),
// //                     ),
// //                     SizedBox(
// //                       height: res_height * 0.006,
// //                     ),
// //                     Text(
// //                       '$dx',
// //                       style: TextStyle(fontSize: 11),
// //                       textAlign: TextAlign.left,
// //                     ),
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(
// //                           Icons.star,
// //                           size: 11,
// //                           color: kprimaryColor,
// //                         ),
// //                         Icon(Icons.star, size: 11),
// //                         Text(
// //                           '$rt ',
// //                           style: TextStyle(fontSize: 11),
// //                         ),
// //                         Text(
// //                           '$rv',
// //                           style: TextStyle(
// //                             fontSize: 9,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
//
// //   Wraper(
// //     img,
// //     txt,
// //     VoidCallback onTap,
// //   ) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         width: 88,
// //         height: 84,
// //         decoration: BoxDecoration(color: Color(0xff321A08), borderRadius: BorderRadius.all(Radius.circular(5))),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Image.asset(
// //               img,
// //               scale: 3,
// //             ),
// //             SizedBox(
// //               height: 5,
// //             ),
// //             Text(
// //               txt,
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     // change read to watch!!!!
// //     final sp = context.watch<SignInProvider>();
// //     double res_width = MediaQuery.of(context).size.width;
// //     double res_height = MediaQuery.of(context).size.height;
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         centerTitle: true,
// //         title: Text(
// //           'My Profile',
// //           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
// //         ),
// //         leading: GestureDetector(
// //           onTap: () {
// //             Get.back();
// //           },
// //           child: Icon(
// //             Icons.arrow_back_ios,
// //             color: Colors.grey,
// //           ),
// //         ),
// //         actions: [
// //           Padding(
// //             padding: EdgeInsets.all(19.0),
// //             child: GestureDetector(
// //               onTap: () {
// //                 Get.to(() => EditProfile());
// //               },
// //               child: Container(
// //                 child: Image.asset('assets/slicing/Group 63@3x.png'),
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //       body: Container(
// //         width: double.infinity,
// //         child: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Container(
// //                   width: res_width * 0.9,
// //                   child: Column(
// //                     children: [
// //                       SizedBox(
// //                         height: res_height * 0.02,
// //                       ),
// //                       Stack(
// //                         clipBehavior: Clip.none,
// //                         children: [
// //                           Container(
// //                             width: 400,
// //                             height: 136,
// //                             decoration: BoxDecoration(),
// //                             child: Image.asset("assets/slicing/Rectangle 546@3x.png"),
// //                           ),
// //                           Positioned(
// //                             left: 15,
// //                             bottom: -20,
// //                             child: Container(
// //                               child: CircleAvatar(radius: 40, child: Image.asset("assets/slicing/Ellipse 67@3x.png")),
// //                             ),
// //                           )
// //                         ],
// //                       ),
// //                       SizedBox(
// //                         height: res_height * 0.04,
// //                       ),
// //                       Row(
// //                         children: [
// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 sp.name.toString(),
// //                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
// //                               ),
// //                               SizedBox(
// //                                 height: 8,
// //                               ),
// //                               Text(
// //                                 "Verified User",
// //                                 style: TextStyle(fontSize: 16, color: Colors.grey),
// //                               ),
// //                               SizedBox(
// //                                 height: 8,
// //                               ),
// //                               Text(
// //                                 "1024 Reservation | 278 For Rents",
// //                                 style: TextStyle(fontSize: 16, color: Colors.grey),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       Wrap(
// //                         alignment: WrapAlignment.start,
// //                         runSpacing: 20,
// //                         spacing: 5,
// //                         children: [
// //                           Wraper(
// //                             "assets/slicing/Path 180@3x.png",
// //                             "Wish List",
// //                             () {
// //                               final bottomcontroller = Get.put(BottomController());
// //                               bottomcontroller.navBarChange(1);
// //                               Get.to(() => MainScreen());
// //                             },
// //                           ),
// //                           Wraper(
// //                             "assets/slicing/Group 352@3x.png",
// //                             "Following",
// //                             () {
// //                               Get.to(() => FollowingStoresScreen());
// //                               ;
// //                             },
// //                           ),
// //                           Wraper(
// //                             "assets/slicing/Group 353@3x.png",
// //                             "My Order",
// //                             () {
// //                               Get.to(() => MyOrdersScreen());
// //                             },
// //                           ),
// //                           Wraper(
// //                             "assets/slicing/Path 163@3x.png",
// //                             "Payment ",
// //                             () {
// //                               // Get.toNamed("/TermsAndConditionsScreen");
// //                             },
// //                           ),
// //                           Wraper(
// //                             "assets/slicing/Path 165@3x.png",
// //                             "Sphipping",
// //                             () {
// //                               Get.to(() => ShippingAddressScreen());
// //                             },
// //                           ),
// //                           Wraper(
// //                             "assets/slicing/Group 353@3x.png",
// //                             "Tracking",
// //                             () {
// //                               Get.to(() => TrackMyOrdersScreen());
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                       SizedBox(
// //                         height: res_height * 0.03,
// //                       ),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           GestureDetector(
// //                             onTap: () {
// //                               onTap:
// //                               () {
// //                                 // Get.to(() => RecorderScreen());
// //                               };
// //                             },
// //                             child: GestureDetector(
// //                               onTap: () {
// //                                 Get.to(() => OrderHistoryScreen());
// //                               },
// //                               child: Container(
// //                                 height: res_height * 0.04,
// //                                 width: res_width * 0.42,
// //                                 child: Center(
// //                                   child: Text(
// //                                     'My Recent Orrders',
// //                                     style: TextStyle(
// //                                       fontWeight: FontWeight.bold,
// //                                       fontSize: 12,
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(8)),
// //                               ),
// //                             ),
// //                           ),
// //                           SizedBox(
// //                             width: res_width * 0.02,
// //                           ),
// //                           Container(
// //                             height: res_height * 0.04,
// //                             width: res_width * 0.42,
// //                             child: Center(
// //                               child: Text(
// //                                 'Recieve Orders',
// //                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
// //                               ),
// //                             ),
// //                             decoration: BoxDecoration(
// //                                 // color: kprimaryColor,
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 border: Border.all(
// //                                   width: 0.6,
// //                                   color: kprimaryColor,
// //                                 )),
// //                           ),
// //                         ],
// //                       ),
// //                       SizedBox(
// //                         height: res_height * 0.02,
// //                       ),
// //                       GestureDetector(
// //                         onTap: () {
// //                           Get.to(() => ProductDetailScreen());
// //                         },
// //                         child: Container(
// //                           child: GestureDetector(
// //                             onTap: () {
// //                               Get.to(() => ProductDetailScreen());
// //                             },
// //                             child: Wrap(
// //                               spacing: 5,
// //                               runSpacing: 8,
// //                               children: [
// //                                 itmBox(
// //                                     img: 'assets/slicing/Layer 4@3x.png',
// //                                     dx: '\$ 7000',
// //                                     rv: '(2.9k Reveiws)',
// //                                     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                     rt: '4.9'),
// //                                 itmBox(
// //                                     img: 'assets/slicing/Layer 4@3x.png',
// //                                     dx: '\$ 9000',
// //                                     rv: '(2.9k Reveiws)',
// //                                     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                     rt: '4.9'),
//
// //                                 // itmBox(
// //                                 //     img: 'assets/slicing/h.jpg',
// //                                 //     dx: '\$ 9000',
// //                                 //     rv: '(2.9k Reveiws)',
// //                                 //     tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
// //                                 //     rt: '4.9'),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         height: 40,
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
