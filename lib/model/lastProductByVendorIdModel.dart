class LastProductByVendorIdModel {
  String? message;
  Data? data;

  LastProductByVendorIdModel({this.message, this.data});

  LastProductByVendorIdModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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
      this.negotiation});

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
    return data;
  }
}