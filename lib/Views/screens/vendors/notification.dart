import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/screens/vendors/OrderReq.dart';
import 'package:jebby/Views/screens/vendors/negotiationRequest.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/deleteNotificationModel.dart';
import '../../../model/getNotificationModel.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../home/Messages(32).dart';

class VendorNotifications extends StatefulWidget {
  const VendorNotifications({super.key});

  @override
  State<VendorNotifications> createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
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

  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black),
          onPressed: (){
            Get.back();
          },
        ),

        actions: [

          Padding(
            padding: const EdgeInsets.only(right:16),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/slicing/avatar.png"),
            ),
          )
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(

        padding: const EdgeInsets.symmetric(horizontal:16),

        child: ListView.builder(

          itemCount: ApiRepository
              .shared
              .getNotificationModelList!
              .data!
              .length,

          itemBuilder: (context,index){

            var data = ApiRepository
                .shared
                .getNotificationModelList!
                .data![index];

            String name = data.name.toString();
            String desc = data.description.toString();
            String id = data.id.toString();
            String seen = data.seen_one.toString();
            String date = data.createdAt.toString();

            var formattedDate =
            DateFormat('hh:mm a')
                .format(DateTime.parse(date));

            /// navigation data
            var prodId = data.productId.toString();
            var status = data.status;
            var price = data.price.toString();
            var negoId = data.negoId;

            return GestureDetector(

              onTap: () {

                seenNotification(id);

                name == "message"
                    ? Get.to(()=>MessagesScreen())

                    : name == "order"
                    ? Get.to(()=>OrderRequestScreen())

                    : name == "negotiation"
                    ? Get.to(()=>NegotiationRequest(
                  price: price,
                  status: status,
                  productId: prodId,
                  negoId: negoId,
                ))
                    : null;
              },

              child: Container(

                margin: const EdgeInsets.only(bottom:14),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    /// DOT

                    Container(
                      margin: const EdgeInsets.only(top:6),
                      width:10,
                      height:10,
                      decoration: BoxDecoration(
                        color: seen == "0"
                            ? Colors.orange
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width:12),

                    /// TEXT AREA

                    Expanded(

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                            children: [

                              Text(
                                name.capitalizeFirst!,
                                style: const TextStyle(
                                  fontSize:16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize:13,
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height:6),

                          Text(
                            desc,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize:14,
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(width:6),

                    /// DELETE BUTTON

                    GestureDetector(
                      onTap: (){
                        deleteNotification(id,index);
                      },
                      child: const Icon(
                        Icons.close,
                        size:18,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  card(name, count, desc, time, id, ind, seen) {
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
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontWeight:
                            seen == "0" ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
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
