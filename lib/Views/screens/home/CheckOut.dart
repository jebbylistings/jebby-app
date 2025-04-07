import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:jebby/Services/provider/sign_in_provider.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/auth/register.dart';
import 'package:jebby/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import 'package:http/http.dart' as http;

import '../../../view_model/user_view_model.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

// ignore: must_be_immutable
class CheckoutScreen extends StatefulWidget {
  var userId;
  var productID;
  var rentStart;
  var rentEnd;
  String vendorName;
  String vendorAddress;
  String cell;
  String vendorImage;
  var vendorID;
  var pastart;
  var paend;
  var price;
  var vendorAccountId;
  var vendorPayPalEmail;
  // var accountId;
  // var paypalMail;
  var userName;
  var email;
  var location;
  var lat;
  var long;
  // var route;
  var negoPrice;
  var delivery_charges;
  var JebbyFee;
  var security_deposit;
  var zipCode;
  var countryCode;

  CheckoutScreen(
    this.userId,
    this.productID,
    this.rentStart,
    this.rentEnd,
    this.vendorName,
    this.vendorAddress,
    this.cell,
    this.vendorImage,
    this.vendorID,
    this.pastart,
    this.paend,
    this.price,
    this.vendorAccountId,
    this.vendorPayPalEmail,
    this.userName,
    this.email,
    this.location,
    this.lat,
    this.long,
    this.negoPrice,
    // this.route,
    this.delivery_charges,
    this.JebbyFee,
    this.security_deposit,
    this.zipCode,
    this.countryCode,
  );

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final termscontroller = Get.put(TermsController());
  bool onlinepay = false;
  bool cod = false;

