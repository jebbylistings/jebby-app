import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';

class SelectPaymentMethodTowScreen extends StatefulWidget {
  final dynamic price;
  final dynamic paypalMail;
  SelectPaymentMethodTowScreen(this.price, this.paypalMail);

  @override
  State<SelectPaymentMethodTowScreen> createState() =>
      _SelectPaymentMethodTowScreenState();
}

class _SelectPaymentMethodTowScreenState
    extends State<SelectPaymentMethodTowScreen> {
  TextEditingController emailController = TextEditingController();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var res_height = MediaQuery.of(context).size.height;
    var res_width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          child: Text(
            "Pay with paypal",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        // actions: [
        //   Icon(
        //     Icons.add_circle_outline,
        //     color: Colors.black,
        //   ),
        // ],
      ),
      body: Center(
        child: Container(
          height: res_height * 0.7,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                "assets/slicing/paypal-logo.png",
                height: 100,
                width: 100,
              ),
              SizedBox(height: res_height * 0.01),
              Text("Pay with PayPal", style: TextStyle(fontSize: 16)),
              SizedBox(height: res_height * 0.01),
              Text("Enter your email address to get started"),
              SizedBox(height: res_height * 0.01),
              SizedBox(
                height: res_height * 0.1,
                width: res_width * 0.8,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 1, 36, 65),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 1, 36, 65),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.01),
              Text("Amount ${widget.price}\$"),
              SizedBox(height: res_height * 0.01),
              MaterialButton(
                onPressed: () {
                  // ApiRepository.shared.payWithPayPal(widget.price, widget.paypalMail, emailController.text.toString());
                },
                color: Color.fromARGB(255, 1, 36, 65),
                child: Text("Pay", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        // TextButton(
        //     onPressed: () => {
        //           Navigator.of(context).push(
        //             MaterialPageRoute(
        //               builder: (BuildContext context) => UsePaypal(
        //                   sandboxMode: true,
        //                   clientId:
        //                       "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dYw8_8yW5lYIbCqf326vrkrp0ce9TAqjEGMHiV3OqJM_aRT0",
        //                   secretKey:
        //                       "EHHtTDjnmTZATYBPiGzZC_AZUfMpMAzj2VZUeqlFUrRJA_C0pQNCxDccB5qoRQSEdcOnnKQhycuOWdP9",
        //                   returnURL: "https://samplesite.com/return",
        //                   cancelURL: "https://samplesite.com/cancel",
        //                   transactions: const [
        //                     {
        //                       "amount": {
        //                         "total": '10.12',
        //                         "currency": "USD",
        //                         "details": {
        //                           "subtotal": '10.12',
        //                           "shipping": '0',
        //                           "shipping_discount": 0
        //                         }
        //                       },
        //                       "description":
        //                           "The payment transaction description.",
        //                       // "payment_options": {
        //                       //   "allowed_payment_method":
        //                       //       "INSTANT_FUNDING_SOURCE"
        //                       // },
        //                       "item_list": {
        //                         "items": [
        //                           {
        //                             "name": "A demo product",
        //                             "quantity": 1,
        //                             "price": '10.12',
        //                             "currency": "USD"
        //                           }
        //                         ],

        //                         // shipping address is not required though
        //                         "shipping_address": {
        //                           "recipient_name": "Jane Foster",
        //                           "line1": "Travis County",
        //                           "line2": "",
        //                           "city": "Austin",
        //                           "country_code": "US",
        //                           "postal_code": "73301",
        //                           "phone": "+00000000",
        //                           "state": "Texas"
        //                         },
        //                       }
        //                     }
        //                   ],
        //                   note: "Contact us for any questions on your order.",
        //                   onSuccess: (Map params) async {
        //                   },
        //                   onError: (error) {
        //                   },
        //                   onCancel: (params) {
        //                   }),
        //             ),
        //           )
        //         },
        //     child: const Text("Make Payment")),
      ),
      // body: Container(
      //   width: double.infinity,
      //   child: SingleChildScrollView(
      //     child: Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 17),
      //       child: Column(
      //         children: [
      //           SizedBox(
      //             height: 10,
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
      //             children: [
      //               Container(
      //                 width: 124,
      //                 height: 96,
      //                 child: Image.asset(
      //                   "assets/slicing/Icon awesome-cc-visa@3x.png",
      //                 ),
      //               ),
      //               Container(
      //                 width: 124,
      //                 height: 96,
      //                 child: Image.asset(
      //                   "assets/slicing/Icon awesome-cc-paypal@3x.png",
      //                 ),
      //               ),
      //               Container(
      //                 width: 124,
      //                 height: 96,
      //                 child: Image.asset(
      //                   "assets/slicing/Icon awesome-cc-apple-pay@3x.png",
      //                 ),
      //               ),
      //             ],
      //           ),
      //           Txtfld("****** ****** ****** 123456"),
      //           Txtfld("Will Smith"),
      //           SizedBox(
      //             height: 30,
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               smallnotdrop("Expiry Date", "10 / 25", 171),
      //               smallnotdrop("CVV", "485", 171),
      //             ],
      //           ),
      //           SizedBox(
      //             height: 40,
      //           ),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Container(
      //                 child: Text(
      //                   "Save card details",
      //                   style: TextStyle(fontSize: 17, color: Colors.black),
      //                 ),
      //               ),
      //               Container(
      //                 width: 50,
      //                 height: 25,
      //                 child: Image.asset("assets/slicing/Group 67@2x.png"),
      //               )
      //             ],
      //           ),
      //           SizedBox(
      //             height: 110,
      //           ),
      //           GestureDetector(
      //             onTap: () {
      //               Get.to(() => SelectPaymentMethodScreen());
      //             },
      //             child: Container(
      //               height: 58,
      //               width: 390,
      //               child: Center(
      //                 child: Text(
      //                   'Add Now',
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold, fontSize: 15),
      //                 ),
      //               ),
      //               decoration: BoxDecoration(
      //                   color: kprimaryColor,
      //                   borderRadius: BorderRadius.circular(20)),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Txtfld(tf) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: res_height * 0.02),
          // Text(txt),
          SizedBox(height: res_height * 0.005),
          Container(
            height: 50,
            width: res_width * 0.9,
            child: TextField(
              decoration: InputDecoration(
                hintText: tf,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: kprimaryColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: kprimaryColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  smallnotdrop(labeltxt, hinttxt, double Sizez) {
    return Container(
      width: Sizez,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hinttxt,
          hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
          labelText: labeltxt,
          contentPadding: EdgeInsets.only(right: -200),
          labelStyle: TextStyle(fontSize: 16, color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
