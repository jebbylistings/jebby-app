import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jared/Views/screens/home/RentNow.dart';
import 'package:jared/view_model/apiServices.dart';

import '../../../res/app_url.dart';
import '../../helper/colors.dart';

class NegotiationScreen extends StatefulWidget {
  var prodId;
  var status;
  var price;
  var negoId;
  var userId;

  NegotiationScreen({this.prodId, this.status, this.price, this.negoId, this.userId});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  var originalPrice = "";
  var negMargin = "";
  var image = "";
  var name = "";
  late var vendorId;
  late var delivery_charges;
  late var security_deposit;
  String? vendorName;
  String? vendorAddress;
  String? cell;
  late var vendorImage;
  late var vendorBackImage;
  late var pastart;
  late var paend;
  late var vendorAccountId;
  late var vendorPPEmail;

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
                        pastart = ApiRepository.shared.getProductsByIdList!.data![0].pastart.toString();
                        paend = ApiRepository.shared.getProductsByIdList!.data![0].paend.toString();
                        vendorId = ApiRepository.shared.getProductsByIdList!.data![0].userId.toString();
                        delivery_charges = ApiRepository.shared.getProductsByIdList!.data![0].delivery_charges.toString();
                        security_deposit = ApiRepository.shared.getProductsByIdList!.data![0].security_deposit.toString();
                        rentVisibility = true;
                        getUserData(vendorId);
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
        widget.prodId.toString());
        
  }



  bool userLoader = true;
  bool userError = false;
  bool userEmpty = false;

  bool rentVisibility = false;

  void getUserData(id) {
    ApiRepository.shared.userCredential(
        (List) => {
              if (this.mounted)
                {

                  if (List.data!.length == 0)
                    {
                      setState(() {

                        print("EMPTY USER DATA");
                        userLoader = false;
                        userError = false;
                        userEmpty = true;
                        vendorName = "Vendor";
                        vendorAddress = "";
                        cell = "";
                        vendorImage = "";
                        vendorBackImage = "";
                      })
                    }
                  else
                    {
                      setState(() {
                        print("USER DATA is not empty");
                        userError = false;
                        userLoader = false;
                        userEmpty = false;
                        vendorName = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].name
                            .toString();
                        vendorAddress = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].address
                            .toString();
                        cell = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].number
                            .toString();
                        vendorImage = ApiRepository
                            .shared.getUserCredentialModelList!.data![0].image
                            .toString();
                        vendorBackImage = ApiRepository.shared
                            .getUserCredentialModelList!.data![0].backImage
                            .toString();
                        vendorAccountId = ApiRepository.shared
                            .getUserCredentialModelList!.data![0].accountId
                            .toString();
                        vendorPPEmail = ApiRepository.shared
                            .getUserCredentialModelList!.data![0].paypalEmail
                            .toString();
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    userError = true;
                    userLoader = false;
                    userEmpty = false;
                    vendorName = "Vendor";
                    vendorAddress = "";
                    cell = "";
                    vendorImage = "";
                    vendorBackImage = "";
                  }),
                },
            },
        id);
        print("USER ID ====> ${widget.userId.toString()}");
    
  }

  void initState() {
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
          "Discount Request Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
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
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
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
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
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
                                widget.status == 1
                                    ? Text(
                                        "Discount Request Approved",
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(
                                        "Discount Request Cancelled",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                widget.status == 1
                                    ? GestureDetector(
                                        onTap: () {
                                          rentVisibility
                                              ? Get.to(() => RentnowScreen(vendorName!, vendorAddress!, cell!, vendorImage, vendorId, widget.prodId,
                                                  pastart, paend, widget.price, vendorAccountId, vendorPPEmail, "nego", delivery_charges, security_deposit))
                                              : null;
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          decoration: BoxDecoration(
                                              color: rentVisibility ? kprimaryColor : kprimaryColor.withOpacity(0.5),
                                              borderRadius: BorderRadius.all(Radius.circular(12))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                                child: Text(
                                              'Rent Now',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            )),
                                          ),
                                        ),
                                      )
                                    : Text(""),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
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
