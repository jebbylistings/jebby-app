import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jared/Views/screens/mainfolder/homemain.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jared/Views/helper/colors.dart';
import 'package:dio/dio.dart' as d;

class WriteReview extends StatefulWidget {
  var stars;
  var reviewsLenght;
  var userID;
  var prodID;

  WriteReview(this.stars, this.reviewsLenght, this.userID, this.prodID);

  @override
  State<WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  late double ratings;
  TextEditingController reviewController = TextEditingController();
  File? _image;

  Future getGalleryImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print("no picked Image");
      }
    });
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
          'Write a Reviews',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
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
        reverse: true,
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: res_width * 0.9,
                child: Column(
                  children: [
                    SizedBox(
                      height: res_height * 0.05,
                    ),
                    Text(
                      'Add Rating',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 37),
                    ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    RatingBar.builder(
                      initialRating: double.parse(widget.stars.toString()),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          ratings = rating;
                        });
                        print(ratings);
                      },
                    ),
                    SizedBox(
                      height: res_height * 0.05,
                    ),
                    Row(
                      children: [
                        Text(
                          'Add Photo or Video',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Container(
                      width: res_width * 0.9,
                      height: res_height * 0.2,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kprimaryColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                          width: res_width * 0.2,
                          height: res_height * 0.15,
                          child: _image == null
                              ? InkWell(
                                  onTap: getGalleryImage,
                                  child: Icon(
                                    Icons.cloud_upload_rounded,
                                    size: 25,
                                  ),
                                )
                              : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.contain,
                                )),
                    ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Row(
                      children: [
                        Text(
                          'Write Your Review',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.85,
                        minHeight: MediaQuery.of(context).size.height * 0.1,
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                        maxHeight: MediaQuery.of(context).size.height * 0.2,
                      ),
                      child: TextField(
                        controller: reviewController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          // hintText:
                          //     "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: kprimaryColor, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   width: res_width * 0.9,
                    //   height: res_height * 0.2,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Text(
                    //       "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                    //       style: TextStyle(color: Colors.grey),
                    //     ),
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: Color(0xffebebeb),
                    //     border: Border.all(
                    //       color: kprimaryColor,
                    //       width: 0.5,
                    //     ),
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    // ),
                    SizedBox(
                      height: res_height * 0.02,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (reviewController.text.toString().isNotEmpty &&
                            _image != null) {
                          try {
                            late d.FormData formData;
                            String fileName = p.basename(_image!.path);
                            formData = new d.FormData.fromMap({
                              "file": await d.MultipartFile.fromFile(
                                  _image!.path,
                                  filename: fileName),
                              "user_id": widget.userID.toString(),
                              "product_id": widget.prodID.toString(),
                              "stars": ratings.toString(),
                              "description": reviewController.text.toString(),
                            });
                            var data ={"file": await d.MultipartFile.fromFile(
                                  _image!.path,
                                  filename: fileName),
                              "user_id": widget.userID.toString(),
                              "product_id": widget.prodID.toString(),
                              "stars": ratings.toString(),
                              "description": reviewController.text.toString(),};
                              print(data);
                            d.Response response = await Dio().post(
                                "https://api.jebbylistings.com/reviewInsert",
                                data: formData);
                            print("API HIT SUCESSFULL");
                            print(response.data);
                            final snackBar =
                                new SnackBar(content: new Text("Uploaded"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                               await Get.offAll(() => MainScreen());
                            // Get.back();
                          } catch (e) {
                            print("error ${e.toString()}");
                          }
                        } else {
                          final snackBar = new SnackBar(
                              content: new Text("Fields Cannot Be Empty"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        height: res_height * 0.06,
                        width: res_width * 0.8,
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: kprimaryColor,
                            borderRadius: BorderRadius.circular(14)),
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
