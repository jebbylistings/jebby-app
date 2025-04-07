import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/home/Review1.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Store Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(child: Icon(Icons.share, color: Colors.black)),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SizedBox(height: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 400,
                      height: 136,
                      decoration: BoxDecoration(),
                      child: Image.asset("assets/slicing/Rectangle 546@3x.png"),
                    ),
                    Positioned(
                      left: 15,
                      bottom: -20,
                      child: Container(
                        child: CircleAvatar(
                          radius: 40,
                          child: Image.asset(
                            "assets/slicing/Ellipse 67@3x.png",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jackson",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "City,ST",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: 380,
                          child: Text(
                            "Lorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitanLorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 34,
                      width: 192,
                      child: Center(
                        child: Text(
                          'Unfollow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 34,
                      width: 192,
                      child: Center(
                        child: Text(
                          'Message',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Followesss(),
                SizedBox(height: 10),
                Reviewsss(),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      scrollss(),
                      scrollss(),
                      scrollss(),
                      scrollss(),
                      scrollss(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Menu",
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  width: 400,
                  height: 1,
                  color: Colors.grey.withAlpha(128),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "New Arrivals",
                          style: TextStyle(color: Colors.black, fontSize: 19),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Top products incredible price",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    itmBox(
                      img: 'assets/slicing/Layer 4@3x.png',
                      dx: '\$ 7000',
                      rv: '(2.9k Revews)',
                      tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                      rt: '4.9',
                    ),
                    itmBox(
                      img: 'assets/slicing/Layer 4@3x.png',
                      dx: '\$ 9000',
                      rv: '(2.9k Revews)',
                      tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                      rt: '4.9',
                    ),
                  ],
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Followesss() {
    return Container(
      width: 391,
      height: 74,
      decoration: BoxDecoration(
        color: Color(0xFF4285F4),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("0", style: TextStyle(color: kprimaryColor)),
                Text("Following", style: TextStyle(color: kprimaryColor)),
              ],
            ),
            SizedBox(width: 20),
            Container(width: 1, height: 40, color: kprimaryColor),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("2654", style: TextStyle(color: kprimaryColor)),
                Text("Followers", style: TextStyle(color: kprimaryColor)),
              ],
            ),
            SizedBox(width: 20),
            Container(width: 1, height: 40, color: kprimaryColor),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("265", style: TextStyle(color: kprimaryColor)),
                Text("Products", style: TextStyle(color: kprimaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Reviewsss() {
    return Row(
      children: [
        Text(
          "Reveiws",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Container(child: Icon(Icons.star, color: kprimaryColor)),
        SizedBox(width: 5),
        Text("4.9 (124)", style: TextStyle(fontSize: 16)),
        SizedBox(width: 110),
        GestureDetector(
          onTap: () {
            Get.to(() => ReviewTapScreen());
          },
          child: Container(
            child: Text("See All", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  scrollss() {
    return Container(
      width: 257,
      height: 135,
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  child: Image.asset(
                    "assets/slicing/20171102_MH_BOBSLED_1737 (1)-1@2x.png",
                    scale: 1.7,
                  ),
                ),
                SizedBox(width: 6),
                Container(child: Text("John Smith")),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star, color: kprimaryColor, size: 20),
                Icon(Icons.star, color: kprimaryColor, size: 20),
                Icon(Icons.star, color: kprimaryColor, size: 20),
                Icon(Icons.star, color: kprimaryColor, size: 20),
                Icon(Icons.star, color: kprimaryColor, size: 20),
                SizedBox(width: 5),
                Text("5.0", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Container(
              width: 200,
              child: Text(
                "Lorem ipsum dolor, adipiscingm dolor, adipiscingelit  elit, seda.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
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
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Image.asset('$img', fit: BoxFit.fill),
                ),
              ),
              SizedBox(height: res_height * 0.005),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tx', style: TextStyle(fontSize: 11)),
                    SizedBox(height: res_height * 0.006),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 11, color: kprimaryColor),
                        Icon(Icons.star, size: 11, color: kprimaryColor),
                        Icon(Icons.star, size: 11, color: kprimaryColor),
                        Icon(Icons.star, size: 11, color: kprimaryColor),
                        Icon(Icons.star, size: 11),
                        Text('$rt ', style: TextStyle(fontSize: 11)),
                        Text(
                          '$rv',
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
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
