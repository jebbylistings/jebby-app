import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/Messages(32).dart';
import 'package:jared/res/app_url.dart';
import 'package:provider/provider.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class Chat extends StatefulWidget {
  var targetID;

  Chat(this.targetID);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
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
      print("Source ID: ${sourceId}");
      getUserData();
      getMessageApi();
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
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
        sourceId.toString(), widget.targetID.toString(), (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isLoading = false;
            isEmpty = true;
            isError = false;
            print("null Data");
          });
        } else {
          print("Data Found");
          setState(() {
            isLoading = false;
            isError = false;
            isEmpty = false;
          });
        }
      }
    }, (error) {
      if (error != null) {
        setState(() {
          print("Error in data");
          isLoading = true;
          isError = true;
          isError = false;
        });
      }
    });
  }

  void sendMessage(msg, sender_id, recipient_id) {
    var data = {
      "msg": msg,
      "sender_id": sender_id,
      "recipient_id": recipient_id
    };
    ApiRepository.shared.postMessage(
        msg.toString(), sourceId.toString(), widget.targetID.toString());
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
                        print("EMPTY USER DATA");
                        userLoader = false;
                        userError = false;
                        userEmpty = true;
                        userImage = "";
                      })
                    }
                  else
                    {
                      setState(() {
                        userError = false;
                        userLoader = false;
                        userEmpty = false;
                        userImage = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].image
                            .toString();
                      })
                    }
                }
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
        sourceId.toString());
  }

  bool targetLoader = false;
  bool targetError = false;
  bool targetEmpty = true;
  var targetImage = "";

  void getTargetData() {
    print("getTargetDataCalled");
    ApiRepository.shared.userCredential(
        (List) => {
              if (this.mounted)
                {
                  if (List.data!.length == 0)
                    {
                      setState(() {
                        print("EMPTY USER DATA");
                        targetLoader = false;
                        targetError = false;
                        targetEmpty = true;
                        targetImage = "";
                      })
                    }
                  else
                    {
                      setState(() {
                        targetError = false;
                        targetLoader = false;
                        targetEmpty = false;
                        targetImage = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].image
                            .toString();
                      })
                    }
                }
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
        widget.targetID.toString());
  }

  void initState() {
    getData();
    profileData(context);
    print("Vendor ID ${widget.targetID}");
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
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
          //  Get.back();
          Ctimer.cancel();
          // Navigator.pop(context);
            Navigator.of(context)
            .push(MaterialPageRoute(builder: ((context) => MessagesScreen())));
            // Navigator.pop(context);
            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MessagesScreen()), (route) => false);
          },
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
            color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(children: [
          isLoading
              ? Center(child: Text("Loading Chats"))
              : isEmpty
                  ? Center(child: Text("start your chat"))
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: ApiRepository
                          .shared.getAllMessagesModelList!.data!.length,
                      itemBuilder: (context, index) {
                        var msg = ApiRepository.shared.getAllMessagesModelList!
                            .data![index].content
                            .toString();
                        String formattedDate = DateFormat('yyyy-MM-dd').format(
                            DateTime.parse(ApiRepository.shared
                                .getAllMessagesModelList!.data![index].timeSent
                                .toString()));
                        String formattedTime = DateFormat('hh:mm a').format(
                            DateTime.parse(ApiRepository.shared
                                .getAllMessagesModelList!.data![index].timeSent
                                .toString()));
                        var time = formattedTime;
                        var date = formattedDate;
                        var sender = ApiRepository.shared
                            .getAllMessagesModelList!.data![index].senderId
                            .toString();
                        // return(Text(msg));
                        return sender == sourceId
                            ? usermsg(msg, time, date)
                            : customersuppor(msg, time, date);
                      }),
          Container(
            height: res_height * 0.11,
          )
        ]),
      ),
      bottomSheet: getBottom(),
    );
  }

  Widget getBottom() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: _sendMessageController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                            hintStyle: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_sendMessageController.text.isNotEmpty) {
                        sendMessage(_sendMessageController.text, sourceId,
                            widget.targetID);
                        _sendMessageController.clear();
                        //  getMessageApi();
                      }
                    },
                    child: Icon(
                      Icons.send,
                      size: 35,
                      color: kprimaryColor,
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
      width: res_width * 0.9,
      child: Row(
        children: [
          Container(
            width: res_width * 0.2,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: targetImage == ""
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            AssetImage("assets/slicing/blankuser.jpeg"),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            AppUrl.baseUrlM + targetImage.toString()),
                      )),
          ),
          SizedBox(
            width: res_width * 0.03,
          ),
          Container(
            width: res_width * 0.67,
            child: Column(
              children: [
                Container(
                  width: res_width * 0.7,
                  decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Text(
                        msg,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(color: Color(0xffbfbab8)),
                    ),
                    Text(
                      time,
                     style: TextStyle(color: Color(0xffbfbab8)))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  usermsg(msg, time, date) {
    double res_width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: res_width * 0.9,
        child: Row(
          children: [
            Container(
              width: res_width * 0.67,
              child: Column(
                children: [
                  Container(
                    width: res_width * 0.7,
                    decoration: BoxDecoration(
                      color: Color(0xFF4285F4),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Text(
                          msg,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(color: Color(0xffbfbab8)),
                      ),
                      Text(time, style: TextStyle(color: Color(0xffbfbab8)))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: res_width * 0.03,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: res_width * 0.2,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: userImage == ""
                        ? CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                AssetImage("assets/slicing/blankuser.jpeg"),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                                AppUrl.baseUrlM + userImage.toString()),
                          )),
              ),
            ),
          ],
        ),
      ),
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
    print(" _socketResponse.sink.added");
    return _socketResponse.sink.add;
  }

  Stream<String> get getResponse {
    print(_socketResponse);
    return _socketResponse.stream;
  }

  void dispose() {
    _socketResponse.close();
  }
}
