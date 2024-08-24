import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/global.dart';
import 'package:jared/Views/screens/auth/login.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/Views/screens/vendors/vendorhome.dart';
import 'package:jared/model/user_model.dart';
import 'package:jared/view_model/user_view_model.dart';

class SplashServices {
  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void checkAuthentication(BuildContext context) async {
    getUserDate().then((value) async {
      print("value ${value.role}");
      FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (value.role.toString() == 'null' || value.role.toString() == '') {
        await Future.delayed(Duration(seconds: 3));
        Get.offAll(() => LoginScreen());
      } else {
        await Future.delayed(Duration(seconds: 3));
        if (value.role.toString() == "1") {
          loginType = "vendor";
          Get.offAll(() => VendrosHomeScreen());
        } else {
          loginType = "user";
          Get.offAll(() => MainScreen());
        }
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
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
    getUserDate().then((value) async {
      token = value.token.toString();
      id = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      phoneNumber = value.phoneNumber.toString();
      role = value.role.toString();
    }).onError((error, stackTrace) {});
  }
}
