import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/screens/vendors/OrderReq.dart';
import 'package:jared/Views/screens/vendors/negotiationRequest.dart';
import 'package:jared/Views/screens/vendors/renterProfile.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/deleteNotificationModel.dart';
import '../../../model/getNotificationModel.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../home/Messages(32).dart';
import '../mainfolder/drawer.dart';

class VendorNotifications extends StatefulWidget {
  const VendorNotifications({super.key});

  @override
  State<VendorNotifications> createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
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
     
     
      // seenNotification();
     
      getNotifications();
    }).onError((error, stackTrace) {
      if (kDebugMode) {
       
      }
    });
  }

  Future<GetNotificationModel> notifications(
      id, onResponse(GetNotificationModel List), onError(error)) async {
   
    final response = await http.get(
        Uri.parse(AppUrl.getAllNotificationForApp + sourceId.toString()),
        headers: {
          'Content-type': "application/json",
        });
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
      headers: {
        'Content-type': "application/json",
      },
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
    ApiRepository.shared.notifications(sourceId, (List) {
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
          isLoading = true;
          isError = true;
        });
      }
    });
  }

  void initState() {
    super.initState();
    getData();
    profileData(context);
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
      drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     Get.to(() => RenterProfile());
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.all(19.0),
          //     child: Container(
          //       child: Image.asset('assets/slicing/avatar.png'),
          //     ),
          //   ),
          // )
        ],
      ),
      // backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: isLoading 
          // ApiRepository.shared.getNotificationModelListApiStatus == false
              ? Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()))
              : ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ApiRepository
                      .shared.getNotificationModelList!.data!.length,
                  itemBuilder: (context, int index) {
                    var name = ApiRepository
                        .shared.getNotificationModelList!.data![index].name
                        .toString();
                    var count = ApiRepository
                        .shared.getNotificationModelList!.data![index].seen
                        .toString();
                    var desc = ApiRepository.shared.getNotificationModelList!
                        .data![index].description
                        .toString();
                    var id = ApiRepository
                        .shared.getNotificationModelList!.data![index].id
                        .toString();
                    var seen = ApiRepository
                        .shared.getNotificationModelList!.data![index].seen
                        .toString();
                        var seen_one = ApiRepository
                        .shared.getNotificationModelList!.data![index].seen_one
                        .toString();
                    var ind = index;
                    var date = ApiRepository
                        .shared.getNotificationModelList!.data![index].createdAt
                        .toString();
                    var formattedDate =
                        DateFormat('dd-MM-yy').format(DateTime.parse(date));
                        //
                    var prodId = ApiRepository
                        .shared.getNotificationModelList!.data![index].productId.toString();
                    var status = ApiRepository
                        .shared.getNotificationModelList!.data![index].status;
                    var price = ApiRepository
                        .shared.getNotificationModelList!.data![index].price.toString();
                    var negoId = ApiRepository
                        .shared.getNotificationModelList!.data![index].negoId;
                    //
                    // return card(name, count, desc, date, id, ind, seen);
                    return GestureDetector(
                      onTap: () {
                        getNotifications();
                        seenNotification(id);
                        name == "message"
                            ? Get.to(() => MessagesScreen())
                            : name == "order"
                                ? Get.to(() => OrderRequestScreen())
                                : 
                                name == "negotiation" ?
                                Get.to(() => NegotiationRequest(price: price, status: status, productId: prodId, negoId: negoId,)) : null;
                      },
                      child: name == "admin" ? SizedBox() : Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.notifications),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      desc,
                                      style: TextStyle(
                                          fontWeight: seen_one == "0"
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    )),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(formattedDate),
                            SizedBox(
                              width: 2,
                            ),
                            
                            name == "admin"
                                ? Text("")
                                : GestureDetector(
                                    onTap: () {
                                      deleteNotification(id, ind);
                                    },
                                    child: Container(child: Icon(Icons.close)))
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  }),
        ),
      ),
    );
  }

  card(name, count, desc, time, id, ind, seen) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
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
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          desc,
                          style: TextStyle(
                              fontWeight: seen == "0"
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        )),
                  ],
                ),
                Text(time),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                     
                      name == "admin" ? null : deleteNotification(id, ind);
                    },
                    child: name == "admin" ? null : Icon(Icons.close_outlined)),
              ],
            )
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
