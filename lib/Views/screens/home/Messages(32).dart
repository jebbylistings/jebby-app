import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:jared/Views/controller/bottomcontroller.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/chat.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/res/app_url.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate().then((value) async {
      token = value.token.toString();
      sourceId = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      get_chat_history();
      seenNotification();
      print("Source ID: ${sourceId}");
      print("role: ${role}");
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  get_chat_history() {
    ApiRepository.shared.chatsHistory(sourceId.toString(), (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isEmpty = true;
            isLoading = false;
            isError = false;
          });
        } else {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          isEmpty = false;
          isLoading = false;
          isError = true;
        });
      }
    });
  }

  late var Mtimer;

  void initState() {
    print("Backed with");
    Mtimer = new Timer.periodic(Duration(seconds: 5), (_) => get_chat_history());
    getData();
    profileData(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Mtimer.cancel();
  }

  final bottomctrl = Get.put(BottomController());

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          // child: Center(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: 'Messages', style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
                // TextSpan(
                //     text: '(32)',
                //     style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 17,
                //         color: Color(0xffFEB038))),
              ],
            ),
          ),
          // ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            print("navigated");
            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false);
            // Get.back();
            // Navigator.pop(context);
            print("role : ${role}");
            // if (bottomctrl.navigationBarIndexValue != 0) {
            bottomctrl.navBarChange(0);
            // }
            // Navigator.of(context).push(MaterialPageRoute(builder: ((context) => MainScreen())));
            Mtimer.cancel();
            Navigator.push(context, MaterialPageRoute(builder: ((context) => MainScreen())));
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                isError
                    ? Text("Error occured in loading data")
                    : isLoading
                        ? CircularProgressIndicator()
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: ApiRepository.shared.getChatsHistoryModelList!.data!.length,
                            itemBuilder: (context, index) {
                              // Access elements in reversed order using reversed.toList()
                              var reversedData = ApiRepository.shared.getChatsHistoryModelList!.data!.reversed.toList();
                              var element = reversedData[index];

                              var name = element.name;
                              var image = element.image.toString();
                              var targetId = element.id.toString();
                              var count = element.count.toString();
                              var lastMessage = element.lastMessage.toString();

                              print("index: ${index} count: ${count}");
                              return msgs(name, image, targetId, count, lastMessage);
                            },
                          ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  msgs(name, img, id, count, lastMsg) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        Mtimer.cancel();
        Navigator.of(context).push(MaterialPageRoute(builder: ((context) => Chat(id))));
      },
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            height: res_height * 0.114,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        height: res_height * 0.070,
                        width: res_width * 0.15,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
                        child: img == ""
                            ? Image.asset("assets/slicing/blankuser.jpeg")
                            : CircleAvatar(
                                backgroundImage: NetworkImage(AppUrl.baseUrlM + img),
                              ),
                      ),
                      SizedBox(
                        width: res_width * 0.05,
                      ),
                      SizedBox(
                        width: res_width * 0.55,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name == "" ? "Vendor" : name,
                              style: TextStyle(fontWeight: count == "0" ? FontWeight.normal : FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              lastMsg.length > 30 ? lastMsg.substring(0, 20) + '...' : lastMsg,
                              style: TextStyle(fontWeight: count != "0" ? FontWeight.bold : FontWeight.normal),
                            )
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   width: 110,
                      // ),
                      count != "0"
                          ? CircleAvatar(
                              backgroundColor: kprimaryColor,
                              radius: 15,
                              child: Text(
                                count,
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : Text("")
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
