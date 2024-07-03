import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view_model/auth_view_model.dart';


class UserNameProvider extends ChangeNotifier{
  String userName = "" ;
  void getUserName()  async {
    if(userName == "Guest" || userName.isEmpty) {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      String _name = sharedPreferences.getString('fullname') ?? "";
        print("the user is $_name");
        userName = _name;
    }
  }

}
class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
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

  String? _role;
  String? get role => _role;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in with google
  Future signInWithGoogle(value, BuildContext context) async {
    print('hello google');
    final authViewMode = Provider.of<AuthViewModel>(context,listen: false);

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        _role=value.toString();

        notifyListeners();

          //save in registerApi
        Map data = {
          "full_name": userDetails.displayName,
          "email": userDetails.email,
          "password": "",
          "source": "GOOGLE",
          "role": value.toString(),
        };
        authViewMode.signUpApiWithSocials(data, context);

      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }


  // // sign in with google
  // Future signInWithGoogle(value, BuildContext context) async {
  //   final authViewMode = Provider.of<AuthViewModel>(context,listen: false);
  //   final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  //   if (googleSignInAccount != null) {
  //     // executing our authentication
  //     try {
  //       final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleSignInAuthentication.accessToken,
  //         idToken: googleSignInAuthentication.idToken,
  //       );

  //       // signing to firebase user instance
  //       final User userDetails = (await firebaseAuth.signInWithCredential(credential)).user!;
  //       log("form Siging  Page"+userDetails.toString() + value.toString());

        

  //       // now save all values
  //       _name = userDetails.displayName;
  //       _email = userDetails.email;
  //       _imageUrl = userDetails.photoURL;
  //       _provider = "GOOGLE";
  //       _uid = userDetails.uid;
  //       _role=value.toString();
  //       notifyListeners();

  //       //save in registerApi
  //       Map data = {
  //         "full_name": userDetails.displayName,
  //         "email": userDetails.email,
  //         "password": "",
  //         "source": "GOOGLE",
  //         "role": value.toString(),
  //       };
  //       authViewMode.signUpApiWithSocials(data, context);


        

        
  //     } on FirebaseAuthException catch (e) {
  //       switch (e.code) {
  //         case "account-exists-with-different-credential":
  //           _errorCode = "You already have an account with us. Use correct provider";
  //           _hasError = true;
  //           notifyListeners();
  //           break;

  //         case "null":
  //           _errorCode = "Some unexpected error while trying to sign in";
  //           _hasError = true;
  //           notifyListeners();
  //           break;
  //         default:
  //           _errorCode = e.toString();
  //           _hasError = true;
  //           notifyListeners();
  //       }
  //     }
  //   } else {
  //     _hasError = true;
  //     notifyListeners();
  //   }
  // }

  // sign in with facebook
  
// Future signInWithFacebook(value, BuildContext context) async {
//   print('facebook');
//     final authViewMode = Provider.of<AuthViewModel>(context,listen: false);

//     try{

//      final LoginResult loginResult = await FacebookAuth.instance
//           .login(permissions: ['email']);

//     print("Result: ${loginResult.accessToken!.token}");

//     final OAuthCredential facebookAuthCredential =
//           FacebookAuthProvider.credential(loginResult.accessToken!.token);

//           print("facebookAuthCredential ${facebookAuthCredential}");

//       var authResult = await FirebaseAuth.instance
//           .signInWithCredential(facebookAuthCredential);
      
//       print("authResult ${authResult}");

//         //save in registerApi
//         if (authResult.user != null) {
//         Map data = {
//           "full_name": '',
//           "email":  authResult.user!.email,
//           "password": "",
//           "source": "FACEBOOK",
//           "role": value.toString(),
//         };
//         authViewMode.signUpApiWithSocials(data, context);
//         // saving the values
//         _name = '';
//         _email = authResult.user!.email;
//         _imageUrl = '';
//         _uid = authResult.user!.uid;
//         _hasError = false;
//         _provider = "FACEBOOK";
//         _role=value.toString();
//         notifyListeners();}
//         else {
//         print("Login failed");
//       }
//       } on FirebaseAuthException catch (e) {
//         print("error: $e");
//         switch (e.code) {
//           case "account-exists-with-different-credential":
//             _errorCode = "You already have an account with us. Use correct provider";
//             _hasError = true;
//             notifyListeners();
//             break;

//           case "null":
//             _errorCode = "Some unexpected error while trying to sign in";
//             _hasError = true;
//             notifyListeners();
//             break;
//           default:
//             _errorCode = e.toString();
//             _hasError = true;
//             notifyListeners();
//         }
//       }
//   }



