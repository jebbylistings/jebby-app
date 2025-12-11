class GetProductsByProductId {
  int? status;
  List<Data>? data;
  String? message;

  GetProductsByProductId({this.status, this.data, this.message});

  GetProductsByProductId.fromJson(Map<String, dynamic> json) {
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
  String? specifications;
  String? serviceAgreements;
  String? createdAt;
  String? updatedAt;
  int? negotiation;
  int? isMessage;
  String? stars;
  String? length;
  int? productId;
  int? per;
  int? subcatId;
  int? fp;
  int? lbd;
  String? pastart;
  String? paend;
  String? dastart;
  String? daend;
  int? price1;
  int? discount;
  var latitude;
  var longitude;
  int? security_deposit;
  int? price2;
  List<Images>? images;
  String? delivery_charges;

  Data({
    this.id,
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
    this.stars,
    this.length,
    this.productId,
    this.per,
    this.subcatId,
    this.fp,
    this.lbd,
    this.pastart,
    this.paend,
    this.dastart,
    this.daend,
    this.price1,
    this.discount,
    this.latitude,
    this.longitude,
    this.security_deposit,
    this.price2,
    this.images,
    this.delivery_charges,
  });

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
    stars = json['stars'];
    length = json['length'];
    productId = json['product_id'];
    per = json['per'];
    subcatId = json['subcat_id'];
    fp = json['fp'];
    lbd = json['lbd'];
    pastart = json['pastart'];
    paend = json['paend'];
    dastart = json['dastart'];
    daend = json['daend'];
    price1 = json['price1'];
    discount = json['discount'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    security_deposit = json['security_deposit'];
    price2 = json['price2'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    delivery_charges = json['delivery_charges'];
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
    data['stars'] = this.stars;
    data['length'] = this.length;
    data['product_id'] = this.productId;
    data['per'] = this.per;
    data['subcat_id'] = this.subcatId;
    data['fp'] = this.fp;
    data['lbd'] = this.lbd;
    data['pastart'] = this.pastart;
    data['paend'] = this.paend;
    data['dastart'] = this.dastart;
    data['daend'] = this.daend;
    data['price1'] = this.price1;
    data['discount'] = this.discount;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['security_deposit'] = this.security_deposit;
    data['price2'] = this.price2;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['delivery_charges'] = this.delivery_charges;
    return data;
  }
}

class Images {
  int? id;
  int? productId;
  String? path;
  String? createdAt;
  String? updatedAt;

  Images({this.id, this.productId, this.path, this.createdAt, this.updatedAt});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    path = json['path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['path'] = this.path;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
