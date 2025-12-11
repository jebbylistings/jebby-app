import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
import '../../../view_model/auth_view_model.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewMode = Provider.of<AuthViewModel>(context);

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            borderRadius: BorderRadius.circular(50),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              // SizedBox(
              //   height: res_height * 0.175,
              // ),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Lottie.asset(
                        'assets/lottie/forget_password.json',
                        width: res_width * 0.9,
                        height: 200,
                      ),
                    ),
                    SizedBox(height: res_height * 0.04),
                    Center(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: darkBlue,
                        ),
                      ),
                    ),
                    Align(
                      child: Text(
                        "Can't remember your password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Email'),
                  // SizedBox(
                  //   height: res_height * 0.01,
                  // ),
                  Container(
                    width: res_width * 0.9,
                    child: TextFormField(
                      controller: _emailController,
                      autocorrect: false,
                      // controller: userEmailController,
                      validator: (text) {
                        if (text == null ||
                            text.isEmpty ||
                            !text.contains("@")) {
                          return 'Enter correct email';
                        }
                        return null;
                      },
                      style: TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: darkBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: darkBlue,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: darkBlue,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: "Enter Your Email Address",
                        fillColor: lightBlue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: res_height * 0.04),
              InkWell(
                onTap: () {
                  if (_emailController.text.isEmpty) {
                    Utils.flushBarErrorMessage('Please enter email', context);
                  } else {
                    Map data = {'email': _emailController.text.toString()};
                    authViewMode.forgetPasswordApi(data, context, "forgot");
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  height: res_height * 0.055,
                  width: res_width * 0.9,
                  child: Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
