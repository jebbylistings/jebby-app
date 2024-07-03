import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:jared/data/response/api_response.dart';
import 'package:jared/model/movies_model.dart';
import 'package:jared/respository/home_repository.dart';
import 'package:jared/view_model/services/splash_services.dart';

import '../model/Change_Profile.dart';

class HomeViewViewModel with ChangeNotifier {
  // final _myRepo = HomeRepository();

  // ApiResponse<MovieListModel> moviesList = ApiResponse.loading();

  // setMoviesList(ApiResponse<MovieListModel> response){
  //   moviesList = response ;
  //   notifyListeners();
  // }

  // Future<void> fetchMoviesListApi ()async{

  //   setMoviesList(ApiResponse.loading());

  //   _myRepo.fetchMoviesList().then((value){

  //     setMoviesList(ApiResponse.completed(value));

  //   }).onError((error, stackTrace){

  //     setMoviesList(ApiResponse.error(error.toString()));

  //   });
  // }

  final myRepo = UserProfileRepository();

  ApiResponse<ChangeProfileModel> changeProfileData = ApiResponse.loading();

  setProfileData(ApiResponse<ChangeProfileModel> response) {
    changeProfileData = response;
    notifyListeners();
  }

  void getData() async {
    DataUsers dataUsers = DataUsers();
    dataUsers.profileData();
    dataUsers.fullname;
    log("dataUsers.fullname.toString()" + dataUsers.fullname.toString());
  }

  Future<void> changeProfileDataApi(id) async {
    setMovieList(ApiResponse.loading());
    myRepo.changeProfileDataWithModel(id).then((value) {
      setProfileData(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setMovieList(ApiResponse.error(error.toString()));
    });
  }

 

 



////////////////////////////////////////////////////////////
  ApiResponse<MovieListModel> movieslist = ApiResponse.loading();

  setMovieList(ApiResponse<MovieListModel> response) {
    movieslist = response;
    notifyListeners();
  }

  Future<void> fetchMoviesListApi() async {
    setMovieList(ApiResponse.loading());
    myRepo.fetchMoviesList().then((value) {
      setMovieList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setMovieList(ApiResponse.error(error.toString()));
    });
  }








  ///////////////////////////////////////////////
  
   Future<void> updateProfileData(id) async {

    dynamic updatedProfile=await myRepo.changeProfileData();
    return updatedProfile;
   }
}
