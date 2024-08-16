import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jared/Views/screens/home/Electronics2.dart';
import 'package:jared/model/sub_category_list_model.dart';

import '../../../view_model/category_get_View_model.dart';

class ElectronicsScreen extends StatefulWidget {
  final String? id;
  final String? categoryname;

  const ElectronicsScreen({super.key, this.categoryname, this.id});

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

    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
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
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    "${widget.categoryname}",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 600,
                  child: FutureBuilder(
                    future: getAPiFromModel.getSubCategoryList(widget.id.toString()),
                    builder: (context, AsyncSnapshot<SubCategoryList> snapshot) {
                      final data = snapshot.data?.data;
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.data!.data!.length != 0) {
                          return ListView.builder(
                            itemCount: snapshot.data!.data!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 400,
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => Electronics2(widget.categoryname, data![index].id.toString()));
                                        },
                                        child: Container(
                                          child: Text(
                                            "${data![index].name}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 400,
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
