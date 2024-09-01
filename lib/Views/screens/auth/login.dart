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
import 'package:lottie/lottie.dart';

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
  final RoundedLoadingButtonController phoneController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController AppleController = RoundedLoadingButtonController();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  int _value = 0;

  bool obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();

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
            image: AssetImage("assets/slicing/bg3.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   leading: GestureDetector(
          //       // onTap: () {
          //       //   Get.back();
          //       // },
          //       // child: Icon(
          //       //   Icons.arrow_back,
          //       //   color: Colors.black,
          //       // ),
          //       ),
          //   elevation: 0,
          //   backgroundColor: Colors.transparent,
          // ),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: res_height * 0.088,
                  ),
                  Container(
                    width: res_width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Lottie.asset(
                          'assets/lottie/welcome.json',
                          width: res_width * 0.9,
                          height: 200,
                          // fit: BoxFit.fill,
                        ),
                        SizedBox(
                          height: res_height * 0.03,
                        ),
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: darkBlue),
                          ),
                        ),
                        Align(
                          child: Text(
                            'Login to your account',
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.03,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: darkBlue),
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
                              hintText: "Enter Your Email",
                              fillColor: lightBlue),
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
                      Container(
                        width: res_width * 0.9,
                        child: TextFormField(
                          controller: _passwordController,
                          autocorrect: false,
                          obscureText: obscure,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                  child: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: darkBlue)),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: darkBlue,
                              ),
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
                              hintText: "Enter Your Password",
                              fillColor: lightBlue),
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
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: Text('Forgot Password?', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold))),
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
                      height: res_height * 0.055,
                      width: res_width * 0.9,
                      child: Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account? ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => RegisterScreen());
                        },
                        child: Text(
                          'Signup',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: darkBlue,
                              color: darkBlue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: res_height * 0.02,
                  ),
                  Container(
                    width: res_width * 0.9,
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('OR'),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                        ),
                        SizedBox(
                          height: res_height * 0.07,
                        ),
                        SizedBox(
                          height: res_height * 0.07,
                        ),
                      ],
                    ),
                  ),
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
                    width: res_width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          valueColor: darkBlue,
                          color: Colors.transparent,
                          child: Container(width: res_width * 0.15, height: res_width * 0.08, child: Image.asset('assets/slicing/fb.png')),
                        ),

                        GetPlatform.isIOS
                            ? IOSButton(res_width)
                            : Container(
                                height: res_width * 0.116,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showPhoneNumberDialog(context, _phoneController, res_width);
                                  },
                                  label: Icon(
                                    Icons.phone,
                                    size: 28,
                                    color: darkBlue,
                                  ),
                                )),

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

                        RoundedLoadingButton(
                          onPressed: () => {handleGoogleSignIn(_value)},
                          controller: googleController,
                          successColor: Colors.red,
                          width: 75,
                          elevation: 0,
                          borderRadius: 25,
                          valueColor: darkBlue,
                          color: Colors.transparent,
                          child: Container(width: res_width * 0.15, height: res_width * 0.15, child: Image.asset('assets/slicing/google.png')),
                        ),
                        Container(
                            height: res_width * 0.116,
                            child: ElevatedButton.icon(
                              onPressed: () {
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

                                //     // authViewMode.loginAsGuest(context);
                              },
                              label: Icon(
                                Icons.person,
                                size: 28,
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: res_height * 0.02,
                  ),
                  GetPlatform.isIOS
                      ? Container(
                          height: res_width * 0.116,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showPhoneNumberDialog(context, _phoneController, res_width);
                            },
                            label: Icon(
                              Icons.phone,
                              size: 28,
                              color: darkBlue,
                            ),
                          ))
                      : SizedBox.shrink(),
                  // RoundedLoadingButton(
                  //   onPressed: () => {
                  //     // Get.dialog(
                  //     //   PhoneNumberModal(),
                  //     //   barrierDismissible: false, // Prevent dismissing by tapping outside
                  //     // )
                  //     showPhoneNumberDialog(context, _phoneController, res_width)
                  //     // handlePhoneSignIn(_value)
                  //   },
                  //   controller: phoneController,
                  //   successColor: Colors.red,
                  //   width: 75,
                  //   elevation: 0,
                  //   borderRadius: 25,
                  //   valueColor: darkBlue,
                  //   color: Colors.transparent,
                  //   child: Icon(
                  //     Icons.phone,
                  //     size: 28,
                  //     color: darkBlue,
                  //   ),
                  // ),
                  SizedBox(
                    height: res_height * 0.05,
                  ),
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

  Future handlePhoneSignIn(value) async {
    //value=_value;
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      showSnackBar(context, "Check your Internet connection");
      phoneController.reset();
    } else {
      await sp.signInWithPhone(value, context).then((value) {
        if (sp.hasError == true) {
          showSnackBar(
            context,
            sp.errorCode.toString(),
          );
          phoneController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
                    phoneController.success();
                    // handleAfterSignIn();
                  })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
                    phoneController.success();
                    // handleAfterSignIn();
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
      }).catchError((error) {
        print('work hasError');
        facebookController.reset();
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
    }).catchError((error) {
      print('work hasError');
      AppleController.reset();
    });
    ;
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
        valueColor: darkBlue,
        elevation: 0,
        borderRadius: 25,
        color: Colors.transparent,
        child: Container(width: res_width * 0.15, height: res_width * 0.08, child: Image.asset('assets/slicing/aple.png')),
      );
    }
    return SizedBox.shrink();
  }
}

void showPhoneNumberDialog(BuildContext context, TextEditingController _phoneController, res_width) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/phone.json',
                    width: res_width * 0.9,
                    height: 150,
                    // fit: BoxFit.fill,
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
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
                      hintText: 'Enter Phone Number',
                      fillColor: lightBlue,
                    ),
                    onChanged: (value) {
                      // Handle phone number input
                    },
                  ),
                  SizedBox(height: 15),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      '* Phone number must be entered with country code +1 --- --- ----',
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _phoneController.clear();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle continue button press
                      String phoneNumber = _phoneController.text;
                      if (phoneNumber.isNotEmpty) {
                        final sp = context.read<SignInProvider>();
                        final ip = context.read<InternetProvider>();
                        await ip.checkInternetConnection();

                        if (ip.hasInternet == false) {
                          showSnackBar(context, "Check your Internet connection");
                        } else {
                          await sp.signInWithPhone(phoneNumber, context);
                        }
                      } else {
                        Get.showSnackbar(
                          GetSnackBar(
                            title: 'Error',
                            message: 'Please enter a phone number',
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                            snackPosition: SnackPosition.TOP,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
