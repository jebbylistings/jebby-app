import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/StoreProfile.dart';


class FollowingStoresScreen extends StatefulWidget {
  const FollowingStoresScreen({super.key});

  @override
  State<FollowingStoresScreen> createState() => _FollowingStoresScreenState();
}

class _FollowingStoresScreenState extends State<FollowingStoresScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Following Stores",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              child: Icon(
                Icons.share,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => StoreProfileScreen());
                      },
                      child: Container(
                        child: Image.asset(
                          "assets/slicing/Ellipse 67@3x.png",
                          scale: 3.8,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => StoreProfileScreen());
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "JB Store",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                          Text(
                            "Verified Store",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                    ),
                    Container(
                      height: 34,
                      width: 113,
                      child: Center(
                        child: Text(
                          'Unfollow',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 370,
                  height: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
                boxx(),
                boxx(),
                boxx(),
                boxx(),
                boxx(),
                boxx(),
                boxx(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  boxx() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Container(
              child: Image.asset(
                "assets/slicing/Ellipse 67@3x.png",
                scale: 3.8,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JB Store",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Text(
                  "Verified Store",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ],
            ),
            SizedBox(
              width: 80,
            ),
            Container(
              height: 34,
              width: 113,
              child: Center(
                child: Text(
                  'Unfollow',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              decoration: BoxDecoration(
                  color: kprimaryColor, borderRadius: BorderRadius.circular(5)),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: 370,
          height: 1,
          color: Colors.grey.withOpacity(0.5),
        )
      ],
    );
  }
}
