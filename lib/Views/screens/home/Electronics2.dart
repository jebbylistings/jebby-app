import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Services/product_services.dart';
import 'package:jebby/Views/screens/auth/ProductDetail.dart';
// import 'package:jebby/screens/home/profile/myprofile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../res/app_url.dart';

class Electronics2 extends StatefulWidget {
  final dynamic catname;
  final dynamic id;
  Electronics2(this.catname, this.id);

  @override
  State<Electronics2> createState() => _Electronics2State();
}

class _Electronics2State extends State<Electronics2> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    // context.watch<ProductProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    ProductServices productServices = ProductServices();

    return Scaffold(
      key: _key,
      // drawer: DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.catname}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 19,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Get.back();
            // _key.currentState!.openDrawer();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: res_height * 0.03),
            Column(
              children: [
                FutureBuilder(
                  future: productServices.getProducts(widget.id.toString()),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 150),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                          // child: Text("No data"),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error Occured While Loading Data");
                    } else {
                      if (snapshot.data?.data?.length != 0) {
                        final data = snapshot.data?.data;
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(12),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: snapshot.data?.data?.length,
                          itemBuilder: (context, index) {
                            var st = snapshot.data?.data[index].stars;
                            var stars = double.parse(st.toString());
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  routeName: "PD",
                                  () => ProductDetailScreen(
                                    snapshot.data?.data[index].id,
                                    snapshot.data?.data[index].name,
                                    snapshot.data?.data[index].price,
                                    snapshot.data?.data[index].stars,
                                    AppUrl.baseUrlM + data[index].image,
                                    snapshot.data?.data[index].specifications,
                                    snapshot.data?.data[index].userId,
                                    snapshot
                                        .data
                                        ?.data[index]
                                        .serviceAgreements,
                                    snapshot.data?.data[index].isMessage,
                                    snapshot.data?.data[index].delivery_charges,
                                  ),
                                );
                              },
                              child: Container(
                                width: res_width * 0.65,
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: res_height * 0.2,
                                        child: Center(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                AppUrl.baseUrlM +
                                                data[index].image.toString(),
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(), // Loading spinner
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ), // Display an error icon
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   height: res_height * 0.2,
                                      //   width: res_width,
                                      //   decoration: BoxDecoration(
                                      //       image: DecorationImage(
                                      //           image: NetworkImage(
                                      //               AppUrl.baseUrlM +
                                      //                   data[index]
                                      //                       .image
                                      //                       .toString()))
                                      //                       ),
                                      //   child: ClipRRect(
                                      //     borderRadius: BorderRadius.all(
                                      //       Radius.circular(10),
                                      //     ),
                                      //   ),
                                      // ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: res_height * 0.01),
                                            Text(
                                              "${data?[index].name}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: res_height * 0.006,
                                            ),
                                            Text(
                                              "\$${data?[index]?.price.toString()}",
                                              style: TextStyle(fontSize: 13),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(
                                              height: res_height * 0.006,
                                            ),
                                            RatingBarIndicator(
                                              rating: stars,
                                              itemBuilder:
                                                  (context, index) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                              itemCount: 5,
                                              itemSize: 15,
                                              direction: Axis.horizontal,
                                            ),
                                            //                            Row(
                                            //   children: [
                                            //     starss.floor() == 1
                                            //         ? Row(
                                            //             children: [
                                            //               Icon(
                                            //                 Icons.star,
                                            //                 size: 11,
                                            //                 color: kprimaryColor,
                                            //               ),
                                            //               Icon(Icons.star, size: 11),
                                            //               Icon(Icons.star, size: 11),
                                            //               Icon(Icons.star, size: 11),
                                            //               Icon(Icons.star, size: 11),
                                            //             ],
                                            //           )
                                            //         : starss.floor() == 2
                                            //             ? Row(
                                            //                 children: [
                                            //                   Icon(
                                            //                     Icons.star,
                                            //                     size: 11,
                                            //                     color: kprimaryColor,
                                            //                   ),
                                            //                   Icon(
                                            //                     Icons.star,
                                            //                     size: 11,
                                            //                     color: kprimaryColor,
                                            //                   ),
                                            //                   Icon(Icons.star, size: 11),
                                            //                   Icon(Icons.star, size: 11),
                                            //                   Icon(Icons.star, size: 11),
                                            //                 ],
                                            //               )
                                            //             : starss.floor() == 3
                                            //                 ? Row(
                                            //                     children: [
                                            //                       Icon(
                                            //                         Icons.star,
                                            //                         size: 11,
                                            //                         color: kprimaryColor,
                                            //                       ),
                                            //                       Icon(
                                            //                         Icons.star,
                                            //                         size: 11,
                                            //                         color: kprimaryColor,
                                            //                       ),
                                            //                       Icon(
                                            //                         Icons.star,
                                            //                         size: 11,
                                            //                         color: kprimaryColor,
                                            //                       ),
                                            //                       Icon(Icons.star, size: 11),
                                            //                       Icon(Icons.star, size: 11),
                                            //                     ],
                                            //                   )
                                            //                 : starss.floor() == 4
                                            //                     ? Row(
                                            //                         children: [
                                            //                           Icon(
                                            //                             Icons.star,
                                            //                             size: 11,
                                            //                             color: kprimaryColor,
                                            //                           ),
                                            //                           Icon(
                                            //                             Icons.star,
                                            //                             size: 11,
                                            //                             color: kprimaryColor,
                                            //                           ),
                                            //                           Icon(
                                            //                             Icons.star,
                                            //                             size: 11,
                                            //                             color: kprimaryColor,
                                            //                           ),
                                            //                           Icon(
                                            //                             Icons.star,
                                            //                             size: 11,
                                            //                             color: kprimaryColor,
                                            //                           ),
                                            //                           Icon(Icons.star, size: 11),
                                            //                         ],
                                            //                       )
                                            //                     : starss.floor() == 5
                                            //                         ? Row(
                                            //                             children: [
                                            //                               Icon(
                                            //                                 Icons.star,
                                            //                                 size: 11,
                                            //                                 color: kprimaryColor,
                                            //                               ),
                                            //                               Icon(
                                            //                                 Icons.star,
                                            //                                 size: 11,
                                            //                                 color: kprimaryColor,
                                            //                               ),
                                            //                               Icon(
                                            //                                 Icons.star,
                                            //                                 size: 11,
                                            //                                 color: kprimaryColor,
                                            //                               ),
                                            //                               Icon(
                                            //                                 Icons.star,
                                            //                                 size: 11,
                                            //                                 color: kprimaryColor,
                                            //                               ),
                                            //                               Icon(
                                            //                                 Icons.star,
                                            //                                 size: 11,
                                            //                                 color: kprimaryColor,
                                            //                               ),
                                            //                             ],
                                            //                           )
                                            //                         : Text(""),
                                            //   ],
                                            // )
                                            // Row(
                                            //   children: [
                                            //     Icon(
                                            //       Icons.star,
                                            //       size: 11,
                                            //       color: kprimaryColor,
                                            //     ),
                                            //     Icon(
                                            //       Icons.star,
                                            //       size: 11,
                                            //       color: kprimaryColor,
                                            //     ),
                                            //     Icon(
                                            //       Icons.star,
                                            //       size: 11,
                                            //       color: kprimaryColor,
                                            //     ),
                                            //     Icon(
                                            //       Icons.star,
                                            //       size: 11,
                                            //       color: kprimaryColor,
                                            //     ),
                                            //     Icon(Icons.star, size: 11),
                                            //     data?[index]?.stars == ""
                                            //         ? Text("0")
                                            //         : Text(
                                            //             "${data?[index]?.stars.toString()}",
                                            //             //   data.review.star[index],
                                            //             style: TextStyle(fontSize: 11),
                                            //           ),
                                            //     // Text(
                                            //     //   '${snapshot.data?.data[index].negotiation}',
                                            //     //   style: TextStyle(
                                            //     //     fontSize: 9,
                                            //     //     color: Colors.grey,
                                            //     //   ),
                                            //     // ),
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            "No Data Availible",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  itmBox({img, tx, dx, rt, rv}) {
    return null;
  }
}
