import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:jared/Views/screens/vendors/OrderDetail.dart';
import 'package:jared/Views/screens/vendors/OrderDetail1.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';

class OrderRequestScreen extends StatefulWidget {
  const OrderRequestScreen({super.key});

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  @override
  var selcted = 1;

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
            // Get.to(() => MainScreen());
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          "Order Details",
          style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: "Inter, Black"),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selcted = 1;
                    });
                  },
                  child: Container(
                    height: 37,
                    width: 122,
                    decoration: BoxDecoration(
                      color: selcted == 1 ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: Colors.amber),
                    ),
                    child: Center(
                      child: Text(
                        "New Orders",
                        style: TextStyle(color: selcted == 1 ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selcted = 2;
                    });
                  },
                  child: Container(
                    height: 37,
                    width: 122,
                    decoration: BoxDecoration(
                        color: selcted == 2 ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.amber)),
                    child: Center(
                      child: Text(
                        "Pending",
                        style: TextStyle(
                          color: selcted == 2 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selcted = 3;
                    });
                  },
                  child: Container(
                    height: 37,
                    width: 122,
                    decoration: BoxDecoration(
                        color: selcted == 3 ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.amber)),
                    child: Center(
                      child: Text(
                        "Completed",
                        style: TextStyle(color: selcted == 3 ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            selcted == 1
                ? Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          isError
                              ? Center(child: Text("An Error Occured"))
                              : isLoading
                                  ? Center(child: Text("Loading"))
                                  : isEmpty ? Center(child: Text("No New Order")) :
                                       ApiRepository.shared.getAllOrdersByVenodrIdList!.data!.where((ele) => ele.status == 0 ).isEmpty ?
                                      Center(child: Text("No Orders"))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: ApiRepository.shared.getAllOrdersByVenodrIdList!.data!.length,
                                          itemBuilder: (context, int index) {
                                            var data = ApiRepository.shared.getAllOrdersByVenodrIdList!.data![index];
                                            var status = data.status;
                                            var image = "";
                                            var name = data.name.toString();
                                            var price = data.totalPrice.toString();
                                            var quantity = "";
                                            var start = data.rentStart.toString();
                                            var end = data.originalReturn.toString();
                                            var id = data.productId.toString();
                                            var orderId = data.id;
                                            var email = data.email.toString();
                                            var location = data.location.toString();
                                            var nego_price = data.negoPrice.toString();
                                            // var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.createdAt.toString()));
                                            return status == 0
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Get.off(() => OrderDetail1Screen(image, name, price, quantity, start, end, id, status, orderId,
                                                          sourceId, email, location, nego_price));
                                                    },
                                                    child: neworderwidget(
                                                      name: name,
                                                      id: id,
                                                      // date: date,
                                                    ),
                                                  )
                                                : SizedBox(height: 0,);
                                          }),
                        ],
                      ),
                    ),
                  )
                : selcted == 2
                    ? Container(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              isError
                                  ? Center(child: Text("An Error Occured"))
                                  : isLoading
                                      ? Center(child: Text("Loading"))
                                      : isEmpty
                                          ? Center(child: Text("No New Order"))
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: ApiRepository.shared.getAllOrdersByVenodrIdList!.data!.length,
                                              itemBuilder: (context, int index) {
                                                var data = ApiRepository.shared.getAllOrdersByVenodrIdList!.data![index];
                                                var status = data.status;
                                                var image = "";
                                                var name = data.name.toString();
                                                var price = data.totalPrice.toString();
                                                var quantity = "";
                                                var start = data.rentStart.toString();
                                                var end = data.originalReturn.toString();
                                                var id = data.productId.toString();
                                                var orderId = data.id;
                                                var email = data.email.toString();
                                                var location = data.location.toString();
                                                var nego_price = data.negoPrice.toString();
                                                return status == 1
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          Get.off(() => OrderDetailScreen(
                                                                prodId: id,
                                                                name: name,
                                                                price: price,
                                                                start: start,
                                                                end: end,
                                                                vendorId: sourceId,
                                                                orderId: orderId,
                                                                orderComplete: 0,
                                                                route: "pending",
                                                                email: email,
                                                                location: location,
                                                                nego_price: nego_price,
                                                              ));
                                                        },
                                                        child: pendingwidget(
                                                          name: name,
                                                        ),
                                                      )
                                                    : SizedBox(height: 0);
                                              }),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          isError
                              ? Center(child: Text("An Error Occured"))
                              : isLoading
                                  ? Center(child: Text("Loading"))
                                  : isEmpty
                                      ? Center(child: Text("No New Order"))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: ApiRepository.shared.getAllOrdersByVenodrIdList!.data!.length,
                                          itemBuilder: (context, int index) {
                                            var data = ApiRepository.shared.getAllOrdersByVenodrIdList!.data![index];
                                            var status = data.status;
                                            var image = "";
                                            var name = data.name.toString();
                                            var price = data.totalPrice.toString();
                                            var quantity = "";
                                            var start = data.rentStart.toString();
                                            var end = data.originalReturn.toString();
                                            var id = data.productId.toString();
                                            var orderId = data.id;
                                            var email = data.email.toString();
                                            var location = data.location.toString();
                                            var nego_price = data.negoPrice.toString();
                                            return status == 2
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Get.to(() => OrderDetailScreen(
                                                            prodId: id,
                                                            name: name,
                                                            price: price,
                                                            start: start,
                                                            end: end,
                                                            vendorId: sourceId,
                                                            orderId: orderId,
                                                            orderComplete: 1,
                                                            route: "complete",
                                                            email: email,
                                                            location: location,
                                                            nego_price: nego_price,
                                                          ));
                                                    },
                                                    child: pendingwidget(
                                                      name: name,
                                                    ),
                                                  )
                                                : SizedBox(height: 0);
                                          }),
                        ],
                      )
          ]),
        ),
      ),
    );
  }
}

