import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jebby/model/getAllProductsModel.dart';
import 'package:jebby/view_model/apiServices.dart';

import '../../../res/app_url.dart';
import '../auth/ProductDetail.dart';

class SearchData extends StatefulWidget {
  final dynamic word;
  SearchData({this.word});

  @override
  State<SearchData> createState() => _SearchDataState();
}

class _SearchDataState extends State<SearchData> {
  bool isLoading = true;
  bool isError = false;
  bool emptyData = false;

  List<Data> results = [];
  GetAllProductsModel? _getAllProducts;

  getProducts() {
    ApiRepository.shared.allProducts(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  isLoading = false;
                  isError = false;
                  emptyData = true;
                  _getAllProducts = List;
                }),
              }
            else
              {
                setState(() {
                  _getAllProducts = List;
                  runFilter(widget.word.toString());
                  isLoading = false;
                  isError = false;
                  emptyData = false;
                }),
              },
          },
      },
      (error) => {
        if (this.mounted)
          {
            if (error != null)
              {
                setState(() {
                  isError = true;
                  isLoading = false;
                  emptyData = false;
                }),
              },
          },
      },
    );
  }

  void runFilter(String keyWord) {
    if (keyWord.isEmpty) {
      results = _getAllProducts!.data!;
    } else {
      results =
          _getAllProducts!.data!
              .where(
                (product) =>
                    product.name!.toLowerCase().contains(keyWord.toLowerCase()),
              )
              .toList();
    }
  }

  void initState() {
    getProducts();
    super.initState();
  }

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
          'Searched Products',
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
                isError
                    ? Center(child: Text("Error in loading data"))
                    : isLoading
                    ? Center(child: Text("Searching"))
                    : emptyData
                    ? Center(child: Text("No data Found"))
                    : results.length == 0
                    ? Center(child: Text("No Product Found"))
                    : FutureBuilder(
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
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            var st = results[index].stars;
                            var stars = double.parse(st.toString());
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  routeName: "PD",
                                  () => ProductDetailScreen(
                                    results[index].id,
                                    results[index].name,
                                    results[index].price,
                                    results[index].stars,
                                    AppUrl.baseUrlM +
                                        results[index].image.toString(),
                                    results[index].specifications,
                                    results[index].userId,
                                    results[index].serviceAgreements,
                                    results[index].isMessage,
                                    results[index].delivery_charges,
                                    // ""
                                    // snapshot.data?.data[index].id,
                                    // snapshot.data?.data[index].name,
                                    // snapshot.data?.data[index].price,
                                    // snapshot.data?.data[index].stars,
                                    // AppUrl.baseUrlM + data[index].image,
                                    // snapshot.data?.data[index]
                                    //     .specifications,
                                    // snapshot.data?.data[index].userId,
                                    // snapshot.data?.data[index]
                                    //     .serviceAgreements
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
                                        width: res_width,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              AppUrl.baseUrlM +
                                                  results[index].image
                                                      .toString(),
                                            ),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: res_height * 0.005),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              results[index].name.toString(),
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            SizedBox(
                                              height: res_height * 0.006,
                                            ),
                                            Text(
                                              "\$${results[index].price.toString()}",
                                              style: TextStyle(fontSize: 11),
                                              textAlign: TextAlign.left,
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
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
