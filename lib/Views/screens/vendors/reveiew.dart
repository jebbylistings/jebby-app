import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../res/app_url.dart';
import '../../../view_model/apiServices.dart';

class VendorReviewScreen extends StatefulWidget {
  var stars;
  var reviewsLenght;
  var prodID;
  VendorReviewScreen({this.stars, this.reviewsLenght, this.prodID});

  @override
  State<VendorReviewScreen> createState() => _VendorReviewScreenState();
}

class _VendorReviewScreenState extends State<VendorReviewScreen> {
  bool isLoading = true;
  bool isError = false;
  bool isEmpty = false;

  getReviews() {
    ApiRepository.shared.reviewsByProductId(widget.prodID.toString(), (List) {
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
    }, (error) {
      if (error != null) {
        setState(() {
          isEmpty = false;
          isLoading = false;
          isError = true;
        });
      }
    });
  }

  @override
  void initState() {
    print(widget.prodID.toString());
    super.initState();
    getReviews();
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
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Container(
              child: Icon(
                Icons.arrow_back,
            color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: res_height * 0.05,
              ),
              Text(
                widget.stars.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33),
              ),
              RatingBarIndicator(
                rating: double.parse(widget.stars),
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 15,
                direction: Axis.horizontal,
              ),
              SizedBox(
                height: res_height * 0.005,
              ),
              Text("${widget.reviewsLenght.toString()} reviews"),
              SizedBox(
                height: res_height * 0.03,
              ),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Excellent'),
                    Row(
                      children: [
                        Container(
                            height: res_height * 0.007,
                            width: res_width * 0.5,
                            decoration: BoxDecoration(
                                color: Color(0xff01af00),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                border: Border(left: BorderSide(width: 12)))),
                        Container(
                          height: res_height * 0.007,
                          width: res_width * 0.12,
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              border: Border(left: BorderSide(width: 12))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Good'),
                    Row(
                      children: [
                        Container(
                            height: res_height * 0.007,
                            width: res_width * 0.43,
                            decoration: BoxDecoration(
                                color: Color(0xff98e01d),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                border: Border(left: BorderSide(width: 12)))),
                        Container(
                          height: res_height * 0.007,
                          width: res_width * 0.19,
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              border: Border(left: BorderSide(width: 12))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Average'),
                    Row(
                      children: [
                        Container(
                            height: res_height * 0.007,
                            width: res_width * 0.33,
                            decoration: BoxDecoration(
                                color: Color(0xfffff023),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                border: Border(
                                  left: BorderSide(width: 12),
                                ))),
                        Container(
                          height: res_height * 0.007,
                          width: res_width * 0.29,
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              border: Border(left: BorderSide(width: 12))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Below Average'),
                    Row(
                      children: [
                        Container(
                            height: res_height * 0.007,
                            width: res_width * 0.23,
                            decoration: BoxDecoration(
                                color: Color(0xfff36523),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                border: Border(left: BorderSide(width: 12)))),
                        Container(
                          height: res_height * 0.007,
                          width: res_width * 0.39,
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              border: Border(left: BorderSide(width: 12))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.02),
              Container(
                width: res_width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Poor'),
                    Row(
                      children: [
                        Container(
                            height: res_height * 0.007,
                            width: res_width * 0.13,
                            decoration: BoxDecoration(
                                color: Color(0xfffe0000),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                border: Border(left: BorderSide(width: 12)))),
                        Container(
                          height: res_height * 0.007,
                          width: res_width * 0.49,
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              border: Border(left: BorderSide(width: 12))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: res_height * 0.04),
              isError
                  ? Center(child: Text("Some Error Occured In Loading Data"))
                  : isLoading
                      ? Center(child: Text("Loading"))
                      : isEmpty
                          ? Center(child: Text(""))
                          : ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: ApiRepository.shared.getReviewsByProductIdModelList!.data!.length,
                              itemBuilder: (context, int index) {
                                var data = ApiRepository.shared.getReviewsByProductIdModelList!.data![index];
                                var image = AppUrl.baseUrlM + data.image.toString();
                                var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data.createdAt.toString()));
                                var stars = data.stars;
                                print("RUNTIMETYPE ${stars.runtimeType}");
                                var desc = data.description.toString();
                                var name = data.userName.toString();
                                return card(image, date, stars, desc, name);
                              }),
              SizedBox(height: res_height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  card(img, date, stars, desc, name) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      // height: res_height * 0.15,
      width: res_width * 0.9,
      // width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            height: res_height * 0.15,
          ),
          Container(
            width: res_width * 0.2,
            child: Image.network(
              img,
              height: 40,
              width: 40,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: res_width * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      width: res_width * 0.31,
                    ),
                    Text(
                      date,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    SizedBox(
                      height: res_height * 0.01,
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: double.parse(stars.toString()),
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 15,
                direction: Axis.horizontal,
              ),
              SizedBox(
                height: res_height * 0.001,
              ),
              Container(
                width: res_width * 0.7,
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