class pendingwidget extends StatelessWidget {
  String name;
  pendingwidget({
    required this.name,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: res_height * 0.125,
          decoration: BoxDecoration(
            color: Color(0xffFFFFFF),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: res_width * 0.02,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.amber),
                child: Image.asset(
                  "assets/slicing/layer.png",
                  fit: BoxFit.none,
                  scale: 3,
                ),
              ),
              SizedBox(
                width: res_width * 0.02,
              ),
              SizedBox(
                width: res_width * 0.83,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "View Details",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: res_height * 0.01,)
      ],
    );
  }
}

class neworderwidget extends StatefulWidget {
  String name;
  var id;
  // var date;
  neworderwidget({
    required this.name,
    this.id,
    // this.date,
    Key? key,
  }) : super(key: key);

  @override
  State<neworderwidget> createState() => _neworderwidgetState();
}

class _neworderwidgetState extends State<neworderwidget> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: res_height * 0.125,
          decoration: BoxDecoration(
            color: Color(0xffFFFFFF),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 8), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: res_width * 0.02,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.amber),
                child: Image.asset(
                  "assets/slicing/layer.png",
                  fit: BoxFit.none,
                  scale: 3,
                ),
              ),
              SizedBox(
                width: res_width * 0.02,
              ),
              SizedBox(
                width: res_width * 0.83,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     widget.name,
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Request your order",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    )
                  ],
                ),
              ),
              // SizedBox(
              //   width: 90,
              // ),
              // Container(child: Text(widget.date),)
              // Container(
              //   width: 35,
              //   height: 35,
              //   decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: Color.fromARGB(255, 122, 236, 126)),
              //   child: Icon(
              //     Icons.check,
              //     size: 20,
              //   ),
              // ),
              // SizedBox(
              //   width: 10,
              // ),
              // Container(
              //   width: 35,
              //   height: 35,
              //   decoration:
              //       BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
              //   child: Icon(
              //     Icons.close,
              //     size: 20,
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(height: res_height * 0.01,)
      ],
    );
  }
}
