import 'package:jebby/Views/screens/mainfolder/homemain.dart';
import 'package:jebby/res/app_url.dart';
import 'package:jebby/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProviderFeedback extends StatefulWidget {
  ProviderFeedback();

  @override
  State<ProviderFeedback> createState() => _ProviderFeedbackState();
}

class _ProviderFeedbackState extends State<ProviderFeedback> {
  late double ratings;
  TextEditingController NameController = TextEditingController();
  TextEditingController EmailController = TextEditingController();
  TextEditingController FeedbackController = TextEditingController();
  var uid;

  Future getGalleryImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (pickedImage != null) {
      } else {}
    });
  }

  void getpre() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    NameController.text = s.getString('fullname').toString();
    EmailController.text = s.getString('email').toString();
  }

  @override
  void initState() {
    getpre();
    super.initState();
  }

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
          'Feedback',
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
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: res_width * 0.9,
                child: Column(
                  children: [
                    SizedBox(height: res_height * 0.05),
                    // Text(
                    //   'Add Rating',
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.bold, fontSize: 37),
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.02,
                    // ),
                    // RatingBar.builder(
                    //   initialRating: double.parse(widget.stars.toString()),
                    //   minRating: 1,
                    //   direction: Axis.horizontal,
                    //   allowHalfRating: true,
                    //   itemCount: 5,
                    //   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    //   itemBuilder: (context, _) => Icon(
                    //     Icons.star,
                    //     color: Colors.amber,
                    //   ),
                    //   onRatingUpdate: (rating) {
                    //     setState(() {
                    //       ratings = rating;
                    //     });
                    //   },
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.05,
                    // ),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'Add Photo or Video',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.normal,
                    //         color: Colors.grey,
                    //         fontSize: 23,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.02,
                    // ),
                    // Container(
                    //   width: res_width * 0.9,
                    //   height: res_height * 0.2,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: kprimaryColor,
                    //       width: 0.5,
                    //     ),
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    //   child: Container(
                    //       width: res_width * 0.2,
                    //       height: res_height * 0.15,
                    //       child: _image == null
                    //           ? InkWell(
                    //               onTap: getGalleryImage,
                    //               child: Icon(
                    //                 Icons.cloud_upload_rounded,
                    //                 size: 25,
                    //               ),
                    //             )
                    //           : Image.file(
                    //               File(_image!.path),
                    //               fit: BoxFit.contain,
                    //             )),
                    // ),
                    // SizedBox(
                    //   height: res_height * 0.02,
                    // ),
                    Row(
                      children: [
                        Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      // constraints: BoxConstraints(
                      //   minWidth: MediaQuery.of(context).size.width * 0.85,
                      //   minHeight: MediaQuery.of(context).size.height * 0.1,
                      //   maxWidth: MediaQuery.of(context).size.width * 0.85,
                      //   maxHeight: MediaQuery.of(context).size.height * 0.2,
                      // ),
                      child: TextField(
                        readOnly: true,
                        controller: NameController,
                        decoration: InputDecoration(
                          hintText: "Enter Name",
                          hintStyle: TextStyle(
                            color:
                                Colors
                                    .grey, // Set the desired hint text color here
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.02),
                    Row(
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      // constraints: BoxConstraints(
                      //   minWidth: MediaQuery.of(context).size.width * 0.85,
                      //   minHeight: MediaQuery.of(context).size.height * 0.1,
                      //   maxWidth: MediaQuery.of(context).size.width * 0.85,
                      //   maxHeight: MediaQuery.of(context).size.height * 0.2,
                      // ),
                      child: TextField(
                        readOnly: true,
                        controller: EmailController,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          hintStyle: TextStyle(
                            color:
                                Colors
                                    .grey, // Set the desired hint text color here
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.02),
                    Row(
                      children: [
                        Text(
                          'Comment',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: res_height * 0.01),
                    Container(
                      // constraints: BoxConstraints(
                      //   minWidth: MediaQuery.of(context).size.width * 0.85,
                      //   minHeight: MediaQuery.of(context).size.height * 0.1,
                      //   maxWidth: MediaQuery.of(context).size.width * 0.85,
                      //   maxHeight: MediaQuery.of(context).size.height * 0.2,
                      // ),
                      child: TextField(
                        // maxLength: 500,
                        maxLines: null,
                        controller: FeedbackController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Enter Comment",
                          hintStyle: TextStyle(
                            color:
                                Colors
                                    .grey, // Set the desired hint text color here
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: kprimaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: res_height * 0.04),
                    GestureDetector(
                      onTap: () async {
                        final SharedPreferences s =
                            await SharedPreferences.getInstance();
                        if (NameController.text.toString().isNotEmpty &&
                            EmailController.text.toString().isNotEmpty &&
                            FeedbackController.text.toString().isNotEmpty) {
                          var data = {
                            "user_id": s.getString('id'),
                            "name": NameController.text,
                            "email": EmailController.text,
                            "comments": FeedbackController.text,
                          };
                          FeedbackApi(data);
                        } else {
                          final snackBar = new SnackBar(
                            content: new Text("Fields Cannot Be Empty"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        height: res_height * 0.06,
                        width: res_width * 0.8,
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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

  void FeedbackApi(data) async {
    final String FeedbackUrl = '${AppUrl.baseUrlM}/feedback';
    try {
      final response = await http.post(
        Uri.parse(FeedbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      final responseBody = jsonDecode(response.body);
      if (responseBody["message"].toString() == 'Inserted') {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                backgroundColor: Color(0xff000000B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.all(0),
                actionsPadding: EdgeInsets.all(0),
                actions: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        width: 320,
                        height: 222,
                        decoration: BoxDecoration(
                          // border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffFEB038),
                        ),
                        child: ListView(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 67),
                                Text(
                                  "Feedback",
                                  style: TextStyle(
                                    fontFamily: "Inter, Bold",
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 250,
                                  child: Center(
                                    child: Text(
                                      "Your feedback has been submitted",
                                      style: TextStyle(
                                        fontFamily: "Inter, Regular",
                                        fontSize: 19,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // 15.verticalSpace,
                                // Container(
                                //   width: 270.w,
                                //   height: 50.h,
                                //   child: Text(
                                //     "You will be contacted by the Owner via direct message to confirm!",
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //       fontFamily: "Inter, Regular",
                                // fontSize: 15.sp,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(height: 18),
                                Row(
                                  children: [
                                    SizedBox(),
                                    // Container(
                                    //   width: 160,
                                    //   height: 51,
                                    //   decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.only(
                                    //         bottomLeft: Radius.circular(10),
                                    //         // bottomRight:
                                    //         //     Radius.circular(10.r),
                                    //       ),
                                    //       color: Colors.white),
                                    //   child: GestureDetector(
                                    //     onTap: () {
                                    //       Get.back();
                                    //     },
                                    //     child: Center(
                                    //       child: Text(
                                    //         "No",
                                    //         style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Container(
                                      width: 312,
                                      height: 51,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          // bottomLeft:
                                          //     Radius.circular(10.r),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // NameController.clear();
                                              // EmailController.clear();
                                              FeedbackController.clear();
                                              // Get.back();
                                              Get.to(() => MainScreen());
                                            });
                                            // ApiRepository.shared.deleteProductsById(prodID);
                                            // final bottomcontroller = Get.put(BottomController());
                                            // bottomcontroller.navBarChange(1);
                                          },
                                          child: Container(
                                            child: Text(
                                              "Okay",
                                              style: TextStyle(
                                                fontFamily: "Inter, Regular",
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -20,
                        // left: 100,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffFEB038),
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/slicing/smile@3x.png",
                              scale: 5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        );
        // Utils.toastMessage('Feedback form has been submitted');
      } else {
        Utils.flushBarErrorMessage(responseBody["message"].toString(), context);
      }
    } catch (err) {
      Utils.flushBarErrorMessage(
        'Something went wrong plz check your internet connection',
        context,
      );
    }
  }
}
