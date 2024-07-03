import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:awesome_card/awesome_card.dart';
import 'package:jared/view_model/apiServices.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  var price;
  var accountId;
  var paypalMail;
  var userId;
  var prodId;
  var rentStart;
  var rentEnd;
  var userName;
  var email;
  var location;
  var lat;
  var long;
  var negoPrice;
  var security_deposit;
  var ApplicationFees;

  SelectPaymentMethodScreen(this.price, this.accountId, this.paypalMail, this.userId, this.prodId, this.rentStart, this.rentEnd, this.userName,
      this.email, this.location, this.lat, this.long, this.negoPrice, this.security_deposit, this.ApplicationFees);

  @override
  State<SelectPaymentMethodScreen> createState() => _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  late FocusNode _focusNode;
  TextEditingController cardNumberCtrl = TextEditingController();
  TextEditingController expiryFieldCtrl = TextEditingController();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBack = false;
  var shipping_address = '';

  @override
  void initState() {
    print("accountId ${widget.accountId}");
    print("paypalEmail ${widget.paypalMail}");
    print("negoPrice ${widget.negoPrice}");
    print("ApplicationFees ${widget.ApplicationFees}");
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
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     Get.to(() => SelectPaymentMethodTowScreen());
          //   },
          //   child: Container(
          //     child: Icon(
          //       Icons.add_circle_outline,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
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
            SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
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
                        newStr += newCardNumber.substring(i, math.min(i + step, newCardNumber.length));
                        if (i + step < newCardNumber.length) newStr += ' ';
                      }

                      setState(() {
                        cardNumber = newStr;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: expiryFieldCtrl,
                    decoration: InputDecoration(hintText: 'Card Expiry'),
                    maxLength: 5,
                    onChanged: (value) {
                      var newDateValue = value.trim();
                      final isPressingBackspace = expiryDate.length > newDateValue.length;
                      final containsSlash = newDateValue.contains('/');

                      if (newDateValue.length >= 2 && !containsSlash && !isPressingBackspace) {
                        newDateValue = newDateValue.substring(0, 2) + '/' + newDateValue.substring(2);
                      }
                      setState(() {
                        expiryFieldCtrl.text = newDateValue;
                        expiryFieldCtrl.selection = TextSelection.fromPosition(TextPosition(offset: newDateValue.length));
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
              "Total : ${(widget.price + widget.security_deposit + widget.ApplicationFees).toString()} \$",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: MaterialButton(
                    color: Color.fromARGB(255, 1, 36, 65),
                    onPressed: () {
                      if (cardNumber.isNotEmpty && expiryDate.isNotEmpty && cvv.isNotEmpty) {
                        final snackBar = new SnackBar(content: new Text("Please Wait"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        var data = {
                          "cardNumber": int.parse(cardNumber.replaceAll(' ', '')),
                          "exp_month": expiryDate.toString().substring(0, 2),
                          "exp_year": expiryDate.toString().substring(3),
                          "cvc": int.parse(cvv.toString()),
                          "amount": widget.price.runtimeType,
                          "vendorAccountId": widget.accountId.toString(),
                          "sales_tax" : widget.ApplicationFees
                        };
                        print(data);
                        ApiRepository.shared.stripePayment(
                            int.parse(cardNumber.replaceAll(' ', '')),
                            expiryDate.toString().substring(0, 2),
                            expiryDate.toString().substring(3),
                            int.parse(cvv.toString()),
                            widget.price,
                            widget.accountId.toString(),
                            context,
                            widget.userId,
                            widget.prodId,
                            widget.rentStart,
                            widget.rentEnd,
                            widget.userName,
                            widget.email,
                            widget.location,
                            widget.lat,
                            widget.long,
                            widget.negoPrice,
                            shipping_address,
                            widget.security_deposit,
                            widget.ApplicationFees,
                            );
                            Map data1 = {
                            "user_id": widget.userId,
                            "product_id": widget.prodId,
                            "rent_start": widget.rentStart,
                            "original_return": widget.rentEnd,
                            "name": widget.userName,
                            "email": widget.email,
                            "location": widget.location,
                            "latitude": widget.lat,
                            "longitude": widget.long,
                            "nego_price": widget.negoPrice,
                            "shipping_address": shipping_address
                          };
                          print("data1 ====> $data1");
                      } else {
                        final snackBar = new SnackBar(content: new Text("Fileds Cant Be Empty"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text(
                      "Pay",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                // Text(
                //   "or",
                //   style: TextStyle(fontSize: 16),
                // ),
                // SizedBox(
                //   width: 5,
                // ),
                // InkWell(
                //   onTap: () {
                //     Get.to(() => SelectPaymentMethodTowScreen(widget.price, widget.paypalMail));
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
      // body: Container(
      //   width: double.infinity,
      //   child: SingleChildScrollView(
      //     child: Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 10),
      //       child: Column(
      //         children: [
      //           SizedBox(
      //             height: 10,
      //           ),
      //           Container(
      //             child: Image.asset("assets/slicing/Layer 7@3x.png"),
      //           ),
      //           SizedBox(
      //             height: 15,
      //           ),
      //           Container(
      //             width: 387,
      //             height: 67,
      //             decoration: BoxDecoration(
      //               color: Colors.white,
      //               border: Border.all(
      //                 color: Color(0xff321A08),
      //               ),
      //               borderRadius: BorderRadius.all(
      //                 Radius.circular(5),
      //               ),
      //             ),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceAround,
      //               children: [
      //                 Container(
      //                   width: 45,
      //                   height: 15,
      //                   child: Image.asset("assets/slicing/visa@3x.png"),
      //                 ),
      //                 Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     Text(
      //                       "**** **** **** 5967",
      //                       style: TextStyle(
      //                           fontWeight: FontWeight.bold, fontSize: 16),
      //                     ),
      //                     Text(
      //                       "Expires on 09/26",
      //                       style: TextStyle(
      //                           fontWeight: FontWeight.normal, fontSize: 12),
      //                     ),
      //                   ],
      //                 ),
      //                 Container(
      //                   width: 16,
      //                   height: 16,
      //                   decoration: BoxDecoration(
      //                     shape: BoxShape.circle,
      //                     color: Colors.orange,
      //                   ),
      //                   child: Image.asset(
      //                     "assets/slicing/Path 71@3x.png",
      //                     scale: 3,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Conts("**** **** **** 5967", "Expires on 09/26",
      //               "assets/slicing/Path 91@3x.png"),
      //           Conts("**** **** **** 5967", "Expires on 09/26",
      //               "assets/slicing/apple-pay@3x.png"),
      //           SizedBox(
      //             height: 37,
      //           ),
      //           GestureDetector(
      //             onTap: () {
      //               showDialog(
      //                 context: context,
      //                 builder: (_) => AlertDialog(
      //                   backgroundColor: Color(0xff000000B8),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   contentPadding: EdgeInsets.all(0),
      //                   actionsPadding: EdgeInsets.all(0),
      //                   actions: [
      //                     Stack(
      //                       clipBehavior: Clip.none,
      //                       alignment: AlignmentDirectional.center,
      //                       children: [
      //                         Container(
      //                           width: 320,
      //                           height: 291,
      //                           decoration: BoxDecoration(
      //                               // border: Border.all(color: Colors.white),
      //                               borderRadius: BorderRadius.circular(10),
      //                               color: Color(0xffFEB038)),
      //                           child: ListView(
      //                             children: [
      //                               Column(
      //                                 mainAxisAlignment: MainAxisAlignment.end,
      //                                 children: [
      //                                   SizedBox(
      //                                     height: 67,
      //                                   ),
      //                                   Text(
      //                                     "Congratulations",
      //                                     style: TextStyle(
      //                                         fontFamily: "Inter, Bold",
      //                                         fontSize: 30,
      //                                         color: Colors.white),
      //                                   ),
      //                                   SizedBox(
      //                                     height: 10,
      //                                   ),
      //                                   Text(
      //                                     "Your Order Has Been Received",
      //                                     style: TextStyle(
      //                                         fontFamily: "Inter, Regular",
      //                                         fontSize: 19,
      //                                         color: Colors.white),
      //                                   ),
      //                                   SizedBox(
      //                                     height: 15,
      //                                   ),
      //                                   Container(
      //                                     width: 270,
      //                                     height: 50,
      //                                     child: Text(
      //                                       "You will be contacted by the Owner via direct message to confirm!",
      //                                       textAlign: TextAlign.center,
      //                                       style: TextStyle(
      //                                         fontFamily: "Inter, Regular",
      //                                         fontSize: 15,
      //                                         color: Colors.white,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                   SizedBox(
      //                                     height: 28,
      //                                   ),
      //                                   GestureDetector(
      //                                     onTap: () {
      //                                       final bottomcontroller =
      //                                           Get.put(BottomController());
      //                                       bottomcontroller.navBarChange(0);
      //                                       Get.to(() => MainScreen());
      //                                     },
      //                                     child: Container(
      //                                       width: 357,
      //                                       height: 65,
      //                                       decoration: BoxDecoration(
      //                                           borderRadius: BorderRadius.only(
      //                                             bottomLeft:
      //                                                 Radius.circular(10),
      //                                             bottomRight:
      //                                                 Radius.circular(10),
      //                                           ),
      //                                           color: Colors.white),
      //                                       child: Center(
      //                                         child: Text(
      //                                           "Go Back To Home",
      //                                           style: TextStyle(
      //                                               fontFamily:
      //                                                   "Inter, Regular",
      //                                               fontSize: 20,
      //                                               color: Colors.black),
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ],
      //                               )
      //                             ],
      //                           ),
      //                         ),
      //                         Positioned(
      //                             top: -20,
      //                             // left: 100,
      //                             child: Container(
      //                                 width: 90,
      //                                 height: 90,
      //                                 decoration: BoxDecoration(
      //                                     shape: BoxShape.circle,
      //                                     color: Color(0xffFEB038)),
      //                                 child: Center(
      //                                     child: Image.asset(
      //                                   "assets/slicing/smile@3x.png",
      //                                   scale: 5,
      //                                 ))))
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //               );
      //             },
      //             child: Container(
      //               height: 58,
      //               width: 390,
      //               child: Center(
      //                 child: Text(
      //                   'Payment Confirm',
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

  Conts(txt1, txt2, Img) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: 387,
          height: 67,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color(0xFF4285F4),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Container(
                  width: 45,
                  height: 15,
                  child: Image.asset(
                    Img,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    txt1,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    txt2,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                  ),
                ],
              ),
              // Container(
              //   width: 16,
              //   height: 16,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Colors.orange,
              //   ),
              //   child: Image.asset("assets/slicing/Path 71@3x.png"),
              // )
            ],
          ),
        ),
      ],
    );
  }
}
