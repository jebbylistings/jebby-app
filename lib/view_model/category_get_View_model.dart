// import 'package:flutter/material.dart';

// import '../respository/home_repository.dart';

// class CategoryGetViewModel with ChangeNotifier{
//  final myRepo = UserProfileRepository();
//  String? _response;
//  dynamic get response => _response;

//   setCategoryList(responsefor){
//     _response = responsefor ;
//     notifyListeners();
//   }
//   Future CategoryGetViewModels()async {

//     myRepo.fetchCategoryList().then((value) {
//       setCategoryList(value.ma);
//       response=value;
//     }).onError((error, stackTrace) {
//       setMovieList(ApiResponse.error(error.toString()));
//     });
//   }

// }

import 'dart:convert';

import 'package:jebby/model/sub_category_list_model.dart';

import '../model/categoryList_model.dart';
import '../model/get_featured_model.dart';
import '../res/app_url.dart';
import 'package:http/http.dart' as http;

class GetAPiFromModel {
  Future<CategoryList> getCategoryList() async {
    final response = await http.get(Uri.parse(AppUrl.categoryGetUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return CategoryList.fromJson(data);
    } else {
      throw Exception("Error");
    }
  }

  Future<SubCategoryList> getSubCategoryList(String id) async {
    final response = await http.get(Uri.parse(AppUrl.subcategoryGetUrl + id));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return SubCategoryList.fromJson(data);
    } else {
      throw Exception("Error");
    }
  }

  Future<GetFeaturedModel> getFeaturedList() async {
    final response = await http.get(Uri.parse(AppUrl.featuredGetUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return GetFeaturedModel.fromJson(data);
    } else {
      throw Exception("Error");
    }
  }
}
