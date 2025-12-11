import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/home/Electronics.dart';

import '../../../model/categoryList_model.dart';
import '../../../res/app_url.dart';
import '../../../view_model/category_get_View_model.dart';

class CategoriesssScreen extends StatefulWidget {
  const CategoriesssScreen({super.key});

  @override
  State<CategoriesssScreen> createState() => _CategoriesssScreenState();
}

class _CategoriesssScreenState extends State<CategoriesssScreen> {
  @override
  Widget build(BuildContext context) {
    GetAPiFromModel getAPiFromModel = GetAPiFromModel();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text("Categories", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    child: Text(
                      "Lets Find!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: getAPiFromModel.getCategoryList(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<CategoryList> snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      final data = snapshot.data!.data;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 5,
                        children: List.generate(snapshot.data!.data!.length, (
                          index,
                        ) {
                          return contBox(
                            txt: data![index].name,
                            img: '${AppUrl.baseUrlM}${data[index].image}',
                            id: data[index].id.toString(),
                          );
                        }),
                      );
                    }
                  },
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
    return GestureDetector(
      onTap: () {
        Get.to(() => ElectronicsScreen(categoryname: txt, id: id));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 5, top: 5),
              width: res_width * 0.25,
              height: res_height * 0.12,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                color: kprimaryColor,
                borderRadius: BorderRadius.all(Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: Offset(2, 1), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipOval(
                  child: CachedNetworkImage(
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
                ),
              ),
            ),
            SizedBox(height: 6),
            SizedBox(
              width: res_width * 0.27,
              child: Center(
                child: Text(
                  "$txt",
                  style: TextStyle(fontSize: responsiveFontSize),
                  overflow: TextOverflow.ellipsis, // Specify overflow behavior
                  maxLines: 1, // Limit to a single line
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
