import 'package:flutter/material.dart';
import 'package:jared/Services/product_detail_service.dart';

class ProDetailProvider extends ChangeNotifier {
  getAllDetails(id) async {
    print("object");
    var data = await ProDetailService().getproDetails(id);
    notifyListeners();
    return data;
  }
}
