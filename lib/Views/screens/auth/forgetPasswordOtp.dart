import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/utils/utils.dart';
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
          image: AssetImage("assets/slicing/bg2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
             onTap: (){
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
              SizedBox(
                height: res_height * 0.175,
              ),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Otp',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  children: [
                    Container(
                      child: Text(
                       "Email: "+ widget.email.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  backgroundColor: Colors.white,
                  borderColor: kprimaryColor,
                  enabledBorderColor: kprimaryColor,
                  focusBorderColor: kprimaryColor,
                ),
                outlineBorderRadius: 8,
                style: TextStyle(fontSize: 29, color: Colors.black),
                onChanged: (pin) {
                  log(pin.toString());
                  print("Changed: " + pin);
                },
                onCompleted: (pin) {
                  print("Completed: " + pin);
                  OtpValue=pin;
                    log("????????????????????????"+OtpValue.toString());

                },
              

              ),
              SizedBox(
                height: res_height * 0.015,
              ),
              GestureDetector(
                onTap: () {
                  if (otpController.toString()=="null") {
                    Utils.flushBarErrorMessage("Please Enter Otp", context);
                  }else{
                     Map data = {
                          "email": widget.email,
                          "otp":OtpValue
                        };
                        // log(data.toString());
                        authViewMode.otpForgetPasswordApi(data , context);

                  }
                  
                 // Get.to(() => CreatePasswordScreen());
                },
                child: Container(
                  height: res_height * 0.065,
                  width: res_width * 0.9,
                  child: Center(
                    child: Text(
                      'Continue',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              SizedBox(
                height: res_height * 0.1,
              ),
             GestureDetector(
              onTap: (){
                print("resend otp invoked");
                Map data = {
                        'email' : widget.email.toString(),                    
                      };
                      authViewMode.forgetPasswordApi(data, context, "forgot");
              },
               child: Container(
                    height: res_height * 0.065,
                    width: res_width * 0.5,
                    child: Center(
                      child: Text(
                        'Resend OTP',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(14)),
                  ),
             ),
            ],
          ),
        ),
      ),
    );
  }
}
