import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';

class SetProfileScreen extends StatefulWidget {
  const SetProfileScreen({super.key});

  @override
  State<SetProfileScreen> createState() => _SetProfileScreenState();
}

class _SetProfileScreenState extends State<SetProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/slicing/bg3.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
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
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Set Profile",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkBlue),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: Image(
                              image: AssetImage("assets/slicing/blankuser_2.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          radius: 85,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // border: Border.all(
                          //     // color: Color(0xffbc7041),
                          //     )
                        ),
                      ),
                      Positioned(
                        top: 100,
                        bottom: 0,
                        right: 42,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                          child: RawMaterialButton(
                            onPressed: () {},
                            elevation: 1,
                            fillColor: darkBlue,
                            child: Icon(
                              Icons.upload,
                              color: Colors.white,
                              size: 20,
                            ),
                            // padding: EdgeInsets.all(2),
                            shape: CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(Icons.circle_notifications_outlined),
                  //     SizedBox(
                  //       width: res_width * 0.01,
                  //     ),
                  //     Container(
                  //       child: Text("User"),
                  //     ),
                  //     SizedBox(
                  //       width: res_width * 0.05,
                  //     ),
                  //     Icon(Icons.circle_notifications_outlined),
                  //     SizedBox(
                  //       width: res_width * 0.01,
                  //     ),
                  //     Container(
                  //       child: Text("Vender"),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Name'),
                      // SizedBox(
                      //   height: res_height * 0.01,
                      // ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          autocorrect: false,
                          // controller: userEmailController,
                          // validator: (text) {
                          //   if (text == null ||
                          //       text.isEmpty ||
                          //       !text.contains("@")) {
                          //     return 'Enter correct email';
                          //   }
                          //   return null;
                          // },
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: darkBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                              hintText: "Enter Name",
                              fillColor: lightBlue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Location'),
                      // SizedBox(
                      //   height: res_height * 0.01,
                      // ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          autocorrect: false,
                          // controller: userEmailController,
                          // validator: (text) {
                          //   if (text == null ||
                          //       text.isEmpty ||
                          //       !text.contains("@")) {
                          //     return 'Enter correct email';
                          //   }
                          //   return null;
                          // },
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_pin,
                                color: darkBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                              hintText: "Enter Location",
                              fillColor: lightBlue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Phone Number'),
                      // SizedBox(
                      //   height: res_height * 0.01,
                      // ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          autocorrect: false,
                          // controller: userEmailController,
                          // validator: (text) {
                          //   if (text == null ||
                          //       text.isEmpty ||
                          //       !text.contains("@")) {
                          //     return 'Enter correct email';
                          //   }
                          //   return null;
                          // },
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.phone,
                                color: darkBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: darkBlue, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                              hintText: "Enter Phone Number",
                              fillColor: lightBlue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MainScreen());
                    },
                    child: Container(
                      height: res_height * 0.055,
                      width: res_width * 0.9,
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
