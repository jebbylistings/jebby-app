import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jared/Views/screens/vendors/ProductList.dart';
import 'package:jared/model/categoryList_model.dart';
import 'package:jared/model/getCategoryByIdModel.dart';
import 'package:jared/model/getRentalAgreementModel.dart';
import 'package:jared/model/getSubCategoryByIdModel.dart';
import 'package:jared/model/lastProductByVendorIdModel.dart';
import 'package:jared/model/postNotificationSeenOneModal.dart';
import 'package:jared/model/vendorProductModel.dart';
import '../Views/screens/home/orderRequestStatusUpdateModel.dart';
import '../Views/screens/mainfolder/homemain.dart';
import '../model/PostMessageModel.dart';
import '../model/PostOrderModel.dart';
import '../model/addFavouriteModel.dart';
import '../model/deleteNotificationModel.dart';
import '../model/getAllMessagesModel.dart';
import '../model/getAllOrdersByUserIdModel.dart';
import '../model/getAllOrdersByVendorId.dart';
import '../model/getAllProductsModel.dart';
import '../model/getAllReviewsByVendorId.dart';
import '../model/getChatHistoryModel.dart';
import '../model/getFavouriteProductsModel.dart';
import '../model/getFeaturedProductsModel.dart';
import '../model/getInsuranceModel.dart';
import '../model/getMaintainenceModel.dart';
import '../model/getNegoByIdModel.dart';
import '../model/getNotificationModel.dart';
import '../model/getReviewsByProductId.dart';
import '../model/getTerminationModel.dart';
import '../model/getTransportModel.dart';
import '../model/getTermLengthModel.dart';
import '../model/deleteProductModel.dart';
import '../model/filteredProductDataModel.dart';
import '../model/getAboutAppModel.dart';
import '../model/getAllProductsByVendorId.dart';
import '../model/getPrivacyPolicyModel.dart';
import '../model/getProductsByProductId.dart';
import '../model/getRelatedProductsModel.dart';
import '../model/getTermsAndConditionsModel.dart';
import '../model/getUsagePolicyModel.dart';
import '../model/getUserCredentialModel.dart';
import '../model/getVendorProductsByReviewsModel.dart';
import '../model/payByPayPalModel.dart';
import '../model/postNegotiationRequestModel.dart';
import '../model/postNotificationSeenModel.dart';
import '../model/postOrderStatusUpdateModel.dart';
import '../model/productDeleteModelImage.dart';
import '../model/productInfoInsert.dart';
import '../model/productUpdateModel.dart';
import '../model/reOrderModel.dart';
import '../model/stripePaymentModel.dart';
import '../model/sub_category_list_model.dart';
import '../res/app_url.dart';

class ApiRepository extends ChangeNotifier {
  bool getCategoryListApiStatus = false;
  bool subCategoryListListApiStatus = false;
  bool getVendorProductListListApiStatus = false;
  bool getProductByVendorIdListApiStatus = false;
  bool getProductsListApiStatus = false;
  bool delStatus = false;
  bool notificationLoader = false;
  bool getNotificationModelListApiStatus = false;
  bool getAllOrdersByVenodrIdListApiStatus = false;

  CategoryList? categoryList;
  SubCategoryList? subCategoryList;
  GetVendorProductsModel? VendorProductList;
  LastProductByVendorIdModel? lastVendorProductList;
  GetAllProductsByVendorId? vendorProductsByIdList;
  GetProductsByProductId? getProductsByIdList;
  GetRelatedProducts? getRelatedProductsList;
  GetCategoryByIdModel? getCategoryByIdModelList;
  GetSubCategoryByIdModel? getSubCategoryByIdModelList;
  ProductDeleteImageModel? getProductDeleteImageModelList;
  GetFilteredProductDataModel? getFilteredProductDataList;
  GetPrivacyPolicyModel? getPrivacyPolicyModelList;
  GetTermsAndConditionsModel? getTermsAndConditionsModelList;
  GetAboutAppModel? getAboutAppModelList;
  GetTermLengthModel? getTermLengthModelList;
  GetUserCredentialModel? getUserCredentialModelList;
  GetRentalAgreementModel? getRentalAgreementModelList;
  GetUsagePolicyModel? getUsagePolicyModelList;
  GetInsuranceModel? getInsuranceModelList;
  GetTransportModel? getTransportModelList;
  GetMaintanenceModel? getMaintainenceModelList;
  GetTerminationModel? getTerminationModelList;
  GetAllProductsModel? getAllProductsModelList;
  GetAllMessagesModel? getAllMessagesModelList;
  GetChatHistoryModel? getChatsHistoryModelList;
  GetFavouriteProductsModel? getFavouriteProductsModelList;
  GetNotificationModel? getNotificationModelList;
  GetAllReviewsByProductId? getReviewsByProductIdModelList;
  GetAllReviewsByVendorId? getAllReviewsByVendorIdModelList;
  GetVendorProductsByReveiwsModel? getVendorProductsByReviewsModelList;
  GetAllOrderByVendorIdModel? getAllOrdersByVenodrIdList;
  GetAllOrdersByUserIdModel? getAllOrdersByUserIdModelList;
  GetFeaturedModel? getFeaturedProductsModelList;
  GetNegoByIdModel? getNegoByIdModelList;

