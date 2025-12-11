import 'package:flutter/material.dart';
import 'package:jebby/res/app_url.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../view_model/apiServices.dart';

// ignore: must_be_immutable
class PhotoGallery extends StatefulWidget {
  PhotoGallery({this.image});

  var image;

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  var productDetailData;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          actions: [
            SizedBox(height: width * 0.1),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: width * 0.15,
                    width: width * 0.12,
                    color: Colors.white,
                    child: Icon(Icons.close, size: 26, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.1),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: PhotoViewGallery.builder(
          itemCount:
              ApiRepository
                  .shared
                  .getProductsByIdList
                  ?.data?[1]
                  .images
                  ?.length, //widget.image.length,
          builder: (context, index) {
            // final url = widget.image.toString();
            var url =
                ApiRepository
                    .shared
                    .getProductsByIdList
                    ?.data?[1]
                    .images?[index]
                    .path;
            return PhotoViewGalleryPageOptions(
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 6,
              imageProvider: NetworkImage(AppUrl.baseUrlM + url.toString()),
            );
          },
        ),
      ),
    );
  }
}
