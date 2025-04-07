import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/screens/home/TypeReviews.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class ReviewTapScreen extends StatefulWidget {
  const ReviewTapScreen({super.key});

  @override
  State<ReviewTapScreen> createState() => _ReviewTapScreenState();
}

class _ReviewTapScreenState extends State<ReviewTapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        children: [
          SizedBox(height: Get.height * 0.90),
          Container(
            width: 392,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(31),
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0xff00FFA3),
              //     spreadRadius: 0,
              //     blurRadius: 6,
              //     offset: Offset(0, 1), // changes position of shadow
              //   ),
              // ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => TypeReviewsScreen());
              },
              label: Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: "Sora, ExtraBold",
                ),
              ),
              // icon: Icon(Icons.thumb_up),
              backgroundColor: Colors.amber,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "4.0",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              RatingBar.builder(
                itemSize: 20,
                unratedColor: Colors.grey.withAlpha(128),
                initialRating: 1,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder:
                    (context, _) => Icon(
                      Icons.star_purple500_outlined,
                      color: Colors.amber,
                    ),
                onRatingUpdate: (rating) {},
              ),
              SizedBox(height: 5),
              Text(
                "Based on 450 reviews",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  progresswidget(
                    variation: "Excellent",
                    progressbarcolor: Colors.green,
                    progressnumber: 80,
                  ),
                  progresswidget(
                    progressnumber: 70,
                    variation: "Good",
                    progressbarcolor: Color(0xffB6FF6F),
                  ),
                  progresswidget(
                    progressnumber: 60,
                    variation: "Averrage",
                    progressbarcolor: Colors.yellow,
                  ),
                  progresswidget(
                    progressnumber: 50,
                    variation: "Below Averrage",
                    progressbarcolor: Colors.orange,
                  ),
                  progresswidget(
                    progressnumber: 40,
                    variation: "Poor",
                    progressbarcolor: Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 30),
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
                    Icon(Icons.star, color: Colors.amber, size: 15),
                    SizedBox(width: 15),
                    Text(
                      "4.9 (124)",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(width: 110),
                    Text(
                      "See All",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              reviewwidgetdart(),
              SizedBox(height: 20),
              reviewwidgetdart(),
              SizedBox(height: 20),
              reviewwidgetdart(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class reviewwidgetdart extends StatelessWidget {
  const reviewwidgetdart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 398,
      height: 209,
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    "assets/slicing/20171102_MH_BOBSLED_1737 (1)-1@2x.png",
                  ),
                ),
                SizedBox(width: 17),
                Text(
                  "John Smith",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                RatingBar.builder(
                  itemSize: 20,
                  unratedColor: Colors.grey.withAlpha(128),
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) => Icon(
                        Icons.star_purple500_outlined,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (rating) {},
                ),
                SizedBox(width: 5),
                Text(
                  "5.0",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              width: 327,
              height: 54,
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              ),
            ),
          ],
        ),
      ),
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
