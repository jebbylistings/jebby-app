import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jebby/res/app_url.dart';

import '../../../view_model/apiServices.dart';

class TrackingDetailScreen extends StatefulWidget {
  final dynamic date;
  final dynamic vendorId;
  final dynamic status;
  final dynamic created;
  final dynamic approve;
  final dynamic complete;
  final dynamic cancel;

  TrackingDetailScreen({
    this.date,
    this.vendorId,
    this.status,
    this.created,
    this.approve,
    this.complete,
    this.cancel,
  });

  @override
  State<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends State<TrackingDetailScreen> {
  bool userLoader = false;
  bool userError = false;
  bool userEmpty = true;
  var userImage = "";
  var userName = "";
  var userNumber = "";
  var userAddress = "";

  void getUserData() {
    ApiRepository.shared.userCredential(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  userLoader = false;
                  userError = false;
                  userEmpty = true;
                  userImage = "";
                }),
              }
            else
              {
                setState(() {
                  userError = false;
                  userLoader = false;
                  userEmpty = false;
                  userImage =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .image
                          .toString();
                  userName =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .name
                          .toString();
                  userNumber =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .number
                          .toString();
                  userAddress =
                      ApiRepository
                          .shared
                          .getUserCredentialModelList!
                          .data![0]
                          .address
                          .toString();
                }),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              userError = true;
              userLoader = false;
              userEmpty = false;
              userImage = "";
            }),
          },
      },
      widget.vendorId.toString(),
    );
  }

  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Tracking Detail",
          style: TextStyle(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 35),
                Row(
                  children: [
                    Text(
                      "Rent starts on ${widget.date}",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  width: 391,
                  height: 1,
                  color: Colors.grey.withAlpha(102),
                ),
                SizedBox(height: 17),
                RR(),
                SizedBox(height: 50),
                widget.status == "3"
                    ? Icn(
                      "assets/slicing/Group 353@3x.png",
                      "Order is Cancelled",
                      "cancel",
                    )
                    : widget.status == "0"
                    ? Icn(
                      "assets/slicing/Group 353@3x.png",
                      "Order is Pending",
                      "",
                    )
                    : widget.status == "1"
                    ? Icn1("assets/slicing/Group 353@3x.png")
                    : Icn2("assets/slicing/Group 353@3x.png"),
                //     Padding(
                //       padding: const EdgeInsets.only(right: 235),
                //       child: Container(
                //         height: 60,
                //         width: 1,
                //         color: Color(0xff707070),
                //       ),
                //     ),
                //     SizedBox(
                //       height: 8,
                //     ),
                //     Icn("assets/slicing/Group 353@3x.png", "Shipped",
                //         "Address : Lorem ipsum dolor sit amet consectetur adipiscing elit cras, condimentum nec purus dictumst consequat taciti City,"),
                //     Padding(
                //       padding: const EdgeInsets.only(right: 235),
                //       child: Container(
                //         height: 60,
                //         width: 1,
                //         color: Color(0xff707070),
                //       ),
                //     ),
                //     SizedBox(
                //       height: 8,
                //     ),
                //     Icn(
                //         "assets/slicing/Group 353@3x.png",
                //         "Arrived at Our Warehouse",
                //         "Address : Lorem ipsum dolor sit amet consectetur adipiscing elit cras, condimentum nec purus dictumst consequat taciti City,"),
                //     Padding(
                //       padding: const EdgeInsets.only(right: 235),
                //       child: Container(
                //         height: 60,
                //         width: 1,
                //         color: Color(0xff707070),
                //       ),
                //     ),
                //     SizedBox(
                //       height: 8,
                //     ),
                //     Icn(
                //         "assets/slicing/Group 353@3x.png",
                //         "Reached Logistic Facility",
                //         "Address : Lorem ipsum dolor sit amet consectetur adipiscing elit cras, condimentum nec purus dictumst consequat taciti City,"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RR() {
    return Column(
      children: [
        // Row(
        //   children: [
        //     Container(
        //       width: 44,
        //       height: 44,
        //       decoration: BoxDecoration(
        //           shape: BoxShape.circle, color: Color(0xff321A08)),
        //       child: Icon(
        //         Icons.person_outline_outlined,
        //         color: Colors.white,
        //       ),
        //     ),
        //     SizedBox(
        //       width: 22,
        //     ),
        //     // Column(
        //     //   crossAxisAlignment: CrossAxisAlignment.start,
        //     //   children: [
        //     //     Text(
        //     //       "Courier BDD Steve - 456789",
        //     //       style: TextStyle(
        //     //           color: Colors.black,
        //     //           fontWeight: FontWeight.bold,
        //     //           fontSize: 16),
        //     //     ),
        //     //     SizedBox(
        //     //       height: 5,
        //     //     ),
        //     //     Text(
        //     //       "Delivery Partners : FEDEX",
        //     //       style: TextStyle(
        //     //           color: Colors.grey,
        //     //           fontWeight: FontWeight.normal,
        //     //           fontSize: 11),
        //     //     ),
        //     //   ],
        //     // )
        //   ],
        // ),
        // SizedBox(
        //   height: 66,
        // ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(),
              child:
                  userImage == ""
                      ? Image.asset("assets/slicing/blankuser.jpeg")
                      : Image.network(AppUrl.baseUrlM + userImage),
            ),
            SizedBox(width: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName == "" ? "vendor" : userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  userNumber == "" ? "" : userNumber,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 7),
                Container(
                  width: 270,
                  child: Text(
                    userAddress == "" ? "" : userAddress,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Icn(img, txt, type) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                type == "cancel"
                    ? widget.cancel == "0"
                        ? ""
                        : DateFormat(
                          'dd-MM-yy',
                        ).format(DateTime.parse(widget.cancel))
                    // : widget.cancel
                    : widget.created,
                style: TextStyle(fontSize: 11),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4285F4),
                ),
                child: Image.asset(img, scale: 3),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Center(
              child: Text(
                txt,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Icn1(img) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(widget.created, style: TextStyle(fontSize: 11)),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Image.asset(img, scale: 3),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Placed",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 235),
          child: Container(height: 60, width: 1, color: Color(0xff707070)),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                widget.approve != "0"
                    ? DateFormat(
                      'dd-MM-yy',
                    ).format(DateTime.parse(widget.approve))
                    : "",
                style: TextStyle(fontSize: 11),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Image.asset(img, scale: 3),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Approved",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 235),
          child: Container(height: 60, width: 1, color: Color(0xff707070)),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Icn2(img) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(widget.created, style: TextStyle(fontSize: 11)),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Image.asset(img, scale: 3),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Placed",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 235),
          child: Container(height: 60, width: 1, color: Color(0xff707070)),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                widget.approve != "0"
                    ? DateFormat(
                      'dd-MM-yy',
                    ).format(DateTime.parse(widget.approve))
                    : "",
                style: TextStyle(fontSize: 11),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Image.asset(img, scale: 3),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Approved",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 235),
          child: Container(height: 60, width: 1, color: Color(0xff707070)),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                widget.complete != "0"
                    ? DateFormat(
                      'dd-MM-yy',
                    ).format(DateTime.parse(widget.complete))
                    : "",
                style: TextStyle(fontSize: 11),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Image.asset(img, scale: 3),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Shipped",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
