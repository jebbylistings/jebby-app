import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypeReviewsScreen extends StatefulWidget {
  const TypeReviewsScreen({super.key});

  @override
  State<TypeReviewsScreen> createState() => _TypeReviewsScreenState();
}

class _TypeReviewsScreenState extends State<TypeReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Type Reviews",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Contbox(),
                SizedBox(
                  height: 33,
                ),
                Container(
                  child: Text(
                    " Give A Star,",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Container(
                  child: Image.asset(
                    "assets/slicing/Group 126@3x.png",
                    scale: 4,
                  ),
                ),
                SizedBox(
                  height: 33,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Add Photos",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 398,
                      height: 98,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(10),
                        dashPattern: [5, 5],
                        color: Colors.grey,
                        strokeWidth: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Image.asset(
                                    "assets/slicing/Group 128@3x.png",
                                    scale: 2.5,
                                  ),
                                )
                                // Image(
                                //   image: AssetImage(
                                //       'assets/slicing/Group 128@3x.png',),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          child: Text(
                            "Write a review",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 209,
                      width: 398,
                      decoration: BoxDecoration(
                          color: Color(0xffE6E6E6),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    SizedBox(
                      height: 68,
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
                                    height: 240,
                                    decoration: BoxDecoration(
                                        // border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xffFEB038)),
                                    child: ListView(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              height: 80,
                                            ),
                                            Text(
                                              "Review",
                                              style: TextStyle(
                                                  fontFamily: "Inter, Bold",
                                                  fontSize: 30,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            // Text(
                                            //   "Your Order Has Been Received",
                                            //   style: TextStyle(
                                            //       fontFamily: "Inter, Regular",
                                            //       fontSize: 19.sp,
                                            //       color: Colors.white),
                                            // ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: 250,
                                              height: 50,
                                              child: Text(
                                                "Your review post successfully",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "Inter, Regular",
                                                  fontSize: 19,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () async{
                                                SharedPreferences sp=await SharedPreferences.getInstance();
                                                String? id= await sp.getString("id");

                                                Get.to(() => MyProfileScreen());
                                              },
                                              child: Container(
                                                width: 320,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                    color: Colors.white),
                                                child: Center(
                                                  child: Text(
                                                    "Go Back To Home",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "Inter, Regular",
                                                        fontSize: 20,
                                                        color: Colors.black),
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
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffFEB038)),
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
                      child: Container(
                        height: 58,
                        width: 371,
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: kprimaryColor,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Contbox() {
    return Column(
      children: [
        Container(
          width: 391,
          height: 169,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.asset("assets/slicing/Layer 4@3x.png"),
                    ),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 159,
                              child: Text(
                                "Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB",
                                style: TextStyle(fontSize: 14),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "\$ 7,000",
                            style: TextStyle(fontSize: 14),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: kprimaryColor,
                              ),
                              Icon(
                                Icons.star,
                                color: kprimaryColor,
                              ),
                              Icon(
                                Icons.star,
                                color: kprimaryColor,
                              ),
                              Icon(
                                Icons.star,
                                color: kprimaryColor,
                              ),
                              Icon(
                                Icons.star,
                              ),
                              // Text(
                              //   "\$ 15.59",
                              //   style: TextStyle(
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.bold),
                              // ),

                              Text(
                                "(2.5k Reviews)",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     Container(
                //       height: 44,
                //       width: 170,
                //       child: Center(
                //         child: Text(
                //           'Type Review',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 19),
                //         ),
                //       ),
                //       decoration: BoxDecoration(
                //           color: kprimaryColor,
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //     Container(
                //       height: 44,
                //       width: 170,
                //       child: Center(
                //         child: Text(
                //           'Reorder',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 19),
                //         ),
                //       ),
                //       decoration: BoxDecoration(
                //           color: kprimaryColor,
                //           borderRadius: BorderRadius.circular(5)),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
