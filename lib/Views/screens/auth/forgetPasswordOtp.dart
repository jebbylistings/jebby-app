import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/utils/utils.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../../view_model/auth_view_model.dart';

class ForgetPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgetPasswordOtpScreen({super.key, this.email});

  @override
  State<ForgetPasswordOtpScreen> createState() =>
      _ForgetPasswordOtpScreenState();
}

class _ForgetPasswordOtpScreenState extends State<ForgetPasswordOtpScreen> {
  OtpFieldController otpController = OtpFieldController();
  String? OtpValue;

  @override
  Widget build(BuildContext context) {
    final authViewMode = Provider.of<AuthViewModel>(context);
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    final sentTo = widget.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.chevron_left, color: Colors.black, size: 28),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(48, 48),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: res_height * 0.02),
              Center(
                child: Image.asset(
                  'assets/slicing/otp.png',
                  width: res_width * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: res_height * 0.04),
              Text(
                'Enter confirmation code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'A 4-digit code was sent to $sentTo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: res_height * 0.05),
              Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: AppColors.primaryColor,
                    selectionColor: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: OTPTextField(
                  controller: otpController,
                  length: 4,
                  width: res_width,
                  textFieldAlignment: MainAxisAlignment.spaceEvenly,
                  fieldWidth: 64,
                  fieldStyle: FieldStyle.box,
                  otpFieldStyle: OtpFieldStyle(
                    backgroundColor: Colors.white,
                    borderColor: Colors.grey.shade300,
                    enabledBorderColor: Colors.grey.shade300,
                    focusBorderColor: AppColors.primaryColor,
                  ),
                  outlineBorderRadius: 12,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (pin) {},
                  onCompleted: (pin) {
                    OtpValue = pin;
                  },
                ),
              ),
              SizedBox(height: res_height * 0.04),
              InkWell(
                onTap: () {
                  Map data = {'email': widget.email.toString()};
                  authViewMode.forgetPasswordApi(data, context, "forgot");
                },
                child: Text(
                  'Resend code',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: darkBlue,
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.04),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (OtpValue == null || OtpValue!.isEmpty) {
                      Utils.flushBarErrorMessage(
                          "Please Enter Otp", context);
                    } else {
                      Map data = {
                        "email": widget.email,
                        "otp": OtpValue,
                      };
                      authViewMode.otpForgetPasswordApi(data, context);
                    }
                  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
