import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/route_manager.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/auth/ProductDetail.dart';
import 'package:jebby/res/app_url.dart';

import '../../../view_model/apiServices.dart';

class RenterScreen extends StatefulWidget {
  final dynamic vendorName;
  final dynamic vendorImage;
  final dynamic vendorBackImage;
  final dynamic vendorAddress;
  final dynamic vendorID;

  RenterScreen(
    this.vendorName,
    this.vendorImage,
    this.vendorBackImage,
    this.vendorAddress,
    this.vendorID,
  );

  @override
  State<RenterScreen> createState() => _RenterScreenState();
}

class _RenterScreenState extends State<RenterScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getReviews() {
    ApiRepository.shared.reviewsByVendorId(
      widget.vendorID.toString(),
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isEmpty = true;
              isLoading = false;
              isError = false;
            });
          } else {
            setState(() {
              isEmpty = false;
              isLoading = false;
              isError = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isEmpty = false;
            isLoading = false;
            isError = true;
          });
        }
      },
    );
  }

  bool isPLoading = true;
  bool isPError = false;
  bool isPEmpty = false;

  getProducts() {
    ApiRepository.shared.reviewsByVenodorProduct(
      widget.vendorID.toString(),
      (List) {
        if (this.mounted) {
          if (List.data!.length == 0) {
            setState(() {
              isPEmpty = true;
              isPLoading = false;
              isPError = false;
            });
          } else {
            setState(() {
              isPEmpty = false;
              isPLoading = false;
              isPError = false;
            });
          }
        }
      },
      (error) {
        if (error != null) {
          setState(() {
            isPEmpty = false;
            isPLoading = false;
            isPError = true;
          });
        }
      },
    );
  }

  void initState() {
    getReviews();
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Renter",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(left: 10),
        //     child: Container(
        //       child: Icon(
        //         Icons.share,
        //         color: Colors.black,
        //       ),
        //     ),
        //   )
        // ],
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SizedBox(height: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 400,
                      height: 136,
                      decoration: BoxDecoration(),
                      child:
                          widget.vendorBackImage != ""
                              ? Image.network(
                                AppUrl.baseUrlM +
                                    widget.vendorBackImage.toString(),
                                fit: BoxFit.contain,
                              )
                              : Image.asset("assets/slicing/userblankpng.png"),
                    ),
                    Positioned(
                      left: 15,
                      bottom: -20,
                      child: Container(
                        child:
                            widget.vendorImage != ""
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    AppUrl.baseUrlM +
                                        widget.vendorImage.toString(),
                                  ),
                                )
                                : CircleAvatar(
                                  radius: 40,
                                  child: Image.asset(
                                    "assets/slicing/blankuser.jpeg",
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendorName != ""
                              ? widget.vendorName
                              : "Vendor",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 300,
                          child: Text(
                            widget.vendorAddress != ""
                                ? widget.vendorAddress
                                : "",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Container(
                        //   width: 380,
                        //   child: Text(
                        //     widget.vendorAddress != "" ? widget.vendorAddress : "",
                        //     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 14),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(height: 10),
                isLoading
                    ? Text("")
                    : isEmpty
                    ? Text("")
                    : Reviewsss(
                      ApiRepository
                          .shared
                          .getAllReviewsByVendorIdModelList!
                          .totalreviews
                          .toString(),
                    ),
                SizedBox(height: 10),
                isLoading
                    ? Text("")
                    : isEmpty
                    ? Text("")
                    : SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        // physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            ApiRepository
                                .shared
                                .getAllReviewsByVendorIdModelList!
                                .data!
                                .length,
                        itemBuilder: (context, int index) {
                          var image =
                              ApiRepository
                                  .shared
                                  .getAllReviewsByVendorIdModelList!
                                  .data![index]
                                  .image
                                  .toString();
                          var stars =
                              ApiRepository
                                  .shared
                                  .getAllReviewsByVendorIdModelList!
                                  .data![index]
                                  .stars
                                  .toString();
                          var desc =
                              ApiRepository
                                  .shared
                                  .getAllReviewsByVendorIdModelList!
                                  .data![index]
                                  .description
                                  .toString();
                          var name =
                              ApiRepository
                                  .shared
                                  .getAllReviewsByVendorIdModelList!
                                  .data![index]
                                  .userName
                                  .toString();
                          return scrollss(image, stars, desc, name);
                        },
                      ),
                    ),
                // Row(
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //       scrollss(),
                //     ],
                //   ),
                // ),
                Row(
                  children: [
                    Text(
                      "Menu",
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  width: 400,
                  height: 1,
                  color: Colors.grey.withAlpha(128),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Review Product",
                          style: TextStyle(color: Colors.black, fontSize: 19),
                        ),
                        SizedBox(height: 5),
                        // Text(
                        //   "Top products incredible price",
                        //   style: TextStyle(color: Colors.grey, fontSize: 14),
                        // ),
                      ],
                    ),
                  ],
                ),
                isPLoading
                    ? Text("")
                    : isPEmpty
                    ? Container(
                      height: 100,
                      child: Center(child: Text("No Review Product")),
                    )
                    : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 30.0,
                        childAspectRatio: 1,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          ApiRepository
                              .shared
                              .getVendorProductsByReviewsModelList!
                              .data!
                              .length,
                      itemBuilder: (context, int index) {
                        var data =
                            ApiRepository
                                .shared
                                .getVendorProductsByReviewsModelList!
                                .data![index];
                        var image = data.image.toString();
                        var price = data.price.toString();
                        var length = data.length.toString();
                        var name = data.name.toString();
                        var id = data.id.toString();
                        var stars = data.stars;
                        var specs = data.specifications.toString();
                        var userID = data.userId.toString();
                        var message = data.isMessage;
                        var desc = data.serviceAgreements.toString();
                        return itmBox(
                          img: image,
                          dx: price,
                          rv: length,
                          tx: name,
                          rt: stars,
                          id: id,
                          specs: specs,
                          userID: userID,
                          message: message,
                          desc: desc,
                        );
                      },
                    ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     itmBox(
                //         img: 'assets/slicing/Layer 4@3x.png',
                //         dx: '\$ 7000',
                //         rv: '(2.9k Revews)',
                //         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                //         rt: '4.9'),
                //     itmBox(
                //         img: 'assets/slicing/Layer 4@3x.png',
                //         dx: '\$ 9000',
                //         rv: '(2.9k Revews)',
                //         tx: 'Apple 10.9-inch iPad Air Wi-Fi Cellular 64GB0',
                //         rt: '4.9'),
                //   ],
                // ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Followesss() {
    return Container(
      width: 391,
      height: 74,
      decoration: BoxDecoration(
        color: Color(0xFF4285F4),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("0", style: TextStyle(color: kprimaryColor)),
                Text("Following", style: TextStyle(color: kprimaryColor)),
              ],
            ),
            SizedBox(width: 20),
            Container(width: 1, height: 40, color: kprimaryColor),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("2654", style: TextStyle(color: kprimaryColor)),
                Text("Followers", style: TextStyle(color: kprimaryColor)),
              ],
            ),
            SizedBox(width: 20),
            Container(width: 1, height: 40, color: kprimaryColor),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("265", style: TextStyle(color: kprimaryColor)),
                Text("Products", style: TextStyle(color: kprimaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reviewsss() {
  //   return Row(
  //     children: [
  //       Text(
  //         "Reveiws",
  //         style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(
  //         width: 5,
  //       ),
  //       Container(
  //         child: Icon(
  //           Icons.star,
  //           color: kprimaryColor,
  //         ),
  //       ),
  //       SizedBox(
  //         width: 5,
  //       ),
  //       Text(
  //         "4.9 (124)",
  //         style: TextStyle(
  //           fontSize: 16,
  //         ),
  //       ),
  //       SizedBox(
  //         width: 145,
  //       ),
  //       GestureDetector(
  //         onTap: () {
  //           Get.to(() => ReviewTapScreen());
  //         },
  //         child: Container(
  //           child: Text(
  //             "See All",
  //             style: TextStyle(
  //               fontSize: 16,
  //             ),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Reviewsss(review) {
    return Row(
      children: [
        Text(
          "Reveiws",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Text(review, style: TextStyle(fontSize: 16)),
        SizedBox(width: 145),
      ],
    );
  }

  // scrollss() {
  //   return Container(
  //     width: 257,
  //     height: 135,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.2),
  //           spreadRadius: 5,
  //           blurRadius: 7,
  //           offset: Offset(0, 3), // changes position of shadow
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 30),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 child: Image.asset(
  //                   "assets/slicing/20171102_MH_BOBSLED_1737 (1)-1@2x.png",
  //                   scale: 1.7,
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 6,
  //               ),
  //               Container(
  //                 child: Text("John Smith"),
  //               )
  //             ],
  //           ),
  //           SizedBox(
  //             height: 8,
  //           ),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Icon(
  //                 Icons.star,
  //                 color: kprimaryColor,
  //                 size: 20,
  //               ),
  //               Icon(
  //                 Icons.star,
  //                 color: kprimaryColor,
  //                 size: 20,
  //               ),
  //               Icon(
  //                 Icons.star,
  //                 color: kprimaryColor,
  //                 size: 20,
  //               ),
  //               Icon(
  //                 Icons.star,
  //                 color: kprimaryColor,
  //                 size: 20,
  //               ),
  //               Icon(
  //                 Icons.star,
  //                 color: kprimaryColor,
  //                 size: 20,
  //               ),
  //               SizedBox(
  //                 width: 5,
  //               ),
  //               Text(
  //                 "5.0",
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ],
  //           ),
  //           SizedBox(
  //             height: 4,
  //           ),
  //           Container(
  //             width: 200,
  //             child: Text(
  //               "Lorem ipsum dolor, adipiscingm dolor, adipiscingelit  elit, seda.",
  //               style: TextStyle(fontSize: 12, color: Colors.grey),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  scrollss(img, stars, desc, name) {
    return Container(
      width: 257,
      height: 135,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(AppUrl.baseUrlM + img),
                ),
                // Container(
                //   child: Image.network(
                //     AppUrl.baseUrlM + img,
                //     fit: BoxFit.fill,
                //   ),
                // ),
                SizedBox(width: 6),
                Container(child: Text(name)),
              ],
            ),
            SizedBox(height: 8),
            RatingBarIndicator(
              rating: double.parse(stars.toString()),
              itemBuilder:
                  (context, index) => Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 15,
              direction: Axis.horizontal,
            ),
            SizedBox(height: 4),
            Container(
              width: 200,
              child: Text(
                desc,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  itmBox({
    img,
    tx,
    dx,
    rt,
    rv,
    id,
    specs,
    userID,
    message,
    desc,
    delivery_charges,
  }) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        // Get.to(() => ProductDetailScreen(id: id,));
        Get.to(
          routeName: "PD",
          () => ProductDetailScreen(
            id,
            tx,
            dx,
            rt,
            img,
            specs,
            userID,
            desc,
            message,
            delivery_charges,
          ),
        );
      },
      child: Container(
        width: res_width * 0.44,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 244, 244, 244),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Container(
                height: res_height * 0.22,
                decoration: BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    AppUrl.baseUrlM + img.toString(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: res_height * 0.005),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tx \$', style: TextStyle(fontSize: 11)),
                    SizedBox(height: res_height * 0.006),
                    Text(
                      '$dx',
                      style: TextStyle(fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(rt.toString()),
                          itemBuilder:
                              (context, index) =>
                                  Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 15,
                          direction: Axis.horizontal,
                        ),
                        Text('$rt ', style: TextStyle(fontSize: 11)),
                        Text(
                          '$rv',
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
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
