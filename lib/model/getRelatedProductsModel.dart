class GetRelatedProducts {
  String? message;
  List<Data>? data;

  GetRelatedProducts({this.message, this.data});

  GetRelatedProducts.fromJson(Map<String, dynamic> json) {
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
  String? stars;
  String? length;
  String? image;
  String? delivery_charges;

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
      this.stars,
      this.length,
      this.image,
      this.delivery_charges});

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
    stars = json['stars'];
    length = json['length'];
    image = json['image'];
    delivery_charges =json['delivery_charges'];
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
    data['stars'] = this.stars;
    data['length'] = this.length;
    data['image'] = this.image;
    data['delivery_charges'] =this.delivery_charges;
    return data;
  }
}