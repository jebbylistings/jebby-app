import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebby/Views/screens/agreements/JebbyAbout.dart';
import 'package:jebby/Views/screens/agreements/privacyPolicy.dart';
import 'package:jebby/Views/screens/auth/createnewpassword.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/profile/editprofile.dart';
import 'package:jebby/Views/support/FAQs.dart';
import 'package:jebby/res/color.dart';
import 'package:jebby/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';
import '../agreements/termsAndConditions.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  Future getProductsApi(id) async {
    try {
      final response = await http.get(
        Uri.parse('${Url}/UserProfileGetById/${id}'),
      );
      var data = jsonDecode(response.body.toString());
      datalength = data["data"].length;

      if (data["data"].length != 0) {
        if (mounted) {
          setState(() {
            imagesapi = data["data"][0]["image"].toString();
            nameapi = data["data"][0]["name"].toString();
            emailapi = data["data"][0]["email"].toString();
            isLoadingImage = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingImage = false;
          });
        }
      }

      if (response.statusCode == 200) {
        return data;
      } else {
        if (mounted) {
          setState(() {
            isLoadingImage = false;
          });
        }
        return "No data";
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingImage = false;
        });
      }
      return "No data";
    }
  }

  var imagesapi = "null";
  var nameapi = "null";
  var emailapi = "user email";
  var datalength;
  bool isLoadingImage = true;

  String? token;
  String? id;
  String? fullname;
  String? email;
  String? role;
  String Url = dotenv.env['baseUrlM'] ?? 'No url found';

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          id = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          getProductsApi(id);
          role = value.role.toString();

          final usp = context.read<UserViewModel>();
          if (usp.role != value.role.toString()) {
            usp.setRole(value.role.toString());
          }

          if (mounted) {
            setState(() {});
          }
        })
        .onError((error, stackTrace) {});
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  String getText(usp, sp) {
    if (usp.name == "null") {
      if (sp.name.toString() == "null") {
        return "user name";
      } else if (sp.phoneNumber.toString() != "null") {
        return sp.phoneNumber.toString();
      } else {
        return sp.name.toString();
      }
    } else {
      if (usp.name.toString() == "") {
        return usp.phoneNumber.toString();
      } else {
        return usp.name.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    final authViewMode = Provider.of<AuthViewModel>(context);
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    final usp = context.watch<UserViewModel>();
    final isProvider = usp.role == "1" || role == "1";
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    return Scaffold(
      backgroundColor: AppColors.greyColor,
      key: _key,
      appBar: AppBar(
        backgroundColor: AppColors.greyColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading:
            isProvider && Navigator.of(context).canPop()
                ? InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(50),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 20,
                  ),
                )
                : null,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: (Column(
            children: [
              SizedBox(height: res_height * 0.02),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isLoadingImage
                      ? CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                      : imagesapi != "null" && imagesapi.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: "${Url}${imagesapi}",
                        imageBuilder:
                            (context, imageProvider) => CircleAvatar(
                              radius: 40,
                              backgroundImage: imageProvider,
                            ),
                        placeholder:
                            (context, url) => CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[200],
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                "assets/slicing/blankuser.jpeg",
                              ),
                            ),
                      )
                      : CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          "assets/slicing/blankuser.jpeg",
                        ),
                      ),
                  SizedBox(width: 15),

                  Text(
                    getText(usp, sp),
                    style: TextStyle(
                      fontSize: 26 * textScaleFactor,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  getText(usp, sp).contains('+')
                      ? Container()
                      : Text(
                        (usp.email.toString() == "null" ||
                                usp.email.toString().contains("Phone"))
                            ? usp.phoneNumber.toString()
                            : usp.email.toString(),
                        style: TextStyle(
                          fontSize: 15 * textScaleFactor,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                ],
              ),
              SizedBox(height: 25),
              Image.asset(
                width: res_width * 0.9,
                "assets/newpacks/becomeprovider.png",
              ),
              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Card2(Icons.person, "Edit Profile", () {
                        Get.to(() => EditProfile());
                      }),
                      Card2(Icons.lock, "Change Password", () {
                        final ue = usp.email.toString();
                        String? pwdEmail;
                        if (ue != 'null' && !ue.contains('Phone')) {
                          pwdEmail = ue;
                        } else if (emailapi != 'user email' &&
                            emailapi.trim().isNotEmpty) {
                          pwdEmail = emailapi.trim();
                        }
                        if (pwdEmail == null || pwdEmail.isEmpty) {
                          Get.snackbar(
                            'Change Password',
                            'Add or fix your email in Edit Profile before changing password.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        Get.to(() => CreatePasswordScreen(email: pwdEmail));
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Card2(Icons.info, "About App", () {
                        Get.to(() => AboutScreen());
                      }),
                      Card2(Icons.quiz, "FAQs", () {
                        Get.to(() => const FAQs());
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Card2(Icons.description, "Terms & Conditions", () {
                        Get.to(() => TermsAndCondition());
                      }),
                      Card2(Icons.security, "Privacy & Security", () {
                        Get.to(() => PrivacyPolicy());
                      }),
                      Card2(Icons.warning, "Delete Account", () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                insetPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    18,
                                    18,
                                    14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.16,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1EF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.delete_forever_outlined,
                                              color: Color(0xFFE05848),
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "Delete Account",
                                              style: GoogleFonts.inter(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1B1B1F),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Are you sure you want to permanently delete your account? This action cannot be undone.",
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF72747A),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Get.back(),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.black87,
                                                side: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                SharedPreferences
                                                sharedPreferences =
                                                    await SharedPreferences.getInstance();
                                                Map data = {
                                                  "id": sharedPreferences
                                                      .getString('id'),
                                                  "role": sharedPreferences
                                                      .getString('role'),
                                                };
                                                authViewMode.DeleteAccount(
                                                  data,
                                                  context,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: const Color(
                                                  0xFFE05848,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      }),
                      Card2(Icons.logout, "Logout", () async {
                        final userPrefernece = Provider.of<UserViewModel>(
                          context,
                          listen: false,
                        );
                        userPrefernece.remove().then((value) {
                          Get.offAll(() => LoginScreen());
                        });
                        sp
                            .userSignOut()
                            .then((value) {
                              Get.offAll(() => LoginScreen());
                            })
                            .catchError((e) {
                              if (kDebugMode) {}
                            });
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.14),
            ],
          )),
        ),
      ),
    );
  }

  Card2(icon, Txts, VoidCallback onTap) {
    return Column(
      children: [
        SizedBox(height: 5),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              width: 373,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Icon(icon, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Txts,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
