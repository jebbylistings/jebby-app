import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:awesome_card/awesome_card.dart';

class ReOrderPayment extends StatefulWidget {
  final dynamic accountId;
  final dynamic paypalMail;
  final dynamic price;
  final dynamic orderId;
  final dynamic location;
  final dynamic applicationFee;
  ReOrderPayment({
    this.accountId,
    this.paypalMail,
    this.price,
    this.orderId,
    this.location,
    this.applicationFee,
  });

  @override
  State<ReOrderPayment> createState() => _ReOrderPaymentState();
}

class _ReOrderPaymentState extends State<ReOrderPayment> {
  late FocusNode _focusNode;
  TextEditingController cardNumberCtrl = TextEditingController();
  TextEditingController expiryFieldCtrl = TextEditingController();

  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBack = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          child: Text(
            "Select Payment Method",
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
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            CreditCard(
              cardNumber: cardNumber,
              cardExpiry: expiryDate,
              // cardHolderName: cardHolderName,
              cvv: cvv,
              // bankName: 'Axis Bank',
              showBackSide: showBack,
              frontBackground: CardBackgrounds.black,
              backBackground: CardBackgrounds.white,
              showShadow: true,
              // mask: getCardTypeMask(cardType: CardType.americanExpress),
            ),
            SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: cardNumberCtrl,
                    decoration: InputDecoration(hintText: 'Card Number'),
                    maxLength: 16,
                    onChanged: (value) {
                      final newCardNumber = value.trim();
                      var newStr = '';
                      final step = 4;

                      for (var i = 0; i < newCardNumber.length; i += step) {
                        newStr += newCardNumber.substring(
                          i,
                          math.min(i + step, newCardNumber.length),
                        );
                        if (i + step < newCardNumber.length) newStr += ' ';
                      }

                      setState(() {
                        cardNumber = newStr;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: expiryFieldCtrl,
                    decoration: InputDecoration(hintText: 'Card Expiry'),
                    maxLength: 5,
                    onChanged: (value) {
                      var newDateValue = value.trim();
                      final isPressingBackspace =
                          expiryDate.length > newDateValue.length;
                      final containsSlash = newDateValue.contains('/');

                      if (newDateValue.length >= 2 &&
                          !containsSlash &&
                          !isPressingBackspace) {
                        newDateValue =
                            newDateValue.substring(0, 2) +
                            '/' +
                            newDateValue.substring(2);
                      }
                      setState(() {
                        expiryFieldCtrl.text = newDateValue;
                        expiryFieldCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: newDateValue.length),
                        );
                        expiryDate = newDateValue;
                      });
                    },
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(
                //     horizontal: 20,
                //   ),
                //   child: TextFormField(
                //     decoration: InputDecoration(hintText: 'Card Holder Name'),
                //     onChanged: (value) {
                //       setState(() {
                //         cardHolderName = value;
                //       });
                //     },
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'CVV'),
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() {
                        cvv = value;
                      });
                    },
                    focusNode: _focusNode,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                "Total : ${(int.parse(widget.price.toString()) + widget.applicationFee).toString()} \$",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: MaterialButton(
                    color: Color.fromARGB(255, 1, 36, 65),
                    onPressed: () {
                      if (cardNumber.isNotEmpty &&
                          expiryDate.isNotEmpty &&
                          cvv.isNotEmpty) {
                        final snackBar = new SnackBar(
                          content: new Text("Please Wait"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // ApiRepository.shared.reOrderStripePayment(
                        //   int.parse(cardNumber.replaceAll(' ', '')),
                        //   expiryDate.toString().substring(0, 2),
                        //   expiryDate.toString().substring(3),
                        //   int.parse(cvv.toString()),
                        //   widget.price,
                        //   widget.accountId.toString(),
                        //   context,
                        //   widget.orderId,
                        //   widget.location,
                        //   widget.applicationFee,
                        // );
                      } else {
                        final snackBar = new SnackBar(
                          content: new Text("Fileds Cant Be Empty"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text("Pay", style: TextStyle(color: Colors.white)),
                  ),
                ),
                // SizedBox(
                //   width: 5,
                // ),
                // Text(
                //   "or",
                //   style: TextStyle(fontSize: 16),
                // ),
                // SizedBox(
                //   width: 5,
                // ),
                // InkWell(
                //   onTap: () {
                //     Get.to(() => SelectPaymentMethodTowScreen(
                //         widget.price, widget.paypalMail));
                //   },
                //   child: Image.asset(
                //     "assets/slicing/paypal-logo.png",
                //     height: 80,
                //     width: 80,
                //   ),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
