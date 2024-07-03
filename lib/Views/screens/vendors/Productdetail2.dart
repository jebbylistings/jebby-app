import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jared/Views/controller/bottomcontroller.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:jared/Views/screens/agreements/insuranceAndIndemnifications.dart';
import 'package:jared/Views/screens/agreements/rentalAgreement.dart';
import 'package:jared/Views/screens/agreements/termsAndConditions.dart';
import 'package:jared/Views/screens/agreements/transportAndInstallationPolicy.dart';
import 'package:jared/Views/screens/vendors/EditProduct.dart';
import 'package:jared/Views/screens/vendors/reveiew.dart';
import 'package:getwidget/getwidget.dart';
import 'package:jared/res/app_url.dart';

import '../../../view_model/apiServices.dart';

class ProductDetail2Screen extends StatefulWidget {
  var id;

  ProductDetail2Screen({
    this.id,
  });

  @override
  State<ProductDetail2Screen> createState() => _ProductDetail2ScreenState();
}

class _ProductDetail2ScreenState extends State<ProductDetail2Screen> {
  String dropdownValue = 'One';
  bool isLoading = true;
  bool isError = false;
  bool emptyProdData = false;
  bool relloading = true;
  bool relError = false;
  late var prodID;
  List imagesList = [];
  List imagesListID = [];
  List relProdArray = [];
  var categoryID = null;
  var subCategoryID = null;
  var name = null;
  var price = null;
  var specifications = null;
  var description = null;
  var negotiation = null;
  var product_id = null;
  var images = null;
  var imageID = null;
  var message = null;
  bool editVisibility = false;
  var length = "";
  var stars = "";
  var delivery_charges= null;

  void initState() {
    getProducts(widget.id.toString());
    print("ID ==> ${widget.id.toString()}");
    print(imagesList);
    super.initState();
  }

