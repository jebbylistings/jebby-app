import 'package:flutter/material.dart';
import 'package:jebby/Services/product_detail_service.dart';

class ProDetailProvider extends ChangeNotifier {
  getAllDetails(id) async {
    var data = await ProDetailService().getproDetails(id);
    notifyListeners();
    return data;
  }
}
