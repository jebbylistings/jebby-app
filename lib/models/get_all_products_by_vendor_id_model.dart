class GetAllProductsByVendorId {
  int? status;
  List<Data>? data;
  String? message;

  GetAllProductsByVendorId({this.status, this.data, this.message});

  GetAllProductsByVendorId.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
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
  String? description;
  String? createdAt;
  String? updatedAt;
  String? stars;
  String? length;
  String? image;
  String? delivery_charges;
  String? publishState;
  String? listingStatus;
  bool? bookable;

  Data({
    this.id,
    this.userId,
    this.categoryId,
    this.subcategoryId,
    this.name,
    this.price,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.stars,
    this.length,
    this.image,
    this.delivery_charges,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    name = json['name'];
    price = json['price'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    stars = json['stars'];
    length = json['length'];
    image = json['image'];
    delivery_charges = json['delivery_charges'];
    publishState = json['publish_state']?.toString();
    listingStatus = json['listing_status']?.toString();
    bookable = json['bookable'] == true ||
        json['bookable'] == 1 ||
        json['bookable'] == '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subcategoryId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['stars'] = this.stars;
    data['length'] = this.length;
    data['image'] = this.image;
    data['delivery_charges'] = this.delivery_charges;
    return data;
  }
}
