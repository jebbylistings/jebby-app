import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/vendors/OrderReq.dart';
import 'package:jared/res/app_url.dart';
import 'package:http/http.dart' as http;
import '../../../model/postOrderStatusUpdateModel.dart';
import '../../../view_model/apiServices.dart';

class OrderDetailScreen extends StatefulWidget {
  var prodId;
  var name;
  var price;
  var start;
  var end;
  var vendorId;
  var orderId;
  var orderComplete;
  var route;
  var email;
  var location;
  var nego_price;

  OrderDetailScreen(
      {this.prodId,
      this.name,
      this.price,
      this.start,
      this.end,
      this.vendorId,
      this.orderId,
      this.orderComplete,
      this.route,
      this.email,
      this.location,
      this.nego_price});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailStateScreen();
}

class _OrderDetailStateScreen extends State<OrderDetailScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;
  var image = "";
  var name = "";
  void getProduct() {
    ApiRepository.shared.getProductsById(
        (list) => {
              if (this.mounted)
                {
                  if (list.data!.length == 0)
                    {
                      setState(() {
                        isLoading = false;
                        isError = false;
                        isEmpty = true;
                      })
                    }
                  else
                    {
                      setState(() {
                        isLoading = false;
                        isError = false;
                        isEmpty = false;
                        image = ApiRepository.shared.getProductsByIdList!.data![1].images![0].path.toString();
                        name = ApiRepository.shared.getProductsByIdList!.data![0].name.toString();
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    isLoading = false;
                    isError = true;
                    isEmpty = false;
                  })
                }
            },
        widget.prodId.toString());
  }

  void orderStatus(id, status, desc) {
    orderStatusUpdate(id, status, desc, widget.vendorId, widget.route.toString());
    final snackBar = new SnackBar(content: new Text("Updating Status"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<PostOrderStatusUpdateModel> orderStatusUpdate(id, status, desc, vendorID, route) async {
    final request = json.encode(<String, dynamic>{"id": id, "status": status, "description": desc});

    print(request);
    final response = await http.post(
      Uri.parse(AppUrl.orderStatusById),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        print("Order Status Updated");
        ApiRepository.shared.getVenodorOrders(vendorID.toString(), (List) {
          if (this.mounted) {
            Get.off(() => OrderRequestScreen());
          }
        }, (error) {});
      } catch (error) {
        print("Order Status :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return PostOrderStatusUpdateModel();
  }

  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22 * textScaleFactor),
        ),
        elevation: 0,
        centerTitle: true,
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
      ),
      body: isLoading
          ? Center(child: Text("Loading"))
          : Center(
              child: Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row(
                        //   children: [
                        //     Container(
                        //       child: Text(
                        //         "Order Status",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 20,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          width: res_width * 0.9,
                          height: res_height * 0.25,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            child: Image.network(
                              AppUrl.baseUrlM + image.toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 18 * textScaleFactor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "${widget.price} \$",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18 * textScaleFactor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer Name:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: res_height * 0.01,
                            ),
                            Text("${widget.name}"),
                          ],
                        ),
                        //  Text("Customer Name: ${widget.name}"),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: res_height * 0.01,
                            ),
                            Text("${widget.email}"),
                          ],
                        ),
                        // Center(child: Text("Email: ${widget.email}")),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                child: Text(
                              "Location:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            SizedBox(
                              height: res_height * 0.01,
                            ),
                            Container(child: Text("${widget.location}")),
                          ],
                        ),
                        // Center(child: Text("Delivery Location: ${widget.location}")),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       "Discount :",
                        //       style: TextStyle(fontWeight: FontWeight.bold),
                        //     ),
                        //      SizedBox(
                        //       height: 10,
                        //     ),
                        //     Text(" ${widget.nego_price} \$"),
                        //   ],
                        // ),
                        // Center(child: Text("Negotiation Price: ${widget.nego_price}")),
                        // SizedBox(
                        //   height: 19,
                        // ),
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Duration:",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: res_height * 0.01,
                                  ),

                                  Container(
                                      child: Text(
                                          "${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.start.toString())).toString()} to ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.end.toString())).toString()}")),
                                  // Row(
                                  //   children: [
                                  //     Text("${widget.start} "),
                                  //     Text(
                                  //       "to",
                                  //       style: TextStyle(fontWeight: FontWeight.bold),
                                  //     ),
                                  //     Text(" ${widget.end}"),
                                  //   ],
                                  // )
                                ],
                              ),
                              //  Text(
                              //   "Start : ${widget.start} to End ${widget.end}",
                              //   style: TextStyle(
                              //     color: Colors.grey,
                              //     fontSize: 18,
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 19,
                        ),
                        GestureDetector(
                            onTap: () {
                              orderStatus(widget.orderId, 2, "Order Completed");
                            },
                            child: widget.orderComplete == 0
                                ? Center(
                                    child: Container(
                                      width: 297,
                                      height: 58,
                                      decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(12)),
                                      child: Center(
                                        child: Text(
                                          'Reached Logistic Facility',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  )
                                : Text("")),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
