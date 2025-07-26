import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/screens/home/Messages(32).dart';
// import 'package:jebby/screens/home/profile/myprofile.dart';
import 'package:jebby/Views/screens/profile/myprofile.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/deleteNotificationModel.dart';
import '../../../model/getNotificationModel.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../vendors/negotiationScreeen.dart';

class MessageScreen extends StatefulWidget {
  MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
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
          // seenNotification();

          getNotifications();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getNotifications() {
    ApiRepository.shared.notifications(
      sourceId,
      (List) {
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
      },
      (error) {
        if (error != null) {
          setState(() {
            isEmpty = false;
            isLoading = true;
            isError = true;
          });
        }
      },
    );
  }

  Future<GetNotificationModel> notifications(
    id,
    onResponse(GetNotificationModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllNotificationForApp + sourceId.toString()),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        // ApiRepository.shared.checkApiStatus(true, "getNotifications");
        var data = GetNotificationModel.fromJson(jsonDecode(response.body));

        ApiRepository.shared.getNotifications(data);

        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    return GetNotificationModel();
  }

  Future<DeleteNotificationModel> deleteNotification(id, ind) async {
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(
      Uri.parse(AppUrl.deleteNotification),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        notifications(id, (List) {
          if (this.mounted) {
            setState(() {});
          }
        }, (error) {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return DeleteNotificationModel();
  }

  seenNotification(id) {
    ApiRepository.shared.seenoneNotification(id);
  }

  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
      // drawer: DrawerScreen(onCloseDrawer: (){
      //   Get.back();
      // },),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
            // _key.currentState!.openDrawer();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => MyProfileScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: Icon(Icons.person_outline, color: Colors.black, size: 25),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              // isError
              //     ? Text("Error occured in loading data")
              isLoading
                  // ApiRepository.shared.getNotificationModelListApiStatus == false
                  ? Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        ApiRepository
                            .shared
                            .getNotificationModelList!
                            .data!
                            .length,
                    itemBuilder: (context, index) {
                      var name =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .name
                              .toString();
                      var desc =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .description
                              .toString();
                      var date =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .createdAt
                              .toString();
                      var formattedDate = DateFormat(
                        'dd-MM-yy',
                      ).format(DateTime.parse(date));
                      var id =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .id
                              .toString();
                      var ind = index;
                      var seen_one =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .seen_one
                              .toString();
                      var prodId =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .productId
                              .toString();
                      var status =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .status;
                      var price =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .price;
                      var negoId =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .negoId
                              .toString();
                      var userId =
                          ApiRepository
                              .shared
                              .getNotificationModelList!
                              .data![index]
                              .userId
                              .toString();

                      //
                      // return card(name, count, desc, date, id, ind);
                      return name == "order"
                          ? SizedBox(height: 0, width: 0)
                          : GestureDetector(
                            onTap: () {
                              seenNotification(id);
                              getNotifications();
                              name == "message"
                                  ? Get.to(() => MessagesScreen())
                                  : name == "negotiation"
                                  ? Get.to(
                                    () => NegotiationScreen(
                                      prodId: prodId,
                                      status: status,
                                      price: price,
                                      negoId: negoId,
                                      userId: userId,
                                    ),
                                  )
                                  : null;
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(Icons.notifications),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name),
                                        SizedBox(height: 4),
                                        Text(
                                          desc,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight:
                                                seen_one == "0"
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(formattedDate),
                                  SizedBox(width: 2),
                                  name == "admin"
                                      ? Text("")
                                      : GestureDetector(
                                        onTap: () {
                                          deleteNotification(id, ind);
                                        },
                                        child: Container(
                                          child: Icon(Icons.close),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  card(name, count, desc, time, id, ind) {
    double res_width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        name == "message" ? Get.to(() => MessagesScreen()) : null;
      },
      child: Container(
        width: res_width * 0.9,
        // height: res_height * 0.09,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  SizedBox(height: 4),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(desc),
                  ),
                ],
              ),
              Text(time),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  name == "admin" ? null : deleteNotification(id, ind);
                },
                child: name == "admin" ? null : Icon(Icons.close_outlined),
              ),
            ],
          ),
          //  ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text(name),
          //   subtitle: Text(desc),
          //   trailing: SizedBox(child: Row(children: [Text(time), Text("x")],),),
          // )
        ),
      ),
    );
  }
}
