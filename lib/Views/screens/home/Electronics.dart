import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jebby/Views/screens/home/Electronics2.dart';
import 'package:jebby/model/sub_category_list_model.dart';

import '../../../res/app_url.dart';
import '../../../view_model/category_get_View_model.dart';

class ElectronicsScreen extends StatefulWidget {
  final String? id;
  final String? categoryname;
  final String? pictureurl;

  const ElectronicsScreen({
    super.key,
    this.categoryname,
    this.id,
    this.pictureurl,
  });

  @override
  State<ElectronicsScreen> createState() => _ElectronicsScreenState();
}

class _ElectronicsScreenState extends State<ElectronicsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GetAPiFromModel getAPiFromModel = GetAPiFromModel();
    double scrimStrength = 0.15;
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   leading: InkWell(
      //     onTap: () {
      //       Get.back();
      //     },
      //     borderRadius: BorderRadius.circular(50),
      //     child: Icon(Icons.arrow_back, color: Colors.black),
      //   ),
      // ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(350),
        child: Builder(
          builder: (context) {
            final top = MediaQuery.of(context).padding.top;
            const radius = 26.0;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    // Image(
                    //   image: imageProvider,
                    //   fit: BoxFit.cover,
                    // ),
                    CachedNetworkImage(
                      imageUrl: widget.pictureurl!,
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

                    // Universal darken layer (ensures white text works on any image)
                    Container(color: Colors.black.withOpacity(scrimStrength)),

                    // Extra bottom gradient for stronger contrast near text
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                            Colors.black87,
                          ],
                          stops: [0.3, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 66, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // child: Stack(
                //   children: [
                //     Container(
                //       height: 400,
                //       decoration: BoxDecoration(
                //         image: DecorationImage(
                //           image: NetworkImage(widget.pictureurl!),
                //         ),
                //         borderRadius: BorderRadius.only(
                //           bottomLeft: Radius.circular(radius),
                //           bottomRight: Radius.circular(radius),
                //         ),
                //       ),
                //       padding: EdgeInsets.fromLTRB(16, top + 12, 16, 18),
                //     ),
                //
                //     Positioned(
                //       top: 10,
                //       left: 10,
                //       child: InkWell(
                //         onTap: () {
                //           Get.back();
                //         },
                //         borderRadius: BorderRadius.circular(50),
                //         child: Icon(Icons.arrow_back, color: Colors.black),
                //       ),
                //     ),
                //   ],
                // ),
              ),
            );
          },
        ),
      ),

      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  child: Text(
                    "${widget.categoryname}",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  width: res_width * 0.9,
                  child: Text(
                    "The perfect T-shirt for when you want to feel comfortable but still stylish. Amazing for all ocasions.Made of 100% cotton fabric in four colours.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                  ),
                ),

                SizedBox(height: 10),
                SizedBox(
                  height: 600,
                  child: FutureBuilder(
                    future: getAPiFromModel.getSubCategoryList(
                      widget.id.toString(),
                    ),
                    builder: (
                      context,
                      AsyncSnapshot<SubCategoryList> snapshot,
                    ) {
                      final data = snapshot.data?.data;
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.data!.data!.length != 0) {

                          return Container(
                            width: res_width,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(6),
                              //                        physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),

                              itemCount: snapshot.data!.data!.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                // Wider than tall to match your screenshot card shape
                                childAspectRatio: 1.2,
                              ),
                              itemBuilder: (context, index) {
                                // final item = items[index];

                                return contBox(
                                  txt: data![index].name,
                                  img: '${AppUrl.baseUrlM}${data[index].image}',
                                  id: data[index].id.toString(),
                                );
                              },
                            ),
                          );
                          return ListView.builder(
                            itemCount: snapshot.data!.data!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => Electronics2(
                                          widget.categoryname,
                                          data[index].id.toString(),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 400,
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                "${data![index].name}",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Container(
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          width: 400,
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "No data available",
                              style: TextStyle(fontSize: 14),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  contBox({txt, img, id}) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    double responsiveFontSize = res_width * 0.035;
    double borderRadius = 20;
    double scrimStrength = 0.05;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(
                () => Electronics2(
              widget.categoryname,
             id.toString(),
            ),
          );
        },
        child: SizedBox(
          width: res_width * 0.45,
          height: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              // Image(
              //   image: imageProvider,
              //   fit: BoxFit.cover,
              // ),
              CachedNetworkImage(
                imageUrl: '$img',
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Center(
                  child: CircularProgressIndicator(), // Loading spinner
                ),
                errorWidget:
                    (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.red,
                ), // Display an error icon
              ),

              // Universal darken layer (ensures white text works on any image)
              Container(color: Colors.black.withOpacity(scrimStrength)),

              // Extra bottom gradient for stronger contrast near text
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width:res_width*0.27,
                          child: Text(
                            "$txt",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.1,
                              letterSpacing: -0.2,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0 items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        shadows: const [
                          Shadow(blurRadius: 3, color: Colors.black45),
                        ],
                      ),
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
