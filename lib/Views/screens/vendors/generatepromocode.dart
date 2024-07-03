import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';

import '../../controller/bottomcontroller.dart';
import '../mainfolder/homemain.dart';

class GeneratePromoCode extends StatefulWidget {
  const GeneratePromoCode({Key? key}) : super(key: key);

  @override
  State<GeneratePromoCode> createState() => _GeneratePromoCodeState();
}

class _GeneratePromoCodeState extends State<GeneratePromoCode> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Generate Promo Code',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
          ),
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: res_width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      itemdtl('Discount Availibility'),
                      SizedBox(
                        height: res_height * 0.02,
                      ),
                      Center(
                        child: Container(
                          width: 380,
                          height: 58,
                          decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              'Add Promo Code',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: res_height * 0.02,
                      ),
                      Text('Price'),
                      SizedBox(
                        height: res_height * 0.005,
                      ),
                      Container(
                        height: 50,
                        width: res_width * 0.8,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '##########',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: kprimaryColor, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: kprimaryColor, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 50,
                      //   width: res_width * 0.8,
                      //   child: TextField(
                      //     decoration: InputDecoration(
                      //         enabledBorder: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(15),
                      //             borderSide: BorderSide(
                      //                 color: kprimaryColor, width: 1)),
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         hintText: "############",
                      //         hintStyle: TextStyle(color: Colors.grey)),
                      //   ),
                      // ),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Text('Discount'),
                      SizedBox(
                        height: res_height * 0.005,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: res_width * 0.4,
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                            ),
                          ),
                          // Container(
                          //   height: 50,
                          //   width: res_width * 0.4,
                          //   child: TextField(
                          //     decoration: InputDecoration(
                          //       enabledBorder: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(15),
                          //           borderSide: BorderSide(
                          //               color: kprimaryColor, width: 1)),
                          //       filled: true,
                          //       fillColor: Colors.white,
                          //       // hintText: "Rs 500",
                          //       // hintStyle: TextStyle(color: Colors.grey)),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            width: res_width * 0.05,
                          ),
                          Text(
                            '%',
                            style: TextStyle(fontSize: 25, color: Colors.grey),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: res_height * 0.02,
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
                                height: 291,
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
                                          "Congratulations",
                                          style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Your Order Has Been Received",
                                          style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          width: 270,
                                          height: 50,
                                          child: Text(
                                            "You will be contacted by the Owner via direct message to confirm!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: "Inter, Regular",
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 28,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final bottomcontroller = Get.put(BottomController());
                                            bottomcontroller.navBarChange(0);
                                            Get.to(() => MainScreen());
                                          },
                                          child: Container(
                                            width: 357,
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            child: Center(
                                              child: Text(
                                                "Go Back To Home",
                                                style: TextStyle(fontFamily: "Inter, Regular", fontSize: 20, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
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
                  // onTap: () {
                  //   showDialog(
                  //     context: context,
                  //     builder: (_) => AlertDialog(
                  //       backgroundColor: Color(0xff000000B8),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       contentPadding: EdgeInsets.all(0),
                  //       actionsPadding: EdgeInsets.all(0),
                  //       actions: [
                  //         Stack(
                  //           clipBehavior: Clip.none,
                  //           alignment: AlignmentDirectional.center,
                  //           children: [
                  //             Container(
                  //               width: 320,
                  //               height: 222,
                  //               decoration: BoxDecoration(
                  //                   // border: Border.all(color: Colors.white),
                  //                   borderRadius: BorderRadius.circular(10),
                  //                   color: Color(0xffFEB038)),
                  //               child: ListView(
                  //                 children: [
                  //                   Column(
                  //                     mainAxisAlignment: MainAxisAlignment.end,
                  //                     children: [
                  //                       SizedBox(
                  //                         height: 67,
                  //                       ),
                  //                       Text(
                  //                         "Add To Cart",
                  //                         style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                  //                       ),
                  //                       SizedBox(
                  //                         height: 10,
                  //                       ),
                  //                       Text(
                  //                         "Item added to your cart",
                  //                         style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                  //                       ),
                  //                       // 15.verticalSpace,
                  //                       // Container(
                  //                       //   width: 270.w,
                  //                       //   height: 50.h,
                  //                       //   child: Text(
                  //                       //     "You will be contacted by the Owner via direct message to confirm!",
                  //                       //     textAlign: TextAlign.center,
                  //                       //     style: TextStyle(
                  //                       //       fontFamily: "Inter, Regular",
                  //                       //       fontSize: 15.sp,
                  //                       //       color: Colors.white,
                  //                       //     ),
                  //                       //   ),
                  //                       // ),
                  //                       SizedBox(
                  //                         height: 32,
                  //                       ),
                  //                       Row(
                  //                         children: [
                  //                           Container(
                  //                             width: 160,
                  //                             height: 51,
                  //                             decoration: BoxDecoration(
                  //                                 borderRadius: BorderRadius.only(
                  //                                   bottomLeft: Radius.circular(10),
                  //                                   // bottomRight:
                  //                                   //     Radius.circular(10.r),
                  //                                 ),
                  //                                 color: Colors.white),
                  //                             child: Center(
                  //                               child: Text(
                  //                                 "Continue Shopping",
                  //                                 style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                  //                               ),
                  //                             ),
                  //                           ),
                  //                           Container(
                  //                             width: 160,
                  //                             height: 51,
                  //                             decoration: BoxDecoration(
                  //                                 borderRadius: BorderRadius.only(
                  //                                   // bottomLeft:
                  //                                   //     Radius.circular(10.r),
                  //                                   bottomRight: Radius.circular(10),
                  //                                 ),
                  //                                 color: Colors.white),
                  //                             child: Center(
                  //                               child: Text(
                  //                                 "Go to cart",
                  //                                 style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ],
                  //                       ),
                  //                     ],
                  //                   )
                  //                   // Container(
                  //                   //   width: 357.w,
                  //                   //   height: 59.h,
                  //                   //   decoration: BoxDecoration(
                  //                   //     borderRadius: BorderRadius.only(
                  //                   //       topLeft: Radius.circular(10.r),
                  //                   //       topRight: Radius.circular(10.r),
                  //                   //     ),
                  //                   //     gradient: LinearGradient(
                  //                   //       begin: Alignment.bottomRight,
                  //                   //       end: Alignment.bottomLeft,
                  //                   //       colors: [
                  //                   //         Color(0xff00006A),
                  //                   //         Color(0xff4B4BFF)
                  //                   //       ],
                  //                   //     ),
                  //                   //   ),
                  //                   //   child: Row(
                  //                   //     children: [
                  //                   //       SizedBox(
                  //                   //         width: 145.w,
                  //                   //       ),
                  //                   //       Text(
                  //                   //         "Note",
                  //                   //         style: TextStyle(
                  //                   //           fontSize: 16.sp,
                  //                   //           color: Colors.white,
                  //                   //         ),
                  //                   //       ),
                  //                   //       SizedBox(
                  //                   //         width: 110.w,
                  //                   //       ),
                  //                   //       GestureDetector(
                  //                   //         onTap: () {
                  //                   //           Get.back();
                  //                   //         },
                  //                   //         child: Icon(
                  //                   //           Icons.close,
                  //                   //           color: Colors.white,
                  //                   //           size: 25,
                  //                   //         ),
                  //                   //       ),
                  //                   //     ],
                  //                   //   ),
                  //                   // ),

                  //                   // SizedBox(
                  //                   //   height: 10.h,
                  //                   // ),
                  //                   // Padding(
                  //                   //   padding: const EdgeInsets.symmetric(
                  //                   //       horizontal: 20),
                  //                   //   child: Column(children: [
                  //                   //     Text(
                  //                   //       "This kind of sensitive information are used by our company just to verify users. Once users get verified such information will be allowed to terminate by users themselves from our system for protecting users privacy data from unethical act. Our slogan No privacy data meaning nothing to worry about leak, hack and crack...",
                  //                   //       textAlign: TextAlign.center,
                  //                   //       style: TextStyle(
                  //                   //           fontSize: 12.sp,
                  //                   //           color: Colors.black),
                  //                   //     ),
                  //                   //     SizedBox(
                  //                   //       height: 50.h,
                  //                   //     ),
                  //                   //     GestureDetector(
                  //                   //       onTap: () {
                  //                   //         Get.to(() => licensephotoupload());
                  //                   //       },
                  //                   //       child: Container(
                  //                   //         width: 250.w,
                  //                   //         height: 59.h,
                  //                   //         decoration: BoxDecoration(
                  //                   //           border: Border.all(
                  //                   //               color: Colors.white),
                  //                   //           borderRadius:
                  //                   //               BorderRadius.circular(10.r),
                  //                   //           color: Color(0xff00006A),
                  //                   //         ),
                  //                   //         child: Center(
                  //                   //           child: Text(
                  //                   //             "Continue",
                  //                   //             style: TextStyle(
                  //                   //                 color: Colors.white,
                  //                   //                 fontSize: 16.sp),
                  //                   //           ),
                  //                   //         ),
                  //                   //       ),
                  //                   //     ),
                  //                   //   ]),
                  //                   // )
                  //                 ],
                  //               ),
                  //             ),
                  //             Positioned(
                  //                 top: -20,
                  //                 // left: 100,
                  //                 child: Container(
                  //                     width: 90,
                  //                     height: 90,
                  //                     decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffFEB038)),
                  //                     child: Center(
                  //                         child: Image.asset(
                  //                       "assets/slicing/smile@3x.png",
                  //                       scale: 5,
                  //                     ))))
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   );
                  // },
                  child: Center(
                    child: Container(
                      width: 380,
                      height: 58,
                      decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(
                          'Next',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: res_height * 0.02,
                ),
              ],
            ),
          ),
        ));
  }

  itemdtl(txth1) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: res_height * 0.01,
          ),
          Container(
            child: Row(
              children: [
                Container(
                  width: res_width * 0.25,
                  height: res_height * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 1,
                      bottom: 1,
                    ),
                    child: Image.asset('assets/slicing/Layer 7.png'),
                  ),
                ),
                SizedBox(width: res_width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apple 10.9-inch',
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                    Text(
                      '70,000',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: res_height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                txth1,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: res_height * 0.018,
          ),
          Center(
            child: Row(
              children: [
                // datebox(),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'Start Date',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Row(
                        children: [
                          Container(
                            height: res_height * 0.04,
                            width: res_width * 0.29,
                            child: Center(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Center(
                                    child: Text(
                                      '31/12/2021  ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              DateTime selectedDate = DateTime.now();

                              showDatePicker(
                                context: context,
                                initialDate: DateTime(2020),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2022),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: kprimaryColor, // header background color
                                        onPrimary: Colors.white, // header text color
                                        onSurface: kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              // if (picked != null && picked != selectedDate) {
                              //   setState(() {
                              //     selectedDate = picked;
                              //   });}
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: res_width * 0.06,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'End Date',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Row(
                        children: [
                          Container(
                            height: res_height * 0.04,
                            width: res_width * 0.29,
                            child: Center(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Center(
                                    child: Text(
                                      '31/12/2021  ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                          ),
                          SizedBox(
                            width: res_width * 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              DateTime selectedDate = DateTime.now();

                              showDatePicker(
                                context: context,
                                initialDate: DateTime(2020),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2022),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: kprimaryColor, // header background color
                                        onPrimary: Colors.white, // header text color
                                        onSurface: kprimaryColor, // body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: kprimaryColor, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              // if (picked != null && picked != selectedDate) {
                              //   setState(() {
                              //     selectedDate = picked;
                              //   });}
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey, width: 0.3)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // datebox(),
              ],
            ),
          ),
          SizedBox(
            height: res_height * 0.02,
          ),
        ],
      ),
    );
  }
}
