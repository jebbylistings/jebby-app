import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/home/OrderConfirmation.dart';
import 'package:jebby/Views/screens/home/TrackingDetail.dart';
import 'package:jebby/res/app_url.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool alllbool = true;
  bool creditbool = false;
  bool debitbool = false;

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
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          sourceId = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          role = value.role.toString();
          getNewOrders();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  getNewOrders() {
    ApiRepository.shared.getAllOrdersByUserId(
      sourceId,
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

  bool ProdLoader = true;
  bool ProdError = false;

  getProducts() {
    ApiRepository.shared.allProducts(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  ProdLoader = false;
                  ProdError = false;
                }),
              }
            else
              {
                setState(() {
                  ProdLoader = false;
                  ProdError = false;
                }),
              },
          },
      },
      (error) => {
        if (this.mounted)
          {
            if (error != null)
              {
                setState(() {
                  ProdError = true;
                  ProdLoader = false;
                }),
              },
          },
      },
    );
  }

  void initState() {
    getProducts();
    getData();
    profileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body:
          isError
              ? Center(child: Text("Some Error Occured While Loading Data"))
              : isLoading
              ? Center(child: Text("Loading"))
              : isEmpty
              ? Center(child: Text("No Orders Found"))
              : Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    creditbool = false;
                                    alllbool = true;
                                    debitbool = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'All',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color:
                                            alllbool
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 120,
                                      color:
                                          alllbool
                                              ? Colors.grey
                                              : Color(0xff707070),
                                      height: alllbool ? 3 : 1,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() {
                                    alllbool = false;
                                    creditbool = true;
                                    debitbool = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'To Ship',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color:
                                            creditbool
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 120,
                                      color:
                                          creditbool
                                              ? Colors.grey
                                              : Color(0xff707070),
                                      height: creditbool ? 3 : 1,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    creditbool = false;
                                    alllbool = false;
                                    debitbool = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'Received',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color:
                                            debitbool
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      width: 120,
                                      color:
                                          debitbool
                                              ? Colors.grey
                                              : Color(0xff707070),
                                      height: debitbool ? 3 : 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        alllbool
                            ? Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    ApiRepository
                                        .shared
                                        .getAllOrdersByUserIdModelList!
                                        .data!
                                        .length,
                                itemBuilder: (context, int index) {
                                  var data =
                                      ApiRepository
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
                                  var long = double.parse(
                                    data.longitude.toString(),
                                  );
                                  var lat = double.parse(
                                    data.latitude.toString(),
                                  );
                                  var vendorID = data.vendorId.toString();
                                  var created1 = DateFormat('dd-MM-yy').format(
                                    DateTime.parse(data.createdAt.toString()),
                                  );
                                  var created = created1.toString();
                                  var approve = data.approveDate.toString();
                                  var complete = data.completeDate.toString();
                                  var cancel = data.cancelDate.toString();
                                  var nego = data.negoPrice;
                                  return Gesture1(
                                    name,
                                    date,
                                    price,
                                    status,
                                    id,
                                    image,
                                    prodId,
                                    location,
                                    long,
                                    lat,
                                    vendorID,
                                    created,
                                    approve,
                                    complete,
                                    cancel,
                                    nego,
                                  );
                                },
                              ),
                            )
                            : Container(),
                        creditbool
                            ? Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    ApiRepository
                                        .shared
                                        .getAllOrdersByUserIdModelList!
                                        .data!
                                        .length,
                                itemBuilder: (context, int index) {
                                  var data =
                                      ApiRepository
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
                                  var nego = data.negoPrice;
                                  return status == "1"
                                      ? toship(
                                        name,
                                        date,
                                        price,
                                        image,
                                        id,
                                        prodId,
                                        location,
                                        vendorID,
                                        nego,
                                      )
                                      : SizedBox(height: 0, width: 0);
                                },
                              ),
                            )
                            : Container(),
                        debitbool
                            ? Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    ApiRepository
                                        .shared
                                        .getAllOrdersByUserIdModelList!
                                        .data!
                                        .length,
                                itemBuilder: (context, int index) {
                                  var data =
                                      ApiRepository
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
                                  var long = double.parse(
                                    data.longitude.toString(),
                                  );
                                  var lat = double.parse(
                                    data.latitude.toString(),
                                  );
                                  var vendorID = data.vendorId.toString();
                                  var nego = data.negoPrice;
                                  return status == "2"
                                      ? Revievedd(
                                        name,
                                        date,
                                        price,
                                        image,
                                        id,
                                        prodId,
                                        location,
                                        long,
                                        lat,
                                        vendorID,
                                        nego,
                                      )
                                      : SizedBox(height: 0, width: 0);
                                },
                              ),
                            )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Revievedd(
    name,
    date,
    price,
    image,
    id,
    prodId,
    location,
    long,
    lat,
    vendorID,
    nego,
  ) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 391,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.network(AppUrl.baseUrlM + image),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 159,
                            child: Text(name, style: TextStyle(fontSize: 14)),
                          ),
                          Text(date, style: TextStyle(fontSize: 14)),
                          SizedBox(height: 10),
                          Text("Received", style: TextStyle(fontSize: 14)),
                          Row(
                            children: [
                              Text(
                                "${nego == 0 ? price : nego} \$",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 80),
                              // Text(
                              //   "Recieved",
                              //   style: TextStyle(fontSize: 14),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                nego == 0
                    ? GestureDetector(
                      onTap: () {
                        Get.to(
                          () => OrderConfirmationScreen(
                            image: image,
                            name: name,
                            price: price,
                            orderId: id,
                            prodId: prodId,
                            location: location,
                            long: long,
                            lat: lat,
                            username: fullname,
                            userid: sourceId,
                            vendorID: vendorID,
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        width: 371,
                        child: Center(
                          child: Text(
                            'Reorder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                    : Text("Negotiated Product"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  toship(name, date, price, image, id, prodId, location, vendorID, nego) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 391,
          // height: 175,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
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
                            child: Text(name, style: TextStyle(fontSize: 14)),
                          ),
                          Text(date, style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
                          Text("Shipped", style: TextStyle(fontSize: 14)),
                          Row(
                            children: [
                              Text(
                                "${nego == 0 ? price : nego} \$",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 80),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     // Container(
                //     //   height: 44,
                //     //   width: 170,
                //     //   child: Center(
                //     //     child: Text(
                //     //       'Type Review',
                //     //       style: TextStyle(
                //     //           fontWeight: FontWeight.bold, fontSize: 19),
                //     //     ),
                //     //   ),
                //     //   decoration: BoxDecoration(
                //     //       color: kprimaryColor,
                //     //       borderRadius: BorderRadius.circular(5)),
                //     // ),
                //     nego == 0 ? GestureDetector(
                //       onTap: () {
                //         Get.to(() => OrderConfirmationScreen(
                //               image: image,
                //               name: name,
                //               price: price,
                //               orderId: id,
                //               prodId: prodId,
                //               location: location,
                //               username: fullname,
                //               userid: sourceId,
                //               vendorID: vendorID,
                //             ));
                //       },
                //       child: Container(
                //         height: 44,
                //         width: 170,
                //         child: Center(
                //           child: Text(
                //             'Reorder',
                //             style: TextStyle(
                //                 fontWeight: FontWeight.bold, fontSize: 19),
                //           ),
                //         ),
                //         decoration: BoxDecoration(
                //             color: kprimaryColor,
                //             borderRadius: BorderRadius.circular(5)),
                //       ),
                //     ): Text("Negotiated Product")
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Toship2() {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 391,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.asset("assets/slicing/Layer 4@3x.png"),
                    ),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 159,
                            child: Text(
                              "Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            "Placed on Dec, 2022",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Text("Delivered", style: TextStyle(fontSize: 14)),
                          Row(
                            children: [
                              Text(
                                "\$ 15.59",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 80),
                              Text("Recieved", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 44,
                  width: 371,
                  child: Center(
                    child: Text(
                      'Reorder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Gesture1(
    name,
    date,
    price,
    status,
    id,
    image,
    prodId,
    location,
    long,
    lat,
    vendorID,
    created,
    approve,
    complete,
    cancel,
    nego,
  ) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 391,
          height: 265,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
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
                            child: Text(name, style: TextStyle(fontSize: 14)),
                          ),
                          Text(date, style: TextStyle(fontSize: 14)),
                          SizedBox(height: 10),
                          Text(
                            status == "0"
                                ? "Pending"
                                : status == "1"
                                ? "delivered"
                                : status == "2"
                                ? "received"
                                : "cancelled",
                            style: TextStyle(fontSize: 14),
                          ),
                          Row(
                            children: [
                              Text(
                                "${nego == 0 ? price : nego} \$",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 80),
                              // Text(
                              //   "Recieved",
                              //   style: TextStyle(fontSize: 14),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => TrackingDetailScreen(
                              date: date,
                              vendorId: vendorID,
                              status: status,
                              created: created,
                              approve: approve,
                              complete: complete,
                              cancel: cancel,
                            ),
                          );
                          // Get.to(() => OrderConfirmationScreen(
                          //       image: image,
                          //       name: name,
                          //       price: price,
                          //       orderId: id,
                          //       prodId: prodId,
                          //       location: location,
                          //       username: fullname,
                          //       userid: sourceId,
                          //       vendorID: vendorID,
                          //     ));
                        },
                        child: Container(
                          height: 44,
                          child: Center(
                            child: Text(
                              'Track',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: kprimaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Expanded(
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Get.to(() => TypeReviewsScreen());
                    //     },
                    //     child: Container(
                    //       height: 44,
                    //       child: Center(
                    //         child: Text(
                    //           'Type Review',
                    //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    //         ),
                    //       ),
                    //       decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(5)),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 8),
                    nego == 0
                        ? Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(
                                () => OrderConfirmationScreen(
                                  image: image,
                                  name: name,
                                  price: price,
                                  orderId: id,
                                  prodId: prodId,
                                  location: location,
                                  long: long,
                                  lat: lat,
                                  username: fullname,
                                  userid: sourceId,
                                  vendorID: vendorID,
                                ),
                              );
                            },
                            child: Container(
                              height: 44,
                              child: Center(
                                child: Text(
                                  'Reorder',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: kprimaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        )
                        : Center(child: Text("Negotiated Product")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Gesture2() {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 391,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
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
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 120,
                      height: 119,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.asset("assets/slicing/Layer 4@3x.png"),
                    ),
                    Container(
                      height: 119,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 159,
                            child: Text(
                              "Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            "Placed on Dec, 2022",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Text("Delivered", style: TextStyle(fontSize: 14)),
                          Row(
                            children: [
                              Text(
                                "\$ 15.59",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 80),
                              Text("Recieved", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 44,
                  width: 371,
                  child: Center(
                    child: Text(
                      'Reorder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.circular(5),
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
