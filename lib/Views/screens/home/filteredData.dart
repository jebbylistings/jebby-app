import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
import 'package:jebby/view_model/apiServices.dart';

import '../../../res/app_url.dart';
import '../auth/ProductDetail.dart';

class FilteredData extends StatefulWidget {
  final dynamic subCatname;

  FilteredData({this.subCatname});

  @override
  State<FilteredData> createState() => _FilteredDataState();
}

class _FilteredDataState extends State<FilteredData> {
  @override
  Widget build(BuildContext context) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.subCatname}',
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
                ApiRepository.shared.getFilteredProductDataList!.data!.length >
                        0
                    ? FutureBuilder(
                      builder: (context, snapshot) {
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 2 / 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount:
                              ApiRepository
                                  .shared
                                  .getFilteredProductDataList!
                                  .data!
                                  .length,
                          itemBuilder: (context, index) {
                            var data =
                                ApiRepository
                                    .shared
                                    .getFilteredProductDataList!
                                    .data![index];
                            var st = data.stars;
                            var stars = double.parse(st.toString());
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  routeName: "PD",
                                  () => ProductDetailScreen(
                                    data.id,
                                    data.name,
                                    data.price,
                                    data.stars,
                                    AppUrl.baseUrlM + data.image.toString(),
                                    data.specifications,
                                    data.userId,
                                    data.serviceAgreements,
                                    data.isMessage,
                                    data.delivery_charges,
                                  ),
                                );
                              },
                              child: Container(
                                width: res_width * 0.65,

                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 244, 244, 244),
                                  borderRadius: BorderRadius.circular(10),
                                ),

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
                                                data.image.toString(),
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
                                      //                   data
                                      //                       .image
                                      //                       .toString()))),
                                      //   child: ClipRRect(
                                      //     borderRadius: BorderRadius.all(
                                      //       Radius.circular(10),
                                      //     ),
                                      //   ),
                                      // ),
                                      SizedBox(height: res_height * 0.01),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.name.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: res_height * 0.006,
                                            ),
                                            Text(
                                              "${data.price.toString()} \$",
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
                      },
                      future: null,
                    )
                    : CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
