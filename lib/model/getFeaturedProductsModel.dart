class GetFeaturedModel {
  String? message;
  List<Data>? data;
  List<Images>? images;
  List<RelatedProducts>? relatedProducts;
  List<Reviews>? reviews;

  GetFeaturedModel({
    this.message,
    this.data,
    this.images,
    this.relatedProducts,
    this.reviews,
  });

  GetFeaturedModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];

    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    if (json['related_products'] != null) {
      relatedProducts = <RelatedProducts>[];
      json['related_products'].forEach((v) {
        relatedProducts!.add(new RelatedProducts.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(new Reviews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.relatedProducts != null) {
      data['related_products'] =
          this.relatedProducts!.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
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
  String? image;
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
    this.isReview,
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
    specifications = json['specifications'];
    serviceAgreements = json['service_agreements'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    negotiation = json['negotiation'];
    isMessage = json['isMessage'];
    isReview = json['is_review'];
    stars = json['stars'];
    length = json['length'];
    image = json['image'];
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
    data['is_review'] = this.isReview;
    data['stars'] = this.stars;
    data['length'] = this.length;
    data['image'] = this.image;
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

class RelatedProducts {
  int? id;
  int? productId;
  int? relatedProductId;
  String? createdAt;
  String? updatedAt;

  RelatedProducts({
    this.id,
    this.productId,
    this.relatedProductId,
    this.createdAt,
    this.updatedAt,
  });

  RelatedProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    relatedProductId = json['related_product_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['related_product_id'] = this.relatedProductId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Reviews {
  int? id;
  int? userId;
  int? productId;
  int? stars;
  String? image;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? vendorId;

  Reviews({
    this.id,
    this.userId,
    this.productId,
    this.stars,
    this.image,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.vendorId,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    stars = json['stars'];
    image = json['image'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vendorId = json['vendor_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['stars'] = this.stars;
    data['image'] = this.image;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['vendor_id'] = this.vendorId;
    return data;
  }
}
