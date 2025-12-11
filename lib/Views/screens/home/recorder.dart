import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({Key? key}) : super(key: key);

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'recorder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(19.0),
        //     child: Container(
        //       child: Image.asset('assets/slicing/avatar.png'),
        //     ),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: res_width * 0.9,
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: kprimaryColor, width: 0.5),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.search_outlined),
                    hintText: "Search",
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),
              recrdBox(
                img: 'assets/slicing/h.jpg',
                txt: 'Apple 10.9-inch',
                price: '7000',
              ),

              // Container(
              //   width: res_width * 0.9,
              //   child: Row(
              //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Container(
              //         width: res_height * 0.12,
              //         child: Image.asset('assets/slicing/h.jpg'),
              //       ),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Apple 10.9-inch',
              //                   style: TextStyle(
              //                     fontSize: 15,
              //                     fontWeight: FontWeight.normal,
              //                   )),
              //               Text('\$ 7,000',
              //                   style: TextStyle(
              //                     fontSize: 13,
              //                     fontWeight: FontWeight.normal,
              //                   )),
              //             ],
              //           ),
              //           SizedBox(
              //             width: res_width * 0.3,
              //           ),
              //           ImageIcon(
              //             AssetImage(
              //               "assets/slicing/refresh-ccw.png",
              //             ),
              //             size: 20,
              //             color: Colors.black,
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  recrdBox({img, txt, price}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.9,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: res_height * 0.12, child: Image.asset('$img')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$txt',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '\$'
                    '$price',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(width: res_width * 0.3),
              ImageIcon(
                AssetImage("assets/slicing/refresh-ccw.png"),
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
