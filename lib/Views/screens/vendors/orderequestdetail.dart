import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/screens/vendors/orderrequest.dart';
import 'package:jebby/res/app_url.dart';
import 'package:http/http.dart' as http;
import '../../../model/postOrderStatusUpdateModel.dart';
import '../../../view_model/apiServices.dart';

class OrderRequestDetail extends StatefulWidget {
  final dynamic name;
  final dynamic price;
  final dynamic id;
  final dynamic start;
  final dynamic end;
  final dynamic sourceId;
  final dynamic orderId;
  final dynamic email;
  final dynamic location;
  final dynamic nego_price;
  OrderRequestDetail({
    this.name,
    this.id,
    this.price,
    this.start,
    this.end,
    this.sourceId,
    this.orderId,
    this.email,
    this.location,
    this.nego_price,
  });

  @override
  State<OrderRequestDetail> createState() => _OrderRequestDetailState();
}

class _OrderRequestDetailState extends State<OrderRequestDetail> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;
  var image = "";
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
                }),
              }
            else
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  isEmpty = false;
                  image =
                      ApiRepository
                          .shared
                          .getProductsByIdList!
                          .data![1]
                          .images![0]
                          .path
                          .toString();
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              isLoading = false;
              isError = true;
              isEmpty = false;
            }),
          },
      },
      widget.id.toString(),
    );
  }

  Future<PostOrderStatusUpdateModel> orderStatusUpdate(
    id,
    status,
    desc,
    vendorID,
    route,
  ) async {
    final request = json.encode(<String, dynamic>{
      "id": id,
      "status": status,
      "description": desc,
    });

    final response = await http.post(
      Uri.parse(AppUrl.orderStatusById),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        ApiRepository.shared.getVenodorOrders(vendorID.toString(), (List) {
          if (this.mounted) {
            setState(() {});
            Get.off(() => OrderRequests());
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
    return PostOrderStatusUpdateModel();
  }

  void orderStatus(id, status, desc) {
    orderStatusUpdate(id, status, desc, widget.sourceId, "listing");
    final snackBar = new SnackBar(content: new Text("Updating Status"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void initState() {
    getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order Request',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body:
          isLoading
              ? Center(child: Text("Loading"))
              : Center(
                child: Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: res_width * 0.9,
                          child: Column(
                            children: [
                              itmBox(
                                img:
                                    ApiRepository
                                        .shared
                                        .getProductsByIdList!
                                        .data![1]
                                        .images![0]
                                        .path
                                        .toString(),
                                dx: widget.price,
                                rv: '(2.9k Revews)',
                                tx:
                                    ApiRepository
                                        .shared
                                        .getProductsByIdList!
                                        .data![0]
                                        .name
                                        .toString(),
                                rt: '4.9',
                                start: widget.start,
                                end: widget.end,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  itmBox({img, tx, dx, rt, rv, start, end}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.9,
      // height: res_height * 0.28,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 244, 244, 244),
        borderRadius: BorderRadius.circular(10),
      ),
      // child: Padding(
      //   padding: const EdgeInsets.only(
      //       bottom: 120, left: 10, right: 10, top: 10),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          children: [
            Container(
              height: res_height * 0.2,
              // width: res_width * 0.8,
              // decoration: BoxDecoration(color: Colors.white),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image.network(AppUrl.baseUrlM + img, fit: BoxFit.fill),
              ),
            ),
            SizedBox(height: res_height * 0.005),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('$tx', style: TextStyle(fontSize: 14.5)),
                  SizedBox(height: res_height * 0.01),
                  Center(
                    child: Text(
                      '$dx \$',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: res_height * 0.005),
                  Center(
                    child: Text(
                      "start ${DateFormat('dd/MM/yyyy').format(DateTime.parse(start))} End ${DateFormat('dd/MM/yyyy').format(DateTime.parse(end))}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: res_height * 0.01),
                  Text("Customer Name: ${widget.name}"),
                  SizedBox(height: res_height * 0.01),
                  Text("Email: ${widget.email}"),
                  SizedBox(height: res_height * 0.01),
                  Text("Delivery Location: ${widget.location}"),
                  SizedBox(height: res_height * 0.01),
                  //  Text("Discount Price: ${widget.nego_price}"),
                  // SizedBox(
                  //   height: res_height * 0.01,
                  // ),
                  Divider(color: Colors.grey, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Approved',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: res_width * 0.01),
                      GestureDetector(
                        onTap: () {
                          orderStatus(widget.orderId, 1, "Approved");
                        },
                        child: Icon(
                          Icons.check_circle,
                          size: 35,
                          color: Color.fromARGB(255, 135, 216, 138),
                        ),
                      ),
                      SizedBox(width: res_width * 0.01),
                      Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: res_width * 0.01),
                      GestureDetector(
                        onTap: () {
                          orderStatus(widget.orderId, 3, "Cancelled");
                        },
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
