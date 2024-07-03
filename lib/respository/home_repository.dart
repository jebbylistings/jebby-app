import 'package:jared/data/network/NetworkApiService.dart';
import 'package:jared/model/Change_Profile.dart';
import 'package:jared/model/movies_model.dart';

import '../data/network/BaseApiServices.dart';
import '../res/app_url.dart';

class UserProfileRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<ChangeProfileModel> changeProfileDataWithModel(id) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(AppUrl.UserProfileGetByIdUrl+"$id");
      return response = ChangeProfileModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  Future changeProfileData() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(AppUrl.UserProfileGetByIdUrl);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<MovieListModel> fetchMoviesList() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(AppUrl.moviesListEndPoint);
      return response = MovieListModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

   Future<void> fetchCategoryList() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(AppUrl.categoryGetUrl);
      return response ;//= MovieListModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }
}
