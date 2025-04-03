class GetNegoByIdModel {
  String? message;
  List<Data>? data;

  GetNegoByIdModel({this.message, this.data});

  GetNegoByIdModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? categoryId;
  int? subcategoryId;
  String? name;
  int? price;
  String? specifications;
  String? serviceAgreements;
  String? createdAt;
  String? updatedAt;
  int? negotiation;
  int? isMessage;
  int? isReview;
  String? stars;
  String? length;
  int? negoprice;
  int? negoVendorId;
  int? negoUserId;
  int? negoStatus;
  int? negoId;
  String? image;

  Data(
      {this.id,
      this.userId,
      this.categoryId,
      this.subcategoryId,
      this.name,
      this.price,
      this.specifications,
      this.serviceAgreements,
      this.createdAt,
      this.updatedAt,
      this.negotiation,
      this.isMessage,
      this.isReview,
      this.stars,
      this.length,
      this.negoprice,
      this.negoVendorId,
      this.negoUserId,
      this.negoStatus,
      this.negoId,
      this.image});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    name = json['name'];
    price = json['price'];
    specifications = json['specifications'];
    serviceAgreements = json['service_agreements'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    negotiation = json['negotiation'];
    isMessage = json['isMessage'];
    isReview = json['is_review'];
    stars = json['stars'];
    length = json['length'];
    negoprice = json['negoprice'];
    negoVendorId = json['nego_vendor_id'];
    negoUserId = json['nego_user_id'];
    negoStatus = json['nego_status'];
    negoId = json['nego_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subcategoryId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['specifications'] = this.specifications;
    data['service_agreements'] = this.serviceAgreements;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['negotiation'] = this.negotiation;
    data['isMessage'] = this.isMessage;
    data['is_review'] = this.isReview;
    data['stars'] = this.stars;
    data['length'] = this.length;
    data['negoprice'] = this.negoprice;
    data['nego_vendor_id'] = this.negoVendorId;
    data['nego_user_id'] = this.negoUserId;
    data['nego_status'] = this.negoStatus;
    data['nego_id'] = this.negoId;
    data['image'] = this.image;
    return data;
  }
}