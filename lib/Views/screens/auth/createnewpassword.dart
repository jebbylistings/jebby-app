import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';

import '../../../view_model/auth_view_model.dart';

import '../../../utils/utils.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String? email;
  const CreatePasswordScreen({Key? key, this.email}) : super(key: key);

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  bool obscureText = false;
  bool obscureText1 = false;
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
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: res_height * 0.1,
              ),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Lottie.asset('assets/lottie/create_password.json', width: res_width * 0.9, height: 200),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Center(
                      child: Text(
                        'Create New Password',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: darkBlue),
                      ),
                    ),
                    Align(
                      child: Text(
                        "Create a new password for your account",
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Enter New Password'),
                  // SizedBox(
                  //   height: res_height * 0.01,
                  // ),
                  Container(
                    width: res_width * 0.9,
                    child: TextFormField(
                      obscureText: !obscureText,
                      autocorrect: false,
                      controller: _passwordController,
                      validator: (text) {
                        if (text == null || text.isEmpty || !text.contains("@")) {
                          return 'Enter correct email';
                        }
                        return null;
                      },
                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: darkBlue,
                          ),
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              child: Icon(
                                !obscureText ? Icons.visibility_off : Icons.visibility,
                                color: darkBlue,
                              )),
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
                          hintText: "Enter New Password",
                          fillColor: lightBlue),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: res_height * 0.02,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Repeat Password'),
                  // SizedBox(
                  //   height: res_height * 0.01,
                  // ),
                  Container(
                    width: res_width * 0.9,
                    child: TextFormField(
                      obscureText: !obscureText1,
                      autocorrect: false,
                      controller: _confirmpasswordController,
                      validator: (text) {
                        if (text == null || text.isEmpty || !text.contains("@")) {
                          return '*******';
                        }
                        return null;
                      },
                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: darkBlue,
                          ),
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText1 = !obscureText1;
                                });
                              },
                              child: Icon(
                                !obscureText1 ? Icons.visibility_off : Icons.visibility,
                                color: darkBlue,
                              )),
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
                          hintText: "Repeat Password",
                          fillColor: lightBlue),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: res_height * 0.04,
              ),
              InkWell(
                onTap: () {
                  if (_passwordController.text.isEmpty) {
                    Utils.flushBarErrorMessage('Enter Your Password', context);
                  } else if ((!_passwordController.text.contains(RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{8,}$')))) {
                    Utils.flushBarErrorMessage(
                        'Password should be minimum of 8 characters and contain small letter, capital letter and special character', context);
                  } else if (_confirmpasswordController.text.isEmpty) {
                    Utils.flushBarErrorMessage('Enter Repeat Password', context);
                  } else if (_passwordController.text != _confirmpasswordController.text) {
                    Utils.flushBarErrorMessage('Password doesn\'t match ', context);
                  } else {
                    Map data = {
                      "email": widget.email.toString(),
                      "password": _passwordController.text.toString(),
                    };
                    authViewMode.changePasswordAPi(data, context);
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  height: res_height * 0.055,
                  width: res_width * 0.9,
                  child: Center(
                    child: Text(
                      'Save',
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
    );
  }
}
