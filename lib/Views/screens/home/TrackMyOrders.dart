import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/home/TrackingDetail.dart';
import 'package:jared/res/app_url.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class TrackMyOrdersScreen extends StatefulWidget {
  const TrackMyOrdersScreen({super.key});

  @override
  State<TrackMyOrdersScreen> createState() => _TrackMyOrdersScreenState();
}

class _TrackMyOrdersScreenState extends State<TrackMyOrdersScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

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
      getNewOrders();
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  getNewOrders() {
    ApiRepository.shared.getAllOrdersByUserId(sourceId, (List) {
      if (this.mounted) {
        if (List.data!.length == 0) {
          setState(() {
            isLoading = false;
            isEmpty = true;
            isError = false;
            print("null Data");
          });
        } else {
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
          isLoading = true;
          isError = true;
          isError = false;
        });
      }
    });
  }

  void initState() {
    getData();
    profileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Track My Orders",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: isError
          ? Center(child: Text("Some Error Occured"))
          : isLoading
              ? Center(child: Text("Loading"))
              : isEmpty
                  ? Center(child: Text("No Orders Found"))
                  : Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              // Container(
                              //   width: 391,
                              //   height: 195,
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     boxShadow: [
                              //       BoxShadow(
                              //         color: Colors.grey.withOpacity(0.2),
                              //         spreadRadius: 5,
                              //         blurRadius: 7,
                              //         offset: Offset(0, 3), // changes position of shadow
                              //       ),
                              //     ],
                              //   ),
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 10),
                              //     child: Column(
                              //       children: [
                              //         SizedBox(
                              //           height: 10,
                              //         ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //   children: [
                              //     Container(
                              //       width: 137,
                              //       height: 119,
                              //       decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         boxShadow: [
                              //           BoxShadow(
                              //             color: Colors.grey.withOpacity(0.2),
                              //             spreadRadius: 5,
                              //             blurRadius: 7,
                              //             offset: Offset(
                              //                 0, 3), // changes position of shadow
                              //           ),
                              //         ],
                              //       ),
                              //       child:
                              //           Image.asset("assets/slicing/Layer 4@3x.png"),
                              //     ),
                              //     Container(
                              //       height: 119,
                              //       child: Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Container(
                              //               width: 159,
                              //               child: Text(
                              //                 "Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB",
                              //                 style: TextStyle(fontSize: 14),
                              //               )),
                              //           Text(
                              //             "Placed on Dec, 2022",
                              //             style: TextStyle(fontSize: 14),
                              //           ),
                              //           SizedBox(
                              //             height: 10,
                              //           ),
                              //           Text(
                              //             "Delivered",
                              //             style: TextStyle(fontSize: 14),
                              //           ),
                              //           Text(
                              //             "\$ 15.59",
                              //             style: TextStyle(
                              //                 fontSize: 20,
                              //                 fontWeight: FontWeight.bold),
                              //           ),
                              //         ],
                              //       ),
                              //     )
                              //   ],
                              // ),
                              // SizedBox(
                              //   height: 16,
                              // ),
                              // GestureDetector(
                              //   onTap: () {
                              //     Get.to(() => TrackingDetailScreen());
                              //   },
                              //   child: Container(
                              //     height: 44,
                              //     width: 391,
                              //     child: Center(
                              //       child: Text(
                              //         'Track',
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold, fontSize: 19),
                              //       ),
                              //     ),
                              //     decoration: BoxDecoration(
                              //         color: kprimaryColor,
                              //         borderRadius: BorderRadius.circular(5)),
                              //   ),
                              // ),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                              ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: ApiRepository
                                      .shared
                                      .getAllOrdersByUserIdModelList!
                                      .data!
                                      .length,
                                  itemBuilder: (context, int index) {
                                    var data = ApiRepository
                                        .shared
                                        .getAllOrdersByUserIdModelList!
                                        .data![index];
                                    var name = data.productName;
                                    var price = data.totalPrice.toString();
                                    var date = data.rentStart.toString();
                                    var status = data.status.toString();
                                    var id = data.id.toString();
                                    var image = data.productImage.toString();
                                    var prodId = data.productId.toString();
                                    var location = data.location.toString();
                                    var vendorID = data.vendorId.toString();
                                    var created1 = DateFormat('dd-MM-yy')
                                        .format(DateTime.parse(
                                            data.createdAt.toString()));
                                    var created = created1.toString();
                                    print(created);
                                    var approve = data.approveDate.toString();
                                    var complete = data.completeDate.toString();
                                    var cancel = data.cancelDate.toString();
                                    var nego = data.negoPrice;
                                    return Tracks(
                                        image,
                                        name,
                                        date,
                                        status,
                                        price,
                                        vendorID,
                                        created,
                                        approve,
                                        complete,
                                        cancel,
                                        nego);
                                  }),
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Tracks(image, name, date, status, price, vendorId, created, approve, complete,
      cancel, nego) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: 391,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
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
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 137,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.network(AppUrl.baseUrlM + image),
                    ),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 159,
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 14),
                              )),
                          Text(
                            "Placed on ${date}",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Text(
                          //   status == "0"
                          //       ? "Pending"
                          //       : status == "1"
                          //           ? "Approved"
                          //           : status == "2"
                          //               ? "Reached"
                          //               : "Cancelled",
                          //   style: TextStyle(fontSize: 14),
                          // ),
                          Text(
                            "${nego == 0 ? price : nego} \$",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => TrackingDetailScreen(
                          date: date,
                          vendorId: vendorId,
                          status: status,
                          created: created,
                          approve: approve,
                          complete: complete,
                          cancel: cancel,
                        ));
                  },
                  child: Container(
                    height: 44,
                    width: 391,
                    child: Center(
                      child: Text(
                        'Track',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
