import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jebby/Views/screens/vendors/ProductList.dart';
import 'package:jebby/model/categoryList_model.dart';
import 'package:jebby/model/getCategoryByIdModel.dart';
import 'package:jebby/model/getRentalAgreementModel.dart';
import 'package:jebby/model/getSubCategoryByIdModel.dart';
import 'package:jebby/model/lastProductByVendorIdModel.dart';
import 'package:jebby/model/postNotificationSeenOneModal.dart';
import 'package:jebby/model/vendorProductModel.dart';
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
import '../model/stripe_verification_model.dart';
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
  StripeVerificationModel? stripeVerificationModelList;

  static var shared = ApiRepository();

  var notificationTimer;
  static var Url = dotenv.env['baseUrlM'] ?? 'No url found';

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
    } else if (apiName == "getAllOrdersByVenodrId") {
      getAllOrdersByVenodrIdListApiStatus = status;
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
    getNotificationModelList = data;
    notificationLoader = true;
    unseenMessages =
        ApiRepository.shared.getNotificationModelList!.unseen.toString();

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

  getNegoById(data) {
    getNegoByIdModelList = data;
    notifyListeners();
  }

  Future<CategoryList> getCategoryList(
    onResponse(CategoryList List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.categoryGetUrl),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = CategoryList.fromJson(jsonDecode(response.body));

        getCategory(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return CategoryList();
  }

  Future<SubCategoryList> getSubCategoryList(
    onResponse(SubCategoryList List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.subcategoryGetUrl + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = SubCategoryList.fromJson(jsonDecode(response.body));

        getSubCategory(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return SubCategoryList();
  }

  Future<GetVendorProductsModel> getVendorProductList(
    onResponse(GetVendorProductsModel list),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.vendorProduct + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetVendorProductsModel.fromJson(jsonDecode(response.body));

        getVendorProduct(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetVendorProductsModel();
  }

  Future<LastProductByVendorIdModel> getLastProductByVendorId(
    onResponse(LastProductByVendorIdModel list),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse("${Url}/LastProductByVendorId/${id}"),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = LastProductByVendorIdModel.fromJson(
          jsonDecode(response.body),
        );

        // getVendorProduct(data);
        getLastVendorProductList(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return LastProductByVendorIdModel();
  }

  Future<ProductInfoInsert> postProductInfo(
    prodID,
    userID,
    price,
    sub_category,
    fp,
    ibd,
    pastart,
    paend,
    dastart,
    daend,
    price1,
    discount,
    lat,
    long,
    security_deposit,
    onResponse(ProductInfoInsert list),
    onError(error),
  ) async {
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
      Uri.parse("${Url}/productInfoInsert"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

        Get.off(() => ProductListScreen(side: false));

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return ProductInfoInsert();
  }

  Future<GetAllProductsByVendorId> getAllVendorProductsByID(
    onResponse(GetAllProductsByVendorId list),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.allVendorProductById + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllProductsByVendorId.fromJson(jsonDecode(response.body));

        getVendorProductsById(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllProductsByVendorId();
  }

  Future<GetProductsByProductId> getProductsById(
    onResponse(GetProductsByProductId List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getProductsByID + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetProductsByProductId.fromJson(jsonDecode(response.body));

        getProductByProductId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetProductsByProductId();
  }

  Future<GetRelatedProducts> getRelatedProducts(
    onResponse(GetRelatedProducts List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getRelatedProduct + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetRelatedProducts.fromJson(jsonDecode(response.body));

        getRelatedProductsByProductId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetRelatedProducts();
  }

  Future<DeleteProduct> deleteProductsById(id) async {
    final request = json.encode(<String, dynamic>{"id": id});
    final response = await http.post(
      Uri.parse(AppUrl.deleteProduct),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        Get.to(() => ProductListScreen(side: false));
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }

    return DeleteProduct();
  }

  Future<ProductDeleteImageModel> deleteProductImage(id) async {
    final request = json.encode(<String, dynamic>{"id": id});
    final response = await http.post(
      Uri.parse(AppUrl.productDeleteImage),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        getdeletedProductImage(true);
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
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
      "delivery_charges": delivery_charges,
      "security_deposit": security_deposit,
    });

    final response = await http.post(
      Uri.parse("${Url}/productUpdate"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

        Get.off(() => ProductListScreen(side: false));

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return ProductUpdateModel();
  }

  Future<GetCategoryByIdModel> CategoryId(
    onResponse(GetCategoryByIdModel List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.categoryID + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetCategoryByIdModel.fromJson(jsonDecode(response.body));

        getCategoryById(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetCategoryByIdModel();
  }

  Future<GetSubCategoryByIdModel> SubCategoryId(
    onResponse(GetSubCategoryByIdModel List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.subCategoryID + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetSubCategoryByIdModel.fromJson(jsonDecode(response.body));

        getSubCategoryById(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetSubCategoryByIdModel();
  }

  Future<GetFilteredProductDataModel> filteredData(
    onResponse(GetFilteredProductDataModel List),
    onError(error),
    url,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetFilteredProductDataModel.fromJson(
          jsonDecode(response.body),
        );

        getFilteredProduct(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetFilteredProductDataModel();
  }

  Future<GetPrivacyPolicyModel> privacyPolicy(
    onResponse(GetPrivacyPolicyModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.privacyPolicy),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetPrivacyPolicyModel.fromJson(jsonDecode(response.body));

        getPrivacyPolicy(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetPrivacyPolicyModel();
  }

  Future<GetTermsAndConditionsModel> termsAndConditons(
    onResponse(GetTermsAndConditionsModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.termsAndConditions),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetTermsAndConditionsModel.fromJson(
          jsonDecode(response.body),
        );

        getTermsAndConditions(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetTermsAndConditionsModel();
  }

  Future<GetAboutAppModel> aboutApp(
    onResponse(GetAboutAppModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.aboutApp),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetAboutAppModel.fromJson(jsonDecode(response.body));

        getAboutApp(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAboutAppModel();
  }

  Future<GetTermLengthModel> termLength(
    onResponse(GetTermLengthModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.termLength),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetTermLengthModel.fromJson(jsonDecode(response.body));

        getTermLength(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetTermLengthModel();
  }

  Future<GetUserCredentialModel> userCredential(
    onResponse(GetUserCredentialModel List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.userCredential + id.toString()),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetUserCredentialModel.fromJson(jsonDecode(response.body));

        getUserCredential(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetUserCredentialModel();
  }

  Future<GetRentalAgreementModel> rentalAgreement(
    onResponse(GetRentalAgreementModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.rentalAgreement),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetRentalAgreementModel.fromJson(jsonDecode(response.body));

        getRentalAgreement(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetRentalAgreementModel();
  }

  Future<GetUsagePolicyModel> usagePolicy(
    onResponse(GetUsagePolicyModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.usagePolicy),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetUsagePolicyModel.fromJson(jsonDecode(response.body));

        getUsagePolicy(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetUsagePolicyModel();
  }

  Future<GetInsuranceModel> insurance(
    onResponse(GetInsuranceModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.insurance),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetInsuranceModel.fromJson(jsonDecode(response.body));

        getInsurance(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetInsuranceModel();
  }

  Future<GetTransportModel> transport(
    onResponse(GetTransportModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.transport),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetTransportModel.fromJson(jsonDecode(response.body));

        getTransport(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetTransportModel();
  }

  Future<GetMaintanenceModel> maintenance(
    onResponse(GetMaintanenceModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.miantenance),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetMaintanenceModel.fromJson(jsonDecode(response.body));

        getMaintainence(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetMaintanenceModel();
  }

  Future<GetTerminationModel> termination(
    onResponse(GetTerminationModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.termination),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetTerminationModel.fromJson(jsonDecode(response.body));

        getTermination(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetTerminationModel();
  }

  Future<GetAllProductsModel> allProducts(
    onResponse(GetAllProductsModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.allProducts),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllProductsModel.fromJson(jsonDecode(response.body));

        getAllProducts(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllProductsModel();
  }

  Future<GetAllMessagesModel> getMessagesApi(
    String sourceID,
    String targetID,
    onResponse(GetAllMessagesModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse("${Url}/GetMessagesByIds/${sourceID}/${targetID}"),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllMessagesModel.fromJson(jsonDecode(response.body));

        getAllMessages(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllMessagesModel();
  }

  Future<PostlMessagesModel> postMessage(
    String content,
    String sender_id,
    String recipient_id,
  ) async {
    final request = json.encode(<String, dynamic>{
      "content": content.toString(),
      "sender_id": sender_id.toString(),
      "recipient_id": recipient_id.toString(),
    });

    final response = await http.post(
      Uri.parse("${Url}/InsertMessage"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {} catch (error) {}
    } else if (response.statusCode == 400) {
    } else if (response.statusCode == 500) {}
    return PostlMessagesModel();
  }

  Future<GetChatHistoryModel> chatsHistory(
    String sourceID,
    onResponse(GetChatHistoryModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse("${Url}/getMessageVendorsProfile/${sourceID}"),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetChatHistoryModel.fromJson(jsonDecode(response.body));

        getChatHistory(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetChatHistoryModel();
  }

  Future<PayWithStripeModel> stripePayment(
    /*cardNumber, expiryMonth, expiryYear, cvv,*/ amount,
    accountId,
    context,
    userid,
    productId,
    rentStart,
    originalReturn,
    name,
    email,
    location,
    lat,
    long,
    negoPrice,
    shipping_address,
    security_deposit,
    ApplicationFees,

    // onResponse(PayWithStripeModel  list),
    // onError(error))
  ) async {
    // final request = json.encode(<String, dynamic>{
    //   "cardNumber": cardNumber,
    //   "exp_month": expiryMonth,
    //   "exp_year": "20${expiryYear}",
    //   "cvc": cvv,
    //   "amount": amount,
    //   "vendorAccountId": accountId,
    //   "sales_tax" : ApplicationFees.toInt()
    // });

    final request = json.encode(<String, dynamic>{
      "amount": amount,
      "vendorAccountId": accountId,
      "sales_tax": ApplicationFees.toInt(),
    });

    final response = await http.post(
      Uri.parse("${Url}/payByStripe"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);

        // Assuming your backend returns the client secret
        final clientSecret = responseData['client_secret'];

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Jebby LLC',
            customerId: userid, // Optional
            // Optionally, configure Google Pay and Apple Pay here:
            // style: ThemeMode.light, // Customize as needed
          ),
        );

        // 3. Present PaymentSheet
        await Stripe.instance.presentPaymentSheet();

        // final snackBar = new SnackBar(content: new Text("Placing order please wait"));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //
        // ChargeBack(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address, cardNumber, expiryMonth, expiryYear, cvv, amount, security_deposit);
        ApiRepository.shared.postOrder(
          context,
          userid,
          productId,
          rentStart,
          originalReturn,
          name,
          email,
          location,
          lat,
          long,
          negoPrice,
          shipping_address,
          security_deposit,
          responseData['payment_intent_id'],
        );
        // ApiRepository.shared.postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long, negoPrice,shipping_address);
        // Get.to(() => ProductListScreen());

        // if (data != null) {
        //   // onResponse(data);
        //   // return data;
        // } else

        //   // onError(data.message.toString());
        // return data;
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // ApiRepository.shared.postOrder(context, userid, productId, rentStart, originalReturn, name, email, location, lat, long);
      final snackBar = new SnackBar(
        content: new Text("Error in placing order ${response.body.toString()}"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
    }
    return PayWithStripeModel();
  }

  void ChargeBack(
    context,
    userid,
    productId,
    rentStart,
    originalReturn,
    name,
    email,
    location,
    lat,
    long,
    negoPrice,
    shipping_address,
    cardNumber,
    expiryMonth,
    expiryYear,
    cvv,
    amount,
    security_deposit,
  ) async {
    final String SeenMessageUrl = "${Url}/PyaByStripeSecurityDeposit";
    var data = {
      "cardNumber": cardNumber,
      "exp_month": expiryMonth,
      "exp_year": expiryYear,
      "cvc": cvv,
      "amount": security_deposit,
    };

    try {
      final response = await http.post(
        Uri.parse(SeenMessageUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      final responseBody = jsonDecode(response.body);

      final snackBar = new SnackBar(
        content: new Text("Placing payment please wait"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ApiRepository.shared.postOrder(
        context,
        userid,
        productId,
        rentStart,
        originalReturn,
        name,
        email,
        location,
        lat,
        long,
        negoPrice,
        shipping_address,
        security_deposit,
        responseBody["paymentIntent"]["id"],
      );
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
      final snackBar = new SnackBar(
        content: new Text(
          'Something went wrong plz check your internet connection',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<PostOrderModel> postOrder(
    context,
    userid,
    productId,
    rentStart,
    originalReturn,
    name,
    email,
    location,
    lat,
    long,
    negoPrice,
    shipping_address,
    security_deposit,
    deposit_id,
  ) async {
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
      "nego_price": negoPrice,
      "shipping_address": shipping_address,
      "sucurity_deposit": security_deposit,
      "deposit_payment_id": deposit_id,
    });

    final response = await http.post(
      Uri.parse("${Url}/rentProductInsert"),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      // try {
      // ProductInfoInsert data = ProductInfoInsert.fromJson(json.decode(response.body));

      final snackBar = new SnackBar(
        content: new Text("Order placed sucessfully"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Get.off(() => MainScreen());

      // if (data != null) {
      //   // onResponse(data);
      //   // return data;
      // } else

      //   // onError(data.message.toString());
      // return data;
      // } catch (error) {

      //   // onError(error.toString());

      // }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      final snackBar = new SnackBar(content: new Text("Error in saving order"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
    }
    return PostOrderModel();
  }

  Future<GetFavouriteProductsModel> getFavourites(
    String id,
    onResponse(GetFavouriteProductsModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getFromFavorite + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetFavouriteProductsModel.fromJson(
          jsonDecode(response.body),
        );

        getFavouriteProduct(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetFavouriteProductsModel();
  }

  Future<AddFavouriteModel> addFavorite(
    userId,
    prodID,
    fav,
    // onResponse(PayWithStripeModel  list),
    // onError(error))
  ) async {
    final request = json.encode(<String, dynamic>{
      "user_id": userId,
      "product_id": prodID,
      "fav": fav,
    });

    final response = await http.post(
      Uri.parse(AppUrl.addToFavourite),
      headers: {'Content-Type': "application/json"},
      body: request,
    );

    if (response.statusCode == 200) {
      try {
        // ApiRepository.shared.getFavourites(userId, (List) => {}, (error) => {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
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

    final response = await http.post(
      Uri.parse("http://192.168.18.39:7000/payByPayPal"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {} catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return PayByPayPalModel();
  }

  Future<GetNotificationModel> notifications(
    id,
    onResponse(GetNotificationModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllNotificationForApp + id.toString()),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        ApiRepository.shared.checkApiStatus(true, "getNotifications");
        var data = GetNotificationModel.fromJson(jsonDecode(response.body));

        //${data.data.toString()}
        getNotifications(data);
        // ApiRepository.shared.getNotificationModelListApiStatus == true ?
        // "" :
        // if (unseenMessages == "") {
        //
        //   getNotifications(data);
        // } else {
        //   if (unseenMessages.toString() == data.unseen.toString().toString()) {
        //
        //   } else {
        //
        //     getNotifications(data);
        //   }
        // }

        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetNotificationModel();
  }

  Future<GetAllReviewsByProductId> reviewsByProductId(
    String id,
    onResponse(GetAllReviewsByProductId List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getReviewsByProductId + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllReviewsByProductId.fromJson(jsonDecode(response.body));

        getReviewsByProductId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllReviewsByProductId();
  }

  Future<GetAllReviewsByVendorId> reviewsByVendorId(
    String id,
    onResponse(GetAllReviewsByVendorId List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllReviewsByVendorId + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllReviewsByVendorId.fromJson(jsonDecode(response.body));

        getAllReviewsByVendorId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllReviewsByVendorId();
  }

  Future<GetVendorProductsByReveiwsModel> reviewsByVenodorProduct(
    String id,
    onResponse(GetVendorProductsByReveiwsModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getVendorProductsByReviews + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetVendorProductsByReveiwsModel.fromJson(
          jsonDecode(response.body),
        );

        getVenodrProductsByReviews(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    return GetVendorProductsByReveiwsModel();
  }

  Future<DeleteNotificationModel> deleteNotification(id) async {
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(
      Uri.parse(AppUrl.deleteNotification),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        unseenMessages = "";

        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return DeleteNotificationModel();
  }

  Future<GetNotificationSeenModel> seenNotification(id) async {
    final request = json.encode(<String, dynamic>{"user_id": id});

    final response = await http.post(
      Uri.parse(AppUrl.postSeenNotification),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 201) {
      try {
        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return GetNotificationSeenModel();
  }

  Future<GetNotificationSeenOneModel> seenoneNotification(id) async {
    final request = json.encode(<String, dynamic>{"id": id});

    final response = await http.post(
      Uri.parse(AppUrl.postSeenoneNotification),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        ApiRepository.shared.notifications(id, (List) {}, (error) {});
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return GetNotificationSeenOneModel();
  }

  Future<GetAllOrderByVendorIdModel> getVenodorOrders(
    String id,
    onResponse(GetAllOrderByVendorIdModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllVendorOrders + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetAllOrderByVendorIdModel.fromJson(
          jsonDecode(response.body),
        );

        getAllOrdersByVenodrId(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllOrderByVendorIdModel();
  }

  Future<PostOrderStatusUpdateModel> orderStatusUpdate(
    id,
    status,
    desc,
    vendorID,
    route,
  ) async {
    final request = json.encode(<String, dynamic>{
      "id": id,
      "status": status,
      "description": desc,
    });

    final response = await http.post(
      Uri.parse(AppUrl.orderStatusById),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        ApiRepository.shared.getVenodorOrders(
          vendorID.toString(),
          (List) {},
          (error) {},
        );
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return PostOrderStatusUpdateModel();
  }

  Future<GetAllOrdersByUserIdModel> getAllOrdersByUserId(
    String id,
    onResponse(GetAllOrdersByUserIdModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.getAllUserOrders + id),
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 200) {
      try {
        var data = GetAllOrdersByUserIdModel.fromJson(
          jsonDecode(response.body),
        );

        getAllUserOrders(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetAllOrdersByUserIdModel();
  }

  Future<ReOrderModel> reOrder(id, location, context) async {
    final request = json.encode(<String, dynamic>{
      "id": id,
      "location": location,
    });

    final response = await http.post(
      Uri.parse(AppUrl.reOrder),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        final snackBar = new SnackBar(
          content: new Text("Order Placed Sucessfully"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Get.offAll(() => MainScreen());
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return ReOrderModel();
  }

  Future<PayWithStripeModel> reOrderStripePayment(
    // cardNumber,
    // expiryMonth,
    // expiryYear,
    // cvv,
    amount,
    accountId,
    context,
    orderId,
    location,
    applicationFee,
  ) async {
    // final request = json.encode(<String, dynamic>{
    //   "cardNumber": cardNumber,
    //   "exp_month": expiryMonth,
    //   "exp_year": "20${expiryYear}",
    //   "cvc": cvv,
    //   "amount": amount,
    //   "vendorAccountId": accountId,
    //   "sales_tax" : applicationFee,
    // });

    final request = json.encode(<String, dynamic>{
      "amount": amount,
      "vendorAccountId": accountId,
      "sales_tax": applicationFee,
    });

    final response = await http.post(
      Uri.parse("${Url}/payByStripe"),
      body: request,
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        // Assuming your backend returns the client secret
        final clientSecret = responseData['client_secret'];

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Jebby LLC',
            // Optionally, configure Google Pay and Apple Pay here:
            // style: ThemeMode.light, // Customize as needed
          ),
        );

        // 3. Present PaymentSheet
        await Stripe.instance.presentPaymentSheet();

        final snackBar = new SnackBar(
          content: new Text("Amount debited, placing order please wait"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        ApiRepository.shared.reOrder(orderId, location, context);
      } catch (error) {
        // onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      final snackBar = new SnackBar(
        content: new Text("Seller Payment Method Invalid, Cannot Place Order"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // onError("Internal Server Error");
    }
    return PayWithStripeModel();
  }

  Future<GetFeaturedModel> featuredProducts(
    onResponse(GetFeaturedModel List),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.featuredGetUrl),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetFeaturedModel.fromJson(jsonDecode(response.body));

        getFeaturedProducts(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetFeaturedModel();
  }

  Future<PostNegotiationRequestModel> negotiationRequest(
    prodId,
    userId,
    price,
    context,
  ) async {
    final request = json.encode(<String, dynamic>{
      "product_id": prodId,
      "user_id": userId,
      "price": price,
    });

    final response = await http.post(
      Uri.parse(AppUrl.negoRequest),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        final snackBar1 = new SnackBar(
          content: new Text("Your request has been send"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
      } catch (error) {}
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return PostNegotiationRequestModel();
  }

  Future<OrderRequestStatusUpdateModel> negotiationRequestUpdate(
    status,
    id,
    context,
  ) async {
    final request = json.encode(<String, dynamic>{"status": status, "id": id});

    final response = await http.post(
      Uri.parse(AppUrl.negoRequestUpdate),
      body: request,
      headers: {'Content-type': "application/json"},
    );

    if (response.statusCode == 201) {
      try {
        final snackBar1 = new SnackBar(
          content: new Text(
            status == 1 ? "Order Request Approved" : "Order Request Canclled",
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        Get.offAll(() => MainScreen());
      } catch (error) {}
    } else if (response.statusCode == 400) {
      // onError("You are not in Range");
    } else if (response.statusCode == 500) {
      // onError("Internal Server Error");
    }
    return OrderRequestStatusUpdateModel();
  }

  Future<GetNegoByIdModel> negoById(
    onResponse(GetNegoByIdModel List),
    onError(error),
    id,
  ) async {
    final response = await http.get(
      Uri.parse(AppUrl.negoById + id),
      headers: {'Content-type': "application/json"},
    );
    if (response.statusCode == 200) {
      try {
        var data = GetNegoByIdModel.fromJson(jsonDecode(response.body));

        getNegoById(data);
        onResponse(data);

        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("You are not in Range");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }

    return GetNegoByIdModel();
  }

  // New methods for Stripe verification
  getStripeVerification(data) {
    stripeVerificationModelList = data;
    notifyListeners();
  }
  
  // Create a verification session with Stripe Identity
  Future<StripeVerificationModel> createVerificationSession(String userId, onResponse(StripeVerificationModel data), onError(error)) async {
    final request = json.encode(<String, dynamic>{
      "user_id": userId,
    });

    final response = await http.post(
      Uri.parse("${Url}/stripe/create-verification-session"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    
    if (response.statusCode == 200) {
      try {
        var data = StripeVerificationModel.fromJson(jsonDecode(response.body));
        getStripeVerification(data);
        onResponse(data);
        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("Error creating verification session");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    
    return StripeVerificationModel();
  }
  
  // Check verification status
  Future<dynamic> checkVerificationStatus(String verificationSessionId, onResponse(dynamic data), onError(error)) async {
    final response = await http.get(
      Uri.parse("${Url}/stripe/verification-status/${verificationSessionId}"),
      headers: {
        'Content-type': "application/json",
      },
    );
    
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        onResponse(data);
        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("Error checking verification status");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    
    return {};
  }

  Future<dynamic> updateProfile(String userId, String fullName, String email, String phoneNumber, String address, double? latitude, double? longitude, onResponse(dynamic data), onError(error)) async {
    final request = json.encode(<String, dynamic>{
      "full_name": fullName,
      "email": email, 
      "phoneNumber": phoneNumber,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "user_id": userId,
    });

    final response = await http.post(
      Uri.parse("${Url}/update-profile"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        onResponse(data);
        return data;
      } catch (error) {
        onError(error.toString());
      }
    }  else if (response.statusCode == 400) {
      onError("Error checking verification status");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    
    return {};
  }

  // Create Stripe Express account link
  Future<dynamic> createStripeExpressAccountLink(
    String userId,
    onResponse(dynamic data),
    onError(error),
  ) async {
    final request = json.encode(<String, dynamic>{
      "user_id": userId,
    });

    final response = await http.post(
      Uri.parse("${Url}/stripe/create-express-account"),
      body: request,
      headers: {
        'Content-type': "application/json",
      },
    );
    
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        onResponse(data);
        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("Error creating Stripe Express account");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    
    return {};
  }

  // Check Stripe Express account status
  Future<dynamic> checkStripeAccountStatus(
    String userId,
    onResponse(dynamic data),
    onError(error),
  ) async {
    final response = await http.get(
      Uri.parse("${Url}/stripe/account-status/${userId}"),
      headers: {
        'Content-type': "application/json",
      },
    );
    
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        onResponse(data);
        return data;
      } catch (error) {
        onError(error.toString());
      }
    } else if (response.statusCode == 400) {
      onError("Error checking account status");
    } else if (response.statusCode == 500) {
      onError("Internal Server Error");
    }
    
    return {};
  }
}

class notiTimer with ChangeNotifier {
  late var timer;
  notifyListeners();
}
