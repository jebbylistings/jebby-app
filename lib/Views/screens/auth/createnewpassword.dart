import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jared/Views/helper/colors.dart';

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
          image: AssetImage("assets/slicing/bg2.jpg"),
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
                height: res_height * 0.175,
              ),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Password',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: res_height * 0.05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter New Password'),
                  SizedBox(
                    height: res_height * 0.01,
                  ),
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
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              child: Icon(!obscureText ? Icons.visibility_off : Icons.visibility)),
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
                          hintText: "*******",
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
                  Text('Repeat Password'),
                  SizedBox(
                    height: res_height * 0.01,
                  ),
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
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText1 = !obscureText1;
                                });
                              },
                              child: Icon(!obscureText1 ? Icons.visibility_off : Icons.visibility)),
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
                          hintText: "*******",
                          fillColor: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: res_height * 0.015,
              ),
              GestureDetector(
                onTap: () {
                   if (_passwordController.text.isEmpty) {
                          Utils.flushBarErrorMessage(
                              'Enter Your Password', context);
                      }
                  else if ((!_passwordController.text.contains(RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{8,}$')))) {
                          Utils.flushBarErrorMessage(
                              'Password should be minimum of 8 characters and contain small letter, capital letter and special character', context);
                      }
                  else if (_confirmpasswordController.text.isEmpty) {
                    Utils.flushBarErrorMessage('Enter Repeat Password', context);
                  }
                 else if (_passwordController.text != _confirmpasswordController.text) {
                    Utils.flushBarErrorMessage('Password doesn\'t match ', context);
                  } 
                  
                  else {
                    Map data = {
                      "email": widget.email.toString(),
                      "password": _passwordController.text.toString(),
                    };
                    log(data.toString());
                    authViewMode.changePasswordAPi(data, context);
                  }
                },
                child: Container(
                  height: res_height * 0.065,
                  width: res_width * 0.9,
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
