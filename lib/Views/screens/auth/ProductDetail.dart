// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:jared/Services/product_detail_service.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/agreements/termsAndConditions.dart';
import 'package:jared/Views/screens/auth/register.dart';
import 'package:jared/Views/screens/home/RentNow.dart';
import 'package:jared/Views/screens/home/RenterView.dart';
import 'package:jared/Views/screens/home/chat.dart';
import 'package:jared/Views/screens/home/gallery.dart';
import 'package:jared/Views/screens/home/reviews.dart';
import 'package:jared/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jared/provider/prodetail_provider.dart';

import '../../../model/user_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';
import '../../../view_model/user_view_model.dart';
import '../agreements/insuranceAndIndemnifications.dart';
import '../agreements/rentalAgreement.dart';
import '../agreements/transportAndInstallationPolicy.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  var id;
  var name;
  var price;
  var stars;
  var image;
  var specs;
  var userID;
  var desc;
  var messageStatus;
  var delivery_charges;
  var sourceId;

  ProductDetailScreen(
      this.id, this.name, this.price, this.stars, this.image, this.specs, this.userID, this.desc, this.messageStatus, this.delivery_charges);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var length = "";

  var prodID = "";

  bool rentVisibility = false;

  String dropdownValue = 'One';
  bool isLoading = true;
  bool isError = false;

  bool userLoader = true;
  bool userError = false;
  bool userEmpty = false;

  bool ProdLoader = true;
  bool ProdError = false;
  bool emptyProd = false;

  late String vendorName;
  late String vendorAddress;
  late String cell;
  late var vendorImage;
  late var vendorBackImage;
  late var pastart;
  late var paend;
  late var vendorAccountId;
  late var vendorPPEmail;
  late var security_deposit;

  bool fav = false;
  bool messageVisibility = false;
  TextEditingController negotiationController = TextEditingController();

  var negotiation = "0";

  void getProducts() {
    ApiRepository.shared.getProductsById(
        (list) => {
              if (this.mounted)
                {
                  if (list.data!.length == 0)
                    {
                      setState(() {
                        ProdLoader = false;
                        ProdError = false;
                        emptyProd == true;
                      }),
                      getRelProducts(),
                    }
                  else
                    {
                      print("Product ID --> ${ApiRepository.shared.getProductsByIdList?.data![0].productId}"),
                      setState(() {
                        pastart = ApiRepository.shared.getProductsByIdList?.data![0].pastart.toString();
                        paend = ApiRepository.shared.getProductsByIdList?.data![0].paend.toString();
                        length = ApiRepository.shared.getProductsByIdList!.data![0].length.toString();
                        prodID = ApiRepository.shared.getProductsByIdList!.data![0].productId.toString();
                        ProdLoader = false;
                        ProdError = false;
                        emptyProd == false;
                        rentVisibility = true;
                        negotiation = ApiRepository.shared.getProductsByIdList!.data![0].negotiation.toString();
                        security_deposit = ApiRepository.shared.getProductsByIdList!.data![0].security_deposit.toString();
                        print(calculate(negotiation));
                      }),
                      getRelProducts(),
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    ProdLoader = true;
                    ProdError = true;
                    emptyProd = false;
                  })
                }
            },
        widget.id.toString());
  }

  void getRelProducts() {
    ApiRepository.shared.getRelatedProducts(
        (List) => {
              if (this.mounted)
                {
                  if (List.data?.length == 0)
                    {
                      print("Related Products Data"),
                      setState(() {
                        isLoading = false;
                        isError = false;
                      }),
                    }
                  else
                    {
                      print("Related Products Data"),
                      setState(() {
                        isLoading = false;
                        isError = false;
                      })
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    isLoading = true;
                    isError = true;
                  })
                }
            },
        widget.id.toString());
  }

  void getUserData() {
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
                        vendorName = ApiRepository.shared.getUserCredentialModelList!.data![0].name.toString();
                        vendorAddress = ApiRepository.shared.getUserCredentialModelList!.data![0].address.toString();
                        cell = ApiRepository.shared.getUserCredentialModelList!.data![0].number.toString();
                        vendorImage = ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString();
                        vendorBackImage = ApiRepository.shared.getUserCredentialModelList!.data![0].backImage.toString();
                        vendorAccountId = ApiRepository.shared.getUserCredentialModelList!.data![0].accountId.toString();
                        vendorPPEmail = ApiRepository.shared.getUserCredentialModelList!.data![0].paypalEmail.toString();
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
        widget.userID.toString());
    print("USER ID: ${widget.userID.toString()}");
    print(widget.messageStatus);
    if (widget.messageStatus == 1) {
      setState(() {
        messageVisibility = true;
        print("message visibiliyt ${messageVisibility}");
      });
    } else {
      setState(() {
        messageVisibility = false;
        print("message visibiliyt ${messageVisibility}");
      });
    }

    getProducts();
  }

  // @override
  // Future getData() async {
  //   final sp = context.read<SignInProvider>();
  //   final usp = context.read<UserViewModel>();
  //   usp.getUser();
  //   sp.getDataFromSharedPreferences();
  // }

  Future<UserModel> getUserDate() => UserViewModel().getUser();

  String? token;
  String sourceId = "";
  String? fullname;
  String? email;
  String? role;
  String? guestName;

  void profileData() async {
    getUserDate().then((value) async {
      token = value.token.toString();
      sourceId = value.id.toString();
      fullname = value.name.toString();
      email = value.email.toString();
      role = value.role.toString();
      getFavourites();
      getProductsApi(value.id.toString());
      print("Source ID: ${sourceId}");
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }

  getFavourites() {
    ApiRepository.shared.getFavourites(
        sourceId,
        (List) => {
              if (this.mounted)
                {
                  if (List.data!.length != 0)
                    {
                      for (int i = 0; i < ApiRepository.shared.getFavouriteProductsModelList!.data!.length; i++)
                        {
                          if (ApiRepository.shared.getFavouriteProductsModelList!.data![i].id.toString() == widget.id.toString())
                            {
                              setState(() {
                                fav = true;
                              })
                            }
                        }
                    }
                }
            },
        (error) => {});
  }

  addFavorite(fav) {
    ApiRepository.shared.addFavorite(sourceId.toString(), widget.id.toString(), fav.toString());
  }

  int calculate(amount) {
    int value = 100 - int.parse(amount).toInt();
    return value;
  }

  void preOrder(neg, req, context) {
    double price = double.parse(widget.price.toString());
    double negotiable = double.parse(neg);
    double amount = (price / 100) * (100 - negotiable);
    double requested = (price / 100) * (100 - double.parse(req.toString()));
    // double.parse(req.toString());
    print("amount ${amount}");
    print("negotiable ${negotiable}");
    print("requested ${requested}");
    final snackBar = new SnackBar(content: new Text("Price is not in range defined"));
    if (requested >= amount && requested <= price) {
      ApiRepository.shared.negotiationRequest(widget.id, sourceId, requested, context);
      negotiationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    // requested >= amount
    //     ? ScaffoldMessenger.of(context).showSnackBar(snackBar1)
    //     : ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var imagesapi = "null";
  var nameapi = "null";
  var back_image_api = "null";

  ////////
  Future getProductsApi(id) async {
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';
    final response = await http.get(Uri.parse('${Url}/UserProfileGetById/${id}'));
    var data = jsonDecode(response.body.toString());
    print(data);
    setState(() {
      if (data["data"].length > 0) {
        imagesapi = data["data"][0]["image"].toString();
        nameapi = data["data"][0]["name"].toString();
        back_image_api = data["data"][0]["back_image"].toString();
      }
    });
    if (response.statusCode == 200) {
      return data;
    } else {
      return "No data";
    }
  }

  @override
  void initState() {
    print("source ID ${sourceId.toString()}");
    print("user ID ${widget.userID.toString()}");
    print("Delivery Charges ${widget.delivery_charges.toString()}");
    print("Id ${widget.id.toString()}");
    print("current route name is  ${Get.currentRoute}");
    // getData();
    profileData();
    getUserData();
    print("Nameapi  ${nameapi}");
    // getProducts();
    // getRelProducts();
    getGestUser();
    super.initState();
  }

  void getGestUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    guestName = sharedPreferences.getString('fullname') ?? "";
    print("$guestName NameGuest");
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthViewModel>();
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    ProDetailService proDetailService = ProDetailService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              children: [
                Visibility(
                  visible: role != "Guest",
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          fav = !fav;
                          print(fav ? "1" : "0");
                          addFavorite(fav ? 1 : 0);
                        });
                      },
                      child: Icon(
                        Icons.favorite,
                        color: fav ? Colors.red : Colors.grey,
                      )),
                ),
                // ImageIcon(
                //   AssetImage(
                //     "assets/slicing/heart2.png",
                //   ),
                //   size: 20,
                //   color: Colors.black,
                // ),
                SizedBox(
                  width: res_width * 0.04,
                ),
                // ImageIcon(
                //   AssetImage(
                //     "assets/slicing/cart.png",
                //   ),
                //   size: 20,
                //   color: Colors.black,
                // ),
                // SizedBox(
                //   width: res_width * 0.02,
                // ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  Text("${widget.id.toString()}"),
              Container(
                width: res_width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        // height: MediaQuery.of(context).size.height,
                        // width: MediaQuery.of(context).size.width,
                        child: Column(
                      children: [
                        ProdError
                            ? Text("Image not Found")
                            : ProdLoader
                                ? SizedBox(
                                    height: 150,
                                  )
                                : emptyProd
                                    ? Text("No Image Found")
                                    : ApiRepository.shared.getProductsByIdList!.data![1].images!.length > 0
                                        ? SizedBox(
                                            height: 150,
                                            child: ListView.separated(
                                                scrollDirection: Axis.horizontal,
                                                shrinkWrap: true,
                                                separatorBuilder: (context, index) => SizedBox(
                                                      width: 10,
                                                    ),
                                                itemCount: ApiRepository.shared.getProductsByIdList!.data![1].images!.length,
                                                itemBuilder: (context, int index) {
                                                  var img = ApiRepository.shared.getProductsByIdList?.data?[1].images?[index].path;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context).push(MaterialPageRoute(
                                                          builder: (context) => PhotoGallery(
                                                                image: AppUrl.baseUrlM + img.toString(),
                                                              )));
                                                    },
                                                    child: Container(
                                                      child: Image.network(
                                                        AppUrl.baseUrlM + img.toString(),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          )
                                        : Text("No Images"),

                        SizedBox(
                          height: res_height * 0.03,
                        ),
                        Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: res_width * 0.7,
                                    child: Text(
                                      "${widget.name.toString()}",
                                      //"${snapshot.data[0].name.toString()}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (prodID != "" && length != "" && sourceId != "") {
                                        Get.to(() => Reviews(stars: widget.stars, reviewsLenght: length, userID: sourceId, prodID: prodID));
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (prodID != "" && length != "" && sourceId != "") {
                                              Get.to(() => Reviews(stars: widget.stars, reviewsLenght: length, userID: sourceId, prodID: prodID));
                                            }
                                          },
                                          child: RatingBarIndicator(
                                            rating: double.parse(widget.stars),
                                            itemBuilder: (context, index) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 15,
                                            direction: Axis.horizontal,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rental Price',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    "\$${widget.price.toString()} / day",
                                    //'${snapshot.data.price.toString()}}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (vendorImage != null && vendorBackImage != null) {
                              Get.to(() => RenterScreen(vendorName, vendorImage, vendorBackImage, vendorAddress, widget.userID.toString()));
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                  height: res_height * 0.05,
                                  width: res_width * 0.125,
                                  // child:
                                  // Text("Image"),
                                  child: userLoader
                                      ? CircleAvatar(backgroundImage: AssetImage("assets/slicing/blankuser.jpeg"))
                                      : userEmpty
                                          ? CircleAvatar(
                                              backgroundImage: AssetImage(
                                              "assets/slicing/blankuser.jpeg",
                                            ))
                                          : ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString() == null
                                              ? CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                  "assets/slicing/blankuser.jpeg",
                                                ))
                                              : CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    AppUrl.baseUrlM + ApiRepository.shared.getUserCredentialModelList!.data![0].image.toString(),
                                                  ),
                                                )),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                // "Vendor",
                                userLoader
                                    ? "Vendor"
                                    : userEmpty
                                        ? "Vendor"
                                        : ApiRepository.shared.getUserCredentialModelList!.data![0].name.toString(),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        GFAccordion(
                            // titleBorderRadius: BorderRadius.circular(10),
                            contentBackgroundColor: Colors.transparent,
                            expandedTitleBackgroundColor: Colors.transparent,
                            margin: EdgeInsets.zero,
                            // contentPadding: EdgeInsets.symmetric(vertical: 15),
                            collapsedTitleBackgroundColor: Colors.transparent,
                            showAccordion: false,
                            titleChild: Row(

                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Image.asset(
                                  //   "assets/images/Icon feather-settings.png",
                                  //   scale: 5,
                                  // ),
                                  // SizedBox(
                                  //   width: 28,
                                  // ),
                                  Text(
                                    "Product Specifications",
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                ]),

                            // textStyle: TextStyle(color: Colors.amber, fontSize: 16),
                            collapsedIcon: Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Colors.black,
                            ),
                            expandedIcon: Icon(
                              Icons.arrow_drop_up_outlined,
                              color: Colors.black,
                            ),
                            contentChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    widget.specs.toString(),
                                    // "Dimensions: 146.7 x 71.5 x 7.7 mm 5.78 x 2.81 x 0.30 in\n\nWeight:     174 g 6.14 oz\n\nBuild:      Glass front (Corning-made glass)\n\nSIM:        Nano-SIM",
                                    style: TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                )
                              ],
                            )),

                        // ),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        GFAccordion(
                          contentBackgroundColor: Colors.transparent,
                          expandedTitleBackgroundColor: Colors.transparent,
                          margin: EdgeInsets.zero,
                          // contentPadding: EdgeInsets.symmetric(vertical: 15),
                          collapsedTitleBackgroundColor: Colors.transparent,
                          // collapsedTitleBackgroundColor: Color(0xffA0A1D6),
                          showAccordion: false,

                          titleChild: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Image.asset(
                            //   "assets/images/Icon feather-settings.png",
                            //   scale: 5,
                            // ),
                            // SizedBox(
                            //   width: 28,
                            // ),
                            Text(
                              "Service & Agreements",
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ]),

                          // textStyle: TextStyle(color: Colors.amber, fontSize: 16),
                          collapsedIcon: Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.black,
                          ),

                          expandedIcon: Icon(
                            Icons.arrow_drop_up_outlined,
                            color: Colors.black,
                          ),
                          contentChild: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => RentalAgreement());
                                },
                                child: Container(
                                  width: 389,
                                  height: 50,
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(5),
                                  //   color: Color(0xffD2D2F1),
                                  // ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(
                                        "Rental Agreement",
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                              Container(
                                width: 389,
                                height: 50,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(5),
                                //   color: Color(0xffD2D2F1),
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => TermsAndCondition());
                                      },
                                      child: Text(
                                        "Terms & Conditions",
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              Container(
                                width: 389,
                                height: 50,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(5),
                                //   color: Color(0xffD2D2F1),
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => InsuranceAndIndemnification());
                                      },
                                      child: Text(
                                        "Insurance & Indemnifications Policy",
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              Container(
                                width: 389,
                                height: 50,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(5),
                                //   color: Color(0xffD2D2F1),
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => TransportAndInstallationPolicy());
                                      },
                                      child: Text(
                                        "Transportation & Installation Policy",
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          width: res_width * 0.9,
                          child: Text(
                            'Products Description',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        Container(
                          width: res_width * 0.9,
                          child: Text(
                            widget.desc,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        // SizedBox(
                        //   height: res_height * 0.01,
                        // ),
                        // negotiation != "0"
                        //     ? Container(
                        //         width: res_width * 0.9,
                        //         child: Text(
                        //           'Negotiation Amount: ${negotiation}%',
                        //           style: TextStyle(fontSize: 15),
                        //         ),
                        //       )
                        //     : Text(""),
                        // SizedBox(
                        //   height: res_height * 0.01,
                        // ),
                        // negotiation != "0" && guestName! != "Guest"
                        //     ? Text("Enter amount in range specified or Rent Now for instant rent")
                        //     : Text(""),
                        SizedBox(
                          height: res_height * 0.01,
                        ),
                        // negotiation != "0" && guestName! != "Guest"
                        //     ? Container(
                        //         height: 50,
                        //         width: res_width * 1,
                        //         child: TextField(
                        //           keyboardType: TextInputType.number,
                        //           controller: negotiationController,
                        //           decoration: InputDecoration(
                        //             suffixIcon: GestureDetector(
                        //                 onTap: () {
                        //                   preOrder(negotiation, negotiationController.text, context);
                        //                 },
                        //                 child: Icon(Icons.send)),
                        //             hintText: "Discount Margin: ${negotiation}%",
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(15.0),
                        //             ),
                        //             enabledBorder: const OutlineInputBorder(
                        //               borderSide: const BorderSide(color: kprimaryColor, width: 1),
                        //               borderRadius: BorderRadius.all(Radius.circular(15)),
                        //             ),
                        //             focusedBorder: const OutlineInputBorder(
                        //               borderSide: const BorderSide(color: kprimaryColor, width: 1),
                        //               borderRadius: BorderRadius.all(Radius.circular(15)),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     : Text(""),
                        SizedBox(
                          height: res_height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // messageVisibility
                            //     ?
                            Visibility(
                              visible: role != "Guest",
                              child: GestureDetector(
                                onTap: () {
                                  if (nameapi == "null") {
                                    final snackBar1 = new SnackBar(content: new Text("First complete your profile."));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                                  } else {
                                    Get.to(() => Chat(widget.userID));
                                  }
                                  print("Nameapi  ${nameapi}");
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: res_width * 0.115,
                                    color: kprimaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                        'assets/slicing/chat.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // : Text(""),
                            Container(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      rentClicked(context);
                                      // rentVisibility
                                      //     ? Get.to(() => RentnowScreen(vendorName, vendorAddress, cell, vendorImage, widget.userID, widget.id,
                                      //         pastart, paend, widget.price, vendorAccountId,  vendorPPEmail, "simple",  widget.delivery_charges, security_deposit))
                                      //     : null;
                                      //  Get.to(() => RentnowScreen());
                                    },
                                    child: Container(
                                      width: res_width * 0.3,
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
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     Get.to(() => MyCart());
                                  //   },
                                  //   child: GestureDetector(
                                  //     onTap: () {
                                  //       showDialog(
                                  //         context: context,
                                  //         builder: (_) => AlertDialog(
                                  //           backgroundColor: Color(0xff000000B8),
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius: BorderRadius.circular(10),
                                  //           ),
                                  //           contentPadding: EdgeInsets.all(0),
                                  //           actionsPadding: EdgeInsets.all(0),
                                  //           actions: [
                                  //             Stack(
                                  //               clipBehavior: Clip.none,
                                  //               alignment: AlignmentDirectional.center,
                                  //               children: [
                                  //                 Container(
                                  //                   width: 320,
                                  //                   height: 222,
                                  //                   decoration: BoxDecoration(
                                  //                       // border: Border.all(color: Colors.white),
                                  //                       borderRadius: BorderRadius.circular(10),
                                  //                       color: Color(0xffFEB038)),
                                  //                   child: ListView(
                                  //                     children: [
                                  //                       Column(
                                  //                         mainAxisAlignment: MainAxisAlignment.end,
                                  //                         children: [
                                  //                           SizedBox(
                                  //                             height: 67,
                                  //                           ),
                                  //                           Container(
                                  //                             child: Text(
                                  //                               "Add To Cart",
                                  //                               style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                                  //                             ),
                                  //                           ),
                                  //                           SizedBox(
                                  //                             height: 10,
                                  //                           ),
                                  //                           Text(
                                  //                             "Item added to your cart",
                                  //                             style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                                  //                           ),
                                  //                           SizedBox(
                                  //                             height: 32,
                                  //                           ),
                                  //                           Row(
                                  //                             children: [
                                  //                               Container(
                                  //                                 width: 160,
                                  //                                 height: 55,
                                  //                                 decoration: BoxDecoration(
                                  //                                     borderRadius: BorderRadius.only(
                                  //                                       bottomLeft: Radius.circular(10),
                                  //                                       // bottomRight:
                                  //                                       //     Radius.circular(10.r),
                                  //                                     ),
                                  //                                     color: Colors.white),
                                  //                                 child: Center(
                                  //                                   child: GestureDetector(
                                  //                                     onTap: () {
                                  //                                       Get.back();
                                  //                                     },
                                  //                                     child: Container(
                                  //                                       child: Text(
                                  //                                         "Continue Shopping",
                                  //                                         style: TextStyle(
                                  //                                             fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                  //                                       ),
                                  //                                     ),
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                               Container(
                                  //                                 width: 160,
                                  //                                 height: 55,
                                  //                                 decoration: BoxDecoration(
                                  //                                     borderRadius: BorderRadius.only(
                                  //                                       // bottomLeft:
                                  //                                       //     Radius.circular(10.r),
                                  //                                       bottomRight: Radius.circular(10),
                                  //                                     ),
                                  //                                     color: Colors.white),
                                  //                                 child: Center(
                                  //                                   child: GestureDetector(
                                  //                                     onTap: () {},
                                  //                                     child: Text(
                                  //                                       "Go to cart",
                                  //                                       style: TextStyle(
                                  //                                           fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                  //                                     ),
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             ],
                                  //                           ),
                                  //                         ],
                                  //                       )
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //                 Positioned(
                                  //                     top: -20,
                                  //                     // left: 100,
                                  //                     child: Container(
                                  //                         width: 90,
                                  //                         height: 90,
                                  //                         decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffFEB038)),
                                  //                         child: Center(
                                  //                             child: Image.asset(
                                  //                           "assets/slicing/smile@3x.png",
                                  //                           scale: 5,
                                  //                         ))))
                                  //               ],
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       );
                                  //     },
                                  //     child: Container(
                                  //       width: res_width * 0.3,
                                  //       decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.all(Radius.circular(12))),
                                  //       child: Padding(
                                  //         padding: const EdgeInsets.all(12.0),
                                  //         child: Center(
                                  //             child: Text(
                                  //           'Add to cart',
                                  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  //         )),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: res_height * 0.01),
                        // SizedBox(height: res_height*0.02,)
                        // SizedBox(height: 50,)
                      ],
                    )),
                  ],
                ),
              ),
              isLoading
                  ? SizedBox(
                      height: 10,
                    )
                  : ApiRepository.shared.getRelatedProductsList!.data!.length > 0
                      ? FutureBuilder(
                          builder: (context, snapshot) {
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 30.0, childAspectRatio: 1),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: ApiRepository.shared.getRelatedProductsList?.data?.length,
                              itemBuilder: (context, int index) {
                                var name = ApiRepository.shared.getRelatedProductsList!.data![index].name;
                                var price = ApiRepository.shared.getRelatedProductsList!.data![index].price;
                                var stars = ApiRepository.shared.getRelatedProductsList!.data![index].stars;
                                var reviews = ApiRepository.shared.getRelatedProductsList!.data![index].length;
                                var specs = ApiRepository.shared.getRelatedProductsList!.data![index].specifications;
                                var image = ApiRepository.shared.getRelatedProductsList!.data![index].image;
                                var length = ApiRepository.shared.getRelatedProductsList!.data![index].length;
                                var delivery_charges = ApiRepository.shared.getRelatedProductsList!.data![index].delivery_charges;
                                return Container(
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      itmBox2(
                                          img: AppUrl.baseUrlM + image.toString(),
                                          dx: '\$${price}',
                                          rv: length.toString(),
                                          tx: name,
                                          rt: stars,
                                          context: context),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          future: null,
                        )
                      : SizedBox(
                          height: 10,
                        ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              )
            ],
          ),
        ),
      ),
    );
  }

  itmBox({img, tx, dx, rt, rv}) {
    return GestureDetector(
      onTap: () {
        // Get.to(() => ProductDetailScreen());
      },
      child: Container(
        width: 50,
        // height: res_height * 0.28,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        // child: Padding(
        //   padding: const EdgeInsets.only(
        //       bottom: 120, left: 10, right: 10, top: 10),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: 2 * 5,
                decoration: BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  child: Image.asset(
                    '$img',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                height: 2 * 0.005,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$tx',
                      style: TextStyle(fontSize: 11),
                    ),
                    SizedBox(
                      height: 2 * 0.006,
                    ),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 11,
                            color: kprimaryColor,
                          ),
                          Icon(
                            Icons.star,
                            size: 11,
                            color: kprimaryColor,
                          ),
                          Icon(
                            Icons.star,
                            size: 11,
                            color: kprimaryColor,
                          ),
                          Icon(
                            Icons.star,
                            size: 11,
                            color: kprimaryColor,
                          ),
                          Icon(Icons.star, size: 11),
                          Text(
                            '$rt ',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '$rv',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: MediaQuery.of(context).size.height*0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  itmBox2({img, tx, dx, rt, rv, context}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      width: res_width * 0.44,
      // height: res_height * 0.28,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 244, 244, 244),
        borderRadius: BorderRadius.circular(10),
      ),
      // child: Padding(
      //   padding: const EdgeInsets.only(
      //       bottom: 120, left: 10, right: 10, top: 10),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          children: [
            Container(
              height: res_height * 0.2,
              decoration: BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                child: Image.network(
                  '$img',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: res_height * 0.005,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tx',
                    style: TextStyle(fontSize: 11),
                  ),
                  SizedBox(
                    height: res_height * 0.006,
                  ),
                  Text(
                    '$dx',
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.left,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(rt),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 15,
                          direction: Axis.horizontal,
                        ),
                        Text(
                          '($rv) Reviews',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            )
          ],
        ),
      ),
    );
  }

  void rentClicked(context) async {
    if (rentVisibility) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String _name = sharedPreferences.getString('fullname') ?? "";
      if (_name == "Guest") {
        onRentClicked("Guest");
        // showSignUpDialog(context);
      } else {
        onRentClicked("");
      }
    }
  }

  void showSignUpDialog(context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xff000000B8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.all(0),
        actionsPadding: EdgeInsets.all(0),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 175,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Color(0xffFEB038)),
                child: ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 67,
                        ),
                        Text(
                          "Please Sign Up to Proceed",
                          style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 160,
                                height: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    color: Colors.white),
                                child: Center(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  Get.back();
                                  onRentClicked("Guest");
                                },
                                child: Container(
                                  width: 160,
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                      ),
                                      color: Colors.white),
                                  child: Center(
                                    child: Text(
                                      "SignUp",
                                      style: TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                  top: -20,
                  child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffFEB038)),
                      child: Center(
                          child: Image.asset(
                        "assets/slicing/smile@3x.png",
                        scale: 5,
                      ))))
            ],
          ),
        ],
      ),
    );
  }

  void onRentClicked(String status) async {
    if (rentVisibility) {
      print("vendor name is $vendorName");

      if (status == "Guest") {
        Get.to(() => RentnowScreen(vendorName, vendorAddress, cell, vendorImage, widget.userID, widget.id, pastart, paend, widget.price,
            vendorAccountId, vendorPPEmail, "simple", widget.delivery_charges, security_deposit));
      } else {
        Get.to(() => RentnowScreen(vendorName, vendorAddress, cell, vendorImage, widget.userID, widget.id, pastart, paend, widget.price,
            vendorAccountId, vendorPPEmail, "simple", widget.delivery_charges, security_deposit));
      }
    }
  }
}