  var fromdate;
  var todate;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  var _locationController = TextEditingController();
  double taxValue = 0;
  Future<void> getSalesTax() async {
    String apiKey = dotenv.env['apiKey'] ?? 'No secret key found';
    final apiUrl = 'https://api.taxjar.com/v2/rates?zip=${widget.zipCode}';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = json.decode(response.body);
      // Access the tax rates
      final taxRates = jsonResponse['rate']['combined_rate'];
      // Use taxRates for further processing
      setState(() {
        // taxRate = double.parse(taxRates);
        taxValue = double.parse(taxRates);
      });
    } else {
      // Handle errors here
    }
  }

  var dc;
  var diff = 0;
  var Jebby;

  void initState() {
    getSalesTax();
    getData();
    profileData(context);
    emailController.text = widget.email;
    _locationController.text = widget.location;
    selectedDate = DateTime.parse(widget.rentStart);
    selectedDate1 = DateTime.parse(widget.rentEnd);
    diff = selectedDate1.difference(selectedDate).inDays;
    dc = int.parse(
      widget.delivery_charges.replaceAll(new RegExp(r'[^0-9]'), ''),
    );
    Jebby = int.parse(widget.JebbyFee.replaceAll(new RegExp(r'[^0-9]'), ''));

    super.initState();
  }

  Future getData() async {
    final sp = context.read<SignInProvider>();
    final usp = context.read<UserViewModel>();
    usp.getUser();
    sp.getDataFromSharedPreferences();
  }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String userID = "";
  String? fullname;
  String? email;
  String? phoneNumber;
  String? role;
  void profileData(BuildContext context) async {
    getUserDate()
        .then((value) async {
          token = value.token.toString();
          userID = value.id.toString();
          fullname = value.name.toString();
          email = value.email.toString();
          phoneNumber = value.phoneNumber.toString();
          role = value.role.toString();
        })
        .onError((error, stackTrace) {
          if (kDebugMode) {}
        });
  }

  int generateRandomNumber() {
    Random random = Random();
    return random.nextInt(1000000); // Adjust range as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child:
                      ApiRepository
                                  .shared
                                  .getProductsByIdList!
                                  .data![1]
                                  .images!
                                  .length >
                              0
                          ? SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              separatorBuilder:
                                  (context, index) => SizedBox(width: 10),
                              itemCount:
                                  ApiRepository
                                      .shared
                                      .getProductsByIdList!
                                      .data![1]
                                      .images!
                                      .length,
                              itemBuilder: (context, int index) {
                                var img =
                                    ApiRepository
                                        .shared
                                        .getProductsByIdList
                                        ?.data?[1]
                                        .images?[index]
                                        .path;
                                return Container(
                                  child: Image.network(
                                    AppUrl.baseUrlM + img.toString(),
                                    fit: BoxFit.fill,
                                  ),
                                );
                              },
                            ),
                          )
                          : Text("No Images"),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ApiRepository.shared.getProductsByIdList!.data![0].name
                          .toString(),
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontFamily: "Inter, Regular",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rental Price",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        " \$${widget.price} / day",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Renting Total",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        " \$${widget.price * (diff + 1)}",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jebby Fees",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        " \$${(widget.price * (diff + 1)) * Jebby / 100}",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Security Deposit",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        " \$${widget.security_deposit}",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Charges",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        "\$${widget.delivery_charges == '' ? 0 : widget.delivery_charges}",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 10),

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sales Tax",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Inter, Regular",
                        ),
                      ),
                      Text(
                        "${(taxValue * 100).toStringAsFixed(2)}\%",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Inter, ExtraBold",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: "Inter, Regular",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "\$${(((widget.price * (diff + 1)) + dc + ((widget.price * (diff + 1)) * Jebby / 100) + int.parse(widget.security_deposit)) + ((widget.price * (diff + 1)) * taxValue)).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontFamily: "Inter, ExtraBold",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Obx(
                  () => CheckboxListTile(
                    title: Text(
                      "I agree to the Terms of Service and Privacy Policy",
                      style: TextStyle(fontSize: 17),
                    ),
                    value: termscontroller.termsValue.value,
                    activeColor: kprimaryColor,
                    onChanged: (newValue) {
                      if (termscontroller.termsValue == true) {
                        termscontroller.chanegValue(false);
                      } else {
                        termscontroller.chanegValue(true);
                      }
                    },
                    controlAffinity:
                        ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                  ),
                ),

                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    int diff = selectedDate1.difference(selectedDate).inDays;
                    var JebbyFees = ((widget.price * (diff + 1)) * Jebby / 100);
                    var Totaltax = (widget.price * (diff + 1)) * taxValue;
                    var ApplicationFees = JebbyFees + Totaltax;
                    // (int.parse(widget.price.toString()) * diff);

                    if (!termscontroller.termsValue.value) {
                      Utils.flushBarErrorMessage(
                        'You must agree to Terms of Service and Privacy Policy',
                        context,
                      );
                    } else {
                      ApiRepository.shared.stripePayment(
                        // amount,
                        num.parse(
                          (((widget.price * (diff + 1)) +
                                      dc +
                                      ((widget.price * (diff + 1)) *
                                          Jebby /
                                          100) +
                                      int.parse(widget.security_deposit)) +
                                  ((widget.price * (diff + 1)) * taxValue))
                              .toStringAsFixed(2),
                        ),
                        widget.vendorAccountId.toString(),
                        context,
                        widget.userId,
                        widget.productID,
                        widget.rentStart,
                        widget.rentEnd,
                        widget.userName,
                        widget.email,
                        widget.location,
                        widget.lat,
                        widget.long,
                        widget.negoPrice,
                        '',
                        widget.security_deposit.toString(),
                        ApplicationFees,
                      );
                      //    Get.to(() => SelectPaymentMethodScreen(
                      // amount,
                      // widget.vendorAccountId,
                      // widget.vendorPayPalEmail,
                      // userID,
                      // widget.productID,
                      // DateFormat('yyyy-MM-dd').format(selectedDate).toString(),
                      // DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
                      // fullname,
                      // emailController.text.toString(),
                      // _locationController.text.toString(),
                      // widget.lat,
                      // widget.long,
                      // widget.negoPrice,
                      // int.parse(widget.security_deposit),
                      // ApplicationFees));
                    }
                  },
                  child: Container(
                    width: 310,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color(0xffFEB038),
                    ),
                    child: Center(
                      child: Text(
                        "Check Out",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontFamily: "Inter, Bold",
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
