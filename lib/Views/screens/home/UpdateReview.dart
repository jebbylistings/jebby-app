import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

import '../../../res/app_url.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // floatingActionButton: Column(children: [
      //   SizedBox(
      //     height: Get.height * 0.90,
      //   ),
      //   Container(
      //     width: 392,
      //     height: 62,
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(31),
      //       // boxShadow: [
      //       //   BoxShadow(
      //       //     color: Color(0xff00FFA3),
      //       //     spreadRadius: 0,
      //       //     blurRadius: 6,
      //       //     offset: Offset(0, 1), // changes position of shadow
      //       //   ),
      //       // ],
      //     ),
      //     child: FloatingActionButton.extended(
      //       onPressed: () {},
      //       label: Text(
      //         'Continue',
      //         style: TextStyle(
      //             fontSize: 20,
      //             color: Colors.black,
      //             fontFamily: "Sora, ExtraBold"),
      //       ),
      //       // icon: Icon(Icons.thumb_up),
      //       backgroundColor: Colors.amber,
      //     ),
      //   ),
      // ]),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          child: Text(
            "Reviews",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Text(
              //   "4.0",
              //   style: TextStyle(
              //       fontSize: 40,
              //       fontWeight: FontWeight.bold,
              //       color: Colors.black),
              // ),
              // RatingBar.builder(
              //   itemSize: 20,
              //   unratedColor: Colors.grey.withOpacity(0.5),
              //   initialRating: 1,
              //   minRating: 1,
              //   direction: Axis.horizontal,
              //   allowHalfRating: true,
              //   itemCount: 5,
              //   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              //   itemBuilder: (context, _) => Icon(
              //     Icons.star_purple500_outlined,
              //     color: Colors.amber,
              //   ),
              //   onRatingUpdate: (rating) {
              //   },
              // ),
              // SizedBox(
              //   height: 5,
              // ),
              // Text(
              //   "Based on 450 reviews",
              //   style: TextStyle(fontSize: 18, color: Colors.black),
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              // Column(
              //   children: [
              //     progresswidget(
              //       variation: "Excellent",
              //       progressbarcolor: Colors.green,
              //       progressnumber: 80,
              //     ),
              //     progresswidget(
              //       progressnumber: 70,
              //       variation: "Good",
              //       progressbarcolor: Color(0xffB6FF6F),
              //     ),
              //     progresswidget(
              //       progressnumber: 60,
              //       variation: "Averrage",
              //       progressbarcolor: Colors.yellow,
              //     ),
              //     progresswidget(
              //       progressnumber: 50,
              //       variation: "Below Averrage",
              //       progressbarcolor: Colors.orange,
              //     ),
              //     progresswidget(
              //       progressnumber: 40,
              //       variation: "Poor",
              //       progressbarcolor: Colors.red,
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 30,
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Reviews",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    SizedBox(width: 5),
                    // Icon(
                    //   Icons.star,
                    //   color: Colors.amber,
                    //   size: 15,
                    // ),
                    // SizedBox(
                    //   width: 15,
                    // ),
                    Text(
                      "(${ApiRepository.shared.getAllReviewsByVendorIdModelList!.totalreviews.toString()})",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    // SizedBox(
                    //   width: 135,
                    // ),
                    // Text(
                    //   "See All",
                    //   style: TextStyle(fontSize: 18, color: Colors.black),
                    // )
                  ],
                ),
              ),
              SizedBox(height: 25),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    ApiRepository
                        .shared
                        .getAllReviewsByVendorIdModelList!
                        .data!
                        .length,
                itemBuilder: (context, int index) {
                  var image =
                      ApiRepository
                          .shared
                          .getAllReviewsByVendorIdModelList!
                          .data![index]
                          .image
                          .toString();
                  var stars =
                      ApiRepository
                          .shared
                          .getAllReviewsByVendorIdModelList!
                          .data![index]
                          .stars
                          .toString();
                  var desc =
                      ApiRepository
                          .shared
                          .getAllReviewsByVendorIdModelList!
                          .data![index]
                          .description
                          .toString();
                  var name =
                      ApiRepository
                          .shared
                          .getAllReviewsByVendorIdModelList!
                          .data![index]
                          .userName
                          .toString();
                  return reviewwidgetdart(
                    image: image,
                    name: name,
                    stars: stars,
                    desc: desc,
                  );
                },
              ),
              // reviewwidgetdart(),
              // SizedBox(
              //   height: 20,
              // ),
              // reviewwidgetdart(),
              // SizedBox(
              //   height: 20,
              // ),
              // reviewwidgetdart(),
              // SizedBox(
              //   height: 100,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class reviewwidgetdart extends StatelessWidget {
  final dynamic image;
  final dynamic name;
  final dynamic stars;
  final dynamic desc;
  reviewwidgetdart({this.image, this.name, this.stars, this.desc});

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: res_height * 0.209,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(AppUrl.baseUrlM + image),
                    ),
                    SizedBox(width: res_width * 0.02),
                    SizedBox(
                      width: res_width * 0.8,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: res_height * 0.010),
                Container(
                  width: res_width * 0.73,
                  child: Row(
                    children: [
                      RatingBarIndicator(
                        rating: double.parse(stars.toString()),
                        itemBuilder:
                            (context, index) =>
                                Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 15,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(width: 5),
                      Text(
                        stars,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(width: res_width * 0.72, child: Text(desc)),
              ],
            ),
          ),
        ),
        SizedBox(height: res_height * 0.02),
      ],
    );
  }
}

class progresswidget extends StatelessWidget {
  final String variation;
  final dynamic progressbarcolor;
  final double progressnumber;
  progresswidget({
    required this.progressnumber,
    required this.variation,
    required this.progressbarcolor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 100,
          height: 20,
          child: Text(
            variation,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        Container(
          width: 240,
          height: 8,
          child: FAProgressBar(
            currentValue: progressnumber,
            // displayText: '50%',
            animatedDuration: Duration(milliseconds: 600),
            // direction: Axis.horizontal,
            // verticalDirection: VerticalDirection.down,
            backgroundColor: Colors.grey,
            progressColor: progressbarcolor,
          ),
        ),
      ],
    );
  }
}
