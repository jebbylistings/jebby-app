import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jared/Views/screens/vendors/OrderReq.dart';
import 'package:jared/res/app_url.dart';
import 'package:jared/view_model/apiServices.dart';

import '../../../model/postOrderStatusUpdateModel.dart';

class OrderDetail1Screen extends StatefulWidget {
  var image;
  var name;
  var price;
  var quantity;
  var start;
  var end;
  var id;
  var status;
  var orderId;
  var vendorId;
  var email;
  var location;
  var nego_price;

  OrderDetail1Screen(this.image, this.name, this.price, this.quantity, this.start, this.end, this.id, this.status, this.orderId, this.vendorId,
      this.email, this.location, this.nego_price);

  @override
  State<OrderDetail1Screen> createState() => _OrderDetailStateScreen();
}

class _OrderDetailStateScreen extends State<OrderDetail1Screen> {
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
        widget.id.toString());
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

  void orderStatus(id, status, desc) {
    orderStatusUpdate(id, status, desc, widget.vendorId, "new");
    final snackBar = new SnackBar(content: new Text("Updating Status"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void initState() {
    print(widget.id);
    getProduct();
    super.initState();
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
                      children: [
                        SizedBox(
                          height: res_height * 0.03,
                        ),
                        // SizedBox(
                        //   height: 30,
                        // ),
                        Container(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.09),
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
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  width: res_width * 0.75,
                                  height: res_height * 0.2,
                                  child: Image.network(AppUrl.baseUrlM + image, fit: BoxFit.cover,),
                                ),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 18 * textScaleFactor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
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
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Text(
                                          "Duration:",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )),
                                        SizedBox(
                                          height: res_height * 0.01,
                                        ),
                                        Container(
                                            child: Text(
                                                "${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.start.toString())).toString()} to ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.end.toString())).toString()}")),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
                                  children: [
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
                                  ],
                                ),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            "Email:",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: res_height * 0.01,
                                        ),
                                        Container(child: Text("${widget.email}")),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Text(
                                          "Delivery Location:",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        )),
                                        SizedBox(
                                          height: res_height * 0.01,
                                        ),
                                        Container(
                                            // width: 300,
                                            child: Text("${widget.location}")),
                                      ],
                                    ),
                                  ],
                                ),
                                // Text("Delivery Location: ${widget.location}"),
                                // SizedBox(
                                //   height: 20,
                                // ),
                                // Row(
                                //   children: [
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           "Discount :",
                                //           style: TextStyle(fontWeight: FontWeight.bold),
                                //         ),
                                //         SizedBox(
                                //           height: 10,
                                //         ),
                                //         Text("${widget.nego_price}"),
                                //       ],
                                //     ),
                                //   ],
                                // ),
                                // Text("Negotiation Price: ${widget.nego_price}"),
                                SizedBox(
                                  height: res_height * 0.02,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text("Approve"),
                                    ),
                                    SizedBox(
                                      width: res_width * 0.02,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        orderStatus(widget.orderId, 1, "Order Approved");
                                      },
                                      child: Container(
                                        width: res_width * 0.1,
                                        height: res_height * 0.038,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 122, 236, 126)),
                                        child: Icon(
                                          Icons.check,
                                          size: 20 * textScaleFactor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: res_width * 0.04,
                                    ),
                                    Container(
                                      child: Text("Cancel"),
                                    ),
                                    SizedBox(
                                      width: res_width * 0.02,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        orderStatus(widget.orderId, 3, "Order Cancelled");
                                      },
                                      child: Container(
                                        width: res_width * 0.1,
                                        height: res_height * 0.038,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                                        child: Icon(
                                          Icons.close,
                                          size: 20 * textScaleFactor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
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