Future signInWithFacebook(value, BuildContext context) async {
  print('facebook');
    final authViewMode = Provider.of<AuthViewModel>(context,listen: false);

    try{

     final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ['email']);

    print("Result: ${loginResult.accessToken!.token}");

    final userData = await FacebookAuth.instance.getUserData();

    print("userData ${userData['name']}  ${userData['email']}");
    

    // final OAuthCredential facebookAuthCredential =
    //       FacebookAuthProvider.credential(loginResult.accessToken!.token);

    //       print("facebookAuthCredential ${facebookAuthCredential}");

    //   var authResult = await FirebaseAuth.instance
    //       .signInWithCredential(facebookAuthCredential);
      
    //   print("authResult ${authResult}");

        // save in registerApi
        if (userData.isNotEmpty) {
        Map data = {
          "full_name": userData['name'],
          "email":  userData['email'],
          "password": "",
          "source": "FACEBOOK",
          "role": value.toString(),
        };
        authViewMode.signUpApiWithSocials(data, context);
        // saving the values
        // _name = '';
        // // _email = authResult.user!.email;
        // _imageUrl = '';
        // // _uid = authResult.user!.uid;
        // _hasError = false;
        // _provider = "FACEBOOK";
        // _role=value.toString();
        notifyListeners();}
        else {
        print("Login failed");
      }
      } on FirebaseAuthException catch (e) {
        print("error: $e");
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
  }

// sign in with apple

Future signInWithApple(value, BuildContext context) async {
    final authViewMode = Provider.of<AuthViewModel>(context,listen: false);

    try{
      final AppleProvider = AppleAuthProvider();
      final userData = await FirebaseAuth.instance.signInWithProvider(AppleProvider);
        // Check if the user data is available
  String? displayName = userData.user?.displayName;
  String? email = userData.user?.email;

  if (displayName == null || email == null) {
    // Fetch user data from Firebase
    final user = FirebaseAuth.instance.currentUser;
    displayName = user?.displayName ?? "Apple User";
    email = user?.email ?? userData.user!.uid;

    // Update user profile if needed
    if (user != null && (user.displayName == null || user.email == null)) {
      // ignore: deprecated_member_use
      await user.updateProfile(displayName: displayName);
      await user.reload();
    }
  }

  print("userData ${userData.user!.emailVerified}");
  print("displayName ${userData.user!.uid}");
  print("email ${email}");
        // save in registerApi
        if (userData.user != null) {
        Map data = {
          "full_name": displayName,
          "email": email,
          "password": "",
          "source": "APPLE",
          "role": value.toString(),
        };
        authViewMode.signUpApiWithSocials(data, context);
        notifyListeners();}
        else {
        print("Login failed");
      }
      } on FirebaseAuthException catch (e) {
        print("error: $e");
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).get().then((DocumentSnapshot snapshot) => {
          _uid = snapshot['uid'],
          _name = snapshot['name'],
          _email = snapshot['email'],
          _imageUrl = snapshot['image_url'],
          _provider = snapshot['provider'],
          // _role = snapshot['role'],
          
         
          
        });
  }

  Future saveDataToFirestore() async {
    final DocumentReference r = FirebaseFirestore.instance.collection("users").doc(uid);
    await r.set({
      "name": _name,
      "email": _email,
      "uid": _uid,
      "image_url": _imageUrl,
      "provider": _provider,
     
      
      
    });
    debugPrint("thw value is set");
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('name', _name!);
    if (_email != null) {
      await s.setString('email', _email!);
    } else {
      await s.setString('email', '');
    }
    await s.setString('uid', _uid!);

    await s.setString('role', _role!);

    await s.setString('image_url', _imageUrl!);
    await s.setString('provider', _provider!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('name');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
   
    _provider = s.getString('provider');
    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      log("EXISTING USER");
      return true;
    } else {
      log("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
   
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    sharedPreferences.remove("fullname");
    sharedPreferences.remove("email");
    sharedPreferences.remove("image");
    sharedPreferences.remove("address");
    sharedPreferences.remove("latitude");
    sharedPreferences.remove("longitude");
    sharedPreferences.remove("number");
    sharedPreferences.remove("token");
    

 await firebaseAuth.signOut();
    await googleSignIn.signOut();
    await facebookAuth.logOut();
    _isSignedIn = false;

    FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    print(user.toString());
    if (user != null) {
      print("/////////////////////////////////////////////////////");
      print("////////////////////${user.displayName}//////////////////////");
      // print("///////////////////${sp.getDataFromSharedPreferences().then((value){sp.name.toString();})}///////////////");
    }

    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
// await s.remove('name');
// await s.remove('email');
// await s.remove('image_url');
// await s.remove('uid');
// await s.remove('provider');
// notifyListeners();
  }

  
}
