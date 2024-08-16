import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../../view_model/auth_view_model.dart';

class ForgetPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgetPasswordOtpScreen({super.key, this.email});

  @override
  State<ForgetPasswordOtpScreen> createState() => _ForgetPasswordOtpScreenState();
}

class _ForgetPasswordOtpScreenState extends State<ForgetPasswordOtpScreen> {
  OtpFieldController otpController = OtpFieldController();
  String? OtpValue;
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
          elevation: 0,
          backgroundColor: Colors.transparent,
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
                    Lottie.asset('assets/lottie/otp.json', width: res_width * 0.9, height: 200),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Center(
                      child: Text(
                        'OTP',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: darkBlue),
                      ),
                    ),
                    Align(
                      child: Text(
                        "Enter OTP for recovery",
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  children: [
                    Container(
                      child: Text(
                        "Email: " + widget.email.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.02,
              ),
              OTPTextField(
                controller: otpController,
                length: 4,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceEvenly,
                fieldWidth: 50,
                obscureText: true,
                fieldStyle: FieldStyle.box,
                otpFieldStyle: OtpFieldStyle(
                  backgroundColor: lightBlue,
                  borderColor: darkBlue,
                  enabledBorderColor: darkBlue,
                  focusBorderColor: darkBlue,
                ),
                outlineBorderRadius: 8,
                style: TextStyle(fontSize: 29, color: darkBlue),
                onChanged: (pin) {
                  print("Changed: " + pin);
                },
                onCompleted: (pin) {
                  print("Completed: " + pin);
                  OtpValue = pin;
                },
              ),
              SizedBox(
                height: res_height * 0.04,
              ),
              GestureDetector(
                onTap: () {
                  if (otpController.toString() == "null") {
                    Utils.flushBarErrorMessage("Please Enter Otp", context);
                  } else {
                    Map data = {"email": widget.email, "otp": OtpValue};
                    // log(data.toString());
                    authViewMode.otpForgetPasswordApi(data, context);
                  }

                  // Get.to(() => CreatePasswordScreen());
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
              SizedBox(
                height: res_height * 0.01,
              ),
              InkWell(
                onTap: () {
                  print("resend otp invoked");
                  Map data = {
                    'email': widget.email.toString(),
                  };
                  authViewMode.forgetPasswordApi(data, context, "forgot");
                },
                child: Container(
                  height: res_height * 0.055,
                  width: res_width * 0.5,
                  child: Center(
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, decoration: TextDecoration.underline),
                    ),
                  ),
                  // decoration: BoxDecoration(
                  //     color: kprimaryColor,
                  //     borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
