import 'package:jared/data/network/BaseApiServices.dart';
import 'package:jared/data/network/NetworkApiService.dart';
import 'package:jared/res/app_url.dart';

class AuthRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.loginApiEndPointM, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> signUpApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.registerApiEndPointM, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> otpRegisterApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.OTPApiEndPoint, data);
      print("response of the $response");
      return response;
    } catch (e) {
      throw e;
    }
  }

  ///////////////////////Social SignIn //////////////////////////////////////
  Future<dynamic> signUpApiWithSocial(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.registerApiEndPointM, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  ///////////////////////Social SignIn //////////////////////////////////////
  Future<dynamic> signUpApiWithGuest(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.registerApiEndPointM, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  //forgetPassword
  Future<dynamic> forgetPasswordApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.forgetPasswordEmail, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> ForgetPasswordotpApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.ForgetPasswordOtpEndPoint, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  //change password
  Future<dynamic> changePasswordApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.ChangePasswordUrl, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> editProfileApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.ChangePasswordUrl, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> DeleteAccount(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.DeleteAccount, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> updateRoleApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.updateUserRoleApiEndPoint,data);
      return response;
    } catch (e) {
      throw e;
    }
  }
}