  void getProducts(id) {
    setState(() {
      isLoading = true;
      isError = false;
      emptyProdData = false;
      relloading = true;
      relError = false;
      imagesList = [];
      imagesListID = [];
      relProdArray = [];
    });

    ApiRepository.shared.getProductsById(
        (list) => {
              if (this.mounted)
                {
                  if (list.data!.length == 0)
                    {
                      setState(() {
                        isLoading = false;
                        isError = false;
                        prodID = ApiRepository.shared.getProductsByIdList?.data![0].productId.toString();
                      }),
                    }
                  else
                    {
                      print("Product ID --> ${ApiRepository.shared.getProductsByIdList?.data![0].productId}"),
                      setState(() {
                        isLoading = false;
                        isError = false;
                        prodID = ApiRepository.shared.getProductsByIdList?.data![0].productId.toString();
                      }),
                      for (int i = 0; i < ApiRepository.shared.getProductsByIdList!.data![1].images!.length; i++)
                        {
                          imagesList.add(ApiRepository.shared.getProductsByIdList?.data?[1].images?[i].path),
                          imagesListID.add(ApiRepository.shared.getProductsByIdList?.data?[1].images?[i].id)
                        },
                      categoryID = ApiRepository.shared.getProductsByIdList?.data![0].categoryId,
                      subCategoryID = ApiRepository.shared.getProductsByIdList?.data![0].subcategoryId,
                      name = ApiRepository.shared.getProductsByIdList?.data![0].name,
                      price = ApiRepository.shared.getProductsByIdList!.data![0].price2.toString(),
                      specifications = ApiRepository.shared.getProductsByIdList?.data![0].specifications,
                      description = ApiRepository.shared.getProductsByIdList?.data![0].serviceAgreements,
                      negotiation = ApiRepository.shared.getProductsByIdList?.data![0].negotiation,
                      product_id = ApiRepository.shared.getProductsByIdList?.data![0].productId,
                      message = ApiRepository.shared.getProductsByIdList?.data![0].isMessage,
                      length = ApiRepository.shared.getProductsByIdList!.data![0].length.toString(),
                      stars = ApiRepository.shared.getProductsByIdList!.data![0].stars.toString(),
                      delivery_charges = ApiRepository.shared.getProductsByIdList!.data![0].delivery_charges.toString(),
                      print("Executed images list"),
                      print(imagesList),
                      print("Executed images list ID"),
                      print(imagesListID),
                      getRelProducts(),
                      images = imagesList,
                      imageID = imagesListID,
                      setState(() {
                        editVisibility = true;
                      }),
                    }
                }
            },
        (error) => {
              if (error != null)
                {
                  setState(() {
                    isLoading = false;
                    isError = true;
                  })
                }
            },
        id);
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
                        relloading = false;
                        relError = false;
                      }),
                    }
                  else
                    {
                      print("Related Products Data"),
                      setState(() {
                        relloading = false;
                        relError = false;
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
                  })
                }
            },
        ApiRepository.shared.getProductsByIdList?.data![0].productId.toString());
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text("Error In LoadingData"))
              : Center(
                  child: Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: res_width * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ApiRepository.shared.getProductsByIdList!.data![1].images!.length > 0
                                    ? SizedBox(
                                        height: 150,
                                        child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) => SizedBox(
                                                  width: 10,
                                                ),
                                            // physics: NeverScrollableScrollPhysics(),
                                            itemCount: ApiRepository.shared.getProductsByIdList!.data![1].images!.length,
                                            itemBuilder: (context, int index) {
                                              var img = ApiRepository.shared.getProductsByIdList?.data?[1].images?[index].path;
                                              return Container(
                                                child: Image.network(AppUrl.baseUrlM + img.toString()),
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
                                          Text(
                                            ApiRepository.shared.getProductsByIdList!.data![0].name.toString(),
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (length != "" && prodID != null && stars != "") {
                                                Get.to(() => VendorReviewScreen(
                                                      stars: stars,
                                                      reviewsLenght: length,
                                                      prodID: prodID,
                                                    ));
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating: double.parse(ApiRepository.shared.getProductsByIdList!.data![0].stars.toString()),
                                                  itemBuilder: (context, index) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 15,
                                                  direction: Axis.horizontal,
                                                ),
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
                                            ApiRepository.shared.getProductsByIdList!.data![0].price2.toString(),
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
                                // GestureDetector(
                                //   // onTap: () {
                                //   //   Get.to(() => RenterScreen());
                                //   // },
                                //   child: Row(
                                //     children: [
                                //       Container(
                                //         height: res_height * 0.05,
                                //         width: res_width * 0.125,
                                //         child: Image.asset('assets/slicing/apple.png'),
                                //       ),
                                //       SizedBox(
                                //         width: 4,
                                //       ),
                                //       Text(
                                //         'Iphone Organization',
                                //         style: TextStyle(
                                //           fontSize: 17,
                                //           fontWeight: FontWeight.normal,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // Divider(
                                //   color: Colors.grey,
                                //   thickness: 0.5,
                                // ),
                                GFAccordion(
                                    // titleBorderRadius: BorderRadius.circular(10),
                                    contentBackgroundColor: Colors.transparent,
                                    expandedTitleBackgroundColor: Colors.transparent,
                                    // margin: EdgeInsets.zero,
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
                                      children: [
                                        Container(
                                          child: Text(
                                            ApiRepository.shared.getProductsByIdList!.data![0].specifications.toString(),
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
                                  // margin: EdgeInsets.zero,
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
                                  height: 7,
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Text(
                                //       'Question about this products (3)',
                                //       style: TextStyle(fontSize: 13, color: Colors.grey),
                                //     ),
                                //     Text(
                                //       'View all',
                                //       style: TextStyle(fontSize: 13, color: Colors.grey),
                                //     )
                                //   ],
                                // ),
                                // SizedBox(
                                //   height: 7,
                                // ),
                                // Row(
                                //   children: [
                                //     ImageIcon(
                                //       AssetImage('assets/slicing/questions.png'),
                                //     ),
                                //     SizedBox(
                                //       width: 10,
                                //     ),
                                //     Text(
                                //       'How soon can i get this products ?',
                                //       style: TextStyle(fontSize: 12.5, color: Colors.grey),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(
                                //   height: 7,
                                // ),
                                // Row(
                                //   children: [
                                //     ImageIcon(
                                //       AssetImage('assets/slicing/questions.png'),
                                //     ),
                                //     SizedBox(
                                //       width: 10,
                                //     ),
                                //     Text(
                                //       'verv soon',
                                //       style: TextStyle(fontSize: 12.5, color: Colors.grey),
                                //     ),
                                //   ],
                                // ),
                                SizedBox(
                                  height: res_height * 0.02,
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
                                    ApiRepository.shared.getProductsByIdList!.data![0].serviceAgreements.toString(),
                                    // 'Lorem Ipsum is simply dummy text of the printing and type-setting industry.Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 39,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
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
                                                  width: 320,
                                                  height: 222,
                                                  decoration: BoxDecoration(
                                                      // border: Border.all(color: Colors.white),
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: Color(0xffFEB038)),
                                                  child: ListView(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          SizedBox(
                                                            height: 67,
                                                          ),
                                                          Text(
                                                            "Delete",
                                                            style: TextStyle(fontFamily: "Inter, Bold", fontSize: 30, color: Colors.white),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width: 250,
                                                            child: Center(
                                                              child: Text(
                                                                "Are you sure you want to delete this item?",
                                                                style: TextStyle(fontFamily: "Inter, Regular", fontSize: 19, color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                          // 15.verticalSpace,
                                                          // Container(
                                                          //   width: 270.w,
                                                          //   height: 50.h,
                                                          //   child: Text(
                                                          //     "You will be contacted by the Owner via direct message to confirm!",
                                                          //     textAlign: TextAlign.center,
                                                          //     style: TextStyle(
                                                          //       fontFamily: "Inter, Regular",
                                                          //       fontSize: 15.sp,
                                                          //       color: Colors.white,
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          SizedBox(
                                                            height: 18,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 160,
                                                                height: 51,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      bottomLeft: Radius.circular(10),
                                                                      // bottomRight:
                                                                      //     Radius.circular(10.r),
                                                                    ),
                                                                    color: Colors.white),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    Get.back();
                                                                  },
                                                                  child: Center(
                                                                    child: Text(
                                                                      "No",
                                                                      style:
                                                                          TextStyle(fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 160,
                                                                height: 51,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      // bottomLeft:
                                                                      //     Radius.circular(10.r),
                                                                      bottomRight: Radius.circular(10),
                                                                    ),
                                                                    color: Colors.white),
                                                                child: Center(
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      ApiRepository.shared.deleteProductsById(prodID);
                                                                      final bottomcontroller = Get.put(BottomController());
                                                                      bottomcontroller.navBarChange(1);
                                                                      print("Navigated");
                                                                    },
                                                                    child: Container(
                                                                      child: Text(
                                                                        "yes",
                                                                        style: TextStyle(
                                                                            fontFamily: "Inter, Regular", fontSize: 14, color: Colors.black),
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
                                                    // left: 100,
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
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white, border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(5)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (categoryID != null &&
                                          subCategoryID != null &&
                                          name != null &&
                                          price != null &&
                                          specifications != null &&
                                          description != null &&
                                          negotiation != null &&
                                          product_id != null &&
                                          images != null &&
                                          imageID != null &&
                                          message != null &&
                                          delivery_charges != null
                                      ){
                                        // print(
                                        //   categoryID.toString() +
                                        //   subCategoryID.toString() +
                                        //   name.toString() +
                                        //   price.toString() +
                                        //   specifications.toString() +
                                        //   description.toString() +
                                        //   negotiation.toString() +
                                        //   product_id.toString()

                                        // );
                                        Get.off(() => EditProductScreen(
                                              category_id: categoryID,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .categoryId,
                                              sub_category_id: subCategoryID,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .subcategoryId,
                                              name: name,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .name,
                                              price: price,

                                              
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .price,
                                              specifications: specifications,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .specifications,
                                              description: description,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .serviceAgreements,
                                              negotiation: negotiation,
                                              //  ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .negotiation,
                                              product_id: product_id,
                                              // ApiRepository
                                              //     .shared
                                              //     .getProductsByIdList
                                              //     ?.data![0]
                                              //     .productId,
                                              relProd: [],
                                              images: images,
                                              imageID: imageID,
                                              messageStatus: message,
                                              delivery_charges:delivery_charges,
                                            ));
                                      }
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          'Edit Product',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: editVisibility ? kprimaryColor : kprimaryColor.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(5)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: res_height * 0.03,
                          ),

                          relloading
                              ? SizedBox(
                                  height: 10,
                                )
                              : FutureBuilder(builder: (context, snapshot) {
                                  return GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, crossAxisSpacing: 2.0, mainAxisSpacing: 30.0, childAspectRatio: 1),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: ApiRepository.shared.getRelatedProductsList?.data?.length,
                                    itemBuilder: (context, int index) {
                                      relProdArray.add(ApiRepository.shared.getRelatedProductsList!.data![index]);
                                      var name = ApiRepository.shared.getRelatedProductsList!.data![index].name;
                                      var price = ApiRepository.shared.getRelatedProductsList!.data![index].price;
                                      var stars = ApiRepository.shared.getRelatedProductsList!.data![index].stars;
                                      var reviews = ApiRepository.shared.getRelatedProductsList!.data![index].length;
                                      var specs = ApiRepository.shared.getRelatedProductsList!.data![index].specifications;
                                      var image = ApiRepository.shared.getRelatedProductsList!.data![index].image;
                                      var length = ApiRepository.shared.getRelatedProductsList!.data![index].length;
                                      var id = ApiRepository.shared.getRelatedProductsList!.data![index].id;
                                      return Container(
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            itmBox(
                                                img: AppUrl.baseUrlM + image.toString(),
                                                dx: '\$${price}',
                                                rv: length.toString(),
                                                tx: name,
                                                rt: stars,
                                                id: id),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }, future: null,),
                          SizedBox(
                            height: 100,
                          )
                          // Container(height: 100,)
                        ],
                      ),
                    ),

                    ///here
                  ),
                ),
    );
  }

  itmBox({img, tx, dx, rt, rv, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        print("First Id: ${widget.id}");
        print("Second Id: ${id}");
        // getProducts(id.toString());
      },
      child: Container(
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
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
