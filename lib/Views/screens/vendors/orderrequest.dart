import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/vendors/orderequestdetail.dart';
import 'package:provider/provider.dart';
import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/postOrderStatusUpdateModel.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import 'package:flutter/foundation.dart';

class OrderRequests extends StatefulWidget {
  const OrderRequests({Key? key}) : super(key: key);

  @override
  State<OrderRequests> createState() => _OrderRequestsState();
}

class _OrderRequestsState extends State<OrderRequests> {
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
    ApiRepository.shared.getVenodorOrders(sourceId, (List) {
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

  void orderStatus(id, status, desc) {
    orderStatusUpdate(id, status, desc, sourceId, "listing");
    final snackBar = new SnackBar(content: new Text("Updating Status"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<PostOrderStatusUpdateModel> orderStatusUpdate(
      id, status, desc, vendorID, route) async {
    final request = json.encode(
        <String, dynamic>{"id": id, "status": status, "description": desc});

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
            setState(() {});
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
    print("INVOKEd");
    getData();
    profileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xfffdfdfd),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Orders',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            width: double.infinity,
            child: isError
                ? Center(child: Text("Some Error Occured"))
                : isLoading
                    ? Center(child: Text("Loading"))
                    : isEmpty
                        ? Center(child: Text("No Orders Yet"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: ApiRepository
                                .shared.getAllOrdersByVenodrIdList!.data!.length,
                            itemBuilder: (context, int index) {
                              var data = ApiRepository.shared
                                  .getAllOrdersByVenodrIdList!.data![index];
                              var name = data.name.toString();
                              var id = data.productId.toString();
                              var price = data.totalPrice.toString();
                              var start = data.rentStart.toString();
                              var end = data.originalReturn.toString();
                              var status = data.status;
                              var orderId = data.id;
                              var email = data.email.toString();
                              var location = data.location.toString();
                              var nego_price = data.negoPrice.toString();
                              return status == 0
                                  ? GestureDetector(
                                      onTap: () {
                                        Get.off(() => OrderRequestDetail(
                                              name : name,
                                              id: id,
                                              price: price,
                                              start: start,
                                              end: end,
                                              sourceId: sourceId,
                                              orderId: orderId,
                                              email: email,
                                              location: location,
                                              nego_price : nego_price,
                                            ));
                                      },
                                      child: reqBox(name, orderId))
                                  : SizedBox(height: 0, width: 0,);
                            })),
      ),
    );
  }

  Widget reqBox(name, orderId) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.95,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: res_width * 0.15,
                    child: Image.asset(
                      "assets/slicing/layer.png",
                      fit: BoxFit.none,
                      scale: 3,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: res_width * 0.45,
                        child: Text(
                         name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        ),
                      ),
                      SizedBox(
                        width: res_width * 0.45,
                        child: Text(
                          'Request your order',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 15),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Material(
                      color: Color(0xff39c0a9), // Button color
                      child: InkWell(
                        splashColor: Colors.red, // Splash color
                        onTap: () {
                          orderStatus(orderId, 1, "Order Approved");
                        },
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ClipOval(
                    child: Material(
                      color: Colors.grey, // Button color
                      child: InkWell(
                        splashColor: Colors.red, // Splash color
                        onTap: () {
                          orderStatus(orderId, 3, "Order Approved");
                        },
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
