import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/mainfolder/drawer.dart';
import 'package:jared/view_model/apiServices.dart';
import 'package:provider/provider.dart';

import '../../../Services/provider/sign_in_provider.dart';
import '../../../model/user_model.dart';
import '../../../view_model/user_view_model.dart';

class TransactionListScreen extends StatefulWidget {
  TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

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
    final GlobalKey<ScaffoldState> _key = GlobalKey();

    return Scaffold(
      key: _key,
      // drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaction List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
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
          child: Column(
            children: [
              // Container(
              //   width: res_width * 0.9,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Container(
              //             width: res_width * 0.3,
              //             child: TextButton(
              //               onPressed: () {},
              //               child: Text(
              //                 'All',
              //                 style: TextStyle(color: Colors.grey),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             width: res_width * 0.3,
              //             decoration: BoxDecoration(
              //               border: Border.all(
              //                 color: Colors.grey,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Container(
              //             width: res_width * 0.3,
              //             child: TextButton(
              //               style: ButtonStyle(
              //                 alignment: Alignment.center,
              //               ),
              //               onPressed: () {},
              //               child: Text(
              //                 'Incoming',
              //                 style: TextStyle(color: kprimaryColor),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             width: res_width * 0.3,
              //             decoration: BoxDecoration(
              //               border: Border.all(
              //                 color: kprimaryColor,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Container(
              //             width: res_width * 0.3,
              //             child: TextButton(
              //               style: ButtonStyle(
              //                 alignment: Alignment.center,
              //               ),
              //               onPressed: () {},
              //               child: Text(
              //                 'Outgoing',
              //                 style: TextStyle(color: Colors.grey),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             width: res_width * 0.3,
              //             decoration: BoxDecoration(
              //               border: Border.all(
              //                 color: Colors.grey,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: res_height * 0.018,
              ),
              isError ? Text("Error in loading data") :
              isLoading ? Text("Loading") : 
              isEmpty ? Text("No transactions yet") :
             ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:  ApiRepository.shared.getAllOrdersByVenodrIdList!.data!.length,
              itemBuilder: (context, int index){
                var data =  ApiRepository.shared.getAllOrdersByVenodrIdList!.data![index];
                var name = data.name.toString();
                var price = data.totalPrice.toString();
                var email = data.email.toString();
                var status = data.status.toString();
                var negoprice = data.negoPrice.toString();
                var cancel_date = data.cancelDate.toString();
                return card(name, price, email, negoprice, cancel_date);
              }),
              SizedBox(
                height: res_height * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }

  card(name, price, email, negoprice, cancel_date) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return cancel_date.toString().isNotEmpty ? SizedBox() : Container(
      width: res_width * 0.9,
      // height: res_height * 0.09,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: res_height * 0.05,
                      width: res_width * 0.1,
                      child: Image.asset('assets/slicing/chip.png'),
                    ),
                    SizedBox(
                      width: res_width * 0.03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${negoprice != '0' ? negoprice : price} \$',
                  style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
