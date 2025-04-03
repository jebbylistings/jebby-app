// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  int? status;
  List<Data>? data;
  List<Images>? images;
  List<Relate>? relate;
  List<Reviews>? reviews;
  String? message;

  ProductModel(
      {this.status,
      this.data,
      this.images,
      this.relate,
      this.reviews,
      this.message});

  ProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    if (json['relate'] != null) {
      relate = <Relate>[];
      json['relate'].forEach((v) {
        relate!.add(new Relate.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(new Reviews.fromJson(v));
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
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.relate != null) {
      data['relate'] = this.relate!.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
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
  String? image;
  String ? delivery_charges;

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
    isMessage = json['isMessage'];
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

class Relate {
  int? id;
  int? productId;
  int? relatedProductId;
  String? createdAt;
  String? updatedAt;

  Relate(
      {this.id,
      this.productId,
      this.relatedProductId,
      this.createdAt,
      this.updatedAt});

  Relate.fromJson(Map<String, dynamic> json) {
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

  Reviews(
      {this.id,
      this.userId,
      this.productId,
      this.stars,
      this.image,
      this.description,
      this.createdAt,
      this.updatedAt});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    stars = json['stars'];
    image = json['image'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    return data;
  }
}

// class ProductModel {
//   ProductModel({
//     required this.status,
//     required this.data,
//     required this.message,
//   });

//   int status;
//   List<Datum> data;
//   String message;

//   factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
//         status: json["status"],
//         data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//         "message": message,
//       };
// }

// class Datum {
//   Datum({
//     required this.id,
//     required this.userId,
//     required this.categoryId,
//     required this.subcategoryId,
//     required this.name,
//     required this.price,
//     required this.specifications,
//     required this.serviceAgreements,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.negotiation,
//     required this.stars,
//     required this.length,
//     required this.image,
//   });

//   int id;
//   int userId;
//   int categoryId;
//   int subcategoryId;
//   String name;
//   int price;
//   String specifications;
//   String serviceAgreements;
//   DateTime createdAt;
//   DateTime updatedAt;
//   int negotiation;
//   String stars;
//   String length;
//   String image;

//   factory Datum.fromJson(Map<String, dynamic> json) => Datum(
//         id: json["id"],
//         userId: json["user_id"],
//         categoryId: json["category_id"],
//         subcategoryId: json["subcategory_id"],
//         name: json["name"],
//         price: json["price"],
//         specifications: json["specifications"],
//         serviceAgreements: json["service_agreements"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//         negotiation: json["negotiation"],
//         stars: json["stars"],
//         length: json["length"],
//         image: json["image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "user_id": userId,
//         "category_id": categoryId,
//         "subcategory_id": subcategoryId,
//         "name": name,
//         "price": price,
//         "specifications": specifications,
//         "service_agreements": serviceAgreements,
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//         "negotiation": negotiation,
//         "stars": stars,
//         "length": length,
//         "image": image,
//       };
// }
