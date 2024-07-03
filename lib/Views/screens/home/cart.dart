import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/home/OrderConfirmation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyCart extends StatefulWidget {
  const MyCart({Key? key}) : super(key: key);

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  bool _value = true;
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          "My Carts",
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontFamily: "My Carts"),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              mycartwidget(),
              SizedBox(
                height: 15,
              ),
              mycartwidget(),
              SizedBox(
                height: 15,
              ),
              mycartwidget(),
              SizedBox(
                height: 15,
              ),
              mycartwidget(),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _value = !_value;
                      });
                    },
                    child: Container(
                      height: 19,
                      width: 19,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _value ? Color(0xff303030) : Colors.black,
                              width: 3)),
                      child: Icon(
                        Icons.circle_rounded,
                        color: _value ? Colors.white : Colors.amber,
                        size: 12,
                      ),
                    ),
                  ),
                  Text(
                    "All",
                    style: TextStyle(
                        fontSize: 21,
                        fontFamily: "Inter, Light",
                        color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => OrderConfirmationScreen());
                    },
                    child: Container(
                      width: 310,
                      height: 58,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.amber),
                      child: Center(
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontFamily: "Inter, Bold"),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  mycartwidget() {
    return GestureDetector(
      onTap: () {
        Get.to(() => OrderConfirmationScreen());
      },
      child: Container(
        width: 391,
        height: 169,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 25,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 15,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Container(
                      width: 160,
                      height: 135,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 25,
                            offset: Offset(0, 5), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.asset("assets/slicing/Layer 4@3x.png"),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 162,
                            height: 34,
                            child: Text(
                              "Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Inter, Regular",
                                  color: Colors.black),
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "\$ 7,000",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontFamily: "Inter, Regular"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBar.builder(
                              itemSize: 15,
                              unratedColor: Colors.grey.withOpacity(0.5),
                              initialRating: 1,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star_purple500_outlined,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            Text(
                              "(2.5k Reviews)",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontFamily: "Inter, Regular"),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 19,
                              height: 19,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  "-",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "6",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 19,
                              height: 19,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  "+",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
