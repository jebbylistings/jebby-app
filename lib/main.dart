import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/vendors/vendorhome.dart';
import 'package:jared/provider/prodetail_provider.dart';

import 'package:jared/view_model/auth_view_model.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services/firebase_authMethod.dart';
import 'Services/provider/internet_provider.dart';
import 'Services/provider/sign_in_provider.dart';
import 'package:provider/provider.dart';

import 'provider/get_products_provider.dart';
import 'view_model/services/splash_services.dart';
import 'view_model/user_view_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'].toString();
  runApp(
    OverlaySupport.global(
      child: MyApp(), // Replace with your actual app widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()..getUserName()),
          Provider<FirebaseAuthMethods>(create: (_) => FirebaseAuthMethods(FirebaseAuth.instance)),
          StreamProvider(create: (context) => context.read<FirebaseAuthMethods>().authState, initialData: null),
          ChangeNotifierProvider(create: ((context) => SignInProvider())),
          ChangeNotifierProvider(create: ((context) => InternetProvider())),
          ChangeNotifierProvider(create: (_) => UserViewModel()),
          ChangeNotifierProvider(create: (_) => UserNameProvider()),
          ChangeNotifierProvider<ProductProvider>(create: (context) => ProductProvider()),
          ChangeNotifierProvider<ProDetailProvider>(create: (context) => ProDetailProvider()),
        ],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen(),
        ));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashServices = SplashServices();

  @override
  void initState() {
    isLogin();
    super.initState();
  }

  var Name;

  void isLogin() async {
    // final sp = context.read<SignInProvider>();
    FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Name = sharedPreferences.getString('fullname') ?? "";
    //
    if (user != null) {
      Timer(const Duration(seconds: 2), () {
        // if (sharedPreferences.getString('role').toString() == "1") {
        //   Get.offAll(() => VendrosHomeScreen());
        // } else {
          Get.offAll(() => MainScreen());
        // }
      });
    } else {
      String _name = sharedPreferences.getString('fullname') ?? "";

      context.read<AuthViewModel>().userName = _name;
      if (_name == "Guest") {
        Timer(const Duration(seconds: 2), () {
          Get.offAll(() => MainScreen());
        });
      } else {
        splashServices.checkAuthentication(context);
        // Timer(const Duration(seconds: 2), () {Get.to(() => LoginScreen());});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: res_height * 0.38,
                ),
                Container(width: res_width * 0.7, child: Image.asset('assets/slicing/logo.png')),
                SizedBox(
                  height: res_height * 0.028,
                ),
                Text('Explore Renting At\n Your Fingertips',
                    textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 23)),
                SizedBox(
                  height: res_height * 0.028,
                ),
                GestureDetector(
                  onTap: () {
                    // Get.to(() => LoginScreen());
                    // Get.to(() => MainScreen());
                  },
                  child: Container(
                    width: res_width * 0.5,
                    decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(
                        'Discover Now',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
