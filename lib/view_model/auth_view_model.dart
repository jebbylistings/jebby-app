import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/global.dart';
import 'package:jebby/Views/screens/auth/Otp.dart';
import 'package:jebby/Views/screens/auth/createnewpassword.dart';
import 'package:jebby/Views/screens/auth/forgetPasswordOtp.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/auth/stripe_onboarding.dart';
import 'package:jebby/Views/screens/profile/myprofile.dart';
import 'package:jebby/model/user_model.dart';
import 'package:jebby/respository/auth_repository.dart';
import 'package:jebby/utils/utils.dart';
import 'package:jebby/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Views/screens/mainfolder/homemain.dart';
import '../utils/overlay_support.dart';

class AuthViewModel with ChangeNotifier {
  final _myRepo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  bool _signUpLoading = false;
  bool get signUpLoading => _signUpLoading;

  String userName = "";
  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String _name = sharedPreferences.getString('fullname') ?? "";

    userName = _name;
  }

  setSignUpLoading(bool value) {
    _signUpLoading = value;
    notifyListeners();
  }

  Future<void> loginApi(
    dynamic data,
    BuildContext context, {
    bool isFromGuestFlow = false,
  }) async {
    setLoading(true);
    Loader.show();

    _myRepo.loginApi(data).then((value) {
      setLoading(false);
      Loader.hide();
      final userPreference = Provider.of<UserViewModel>(context, listen: false);
      if (value["message"].toString() == "Incorrect password") {
        Utils.flushBarErrorMessage('Incorrect password', context);
      } else if (value["message"].toString() == "enter valid email") {
        Utils.flushBarErrorMessage('Email doesn\'t Exist', context);
      } else if (value["message"].toString() == "account is not verified") {
        Utils.flushBarErrorMessage('Account is not verified', context);
      } else {
        userPreference.saveUser(UserModel(
          token: value['token'].toString(),
          name: value['name'].toString(),
          email: value['email'].toString(),
          id: value['id'].toString(),
          role: value['role'].toString(),
        ));
        userName = value['name'].toString();
        
        if (kDebugMode) {}
        
        String userId = value['id'].toString();
        
        // Get identity_verified and stripe verification status from API response
        bool onboardingCompleted = value['identity_verified'] == 1 || value['identity_verified'] == "1";
        String stripeStatus = value['stripe_verification_status'] ?? "";
        
        // Save both statuses to SharedPreferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('identity_verified', onboardingCompleted);
          prefs.setString('stripe_verification_status', stripeStatus);
        });
        print('stripeStatus: $stripeStatus');
        if (isFromGuestFlow) {
          Get.until((route) {
            return Get.currentRoute == "/PD";
          });
        } else {
          loginType = "user";
          
          // Only go to MainScreen if onboarding is completed
          if (onboardingCompleted) {
            Get.offAll(() => MainScreen());
          } else {
            // Navigate to StripeOnboardingScreen with verification status
            Get.to(() => StripeOnboardingScreen(
              userId: userId,
              verificationStatus: stripeStatus,
            ));
          }
        }
      }
    }).onError((error, stackTrace) {
      Loader.hide();
      setLoading(false);
      Utils.flushBarErrorMessage(error.toString(), context);
      if (kDebugMode) {
        
      }
    });
  }

  Future<void> signUpApi(
    dynamic data,
    BuildContext context, {
    bool isFromGuestFlow = false,
  }) async {
    if (_signUpLoading) return;
    setSignUpLoading(true);

    _myRepo
        .signUpApi(data)
        .then((value) async {
          setSignUpLoading(false);
          if (value["message"].toString() == "OTP send") {
            Utils.flushBarErrorMessage('Otp sent', context);
            Get.to(
              () => OTPSCREEN(
                email: data["email"],
                name: data["full_name"],
                password: data["password"],
                role: data["role"],
                isGuestUserFlow: isFromGuestFlow,
              ),
            );
          } else if (value["message"].toString() == "Signin successfull") {
            Utils.flushBarErrorMessage('Signin Successful', context);

        // Save Data To SharedPrefrences
        SharedPreferences updatePrefrences = await SharedPreferences.getInstance();
        
        
        updatePrefrences.setString('fullname', value["data"]["full_name"].toString());
        updatePrefrences.setString('email', value["data"]["email"].toString());
        updatePrefrences.setString('id', value["data"]["id"].toString());
        updatePrefrences.setString('phoneNumber', value["data"]["phoneNumber"].toString());
        // updatePrefrences.setString('address', value["address"].toString());
        updatePrefrences.setString('latitude', value["data"]["latitude"].toString());
        updatePrefrences.setString('longitude', value["data"]["longitude"].toString());
        updatePrefrences.setString('role', value["data"]["role"].toString());
        // updatePrefrences.setString('number', value["number"].toString());
        
        // Get stripe verification status
        String stripeStatus = value["data"]["stripe_verification_status"] ?? "";
        bool onboardingCompleted = value["data"]["identity_verified"] == 1 || value["data"]["identity_verified"] == "1";
        
        // Save verification statuses
        updatePrefrences.setBool('identity_verified', onboardingCompleted);
        updatePrefrences.setString('stripe_verification_status', stripeStatus);
        
        // If onboarding and verification are completed, go to MainScreen, otherwise go to StripeOnboardingScreen
        if (onboardingCompleted) {
          Get.offAll(() => MainScreen());
        } else {
          Get.to(() => StripeOnboardingScreen(
            userId: value["data"]["id"].toString(),
            verificationStatus: stripeStatus,
          ));
        }
      } else if (value["message"].toString() == "Email Already Registered") {
        Utils.flushBarErrorMessage('Email Already Registered', context);
      } else {
        Utils.flushBarErrorMessage('Something went wrong', context);
      }
      //  Get.to(()=> OTPSCREEN()) ;
      if (kDebugMode) {
        
      }
    }).onError((error, stackTrace) {
      setSignUpLoading(false);
      Utils.flushBarErrorMessage(error.toString(), context);
      if (kDebugMode) {
        
      }
    });
  }

  Future<void> otpRegisterApi(
    dynamic data,
    BuildContext context, {
    bool isGuestUserFlow = false,
  }) async {
    setSignUpLoading(true);

    _myRepo.otpRegisterApi(data).then((value) {
      setSignUpLoading(false);
      if (value["message"].toString() == "Successfully signup") {
        Utils.flushBarErrorMessage('SignUp Successfully', context);
        
        String userId = value["data"]["id"].toString();
        
        // Get stripe verification status if available
        String stripeStatus = value["data"]["stripe_verification_status"] ?? "";
        
        // After successful signup, go to Stripe onboarding before login
        Get.to(() => StripeOnboardingScreen(
          userId: userId,
          verificationStatus: stripeStatus,
        ));
      } else if (value["message"].toString() == "invalid OTP") {
        Utils.flushBarErrorMessage('invalid OTP', context);
      } else {
        Utils.flushBarErrorMessage('Something went wrong', context);
      }
      if (kDebugMode) {
        
      }
    }).onError((error, stackTrace) {
      print("Error in otpRegisterApi: $error");
      setSignUpLoading(false);
      Utils.flushBarErrorMessage("Please Enter Otp", context);

          if (kDebugMode) {}
        });
  }

  Future<void> signUpApiWithSocials(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo
        .signUpApiWithSocial(data)
        .then((value) async {
          setSignUpLoading(false);
          if (value["message"].toString() == "Signin successfull") {
            Utils.flushBarErrorMessage('Signin Successful', context);

        // Save Data To SharedPrefrences
        SharedPreferences updatePrefrences = await SharedPreferences.getInstance();
        
        
        updatePrefrences.setString('fullname', value["data"]["full_name"].toString());
        updatePrefrences.setString('email', value["data"]["email"].toString());
        updatePrefrences.setString('id', value["data"]["id"].toString());
        // updatePrefrences.setString('address', value["address"].toString());
        updatePrefrences.setString('latitude', value["data"]["latitude"].toString());
        updatePrefrences.setString('longitude', value["data"]["longitude"].toString());
        updatePrefrences.setString('role', value["data"]["role"].toString());
        // updatePrefrences.setString('number', value["number"].toString());
        
        // Check onboarding and verification status
        String userId = value["data"]["id"].toString();
        bool onboardingCompleted = value["data"]["identity_verified"] == 1 || value["data"]["identity_verified"] == "1";
        
        // Save onboarding status
        updatePrefrences.setBool('identity_verified', onboardingCompleted);
        updatePrefrences.setString('stripe_verification_session', value["data"]["stripe_verification_session"] ?? "");
        
        // Get stripe verification status
        String stripeStatus = value["data"]["stripe_verification_status"] ?? "";
        updatePrefrences.setString('stripe_verification_status', stripeStatus);
        
        // If onboarding and verification are completed, go to MainScreen, otherwise go to StripeOnboardingScreen
        if (onboardingCompleted) {
          Get.offAll(() => MainScreen());
        } else {
          Get.to(() => StripeOnboardingScreen(
            userId: userId,
            verificationStatus: stripeStatus,
          ));
        }
      } else {
        Utils.flushBarErrorMessage('Something went wrong', context);
      }

          if (kDebugMode) {}
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString(), context);
          if (kDebugMode) {}
        });
  }

  Future<void> signUpApiWithGuest(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo
        .signUpApiWithGuest(data)
        .then((value) async {
          setSignUpLoading(false);
          if (value["message"].toString() == "Signin successfull") {
            final userPreference = Provider.of<UserViewModel>(
              context,
              listen: false,
            );
            userPreference.saveUser(
              UserModel(
                token: "",
                name: "Guest",
                email: "",
                id: value?["data"]?["id"].toString(),
                role: "Guest",
                isGuest: true,
              ),
            );

            // Save Data To SharedPrefrences
            // SharedPreferences updatePrefrences = await SharedPreferences.getInstance();
            // updatePrefrences.setString('fullname', value["data"]["full_name"].toString());
            // // updatePrefrences.setString('email', value["data"]["email"].toString());
            // updatePrefrences.setString('id', value["data"]["id"].toString());
            // updatePrefrences.setString('role', value["data"]["role"].toString());
            // String? test = updatePrefrences.getString("id");
            // log("For checking shared Prefrences " + test.toString());
            loginType = "user";
            Get.offAll(() => MainScreen());
            // }
          } else {
            Utils.flushBarErrorMessage('Something went wrong', context);
          }
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString(), context);
          if (kDebugMode) {}
        });
  }

  Future<void> forgetPasswordApi(
    dynamic data,
    BuildContext context,
    route, {
    bool isGuestUserFlow = false,
  }) async {
    setSignUpLoading(true);

    _myRepo
        .forgetPasswordApi(data)
        .then((value) {
          setSignUpLoading(false);
          if (value["message"].toString() == "Otp Send") {
            Utils.flushBarErrorMessage('OTP resent successfully', context);
            route == "forgot"
                ? Get.to(() => ForgetPasswordOtpScreen(email: data["email"]))
                : Get.to(
                  () => OTPSCREEN(
                    email: data["email"],
                    name: "",
                    password: data["password"],
                    role: "",
                    isGuestUserFlow: isGuestUserFlow,
                  ),
                );
          } else if (value["message"].toString() == "Email not Found") {
            Utils.flushBarErrorMessage('Email not Found', context);
          } else {
            Utils.flushBarErrorMessage('Something went wrong', context);
          }
          if (kDebugMode) {}
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString() + "Ameer", context);
          if (kDebugMode) {}
        });
  }

  Future<void> otpForgetPasswordApi(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo.ForgetPasswordotpApi(data)
        .then((value) {
          setSignUpLoading(false);
          if (value["message"].toString() == "otp correct") {
            Utils.flushBarErrorMessage('Otp Correct', context);
            Get.to(() => CreatePasswordScreen(email: data["email"]));
          } else if (value["message"].toString() == "otp incorrect") {
            Utils.flushBarErrorMessage('invalid OTP', context);
          } else {
            Utils.flushBarErrorMessage('Something went wrong', context);
          }
          //  Get.to(()=> OTPSCREEN()) ;
          if (kDebugMode) {}
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage("Please Enter Otp", context);
          if (kDebugMode) {}
        });
  }

  Future<void> changePasswordAPi(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo
        .changePasswordApi(data)
        .then((value) {
          setSignUpLoading(false);
          if (value["message"].toString() == "Password Updated") {
            Utils.flushBarErrorMessage(
              'Password Changed Successfully',
              context,
            );
            Get.offAll(() => LoginScreen());
          } else if (value["message"].toString() == "Email not Found") {
            Utils.flushBarErrorMessage('email  not found', context);
          } else if (value["message"].toString() ==
              "this is a social auth account") {
            Utils.flushBarErrorMessage(
              'This is a social auth account',
              context,
            );
          } else {
            Utils.flushBarErrorMessage('Something went wrong', context);
          }
          //  Get.to(()=> OTPSCREEN()) ;
          if (kDebugMode) {}
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString(), context);
          if (kDebugMode) {}
        });
  }

  Future<void> editProfileApi(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo
        .editProfileApi(data)
        .then((value) {
          setSignUpLoading(false);
          if (value["result"].toString() == data["file"].toString()) {
            Utils.flushBarErrorMessage('Otp sent', context);
            Get.to(() => MyProfileScreen());
          } else if (value["message"].toString() == "Please upload a file!") {
            Utils.flushBarErrorMessage('Please upload a file!', context);
          } else {
            Utils.flushBarErrorMessage('Something went wrong', context);
          }
          //  Get.to(()=> OTPSCREEN()) ;
          if (kDebugMode) {}
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString(), context);
          if (kDebugMode) {}
        });
  }

  Future<void> DeleteAccount(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    _myRepo.DeleteAccount(data)
        .then((value) async {
          setSignUpLoading(false);
          if (value["message"] == "User has been deleted" ||
              value["message"] == "Vendor has been deleted") {
            Utils.flushBarErrorMessage(value["message"].toString(), context);
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            notifyListeners();
            sharedPreferences.setString('token', "");
            sharedPreferences.setString('role', "");
            Get.to(() => LoginScreen());
          } else {
            Utils.flushBarErrorMessage(value["message"].toString(), context);
          }
        })
        .onError((error, stackTrace) {
          setSignUpLoading(false);
          Utils.flushBarErrorMessage(error.toString(), context);
          if (kDebugMode) {}
        });
  }

  /// login will  be done as a guest
  void loginAsGuest(BuildContext context) {
    final userPreference = Provider.of<UserViewModel>(context, listen: false);
    userName = "Guest";
    userPreference.saveUser(
      UserModel(
        token: "",
        name: "Guest",
        email: "",
        id: "Guest",
        role: "Guest",
        isGuest: true,
      ),
    );

    Get.offAll(() => MainScreen());
  }
}
