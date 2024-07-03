import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
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
          'Add Card',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
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
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: res_height * 0.1,
                      width: res_width * 0.2,
                      child: Image.asset('assets/slicing/visa.png'),
                    ),
                    Container(
                      height: res_height * 0.1,
                      width: res_width * 0.2,
                      child: Image.asset('assets/slicing/paypal.png'),
                    ),
                    Container(
                      height: res_height * 0.1,
                      width: res_width * 0.2,
                      child: Image.asset('assets/slicing/apple-pay.png'),
                    ),
                  ],
                ),
              ),
              Container(
                height: res_height * 0.25,
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 200, 200, 200),
                  // shape: BoxShape.rectangle,
                  border: Border.all(
                    color: kprimaryColor,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Container(
                    // height: res_height * 0.23,
                    // width: res_width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: res_width * 0.7,
                          child: Text('THE BANK OF ANYTHING'),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          height: res_height * 0.04,
                          width: res_width * 0.08,
                          child: Image.asset('assets/slicing/chip1.png'),
                        ),
                        Row(
                          children: [
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              width: res_width * 0.05,
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              width: res_width * 0.05,
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              '.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              width: res_width * 0.05,
                            ),
                            Text(
                              '2',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '5',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '4',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '1',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),

                            // Text('THE BANK OF ANYTHING'),
                            // Text('THE BANK OF ANYTHING'),
                          ],
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Row(
                          children: [
                            Text(
                              '3/18',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(
                              width: res_width * 0.09,
                            ),
                            Text(
                              '3/28',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name on Card',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                            Container(
                              height: res_height * 0.05,
                              width: res_width * 0.08,
                              child: Image.asset(
                                  'assets/slicing/mastercard-logo.png'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: res_height * 0.015,
              ),
              Container(
                width: res_width * 0.9,
                child: Row(
                  children: [
                    Text(
                      'Name',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: res_width * 0.9,
                child: TextField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    hintText: "******* ******* ******* 123456",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ),
              // Container(
              //   height: res_height * 0.08,
              //   width: res_width * 0.9,
              //   // decoration: BoxDecoration(
              //   //   border: Border.all(color: kprimaryColor),
              //   //   borderRadius: BorderRadius.circular(20),
              //   // ),
              //   child: TextField(
              //     decoration: InputDecoration(
              //         enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(15.0),
              //             borderSide:
              //                 BorderSide(color: kprimaryColor, width: 0.5)),
              //         filled: true,
              //         hintStyle: TextStyle(color: Colors.grey),
              //         suffixIcon: Icon(Icons.search_outlined),
              //         hintText: "******* ******* ******* 123456",
              //         fillColor: Colors.white),
              //   ),
              // ),
              Container(
                width: res_width * 0.9,
                child: Row(
                  children: [
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: res_width * 0.9,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Will Smith",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: kprimaryColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ),
              // Container(
              //   height: res_height * 0.08,
              //   width: res_width * 0.9,
              //   // decoration: BoxDecoration(
              //   //   border: Border.all(color: kprimaryColor),
              //   //   borderRadius: BorderRadius.circular(20),
              //   // ),
              //   child: TextField(
              //     decoration: InputDecoration(
              //         enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(15.0),
              //             borderSide:
              //                 BorderSide(color: kprimaryColor, width: 0.5)),
              //         filled: true,
              //         hintStyle: TextStyle(color: Colors.grey),
              //         suffixIcon: Icon(Icons.search_outlined),
              //         hintText: "Will Smith",
              //         fillColor: Colors.white),
              //   ),
              // ),
              SizedBox(
                height: res_height * 0.01,
              ),
              Container(
                width: res_width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: res_width * 0.3,
                      // color: Colors.red,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expiry Date'),
                          Container(
                            height: res_height * 0.08,
                            width: res_width * 0.3,
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: kprimaryColor),
                            //   borderRadius: BorderRadius.circular(20),
                            // ),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: "10/25",
                                  fillColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: res_width * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CVV'),
                          Container(
                            height: res_height * 0.08,
                            width: res_width * 0.3,
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: kprimaryColor),
                            //   borderRadius: BorderRadius.circular(20),
                            // ),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: "10/25",
                                  fillColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.01,
              ),

              GestureDetector(
                onTap: (() {
                  Get.back();
                }),
                child: Container(
                  height: res_height * 0.06,
                  width: res_width * 0.8,
                  child: Center(
                    child: Text(
                      'Add',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              // Container(
              //   width: res_width * 0.7,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       // Text(
              //       //   '10/25',
              //       //   style: TextStyle(
              //       //     color: Colors.grey,
              //       //   ),
              //       // ),
              //       // Text(
              //       //   '10/25',
              //       //   style: TextStyle(
              //       //     color: Colors.grey,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // Container(
              //   child: Row(
              //     children: [
              //       Container(
              //         width: res_width * 0.01,
              //         decoration: BoxDecoration(
              //             border: Border.all(color: Colors.grey, width: 10)),
              //       )
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
