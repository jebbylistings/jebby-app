import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Services/provider/sign_in_provider.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/helper/global.dart';
import 'package:jared/Views/screens/auth/forgot.dart';
import 'package:jared/Views/screens/auth/register.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/model/user_model.dart';
import 'package:jared/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../Services/provider/internet_provider.dart';
import '../../../utils/show_snackbar.dart';
import '../../../utils/utils.dart';
import '../../../view_model/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<UserModel> getUserDate() => UserViewModel().getUser();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController AppleController = RoundedLoadingButtonController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  int _value = 0;

  bool obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  String? role;

  @override
  void initState() {
    super.initState();
    getUserDate().then((value) async {
      role = value.role;
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

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
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: GestureDetector(
                // onTap: () {
                //   Get.back();
                // },
                // child: Icon(
                //   Icons.arrow_back,
                //   color: Colors.black,
                // ),
                ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                      // height: res_height * 0.12,
                      ),
                  Container(
                    width: res_width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Color(0xFF4285F4)),
                        ),
                        SizedBox(
                            height: res_height * 0.08,
                            ),
                        Row(
                          children: [
                            Text(
                              'Login below or ',
                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => RegisterScreen());
                              },
                              child: Text(
                                'create an account',
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
                    height: res_height * 0.03,
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
                          autocorrect: false,
                          controller: _emailController,
                          validator: (text) {
                            if (text == null || text.isEmpty || !text.contains("@")) {
                              return 'Enter correct email';
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                              hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              hintText: "Enter Your Email",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.03,
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
                          controller: _passwordController,
                          autocorrect: false,
                          obscureText: obscure,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                  child: Icon(obscure ? Icons.visibility_off : Icons.visibility)),
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
                              hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              hintText: "Enter Your Password",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.02,
                  ),
                  Container(
                      width: res_width * 0.9,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => ForgotScreen());
                        },
                        child: Align(alignment: Alignment.bottomRight, child: Text('Forgot Password?')),
                      )),
                  SizedBox(
                    height: res_height * 0.03,
                  ),
                  GestureDetector(
                    onTap: () {
                      print(_emailController.text.toString());
                      if (_emailController.text.toString().toLowerCase() == "vendor") {
                        setState(() {
                          loginType = "vendor";
                        });
                      }
                      if (_emailController.text.isEmpty || !_emailController.text.contains("@")) {
                        Utils.flushBarErrorMessage('Please enter email', context);
                      } else if (_passwordController.text.isEmpty) {
                        Utils.flushBarErrorMessage('Please enter password', context);
                      } else if (_passwordController.text.length < 6) {
                        Utils.flushBarErrorMessage('Please enter 6 digit password', context);
                      } else {
                        Map data = {
                          'email': _emailController.text.toString(),
                          'password': _passwordController.text.toString(),
                        };
                        authViewMode.loginApi(data, context);
                        print('api hit');
                        print(loginType);
                      }
                    },
                    child: Container(
                      height: res_height * 0.065,
                      width: res_width * 0.9,
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(color: Color(0xFF4285F4), borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      getUserDate().then((value) async {
                        print("value ${value.role}");
                        if (value.role.toString() == 'null' || value.role.toString() == '') {
                          int uniqueNumber = generateUniqueNumber();
                          print('Unique Number: $uniqueNumber');
                          Map data = {
                            "full_name": "Guest",
                            "email": "Guest${uniqueNumber.toString()}@gmail.com",
                            "source": "Guest",
                            "role": "0",
                          };
                          authViewMode.signUpApiWithGuest(data, context);
                        } else {
                          Get.offAll(() => MainScreen());
                        }
                      }).onError((error, stackTrace) {
                        if (kDebugMode) {
                          print(error.toString());
                        }
                      });

                      // authViewMode.loginAsGuest(context);
                    },
                    child: Container(
                      height: res_height * 0.065,
                      width: res_width * 0.9,
                      child: Center(
                        child: Text(
                          'Sign In As Guest',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(color: Color(0xFF4285F4), borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.07,
                  ),
                  Text('Login With', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(
                    height: res_height * 0.01,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Radio(
                  //         activeColor: Colors.black,
                  //         value: 0,
                  //         groupValue: _value,
                  //         onChanged: (value) {
                  //           setState(() {
                  //             _value = int.parse(value.toString());
                  //           }); //selected value
                  //         }),
                  //     Text(
                  //       "User",
                  //       style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: "Inter, Regular"),
                  //     ),
                  //     SizedBox(
                  //       width: 20,
                  //     ),
                  //     Radio(
                  //         value: 1,
                  //         activeColor: Colors.black,
                  //         groupValue: _value,
                  //         onChanged: (value) {
                  //           setState(() {
                  //             _value = int.parse(value.toString());
                  //           }); //selected value
                  //         }),
                  //     Text(
                  //       "Vender",
                  //       style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: "Inter, Regular"),
                  //     ),
                  //   ],
                  // ),
                  Container(
                    width: res_width * 0.7,
                    child: GestureDetector(
                      onTap: () {
                        // Get.to(() => SetProfileScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // InkWell(
                          //   onTap: (){
                          //      context.read<FirebaseAuthMethods>().signInWithFacebook(context).then((value) {
                          //       Get.to(() => MainScreen());
                          //      }).catchError((err){
                          //       log(err.toString());
                          //      });

                          //   },
                          //   child: Container(
                          //       width: res_width * 0.15,
                          //       height: res_width * 0.15,
                          //       child: Image.asset('assets/slicing/fb.png')),
                          // ),
                          RoundedLoadingButton(
                            onPressed: () {
                              handleFacebookAuth(_value);
                            },
                            controller: facebookController,
                            successColor: Colors.blue,
                            width: 75,
                            elevation: 0,
                            borderRadius: 25,
                            color: Colors.transparent,
                            child: Container(width: res_width * 0.15, height: res_width * 0.15, child: Image.asset('assets/slicing/fb.png')),
                          ),

                          IOSButton(res_width)

                          // InkWell(
                          //   onTap: () {
                          //   // FirebaseAuthMethods(FirebaseAuth.instance).signInWithGoogle(context);
                          //      context.read<FirebaseAuthMethods>().signInWithGoogle(context).then((value){
                          //       Get.to(() => MainScreen());
                          //      }).catchError((error){
                          //       log(error.toString());
                          //      });

                          //       },
                          //   child: Container(

                          //       width: res_width * 0.15,
                          //       height: res_width * 0.15,
                          //       child: Image.asset('assets/slicing/google.png')),
                          // )
                          ,
                          RoundedLoadingButton(
                            onPressed: () => {handleGoogleSignIn(_value)},
                            controller: googleController,
                            successColor: Colors.red,
                            width: 75,
                            elevation: 0,
                            borderRadius: 25,
                            color: Colors.transparent,
                            child: Container(width: res_width * 0.15, height: res_width * 0.15, child: Image.asset('assets/slicing/google.png')),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  // handling google sigin in
  Future handleGoogleSignIn(value) async {
    //value=_value;
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showSnackBar(context, "Check your Internet connection");
      googleController.reset();
    } else {
      await sp.signInWithGoogle(value, context).then((value) {
        if (sp.hasError == true) {
          showSnackBar(
            context,
            sp.errorCode.toString(),
          );
          googleController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
                    googleController.success();
                    handleAfterSignIn();
                  })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
                    googleController.success();
                    handleAfterSignIn();
                  })));
            }
          });
        }
      });
    }
  }

  // handling facebookauth

  // Future handleFacebookAuth(value) async {
  //   print("value $value");
  //   final sp = context.read<SignInProvider>();
  //   final ip = context.read<InternetProvider>();
  //   await ip.checkInternetConnection();

  //   if (ip.hasInternet == false) {
  //     showSnackBar(
  //       context,
  //       "Check your Internet connection",
  //     );
  //     facebookController.reset();
  //   } else {
  //     await sp.signInWithFacebook(value, context).then((value) {
  //       print('work signInWithFacebook $value');
  //       if (sp.hasError == true) {
  //         print('work hasError');
  //         showSnackBar(
  //           context,
  //           sp.errorCode.toString(),
  //         );
  //         facebookController.reset();
  //       } else {
  //         // checking whether user exists or not
  //         sp.checkUserExists().then((value) async {
  //           print('work $value');
  //           if (value == true) {
  //             // user exists
  //             await sp.getUserDataFromFirestore(sp.uid).then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
  //                   facebookController.success();
  //                   handleAfterSignIn();
  //                 })));
  //           } else {
  //             print('work $value user does not exist');
  //             // user does not exist
  //             sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
  //                   facebookController.success();
  //                   handleAfterSignIn();
  //                 })));
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  Future handleFacebookAuth(value) async {
    print("value $value");
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showSnackBar(
        context,
        "Check your Internet connection",
      );
      facebookController.reset();
    } else {
      await sp.signInWithFacebook(value, context).then((value) {
        print('work signInWithFacebook $value');
        facebookController.reset();
        if (sp.hasError == true) {
          print('work hasError');
          showSnackBar(
            context,
            sp.errorCode.toString(),
          );
          facebookController.reset();
        }
        // else {
        //   // checking whether user exists or not
        //   sp.checkUserExists().then((value) async {
        //     print('work $value');
        //     if (value == true) {
        //       // user exists
        //       await sp.getUserDataFromFirestore(sp.uid).then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
        //             facebookController.success();
        //             handleAfterSignIn();
        //           })));
        //     } else {
        //       print('work $value user does not exist');
        //       // user does not exist
        //       sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
        //             facebookController.success();
        //             handleAfterSignIn();
        //           })));
        //     }
        //   });
        // }
      });
    }
  }

  Future handleAppleAuth(value) async {
    print("value $value");
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    // if (ip.hasInternet == false) {
    //   showSnackBar(
    //     context,
    //     "Check your Internet connection",
    //   );
    //   AppleController.reset();
    // } else {
    await sp.signInWithApple(value, context).then((value) {
      print('work signInWithApple $value');
      AppleController.reset();
      if (sp.hasError == true) {
        print('work hasError');
        showSnackBar(
          context,
          sp.errorCode.toString(),
        );
        AppleController.reset();
      }
      // else {
      //   // checking whether user exists or not
      //   sp.checkUserExists().then((value) async {
      //     print('work $value');
      //     if (value == true) {
      //       // user exists
      //       await sp.getUserDataFromFirestore(sp.uid).then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
      //             facebookController.success();
      //             handleAfterSignIn();
      //           })));
      //     } else {
      //       print('work $value user does not exist');
      //       // user does not exist
      //       sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
      //             facebookController.success();
      //             handleAfterSignIn();
      //           })));
      //     }
      //   });
      // }
    });
    // }
  }

  Random random = Random();

  int generateUniqueNumber() {
    // Generate a random number between 0 and 999999
    int randomNumber = random.nextInt(1000000);

    // Get the current timestamp in milliseconds
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Combine the random number and timestamp to create a unique number
    int uniqueNumber = int.parse('$randomNumber$timestamp');

    return uniqueNumber;
  }

  // handle after signin
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      // log(value.toString());
      Get.offAll(() => MainScreen());
    });
  }

  Widget IOSButton(res_width) {
    if (GetPlatform.isIOS) {
      return RoundedLoadingButton(
        onPressed: () {
          handleAppleAuth(_value);
        },
        controller: AppleController,
        successColor: Colors.black,
        width: 75,
        elevation: 0,
        borderRadius: 25,
        color: Colors.transparent,
        child: Container(width: res_width * 0.15, height: res_width * 0.15, child: Image.asset('assets/slicing/aple.png')),
      );
    }
    return SizedBox.shrink();
  }
}
