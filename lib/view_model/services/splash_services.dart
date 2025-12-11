import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/global.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/auth/stripe_onboarding.dart';
import 'package:jebby/Views/screens/mainfolder/homemain.dart';
import 'package:jebby/model/user_model.dart';
import 'package:jebby/view_model/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashServices {
  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void checkAuthentication(BuildContext context) async {
    getUserDate()
        .then((value) async {
          if (value.role.toString() == 'null' || value.role.toString() == '') {
            await Future.delayed(Duration(seconds: 3));
            Get.offAll(() => LoginScreen());
          } else {
            await Future.delayed(Duration(seconds: 3));
            
            loginType = "user";
            Get.offAll(() => MainScreen());
          }
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }
}

class DataUsers {
  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? phoneNumber;
  String? role;
  void profileData() async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          phoneNumber = value.phoneNumber.toString();
          role = value.role.toString();
        })
        .onError((error, stackTrace) {});
  }
}
