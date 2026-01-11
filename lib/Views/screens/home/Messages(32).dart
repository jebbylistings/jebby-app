import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/controller/bottomcontroller.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/home/chat.dart';
import 'package:jebby/res/app_url.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';
import '../../../model/getChatHistoryModel.dart' as datamodel;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  /// ---------------- EXISTING ----------------
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
    getUserDate()
        .then((value) async {
      token = value.token.toString();
      sourceId = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      get_chat_history();
      seenNotification();
    })
        .onError((error, stackTrace) {
      if (kDebugMode) {}
    });
  }

  seenNotification() {
    ApiRepository.shared.seenNotification(sourceId);
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  get_chat_history() {
    ApiRepository.shared.chatsHistory(
      sourceId.toString(),
          (List) {
        if (this.mounted) {
          List.data!.add(
            datamodel.Data(
              id: 1,
              name: 'Abhi',
              image: '',
              count: 2,
              lastMessage: "Hello can we sign contract",
              lastMessageTime: "2023-08-03T20:12:00Z",
            ),
          );
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
      },
          (error) {
        if (error != null) {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = true;
          });
        }
      },
    );
  }

  late var Mtimer;

  @override
  void initState() {
    Mtimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => get_chat_history(),
    );
    getData();
    profileData(context);
    super.initState();
  }

  @override
  void dispose() {
    Mtimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  final bottomctrl = Get.put(BottomController());

  /// ---------------- SEARCH (ADDED ONLY) ----------------
  TextEditingController _searchController = TextEditingController();
  String searchText = "";

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14.0, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: 'Chat',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xffF2F2F2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              /// -------- SEARCH BAR --------
              searchBar(),

              isError
                  ? const Text("Error occured in loading data")
                  : isLoading
                  ? const CircularProgressIndicator()
                  : ApiRepository
                  .shared
                  .getChatsHistoryModelList!
                  .data!
                  .length ==
                  0
                  ? const Text("No messages",
                  style: TextStyle(fontSize: 14))
                  : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: ApiRepository
                    .shared
                    .getChatsHistoryModelList!
                    .data!
                    .length,
                itemBuilder: (context, index) {
                  /// -------- FILTER + REVERSE --------
                  var reversedData = ApiRepository
                      .shared
                      .getChatsHistoryModelList!
                      .data!
                      .reversed
                      .where((element) {
                    if (searchText.isEmpty) return true;
                    return element.name
                        .toString()
                        .toLowerCase()
                        .contains(searchText);
                  })
                      .toList();

                  var element = reversedData[index];

                  var name = element.name;
                  var image = element.image.toString();
                  var targetId = element.id.toString();
                  var count = element.count.toString();
                  var lastMessage =
                  element.lastMessage.toString();
                  var lastMessageTime =
                  element.lastMessageTime.toString();

                  return msgs(
                    name,
                    image,
                    targetId,
                    count,
                    lastMessage,
                    lastMessageTime,
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- SEARCH BAR UI ----------------
  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FB),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: "Search",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- MESSAGE TILE ----------------
  msgs(name, img, id, count, lastMsg, lastMessageTime) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Mtimer.cancel();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => Chat(id))));
      },
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: res_height * 0.1,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    height: res_height * 0.070,
                    width: res_width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: img == ""
                        ? Image.asset(
                      "assets/newpacks/chatpersonicon.png",
                    )
                        : CircleAvatar(
                      backgroundImage:
                      NetworkImage(AppUrl.baseUrlM + img),
                    ),
                  ),
                  SizedBox(width: res_width * 0.05),
                  SizedBox(
                    width: res_width * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name == "" ? "Vendor" : name,
                          style: TextStyle(
                            fontWeight: count == "0"
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        Text(
                          lastMsg.length > 30
                              ? lastMsg.substring(0, 20) + '...'
                              : lastMsg,
                          style: TextStyle(
                            color: const Color(0xff8F9098),
                            fontWeight: count != "0"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat('MMM dd, yyyy hh:mm a').format(
                            DateTime.parse(lastMessageTime).toLocal(),
                          ),
                          style: const TextStyle(
                            color: Color(0xff8F9098),
                            fontWeight: FontWeight.bold,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  count != "0"
                      ? CircleAvatar(
                    backgroundColor: kprimaryColor,
                    radius: 15,
                    child: Text(
                      count,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
