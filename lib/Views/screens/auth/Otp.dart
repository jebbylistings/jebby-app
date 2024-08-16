import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Services/provider/sign_in_provider.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
import '../../../view_model/auth_view_model.dart';

class OTPSCREEN extends StatefulWidget {
  final String? email;
  var name;
  var password;
  var role;
  final bool isGuestUserFlow;
  final bool fromPhoneAuth;
  final verificationId;
  final phoneNumber;
  bool _isLoading = false;

  OTPSCREEN(
      {super.key,
      this.email,
      this.name,
      this.password,
      this.role,
      this.isGuestUserFlow = false,
      this.fromPhoneAuth = false,
      this.verificationId = null,
      this.phoneNumber = null});

  @override
  State<OTPSCREEN> createState() => _OTPSCREENState();
}

class _OTPSCREENState extends State<OTPSCREEN> {
  OtpFieldController otpController = OtpFieldController();
  TextEditingController _otpController = TextEditingController();
  String? OtpValue;

  void initState() {
    print("email ${widget.email}");
    print("full_name ${widget.name}");
    print("password ${widget.password}");
    print("role ${widget.role}");
    super.initState();
  }

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
        body: SingleChildScrollView(
          child: Container(
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
                          'Verify OTP',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: darkBlue),
                        ),
                      ),
                      Align(
                        child: Text(
                          "Enter OTP for verification",
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
                          widget.fromPhoneAuth ? "Phone: " + widget.phoneNumber.toString() : "Email: " + widget.email.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: res_height * 0.02,
                ),
                !widget.fromPhoneAuth
                    ? OTPTextField(
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
                      )
                    : Container(
                        width: res_width * 0.9,
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.pin,
                              color: darkBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: darkBlue, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: darkBlue, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            filled: true,
                            hintStyle: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                            hintText: 'Enter 6 digits OTP',
                            fillColor: lightBlue,
                          ),
                          onChanged: (value) {},
                        ),
                      ),
                widget._isLoading ? Container() : SizedBox(
                  height: res_height * 0.04,
                ),
                widget._isLoading ? Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    color: darkBlue,
                  ),
                ) : Container(),
                GestureDetector(
                  onTap: () async {
                    if (widget.fromPhoneAuth) {
                      if (_otpController.text == "") {
                        Utils.flushBarErrorMessage("Please Enter Otp", context);
                      } else {
                        final sp = context.read<SignInProvider>();
                        widget._isLoading = true;
                        setState(() {});
                        await sp.signInWithPhoneCode(widget.verificationId, _otpController.text, context);
                        widget._isLoading = false;
                        setState(() {});
                      }
                    } else {
                      if (otpController.toString() == "null") {
                        Utils.flushBarErrorMessage("Please Enter Otp", context);
                      } else {
                        Map data = {"email": widget.email, "otp": OtpValue, "password": widget.password};
                        authViewMode.otpRegisterApi(data, context, isGuestUserFlow: widget.isGuestUserFlow);
                      }
                      // Get.to(() => CreatePasswordScreen());
                    }
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
                  onTap: () async {
                    if (widget.fromPhoneAuth) {
                      final sp = context.read<SignInProvider>();
                      await sp.signInWithPhone(widget.phoneNumber, context);
                    } else {
                      Map data = {
                        "email": widget.email.toString(),
                      };
                      var ob = data = {
                        "email": widget.email.toString(),
                      };
                      print(ob);
                      authViewMode.forgetPasswordApi(data, context, "register", isGuestUserFlow: widget.isGuestUserFlow);
                    }
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
                    // decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