  static var shared = ApiRepository();

  var notificationTimer;

  checkApiStatus(status, apiName) {
    if (apiName == "categoryList") {
      getCategoryListApiStatus = status;
    } else if (apiName == "subcategoryList") {
      getCategoryListApiStatus = status;
    } else if (apiName == "getVendorProductList") {
      getVendorProductListListApiStatus = status;
    } else if (apiName == "getProductsList") {
      getProductsListApiStatus = status;
    } else if (apiName == "getNotifications") {
      getNotificationModelListApiStatus = status;
      print("notification status ${getNotificationModelListApiStatus}");
    } else if (apiName == "getAllOrdersByVenodrId") {
      getAllOrdersByVenodrIdListApiStatus = status;
      print("order status ${getNotificationModelListApiStatus}");
    }
  }

  getCategory(data) {
    categoryList = data;
    notifyListeners();
  }

  getSubCategory(data) {
    subCategoryList = data;
    notifyListeners();
  }

  getVendorProduct(data) {
    VendorProductList = data;
    notifyListeners();
  }

  getLastVendorProductList(data) {
    lastVendorProductList = data;
    notifyListeners();
  }

  getVendorProductsById(data) {
    vendorProductsByIdList = data;
    notifyListeners();
  }

  getProductByProductId(data) {
    getProductsByIdList = data;
    notifyListeners();
  }

  getRelatedProductsByProductId(data) {
    getRelatedProductsList = data;
    notifyListeners();
  }

  getSubCategoryById(data) {
    getSubCategoryByIdModelList = data;
  }

  getCategoryById(data) {
    getCategoryByIdModelList = data;
  }

  getdeletedProductImage(status) {
    delStatus = status;
    notifyListeners();
  }

  getFilteredProduct(data) {
    getFilteredProductDataList = data;
    notifyListeners();
  }

  getPrivacyPolicy(data) {
    getPrivacyPolicyModelList = data;
  }

  getTermsAndConditions(data) {
    getTermsAndConditionsModelList = data;
  }

  getAboutApp(data) {
    getAboutAppModelList = data;
  }

  getTermLength(data) {
    getTermLengthModelList = data;
  }

  getUserCredential(data) {
    getUserCredentialModelList = data;
  }

  getRentalAgreement(data) {
    getRentalAgreementModelList = data;
  }

  getUsagePolicy(data) {
    getUsagePolicyModelList = data;
  }

  getInsurance(data) {
    getInsuranceModelList = data;
  }

  getTransport(data) {
    getTransportModelList = data;
  }

  getMaintainence(data) {
    getMaintainenceModelList = data;
  }

  getTermination(data) {
    getTerminationModelList = data;
  }

  getAllProducts(data) {
    getAllProductsModelList = data;
    notifyListeners();
  }

  getAllMessages(data) {
    getAllMessagesModelList = data;
    print("length 1: ${getAllMessagesModelList!.data!.length}");
  }

  getChatHistory(data) {
    getChatsHistoryModelList = data;
    notifyListeners();
  }

  getFavouriteProduct(data) {
    getFavouriteProductsModelList = data;
    notifyListeners();
  }

  getAllUserOrders(data) {
    getAllOrdersByUserIdModelList = data;
    notifyListeners();
  }

  var unseenMessages = "";

  getNotifications(data) {
    print("notifications list rebuild");
    getNotificationModelList = data;
    notificationLoader = true;
    unseenMessages = ApiRepository.shared.getNotificationModelList!.unseen.toString();
    print("unseen Messages ${unseenMessages}");
    notifyListeners();
  }

  getReviewsByProductId(data) {
    getReviewsByProductIdModelList = data;
    notifyListeners();
  }

  getAllReviewsByVendorId(data) {
    getAllReviewsByVendorIdModelList = data;
    notifyListeners();
  }

  getVenodrProductsByReviews(data) {
    getVendorProductsByReviewsModelList = data;
    notifyListeners();
  }

  getAllOrdersByVenodrId(data) {
    getAllOrdersByVenodrIdList = data;
    notifyListeners();
  }

  getFeaturedProducts(data) {
    getFeaturedProductsModelList = data;
    notifyListeners();
  }

  getNegoById(data){
    getNegoByIdModelList = data;
    notifyListeners();
  }

