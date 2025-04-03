// To parse this JSON data, do
//
//     final productDetailmodel = productDetailmodelFromJson(jsonString);

import 'dart:convert';

ProductDetailmodel productDetailmodelFromJson(String str) => ProductDetailmodel.fromJson(json.decode(str));

String productDetailmodelToJson(ProductDetailmodel data) => json.encode(data.toJson());

class ProductDetailmodel {
  ProductDetailmodel({
    required this.status,
    required this.data,
    required this.message,
  });

  int status;
  List<Datum> data;
  String message;

  factory ProductDetailmodel.fromJson(Map<String, dynamic> json) => ProductDetailmodel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class Datum {
  Datum({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.subcategoryId,
    required this.name,
    required this.price,
    required this.specifications,
    required this.serviceAgreements,
    required this.createdAt,
    required this.updatedAt,
    required this.negotiation,
    required this.stars,
    required this.length,
    required this.images,
  });

  int id;
  int userId;
  int categoryId;
  int subcategoryId;
  String name;
  int price;
  String specifications;
  String serviceAgreements;
  String createdAt;
  String updatedAt;
  int negotiation;
  String stars;
  String length;
  List<Image> images;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        userId: json["user_id"],
        categoryId: json["category_id"],
        subcategoryId: json["subcategory_id"],
        name: json["name"],
        price: json["price"],
        specifications: json["specifications"],
        serviceAgreements: json["service_agreements"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        negotiation: json["negotiation"],
        stars: json["stars"],
        length: json["length"],
        images: json["images"] == null ? [] : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "category_id": categoryId,
        "subcategory_id": subcategoryId,
        "name": name,
        "price": price,
        "specifications": specifications,
        "service_agreements": serviceAgreements,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "negotiation": negotiation,
        "stars": stars,
        "length": length,
        // ignore: unnecessary_null_comparison
        "images": images == null ? [] : List<dynamic>.from(images.map((x) => x.toJson())),
      };
}

class Image {
  Image({
    required this.id,
    required this.productId,
    required this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int productId;
  String path;
  DateTime createdAt;
  DateTime updatedAt;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        productId: json["product_id"],
        path: json["path"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "path": path,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
