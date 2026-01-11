import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/res/app_url.dart';
import 'package:provider/provider.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class Chat extends StatefulWidget {
  final dynamic targetID;

  Chat(this.targetID);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
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
  String? phoneNumber;
  String? role;

  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          phoneNumber = value.phoneNumber.toString();
          email = value.email.toString();
          role = value.role.toString();
          getUserData();
          getMessageApi();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  late var Ctimer;
  var messages = [];
  bool socketConnected = false;
  bool msgData = false;

  // var url = "https://192.168.18.39:7000/InsertMessage";
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;
  TextEditingController _sendMessageController = TextEditingController();

  void getMessageApi() {
    ApiRepository.shared.getMessagesApi(
      sourceId.toString(),
      widget.targetID.toString(),
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isLoading = false;
              isEmpty = true;
              isError = false;
            });
          } else {
            setState(() {
              isLoading = false;
              isError = false;
              isEmpty = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isLoading = true;
            isError = true;
            isError = false;
          });
        }
      },
    );
  }

  void sendMessage(msg, sender_id, recipient_id) {
    ApiRepository.shared.postMessage(
      msg.toString(),
      sourceId.toString(),
      widget.targetID.toString(),
    );
  }

  bool userLoader = false;
  bool userError = false;
  bool userEmpty = true;
  var userImage = "";

  void getUserData() {
    ApiRepository.shared.userCredential(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  userLoader = false;
                  userError = false;
                  userEmpty = true;
                  userImage = "";
                }),
              }
            else
              {
                setState(() {
                  userError = false;
                  userLoader = false;
                  userEmpty = false;
                  userImage =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .image
                          .toString();
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              userError = true;
              userLoader = false;
              userEmpty = false;
              userImage = "";
            }),
          },
      },
      sourceId.toString(),
    );
  }

  bool targetLoader = false;
  bool targetError = false;
  bool targetEmpty = true;
  var targetImage = "";

  void getTargetData() {
    ApiRepository.shared.userCredential(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  targetLoader = false;
                  targetError = false;
                  targetEmpty = true;
                  targetImage = "";
                }),
              }
            else
              {
                setState(() {
                  targetError = false;
                  targetLoader = false;
                  targetEmpty = false;
                  targetImage =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .image
                          .toString();
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              targetError = true;
              targetLoader = false;
              targetEmpty = false;
              targetImage = "";
            }),
          },
      },
      widget.targetID.toString(),
    );
  }

  void initState() {
    getData();
    profileData(context);
    getTargetData();
    Ctimer = new Timer.periodic(Duration(seconds: 2), (_) => getMessageApi());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    Ctimer.cancel();
  }

  Widget build(BuildContext context) {
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset(
              "assets/newpacks/chatpersonicon.png",
              height: 30,
              width: 30,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              'Abhi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 19,
              ),
            ),
          ],
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
            Ctimer.cancel();
            // Navigator.pop(context);
            // Navigator.of(context)
            // .push(MaterialPageRoute(builder: ((context) => MessagesScreen())));
            // Navigator.pop(context);
            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MessagesScreen()), (route) => false);
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            isLoading
                ? Center(child: Text("Loading Chats"))
                : isEmpty
                ? Center(child: Text("start your chat"))
                : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      ApiRepository
                          .shared
                          .getAllMessagesModelList!
                          .data!
                          .length,
                  itemBuilder: (context, index) {
                    var msg =
                        ApiRepository
                            .shared
                            .getAllMessagesModelList!
                            .data![index]
                            .content
                            .toString();
                    String formattedDate = DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(
                      DateTime.parse(
                        ApiRepository
                            .shared
                            .getAllMessagesModelList!
                            .data![index]
                            .timeSent
                            .toString(),
                      ),
                    );
                    String formattedTime = DateFormat('hh:mm a').format(
                      DateTime.parse(
                        ApiRepository
                            .shared
                            .getAllMessagesModelList!
                            .data![index]
                            .timeSent
                            .toString(),
                      ),
                    );
                    var time = formattedTime;
                    var date = formattedDate;
                    var sender =
                        ApiRepository
                            .shared
                            .getAllMessagesModelList!
                            .data![index]
                            .senderId
                            .toString();
                    // return(Text(msg));
                    return sender == sourceId
                        ? usermsg(msg, time, date)
                        : customersuppor(msg, time, date);
                  },
                ),
            Container(height: res_height * 0.11),
          ],
        ),
      ),
      bottomSheet: getBottom(),
    );
  }

  Widget getBottom() {
    return Container(
      height: 80,
      width: double.infinity,
      color: Color(0xffF2F2F2),
      //  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        controller: _sendMessageController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_sendMessageController.text.isNotEmpty) {
                        sendMessage(
                          _sendMessageController.text,
                          sourceId,
                          widget.targetID,
                        );
                        _sendMessageController.clear();
                        //  getMessageApi();
                      }
                    },
                    child: Image.asset(
                      'assets/newpacks/chatsendicon.png',
                      height: 40,
                      width: 40,
                   //   color: kprimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  customersuppor(msg, time, date) {
    double res_width = MediaQuery.of(context).size.width;
    return Container(
      width: res_width * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: res_width * 0.75,
            margin: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Color(0xffF8F9FE),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
               // bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [

                // Container(
                //   width: res_width * 0.2,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child:
                //         targetImage == ""
                //             ? CircleAvatar(
                //               backgroundColor: Colors.grey,
                //               backgroundImage: AssetImage(
                //                 "assets/slicing/blankuser.jpeg",
                //               ),
                //             )
                //             : CachedNetworkImage(
                //               imageUrl:
                //                   AppUrl.baseUrlM + targetImage.toString(),
                //               imageBuilder:
                //                   (context, imageProvider) => CircleAvatar(
                //                     backgroundImage: imageProvider,
                //                   ),
                //               placeholder:
                //                   (context, url) => Center(
                //                     child: SizedBox(
                //                       width: 30,
                //                       height: 30,
                //                       child: CircularProgressIndicator(
                //                         strokeWidth: 2.0,
                //                       ),
                //                     ),
                //                   ),
                //               errorWidget:
                //                   (context, url, error) => Icon(Icons.error),
                //             ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Container(
                      width: res_width * 0.6,
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 5,
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                // Text(time, style: TextStyle(color: Color(0xffbfbab8)))
              ],
            ),
          ),
        ],
      ),
    );
  }

  usermsg(msg, time, date) {
    double res_width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: res_width * 0.75,
          child: Column(
            children: [
              Container(
                width: res_width * 0.9,
                decoration: BoxDecoration(
                  color: Color(0xFF1F2024),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  //  bottomRight: Radius.circular(20),
                    topRight:  Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(

                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: res_width * 0.6,
                          child: Text(
                            msg,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   width: res_width * 0.2,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child:
                    //         userImage == ""
                    //             ? CircleAvatar(
                    //               backgroundColor: Colors.grey,
                    //               backgroundImage: AssetImage(
                    //                 "assets/slicing/blankuser.jpeg",
                    //               ),
                    //             )
                    //             : CircleAvatar(
                    //               backgroundColor:
                    //                   Colors
                    //                       .transparent, // Optional: Background color
                    //               child: CachedNetworkImage(
                    //                 imageUrl:
                    //                     AppUrl.baseUrlM + userImage.toString(),
                    //                 imageBuilder:
                    //                     (context, imageProvider) => CircleAvatar(
                    //                       backgroundImage: imageProvider,
                    //                     ),
                    //                 placeholder:
                    //                     (context, url) => Center(
                    //                       child: SizedBox(
                    //                         width: 30,
                    //                         height: 30,
                    //                         child: CircularProgressIndicator(
                    //                           strokeWidth: 2.0,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 errorWidget:
                    //                     (context, url, error) =>
                    //                         Icon(Icons.error),
                    //               ),
                    //             ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 5,
                  bottom: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    // Text(time, style: TextStyle(color: Colors.black, fontSize: 12))
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}

class MessageModel {
  String? Message;
  String? type;

  MessageModel({this.Message, this.type});
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse {
    return _socketResponse.sink.add;
  }

  Stream<String> get getResponse {
    return _socketResponse.stream;
  }

  void dispose() {
    _socketResponse.close();
  }
}
