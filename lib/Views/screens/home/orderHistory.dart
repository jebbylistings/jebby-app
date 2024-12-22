import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
// import 'package:jared/screens/home/profile/myprofile.dart';
import 'package:jared/Views/screens/profile/myprofile.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
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
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
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
              child: Icon(
                        Icons.person_outline,
                        color: Colors.black,
                        size: 25
                      )
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: res_width * 0.45,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Ongoing',
                              style: TextStyle(color: kprimaryColor),
                            ),
                          ),
                        ),
                        Container(
                          width: res_width * 0.44,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: res_width * 0.45,
                          child: TextButton(
                            style: ButtonStyle(
                              alignment: Alignment.center,
                            ),
                            onPressed: () {},
                            child: Text(
                              'History',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          width: res_width * 0.44,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.018,
              ),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: res_height * 0.035,
                      child: Image.asset('assets/slicing/line.png'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: res_height * 0.035,
                      child: Image.asset('assets/slicing/column.png'),
                    )
                  ],
                ),
              ),
              Container(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    itmBox(
                        img: 'assets/slicing/h.jpg',
                        dx: '\$ 7000',
                        rv: '(2.9k Revews)',
                        tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                        rt: '4.9'),
                    itmBox(
                        img: 'assets/slicing/h.jpg',
                        dx: '\$ 7000',
                        rv: '(2.9k Revews)',
                        tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                        rt: '4.9'),
                    itmBox(
                        img: 'assets/slicing/h.jpg',
                        dx: '\$ 7000',
                        rv: '(2.9k Revews)',
                        tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                        rt: '4.9'),
                    itmBox(
                        img: 'assets/slicing/h.jpg',
                        dx: '\$ 7000',
                        rv: '(2.9k Revews)',
                        tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                        rt: '4.9'),
                    itmBox(
                        img: 'assets/slicing/h.jpg',
                        dx: '\$ 7000',
                        rv: '(2.9k Revews)',
                        tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                        rt: '4.9'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  itmBox({img, tx, dx, rt, rv}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        // Get.to(() => ProductDetailScreen());
      },
      child: Container(
        width: res_width * 0.44,
        // height: res_height * 0.28,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        // child: Padding(
        //   padding: const EdgeInsets.only(
        //       bottom: 120, left: 10, right: 10, top: 10),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: res_height * 0.2,
                decoration: BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: Image.asset(
                    '$img',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                height: res_height * 0.005,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$tx',
                      style: TextStyle(fontSize: 11),
                    ),
                    SizedBox(
                      height: res_height * 0.006,
                    ),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 11,
                          color: kprimaryColor,
                        ),
                        Icon(
                          Icons.star,
                          size: 11,
                          color: kprimaryColor,
                        ),
                        Icon(
                          Icons.star,
                          size: 11,
                          color: kprimaryColor,
                        ),
                        Icon(
                          Icons.star,
                          size: 11,
                          color: kprimaryColor,
                        ),
                        Icon(Icons.star, size: 11),
                        Text(
                          '$rt ',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          '$rv',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
