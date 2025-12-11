// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jebby/Views/helper/colors.dart';
// import 'package:jebby/Views/screens/auth/ProductDetail.dart';
// // import 'package:jebby/screens/home/profile/myprofile.dart';
// import 'package:jebby/Views/screens/profile/myprofile.dart';

// class CategoryProducts extends StatefulWidget {
//   final String? categoryname;
//   final String? id;
//   const CategoryProducts({Key? key, required this.categoryname , required this.id})
//       : super(key: key);

//   @override
//   State<CategoryProducts> createState() => _CategoryProductsState();
// }

// class _CategoryProductsState extends State<CategoryProducts> {
//   @override
//   Widget build(BuildContext context) {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           '${widget.categoryname} Products',
//           style: TextStyle(
//               fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
//         ),
//         leading: GestureDetector(
//           onTap: () {
//             Get.back();
//           },
//           child: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.grey,
//           ),
//         ),
//         actions: [
//           GestureDetector(
//             onTap: () {
//               Get.to(() => MyProfileScreen());
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(19.0),
//               child: Container(
//                 child: Image.asset('assets/slicing/avatar.png'),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           width: double.infinity,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 height: 50,
//                 width: res_width * 0.9,
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: "Search",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15.0),
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderSide:
//                           const BorderSide(color: kprimaryColor, width: 1),
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderSide:
//                           const BorderSide(color: kprimaryColor, width: 1),
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                     ),
//                   ),
//                 ),
//               ),
//               // Container(
//               //   width: res_width * 0.9,
//               //   child: TextField(
//               //     decoration: InputDecoration(
//               //         enabledBorder: OutlineInputBorder(
//               //             borderRadius: BorderRadius.circular(15.0),
//               //             borderSide:
//               //                 BorderSide(color: kprimaryColor, width: 0.5)),
//               //         filled: true,
//               //         hintStyle: TextStyle(color: Colors.grey),
//               //         suffixIcon: Icon(Icons.search_outlined),
//               //         hintText: "Search",
//               //         fillColor: Colors.white),
//               //   ),
//               // ),
//               SizedBox(
//                 height: res_height * 0.03,
//               ),
//               // Container(
//               //   width: res_width * 0.9,
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Container(
//               //         child: Text(
//               //           'Featured Categories',
//               //           style: TextStyle(
//               //               fontSize: 20, fontWeight: FontWeight.bold),
//               //         ),
//               //       ),
//               //       Row(
//               //         children: [
//               //           Container(
//               //             width: res_height * 0.035,
//               //             child: Image.asset('assets/slicing/line.png'),
//               //           ),
//               //           SizedBox(
//               //             width: 10,
//               //           ),
//               //           Container(
//               //             width: res_height * 0.035,
//               //             child: Image.asset('assets/slicing/column.png'),
//               //           )
//               //         ],
//               //       )
//               //     ],
//               //   ),
//               // ),
//               // SizedBox(
//               //   height: res_height * 0.03,
//               // ),
//               Container(
//                 child: Wrap(
//                   spacing: 10,
//                   runSpacing: 10,
//                   children: [
//                     itmBox(
//                         img: 'assets/slicing/h.jpg',
//                         dx: '\$ 7000',
//                         rv: '(2.9k Revews)',
//                         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                         rt: '4.9'),
//                     itmBox(
//                         img: 'assets/slicing/h.jpg',
//                         dx: '\$ 9000',
//                         rv: '(2.9k Revews)',
//                         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                         rt: '4.9'),
//                     itmBox(
//                         img: 'assets/slicing/h.jpg',
//                         dx: '\$ 9000',
//                         rv: '(2.9k Revews)',
//                         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                         rt: '4.9'),
//                     itmBox(
//                         img: 'assets/slicing/h.jpg',
//                         dx: '\$ 9000',
//                         rv: '(2.9k Revews)',
//                         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
//                         rt: '4.9'),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   itmBox({img, tx, dx, rt, rv}) {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => ProductDetailScreen());
//       },
//       child: Container(
//         width: res_width * 0.44,
//         // height: res_height * 0.28,
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
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   child: Image.asset(
//                     '$img',
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: res_height * 0.005,
//               ),
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$tx',
//                       style: TextStyle(fontSize: 11),
//                     ),
//                     SizedBox(
//                       height: res_height * 0.006,
//                     ),
//                     Text(
//                       '$dx',
//                       style: TextStyle(fontSize: 11),
//                       textAlign: TextAlign.left,
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.star,
//                           size: 11,
//                           color: kprimaryColor,
//                         ),
//                         Icon(
//                           Icons.star,
//                           size: 11,
//                           color: kprimaryColor,
//                         ),
//                         Icon(
//                           Icons.star,
//                           size: 11,
//                           color: kprimaryColor,
//                         ),
//                         Icon(
//                           Icons.star,
//                           size: 11,
//                           color: kprimaryColor,
//                         ),
//                         Icon(Icons.star, size: 11),
//                         Text(
//                           '$rt ',
//                           style: TextStyle(fontSize: 11),
//                         ),
//                         Text(
//                           '$rv',
//                           style: TextStyle(
//                             fontSize: 9,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
