import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/show_snackbar.dart';

class FirebaseAuthMethods with ChangeNotifier{
  final FirebaseAuth auth;

  FirebaseAuthMethods(this.auth);

  User get user=> auth.currentUser!;


  //StateMAnagement
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();
  

  //Email SignUp

  // Future<void> signUpWithEmail({
  //   required String email,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     await auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     await sendEmailVerification(context);
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message!);
  //   }
  // }

  //login With Email

  // Future<void> loginWithEmail({
  //   required String email,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     await auth.signInWithEmailAndPassword(email: email, password: password);
  //     if (!auth.currentUser!.emailVerified) {
  //       // ignore: use_build_context_synchronously
  //       await sendEmailVerification(context);
  //     }
  //     showSnackBar(context, "Successfull");
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message!);
  //   }
  // }

  // //Email Verificaation
  // Future<void> sendEmailVerification(BuildContext context) async {
  //   try {
  //     auth.currentUser!.sendEmailVerification();
  //     showSnackBar(context, "Email verification Send");
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message!);
  //   }
  // }

  //Gooogle Sign In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope("https://www.googleapis.com/auth/contacts.readonly");
        await auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        if (googleAuth?.accessToken != null || googleAuth?.idToken != null) {
          //create a new Credential

          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth?.idToken,
            accessToken: googleAuth?.accessToken,
          );
          UserCredential usercredential =
              await auth.signInWithCredential(credential);

          //This is For SignUp
          // if (usercredential.user!=null) {
          //   if (usercredential.additionalUserInfo!.isNewUser) {
          //     //Add Data additional data
          //     //Store into a data base or postApi
          //   }
          // }
          showSnackBar(context, "Successfull Login");
        }
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  //Firebase SignIn
 Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
          print("loginResult.toString() ${loginResult.toString()}");

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);


      await auth.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  //Phone Verifications
  // Future<void> phoneSignIn({
  //   required String phoneNumber,
  //   required BuildContext context,
  // }) async {
  //   final TextEditingController codeController = TextEditingController();

  //   try {
  //     if (kIsWeb) {
  //       ConfirmationResult result =
  //           await auth.signInWithPhoneNumber(phoneNumber);
  //       showOTPDialog(
  //           context: context,
  //           codeController: codeController,
  //           onPressed: () async {
  //             PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //               verificationId: result.verificationId,
  //               smsCode: codeController.text.trim(),
  //             );
  //             await auth.signInWithCredential(credential);
  //             Navigator.of(context).pop(); //for Remove
  //           });
  //     } else {
  //       //only for android or ios
  //       await auth.verifyPhoneNumber(
  //         verificationCompleted: (PhoneAuthCredential credential) async {
  //           await auth.signInWithCredential(credential);
  //         },
  //         verificationFailed: ((error) {
  //           showSnackBar(context, error.message!);
  //         }),
  //         phoneNumber: phoneNumber,
  //         codeSent: (verificationId, resendingToken) {
  //           showOTPDialog(
  //               context: context,
  //               codeController: codeController,
  //               onPressed: () async {
  //                 PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //                   verificationId: verificationId,
  //                   smsCode: codeController.text.trim(),
  //                 );
  //                 await auth.signInWithCredential(credential);
  //                 Navigator.of(context).pop();
  //               });
  //         },
  //         codeAutoRetrievalTimeout: ((verificationId) {}),
  //       );
  //     }
  //   } catch (e) {
  //     showSnackBar(context, e.toString());
  //   }
  // }

//   Future<void> signOut(BuildContext context)async{
//     try {
//       await auth.signOut();
//     }on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message!);
//     }
//   }
//   Future<void> deleteAccount(BuildContext context)async{
//     try {
//       await auth.currentUser!.delete();
//     }on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message!);
//     }
//   }
















 final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  
}