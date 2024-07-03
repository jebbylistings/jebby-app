import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/auth/login.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
import '../../../view_model/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  final bool isGuestUserFlow;
  const RegisterScreen({Key? key,  this.isGuestUserFlow = false }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool onlinepay = false;
  bool cod = false;
  int _value = 0; //="User";
  bool obscureText = true;
  bool obscureText1 = true;
  final termscontroller = Get.put(TermsController());
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        Text(
                          'Create account!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        Row(
                          children: [
                            Text(
                              'Enter your account details below or ',
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => LoginScreen());
                              },
                              child: Text(
                                'log in',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 19,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.05,
                  ),
                  Row(
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       onlinepay = false;
                      //       if (onlinepay == false) {
                      //         registerFor = "1";
                      //       }
                      //       // cod = false;
                      //     });
                      //   },
                      //   child: Container(
                      //     height: 19,
                      //     width: 19,
                      //     decoration: BoxDecoration(
                      //         shape: BoxShape.circle, border: Border.all(color: onlinepay == false ? Color(0xff303030) : Colors.black, width: 3)),
                      //     child: Icon(
                      //       Icons.circle_rounded,
                      //       color: onlinepay == false ? Color(0xff303030) : Colors.white,
                      //       size: 13,
                      //     ),
                      //   ),
                      // ),
                      Radio(
                          activeColor: Colors.black,
                          value: 0,
                          groupValue: _value,
                          onChanged: (value) {
                            setState(() {
                              _value = int.parse(value.toString());
                            }); //selected value
                          }),

                      Text(
                        "User",
                        style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: "Inter, Regular"),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       onlinepay = true;
                      //       if (onlinepay == false) {
                      //         _value = 0;
                      //       }
                      //       // cod = true;
                      //     });
                      //   },
                      //   child: Container(
                      //     height: 19,
                      //     width: 19,
                      //     decoration: BoxDecoration(
                      //         shape: BoxShape.circle, border: Border.all(color: onlinepay == true ? Color(0xff303030) : Colors.black, width: 3)),
                      //     child: Icon(
                      //       Icons.circle_rounded,
                      //       color: onlinepay == true ? Color(0xff303030) : Colors.white,
                      //       size: 13,
                      //     ),
                      //   ),
                      // ),
                      Radio(
                          value: 1,
                          activeColor: Colors.black,
                          groupValue: _value,
                          onChanged: (value) {
                            setState(() {
                              _value = int.parse(value.toString());
                            }); //selected value
                          }),

                      Text(
                        "Provider",
                        // "Vendor",
                        style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: "Inter, Regular"),
                      ),
                    ],
                  ),

                  // Row(
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
                    height: res_height * 0.05,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name'),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          controller: _userNameController,
                          autocorrect: false,
                          // controller: userEmailController,
                          validator: (text) {
                            if (text == null || text.isEmpty || !text.contains("@")) {
                              return 'Enter correct email';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "Username",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.015,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email'),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          
                          controller: _emailController,
                          autocorrect: false,
                          // controller: userEmailController,
                          validator: (text) {
                            if (text == null || text.isEmpty || !text.contains("@")) {
                              return 'Enter correct email';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                             
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "Example@gmail.com",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.015,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password'),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          obscureText: obscureText,
                          controller: _passwordController,
                          autocorrect: false,
                          // obscureText: true,
                          // controller: userEmailController,
                          validator: (text) {
                            if (text == null || text.isEmpty || !text.contains("@")) {
                              return 'Enter correct email';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                             suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                  child: Icon(obscureText ? Icons.visibility_off : Icons.visibility)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "*********",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.015,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirm Password'),
                      SizedBox(
                        height: res_height * 0.01,
                      ),
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          obscureText: obscureText1,
                          controller: _confirmpasswordController,
                          autocorrect: false,
                          // obscureText: true,
                          // controller: userEmailController,
                          validator: (text) {
                            if (text == null || text.isEmpty || !text.contains("@")) {
                              return 'Enter correct email';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      obscureText1 = !obscureText1;
                                    });
                                  },
                                  child: Icon(obscureText1 ? Icons.visibility_off : Icons.visibility)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: const BorderSide(color: kprimaryColor, width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: "*********",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.015,
                  ),
                  Obx(() => CheckboxListTile(
                        title: Text("I agree to the Terms of Services and Privacy Policy", style: TextStyle(fontSize: 17)),
                        value: termscontroller.termsValue.value,
                        activeColor: kprimaryColor,
                        onChanged: (newValue) {
                          if (termscontroller.termsValue == true) {
                            termscontroller.chanegValue(false);
                          } else {
                            termscontroller.chanegValue(true);
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                      )),
                  SizedBox(
                    height: res_height * 0.015,
                  ),
                  GestureDetector(
                    onTap: () {
                      if(_userNameController.text.isEmpty&&_emailController.text.isEmpty&&_passwordController.text.isEmpty&&
                          _confirmpasswordController.text.isEmpty){
                        Utils.flushBarErrorMessage('Please fill all the required fields', context);
                        return;
                      }

                      final bool emailValid =
                          RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.(com)").hasMatch(_emailController.text);
                      if (_userNameController.text.isEmpty) {
                        Utils.flushBarErrorMessage('Please enter your name', context);
                      } else if (_emailController.text.isEmpty || !emailValid) {
                        Utils.flushBarErrorMessage('Please enter valid email', context);
                      } else if (_passwordController.text.isEmpty) {
                        Utils.flushBarErrorMessage('Please enter password', context);
                      } else if ((!_passwordController.text.contains(RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{8,}$')))) {
                          Utils.flushBarErrorMessage(
                              'Password should be minimum of 8 characters and contain small letter, capital letter and special character', context);
                      } else if (_confirmpasswordController.text.isEmpty) {
                        Utils.flushBarErrorMessage('Please enter confirm password', context);
                      } else if (_passwordController.text != _confirmpasswordController.text) {
                        Utils.flushBarErrorMessage('Password doesn\'t match ', context);
                      } else if (!termscontroller.termsValue.value) {
                        Utils.flushBarErrorMessage('Please accept our Terms of services & Privacy Policy', context);
                      } else {
                        log(_value.toString());
                        Map data = {
                          "full_name": _userNameController.text,
                          "email": _emailController.text.toString(),
                          "password": _passwordController.text.toString(),
                          "source": "simple",
                          "role": _value.toString()
                        };
                        log(data.toString());
                        authViewMode.signUpApi(data, context,isFromGuestFlow: widget.isGuestUserFlow);
                      }

                      print('api hit');

                      //Get.to(() => SetProfileScreen());
                    },
                    child: Container(
                      height: res_height * 0.065,
                      width: res_width * 0.9,
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.08,
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

class TermsController extends GetxController {
  RxBool termsValue = false.obs;
  void chanegValue(data) {
    termsValue.value = data;
    update();
  }
}
