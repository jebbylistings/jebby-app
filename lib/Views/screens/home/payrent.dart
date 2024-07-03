import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/addCard.dart';
import 'package:jared/Views/screens/home/chat.dart';
import 'package:jared/Views/screens/home/home.dart';

class PayRent extends StatefulWidget {
  const PayRent({Key? key}) : super(key: key);

  @override
  State<PayRent> createState() => _PayRentState();
}

class _PayRentState extends State<PayRent> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            itemdtl(),
            SizedBox(
              height: res_height * 0.02,
            ),
            Center(
              child: Divider(
                // height: 20,
                thickness: 0.4,
                indent: 14,
                endIndent: 14,
                color: Colors.grey,
              ),
            ),
            itemdtl(),
            SizedBox(
              height: res_height * 0.1,
            ),
            Center(
              child: Divider(
                // height: 20,
                thickness: 0.4,
                indent: 14,
                endIndent: 14,
                color: Colors.grey,
              ),
            ),
            itemdtl(),
            SizedBox(
              height: res_height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => AddCardScreen());
                  },
                  child: Container(
                    width: res_width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Center(
                        child: Text(
                          'Add New Card/Pay',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  width: res_width * 0.01,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => HomeScreen());
                  },
                  child: Container(
                    width: res_width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Center(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: res_height * 0.1,
            ),
          ],
        ),
      ),
    );
  }

  itemdtl() {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
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
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 19),
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
            height: res_height * 0.012,
          ),
          SizedBox(
            height: res_height * 0.015,
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
                          'Rent Start',
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3)),
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
                                        primary:
                                            kprimaryColor, // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface:
                                            kprimaryColor, // body text color
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
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child:
                                    Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3)),
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
                          'Original Return',
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: Colors.grey, width: 0.3)),
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
                                        primary:
                                            kprimaryColor, // header background color
                                        onPrimary:
                                            Colors.white, // header text color
                                        onSurface:
                                            kprimaryColor, // body text color
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
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child:
                                    Image.asset('assets/slicing/calender.png'),
                              ),
                              height: res_height * 0.04,
                              width: res_width * 0.11,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3)),
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
          GestureDetector(
            onTap: () {
              Get.to(() => Chat(""));
            },
            child: Container(
              width: res_width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Text('Write a message'),
                  ),
                  SizedBox(
                    width: res_width * 0.02,
                  ),
                  Container(
                    height: res_height * 0.02,
                    child: Image.asset('assets/slicing/mesage.png'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

//   datebox() {
//     double res_width = MediaQuery.of(context).size.width;
//     double res_height = MediaQuery.of(context).size.height;
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             child: Text(
//               'Rent Start',
//               style: TextStyle(fontSize: 17),
//             ),
//           ),
//           Row(
//             children: [
//               Container(
//                 height: res_height * 0.04,
//                 width: res_width * 0.29,
//                 child: Center(
//                     child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(right: 3),
//                       child: Center(
//                         child: Text(
//                           '31/12/2021',
//                           style: TextStyle(fontSize: 10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(7),
//                     border: Border.all(color: Colors.grey, width: 0.3)),
//               ),
//               SizedBox(
//                 width: res_width * 0.01,
//               ),
//               Container(
//                 child: Padding(
//                   padding: const EdgeInsets.all(6.0),
//                   child: Image.asset('assets/slicing/calender.png'),
//                 ),
//                 height: res_height * 0.04,
//                 width: res_width * 0.11,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(7),
//                     border: Border.all(color: Colors.grey, width: 0.3)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
}
