import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';

class NegotiationRequest extends StatefulWidget {
  var price;
  var status;
  var productId;
  var negoId;

  NegotiationRequest({this.price, this.status, this.productId, this.negoId});

  @override
  State<NegotiationRequest> createState() => _NegotiationRequestState();
}

class _NegotiationRequestState extends State<NegotiationRequest> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  var originalPrice = "";
  var negMargin = "";
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
                        print(image);
                        name = ApiRepository.shared.getProductsByIdList!.data![0].name.toString();
                        originalPrice = ApiRepository.shared.getProductsByIdList!.data![0].price2.toString();
                        negMargin = ApiRepository.shared.getProductsByIdList!.data![0].negotiation.toString();
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
        widget.productId.toString());
  }

  updateRequest(status) {
    ApiRepository.shared.negotiationRequestUpdate(status, widget.negoId, context);
  }

  bool negoLoading = true;
  bool negoError = false;
  bool negoEmpty = false;

  var negoStatus;

  void nego() {
    ApiRepository.shared.negoById(
        (list) => {
              if (this.mounted)
                {
                  if (list.data!.length == 0)
                    {
                      setState(() {
                        negoLoading = false;
                        negoError = false;
                        negoEmpty = true;
                      })
                    }
                  else
                    {
                      setState(() {
                        negoLoading = false;
                        negoError = false;
                        negoEmpty = false;
                        negoStatus = ApiRepository.shared.getNegoByIdModelList!.data![0].negoStatus;
                        print("nego status ${negoStatus}");
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    negoLoading = false;
                    negoError = true;
                    negoEmpty = false;
                  })
                }
            },
        widget.negoId.toString());
  }

  void initState() {
    nego();
    getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
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
                    // padding: const EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
                          // width: 399,
                          // height: 400,
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
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.height * 0.55,
                                  height: MediaQuery.of(context).size.width * 0.45,
                                  child: Image.network(AppUrl.baseUrlM + image),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 18,
                                ),
                                Text(
                                  "Original Price: ${originalPrice} \$",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                Text(
                                  "Discount Margin: ${negMargin} %",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                Text(
                                  "Negotiated Requested: ${widget.price} \$",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.04,
                                ),
                                negoLoading
                                    ? Text("")
                                    : negoStatus == 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(left: 100),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Text("Approve"),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    // orderStatus(widget.orderId,
                                                    //     1, "Order Approved");
                                                    updateRequest(1);
                                                  },
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 122, 236, 126)),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  child: Text("Cancel"),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    // orderStatus(widget.orderId, 3, "Order Cancelled");
                                                    updateRequest(2);
                                                  },
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
                                            negoStatus == 1 ? "Request was approved" : "Request was cancelled",
                                            style: TextStyle(color: negoStatus == 1 ? Colors.green : Colors.red),
                                          )
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