  Future<CategoryList> getCategoryList(onResponse(CategoryList List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.categoryGetUrl), headers: {
      'Content-type': "application/json",
    });
    print("INVOKED");
    if (response.statusCode == 200) {
      try {
        var data = CategoryList.fromJson(jsonDecode(response.body));
        print("Data is here  ${data.data.toString()}");

        getCategory(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return CategoryList();
  }

  Future<SubCategoryList> getSubCategoryList(onResponse(SubCategoryList List), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.subcategoryGetUrl + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = SubCategoryList.fromJson(jsonDecode(response.body));
        print("Data is here  ${data.data.toString()}");

        getSubCategory(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return SubCategoryList();
  }

  Future<GetVendorProductsModel> getVendorProductList(onResponse(GetVendorProductsModel list), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.vendorProduct + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetVendorProductsModel.fromJson(jsonDecode(response.body));
        print("Vendor Product Data is here  ${data.data.toString()}");

        getVendorProduct(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetVendorProductsModel();
  }

  Future<LastProductByVendorIdModel> getLastProductByVendorId(onResponse(LastProductByVendorIdModel list), onError(error), id) async {
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/LastProductByVendorId/${id}"), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = LastProductByVendorIdModel.fromJson(jsonDecode(response.body));
        print("Last Product Vendor Data is here  ${data.data.toString()}");

        // getVendorProduct(data);
        getLastVendorProductList(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return LastProductByVendorIdModel();
  }

  Future<ProductInfoInsert> postProductInfo(prodID, userID, price, sub_category, fp, ibd, pastart, paend, dastart, daend, price1, discount, lat, long, security_deposit,
      onResponse(ProductInfoInsert list), onError(error)) async {
    var pData = {
      "product_id": prodID,
      "user_id": userID,
      "price": price,
      "per": 0,
      "subcat_id": sub_category,
      "fp": fp,
      "lbd": ibd,
      "pastart": pastart,
      "paend": paend,
      "dastart": dastart,
      "daend": daend,
      "price1": price1,
      "discount": discount,
      "latitude": lat,
      "longitude": long,
      "security_deposit": security_deposit,
    };
    print(pData);
    final request = json.encode(<String, dynamic>{
      "product_id": prodID,
      "user_id": userID,
      "price": price,
      "per": 0,
      "subcat_id": sub_category,
      "fp": fp,
      "lbd": ibd,
      "pastart": pastart,
      "paend": paend,
      "dastart": dastart,
      "daend": daend,
      "price1": price1,
      "discount": discount,
      "latitude": lat,
      "longitude": long,
      "security_deposit": security_deposit,
    });

    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/productInfoInsert"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

        print("Post Product Data is here");
        Get.off(() => ProductListScreen(side: false));

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        print("postProduct :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return ProductInfoInsert();
  }

  Future<GetAllProductsByVendorId> getAllVendorProductsByID(onResponse(GetAllProductsByVendorId list), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.allVendorProductById + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllProductsByVendorId.fromJson(jsonDecode(response.body));
        print("Vendor Products Data is here  ${data.data.toString()}");

        getVendorProductsById(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      print("Response ${response.body}");
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllProductsByVendorId();
  }

  Future<GetProductsByProductId> getProductsById(onResponse(GetProductsByProductId List), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.getProductsByID + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetProductsByProductId.fromJson(jsonDecode(response.body));
        print("Products Data By Product Id is here  ${data.data.toString()}");

        getProductByProductId(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetProductsByProductId();
  }

  Future<GetRelatedProducts> getRelatedProducts(onResponse(GetRelatedProducts List), onError(error), id) async {
    print("Method Invoked");
    final response = await http.get(Uri.parse(AppUrl.getRelatedProduct + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetRelatedProducts.fromJson(jsonDecode(response.body));
        print("Related Products Data is here  ${data.data.toString()}");

        getRelatedProductsByProductId(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetRelatedProducts();
  }

  Future<DeleteProduct> deleteProductsById(id) async {
    final request = json.encode(<String, dynamic>{"id": id});
    final response = await http.post(Uri.parse(AppUrl.deleteProduct), body: request, headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetProductsByProductId.fromJson(jsonDecode(response.body));
        // print("Products Data By Product Id is here  ${data.data.toString()}");
        print("product deleted");
        Get.to(() => ProductListScreen(side: false));
      } catch (error) {
        print("catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }

    return DeleteProduct();
  }

  Future<ProductDeleteImageModel> deleteProductImage(id) async {
    final request = json.encode(<String, dynamic>{"id": id});
    final response = await http.post(Uri.parse(AppUrl.productDeleteImage), body: request, headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = ProductDeleteImageModel.fromJson(jsonDecode(response.body));
        // print("Products Data By Product Id is here  ${data.data.toString()}");
        print("product Image deleted");
        getdeletedProductImage(true);
      } catch (error) {
        print("Product Delete Image catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }

    return ProductDeleteImageModel();
  }

  Future<ProductUpdateModel> productUpdate(
    user_id,
    category_id,
    subcategory_id,
    name,
    price,
    specifications,
    service_agreements,
    negotiation,
    id,
    array,
    prodID,
    user_id1,
    price2,
    per,
    subcat_id,
    fp,
    lbd,
    pastart,
    paend,
    dastart,
    daend,
    price1,
    discount,
    message,
    delivery_charges,
    security_deposit,

    // onResponse(ProductUpdateModel list),
    // onError(error)
  ) async {
    final request = json.encode(<String, dynamic>{
      "user_id": user_id,
      "category_id": category_id,
      "subcategory_id": subcategory_id,
      "name": name,
      "price": price,
      "specifications": specifications,
      "service_agreements": service_agreements,
      "negotiation": negotiation,
      "id": id,
      "array": array,
      "product_id": prodID,
      "user_id1": user_id1,
      "price2": price2,
      "per": per,
      "subcat_id": subcat_id,
      "fp": fp,
      "lbd": lbd,
      "pastart": pastart,
      "paend": paend,
      "dastart": dastart,
      "daend": daend,
      "price1": price1,
      "discount": discount,
      "isMessage": message,
      "delivery_charges":delivery_charges,
      "security_deposit":security_deposit,
    });

    var data = {
      "user_id": user_id,
      "category_id": category_id,
      "subcategory_id": subcategory_id,
      "name": name,
      "price": price,
      "specifications": specifications,
      "service_agreements": service_agreements,
      "negotiation": negotiation,
      "id": id,
      "array": array,
      "product_id": prodID,
      "user_id1": user_id1,
      "price2": price2,
      "per": per,
      "subcat_id": subcat_id,
      "fp": fp,
      "lbd": lbd,
      "pastart": pastart,
      "paend": paend,
      "dastart": dastart,
      "daend": daend,
      "price1": price1,
      "discount": discount,
      "isMessage": message,
      "delivery_charges":delivery_charges,
      "security_deposit":security_deposit,
    };
    print(data);
    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/productUpdate"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

        print("Product Updated");
        Get.off(() => ProductListScreen(side: false));

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        print("Product Update :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return ProductUpdateModel();
  }

  Future<GetCategoryByIdModel> CategoryId(onResponse(GetCategoryByIdModel List), onError(error), id) async {
    print("Method Invoked");
    final response = await http.get(Uri.parse(AppUrl.categoryID + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetCategoryByIdModel.fromJson(jsonDecode(response.body));
        print("Category Data is here  ${data.data.toString()}");

        getCategoryById(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetCategoryByIdModel();
  }

  Future<GetSubCategoryByIdModel> SubCategoryId(onResponse(GetSubCategoryByIdModel List), onError(error), id) async {
    print("Method Invoked");
    final response = await http.get(Uri.parse(AppUrl.subCategoryID + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetSubCategoryByIdModel.fromJson(jsonDecode(response.body));
        print("SubCategory Data is here  ${data.data.toString()}");

        getSubCategoryById(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetSubCategoryByIdModel();
  }

  Future<GetFilteredProductDataModel> filteredData(onResponse(GetFilteredProductDataModel List), onError(error), url) async {
    print("Method Invoked");
    final response = await http.get(Uri.parse(url), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetFilteredProductDataModel.fromJson(jsonDecode(response.body));
        print("FilteredProduct Data is here  ${data.data.toString()}");

        getFilteredProduct(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetFilteredProductDataModel();
  }

  Future<GetPrivacyPolicyModel> privacyPolicy(onResponse(GetPrivacyPolicyModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.privacyPolicy), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetPrivacyPolicyModel.fromJson(jsonDecode(response.body));
        print("PP Data is here  ${data.data.toString()}");

        getPrivacyPolicy(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetPrivacyPolicyModel();
  }

  Future<GetTermsAndConditionsModel> termsAndConditons(onResponse(GetTermsAndConditionsModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.termsAndConditions), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetTermsAndConditionsModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getTermsAndConditions(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetTermsAndConditionsModel();
  }

  Future<GetAboutAppModel> aboutApp(onResponse(GetAboutAppModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.aboutApp), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetAboutAppModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getAboutApp(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAboutAppModel();
  }

  Future<GetTermLengthModel> termLength(onResponse(GetTermLengthModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.termLength), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetTermLengthModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getTermLength(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetTermLengthModel();
  }

  Future<GetUserCredentialModel> userCredential(onResponse(GetUserCredentialModel List), onError(error), id) async {
    print(AppUrl.userCredential + id.toString());
    final response = await http.get(Uri.parse(AppUrl.userCredential + id.toString()), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        print("user data here");
        var data = GetUserCredentialModel.fromJson(jsonDecode(response.body));
        print("User Data is here  ${data.data.toString()}");
        getUserCredential(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("user data catched" );
        onError(error.toString());
        print("error $error");
      }
      print("user data  ${response.body}" );
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetUserCredentialModel();
  }

  Future<GetRentalAgreementModel> rentalAgreement(onResponse(GetRentalAgreementModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.rentalAgreement), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetRentalAgreementModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getRentalAgreement(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetRentalAgreementModel();
  }

  Future<GetUsagePolicyModel> usagePolicy(onResponse(GetUsagePolicyModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.usagePolicy), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetUsagePolicyModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getUsagePolicy(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetUsagePolicyModel();
  }

  Future<GetInsuranceModel> insurance(onResponse(GetInsuranceModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.insurance), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetInsuranceModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getInsurance(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetInsuranceModel();
  }

  Future<GetTransportModel> transport(onResponse(GetTransportModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.transport), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetTransportModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getTransport(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetTransportModel();
  }

  Future<GetMaintanenceModel> maintenance(onResponse(GetMaintanenceModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.miantenance), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetMaintanenceModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getMaintainence(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetMaintanenceModel();
  }

  Future<GetTerminationModel> termination(onResponse(GetTerminationModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.termination), headers: {
      'Content-type': "application/json",
    });

    if (response.statusCode == 200) {
      try {
        var data = GetTerminationModel.fromJson(jsonDecode(response.body));
        print("T&C Data is here  ${data.data.toString()}");

        getTermination(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetTerminationModel();
  }

  Future<GetAllProductsModel> allProducts(onResponse(GetAllProductsModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.allProducts), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllProductsModel.fromJson(jsonDecode(response.body));
        print("Product Data is here  ${data.data.toString()}");

        getAllProducts(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllProductsModel();
  }

  Future<GetAllMessagesModel> getMessagesApi(String sourceID, String targetID, onResponse(GetAllMessagesModel List), onError(error)) async {
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/GetMessagesByIds/${sourceID}/${targetID}"), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllMessagesModel.fromJson(jsonDecode(response.body));
        print("Message is here  ${data.data.toString()}");

        getAllMessages(data);
        onResponse(data);
        print("tried");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllMessagesModel();
  }

  Future<PostlMessagesModel> postMessage(
    String content,
    String sender_id,
    String recipient_id,
  ) async {
    var data = {
      "content": content.toString(),
      "sender_id": sender_id.toString(),
      "recipient_id": recipient_id.toString(),
    };
    print(data);
    final request = json.encode(<String, dynamic>{
      "content": content.toString(),
      "sender_id": sender_id.toString(),
      "recipient_id": recipient_id.toString(),
    });

    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/InsertMessage"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        print("Message Sent");
      } catch (error) {
        print("Message Unsent :catched");
        print(error);
      }
    } else if (response.statusCode == 400) {
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      print("Internal Server Error");
    }
    return PostlMessagesModel();
  }

  Future<GetChatHistoryModel> chatsHistory(String sourceID, onResponse(GetChatHistoryModel List), onError(error)) async {
    final response = await http.get(Uri.parse("https://api.jebbylistings.com/getMessageVendorsProfile/${sourceID}"), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetChatHistoryModel.fromJson(jsonDecode(response.body));
        print("chats history is here  ${data.data.toString()}");

        getChatHistory(data);
        onResponse(data);
        print("chats history data");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetChatHistoryModel();
  }

  Future<PayWithStripeModel> stripePayment(cardNumber, expiryMonth, expiryYear, cvv, amount, accountId, context, userid, productId, rentStart,
      originalReturn, name, email, location, lat, long, negoPrice, shipping_address, security_deposit, ApplicationFees
      // onResponse(PayWithStripeModel  list),
      // onError(error))

      ) async {
    final request = json.encode(<String, dynamic>{
      "cardNumber": cardNumber,
      "exp_month": expiryMonth,
      "exp_year": "20${expiryYear}",
      "cvc": cvv,
      "amount": amount,
      "vendorAccountId": accountId,
      "sales_tax" : ApplicationFees.toInt()

    });

    print("request ${request}");

    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/payByStripe"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        final snackBar = new SnackBar(content: new Text("Placing order please wait"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // print("Paid SucessFully");
        ChargeBack(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address, cardNumber, expiryMonth, expiryYear, cvv, amount, security_deposit);
        // ApiRepository.shared.postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address);
        // Get.to(() => ProductListScreen());

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        print("Payment :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      print("hhhhhh ${response.body.toString()}");
      print("Internal Server Error");
      // ApiRepository.shared.postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long);
      final snackBar = new SnackBar(content: new Text("Error in placing order ${response.body.toString()}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
    }
    return PayWithStripeModel();
  }

  void ChargeBack(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address, cardNumber, expiryMonth, expiryYear, cvv, amount, security_deposit) async {
    final String SeenMessageUrl = "https://api.jebbylistings.com/PyaByStripeSecurityDeposit";
    var data = {
    "cardNumber":cardNumber,
    "exp_month":expiryMonth,
    "exp_year":expiryYear,
    "cvc":cvv,
    "amount":security_deposit
    };
    print(data);
    try {
      final response = await http.post(
        Uri.parse(SeenMessageUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      final responseBody = jsonDecode(response.body);
      print("response ${responseBody}");
      print("response ${responseBody["paymentIntent"]["id"]}");
      final snackBar = new SnackBar(content: new Text("Placing payment please wait"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ApiRepository.shared.postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address,security_deposit,responseBody["paymentIntent"]["id"]);
      // if (responseBody["message"].toString() == 'updated') {
      //   if(prefs.getInt('type') == 1){
      //     name == "leave" ?  Get.to(() => Requests())
      //      : Get.to(() => BottomInvoiceScreen(side: true,));
      //      } else{
      //       name == "leave" ?  Get.to(() => ShowLeave())
      //      : Get.to(() => EmplSchedule());
      //       // Utils.flushBarMessage(responseBody["message"].toString(), context);
      //      }
      // } 
      // else{
      //   Utils.flushBarErrorMessage(responseBody["message"].toString(), context);
      // }
    } catch (err) {
      print(err);
      final snackBar = new SnackBar(content: new Text('Something went wrong plz check your internet connection'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
}

  Future<PostOrderModel> postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice, shipping_address,security_deposit,deposit_id) async {
    final request = json.encode(<String, dynamic>{
      "user_id": userid,
      "product_id": productId,
      "rent_start": rentStart,
      "original_return": originalReturn,
      "name": name,
      "email": email,
      "location": location,
      "latitude": lat,
      "longitude": long,
      "nego_price" : negoPrice,
      "shipping_address" :shipping_address,
      "sucurity_deposit" :security_deposit,
      "deposit_payment_id" :deposit_id,
    });

    print("request $request");

    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/rentProductInsert"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    print("response4324343432 ${response.body}");
    if (response.statusCode == 200) {
      try {
        // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

        print("Order Placed SucessFully");
        final snackBar = new SnackBar(content: new Text("Order placed sucessfully"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
         Get.offAll(() => MainScreen());

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        print("Payment :catched");
        // onError(error.toString());
        print(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      final snackBar = new SnackBar(content: new Text("Error in saving order"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return PostOrderModel();
  }

  Future<GetFavouriteProductsModel> getFavourites(String id, onResponse(GetFavouriteProductsModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.getFromFavorite + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetFavouriteProductsModel.fromJson(jsonDecode(response.body));
        print("favourites data is here  ${data.data.toString()}");

        getFavouriteProduct(data);
        onResponse(data);
        print("favourites data");
        return data;
      } catch (error) {
        print("catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetFavouriteProductsModel();
  }

  Future<AddFavouriteModel> addFavorite(userId, prodID, fav
      // onResponse(PayWithStripeModel  list),
      // onError(error))
      ) async {
    final request = json.encode(<String, dynamic>{"user_id": userId, "product_id": prodID, "fav": fav});

    print(request);

    final response = await http.post(
      Uri.parse(AppUrl.addToFavourite),
      headers: {
        'Content-Type': "application/json",
      },
      body: request,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      try {
        print("Favorite Added");
        // ApiRepository.shared.getFavourites(userId, (List) => {}, (error) => {});
      } catch (error) {
        print("Favorite :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return AddFavouriteModel();
  }

  Future<PayByPayPalModel> payWithPayPal(amount, vendorID, payerID) async {
    final request = json.encode(<String, dynamic>{
      "amount": amount,
      "vendorId": vendorID,
      "adminId": "talha@tempmail.com",
      "PayerID": payerID,
    });

    print(request);

    final response = await http.post(
      Uri.parse("http://192.168.18.39:7000/payByPayPal"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        print("Paid SucessFully");
      } catch (error) {
        print("Payment :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return PayByPayPalModel();
  }

  Future<GetNotificationModel> notifications(id, onResponse(GetNotificationModel List), onError(error)) async {
    print("URL --> ${AppUrl.getAllNotificationForApp + id.toString()}");
    final response = await http.get(Uri.parse(AppUrl.getAllNotificationForApp + id.toString()), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        ApiRepository.shared.checkApiStatus(true, "getNotifications");
        var data = GetNotificationModel.fromJson(jsonDecode(response.body));
        print("Admin Notifications is here ");
        //${data.data.toString()}
        getNotifications(data);
        // ApiRepository.shared.getNotificationModelListApiStatus == true ?
        // "" :
        // if (unseenMessages == "") {
        //   print("null unseen messages");
        //   getNotifications(data);
        // } else {
        //   if (unseenMessages.toString() == data.unseen.toString().toString()) {
        //     print("matched unseen messages");
        //   } else {
        //     print("messages rebuild");
        //     getNotifications(data);
        //   }
        // }

        print("notification status ${getNotificationModelListApiStatus}");
        onResponse(data);

        print("Admin Notifications data");
        return data;
      } catch (error) {
        print("Notifications catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetNotificationModel();
  }

  Future<GetAllReviewsByProductId> reviewsByProductId(String id, onResponse(GetAllReviewsByProductId List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.getReviewsByProductId + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllReviewsByProductId.fromJson(jsonDecode(response.body));
        print("Reviews Data is here  ${data.data.toString()}");

        getReviewsByProductId(data);
        onResponse(data);
        print("Reviews Data");
        return data;
      } catch (error) {
        print("Reviews catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllReviewsByProductId();
  }

  Future<GetAllReviewsByVendorId> reviewsByVendorId(String id, onResponse(GetAllReviewsByVendorId List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.getAllReviewsByVendorId + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllReviewsByVendorId.fromJson(jsonDecode(response.body));
        print(" Vendor Reviews Data is here  ${data.data.toString()}");

        getAllReviewsByVendorId(data);
        onResponse(data);
        print(" Vendor Reviews Data");
        return data;
      } catch (error) {
        print(" Vendor Reviews catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllReviewsByVendorId();
  }

  Future<GetVendorProductsByReveiwsModel> reviewsByVenodorProduct(String id, onResponse(GetVendorProductsByReveiwsModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.getVendorProductsByReviews + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetVendorProductsByReveiwsModel.fromJson(jsonDecode(response.body));
        print(" Vendor Product Reviews Data is here  ${data.data.toString()}");
        getVenodrProductsByReviews(data);
        onResponse(data);
        print(" Vendor Product Reviews Data");
        return data;
      } catch (error) {
        print(" Vendor Product Reviews catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }
    return GetVendorProductsByReveiwsModel();
  }

  Future<DeleteNotificationModel> deleteNotification(id) async {
    final request = json.encode(<String, dynamic>{"id": id});
    print(request);

    final response = await http.post(
      Uri.parse(AppUrl.deleteNotification),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );

    if (response.statusCode == 201) {
      try {
        unseenMessages = "";
        print("Notification deleted");
        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        print("Notification deleted :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return DeleteNotificationModel();
  }

  Future<GetNotificationSeenModel> seenNotification(id) async {
    final request = json.encode(<String, dynamic>{"user_id": id});

    print(request);

    final response = await http.post(
      Uri.parse(AppUrl.postSeenNotification),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 201) {
      try {
        print("Notification seen");
        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        print("Notification seen :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return GetNotificationSeenModel();
  }

    Future<GetNotificationSeenOneModel> seenoneNotification(id) async {
    final request = json.encode(<String, dynamic>{"id": id});

    print(AppUrl.postSeenoneNotification);

    final response = await http.post(
      Uri.parse(AppUrl.postSeenoneNotification),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    print("${response.body} khbhhjkh");
    if (response.statusCode == 201) {
      try {
        print("Notification seen");
        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        print("Notification seen :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return GetNotificationSeenOneModel();
  }

  Future<GetAllOrderByVendorIdModel>getVenodorOrders(String id, onResponse(GetAllOrderByVendorIdModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.getAllVendorOrders + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetAllOrderByVendorIdModel.fromJson(jsonDecode(response.body));
        print("Vendor Order  ${data.data.toString()}");

        getAllOrdersByVenodrId(data);
        onResponse(data);
        print("orders data");
        return data;
      } catch (error) {
        print("orders data catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllOrderByVendorIdModel();
  }

  Future<PostOrderStatusUpdateModel> orderStatusUpdate(id, status, desc, vendorID, route) async {
    final request = json.encode(<String, dynamic>{"id": id, "status": status, "description": desc});

    print(request);
    final response = await http.post(
      Uri.parse(AppUrl.orderStatusById),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        print("Order Status Updated");
        ApiRepository.shared.getVenodorOrders(vendorID.toString(), (List) {}, (error) {});
      } catch (error) {
        print("Order Status :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return PostOrderStatusUpdateModel();
  }

  Future<GetAllOrdersByUserIdModel> getAllOrdersByUserId(String id, onResponse(GetAllOrdersByUserIdModel List), onError(error)) async {
    print("id ====>  ${AppUrl.getAllUserOrders + id}");
    final response = await http.get(Uri.parse(AppUrl.getAllUserOrders + id), headers: {
      'Content-type': "application/json",
    });
    print("Response ${response.statusCode}");
    if (response.statusCode == 200) {
      try {
        var data = GetAllOrdersByUserIdModel.fromJson(jsonDecode(response.body));
        print("User Order  ${data.data.toString()}");

        getAllUserOrders(data);
        onResponse(data);
        print("User orders data $data");
        return data;
      } catch (error) {
        print("User orders data catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetAllOrdersByUserIdModel();
  }

  Future<ReOrderModel> reOrder(id, location, context) async {
    final request = json.encode(<String, dynamic>{
      "id": id,
      "location": location,
    });

    print("request $request");
    final response = await http.post(
      Uri.parse(AppUrl.reOrder),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        final snackBar = new SnackBar(content: new Text("Order Placed Sucessfully"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print("Order Posted ");
         Get.offAll(() => MainScreen());
      } catch (error) {
        print("Order Post :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return ReOrderModel();
  }

  Future<PayWithStripeModel> reOrderStripePayment(
    cardNumber,
    expiryMonth,
    expiryYear,
    cvv,
    amount,
    accountId,
    context,
    orderId,
    location,
    applicationFee,
  ) async {
    final request = json.encode(<String, dynamic>{
      "cardNumber": cardNumber,
      "exp_month": expiryMonth,
      "exp_year": "20${expiryYear}",
      "cvc": cvv,
      "amount": amount,
      "vendorAccountId": accountId,
      "sales_tax" : applicationFee,
    });

    print(request);

    final response = await http.post(
      Uri.parse("https://api.jebbylistings.com/payByStripe"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      try {
        final snackBar = new SnackBar(content: new Text("Amount debited, placing order please wait"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print("Paid SucessFully");
        ApiRepository.shared.reOrder(orderId, location, context);
      } catch (error) {
        print("Payment :catched");
        // onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      print("response ${response}");
      print("Internal Server Error");
      final snackBar = new SnackBar(content: new Text("Seller Payment Method Invalid, Cannot Place Order"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
    }
    return PayWithStripeModel();
  }

  Future<GetFeaturedModel> featuredProducts(onResponse(GetFeaturedModel List), onError(error)) async {
    final response = await http.get(Uri.parse(AppUrl.featuredGetUrl), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetFeaturedModel.fromJson(jsonDecode(response.body));
        print("Featured Data  ${data.data.toString()}");

        getFeaturedProducts(data);
        onResponse(data);
        print("Featured Data");
        return data;
      } catch (error) {
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetFeaturedModel();
  }

  Future<PostNegotiationRequestModel> negotiationRequest(prodId, userId, price, context) async {
    final request = json.encode(<String, dynamic>{"product_id": prodId, "user_id": userId, "price": price});

    print(request);

    final response = await http.post(
      Uri.parse(AppUrl.negoRequest),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );

    if (response.statusCode == 201) {
      try {
        print("Neogotiation Requested");
        final snackBar1 = new SnackBar(content: new Text("Your request has been send"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
      } catch (error) {
        print("Neogotiation Request :catched");
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return PostNegotiationRequestModel();
  }

  Future<OrderRequestStatusUpdateModel>negotiationRequestUpdate(status, id, context) async {
    final request = json.encode(<String, dynamic>{"status": status, "id": id});

    print(request);

    final response = await http.post(
      Uri.parse(AppUrl.negoRequestUpdate),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );

    if (response.statusCode == 201) {
      try {
        print("response $response");
        print("Neogotiation Updated");
        final snackBar1 = new SnackBar(content: new Text(status == 1 ? "Order Request Approved" : "Order Request Canclled"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        Get.offAll(() => MainScreen());
      } catch (error) {
        print("Neogotiation Update :catched");
        print(error);
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
      print("Internal Server Error");
    }
    return OrderRequestStatusUpdateModel();
  }

  Future<GetNegoByIdModel> negoById(onResponse(GetNegoByIdModel  List), onError(error), id) async {
    final response = await http.get(Uri.parse(AppUrl.negoById + id), headers: {
      'Content-type': "application/json",
    });
    if (response.statusCode == 200) {
      try {
        var data = GetNegoByIdModel.fromJson(jsonDecode(response.body));
        print("Nego By Id  ${data.data.toString()}");

        getNegoById(data);
        onResponse(data);
        print("Nego By Id");
        return data;
      } catch (error) {
        print("Nego By Id: catched");
        onError(error.toString());
        print(error);
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
      print("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
      print("Internal Server Error");
    }

    return GetNegoByIdModel();
  }
}

class notiTimer with ChangeNotifier{

  late var timer;
  notifyListeners();

}
