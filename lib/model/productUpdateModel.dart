class ProductUpdateModel {
  int? userId;
  int? categoryId;
  int? subcategoryId;
  String? name;
  int? price;
  String? specifications;
  String? serviceAgreements;
  int? negotiation;
  int? id;
  List<int>? array;

  ProductUpdateModel(
      {this.userId,
      this.categoryId,
      this.subcategoryId,
      this.name,
      this.price,
      this.specifications,
      this.serviceAgreements,
      this.negotiation,
      this.id,
      this.array});

  ProductUpdateModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    name = json['name'];
    price = json['price'];
    specifications = json['specifications'];
    serviceAgreements = json['service_agreements'];
    negotiation = json['negotiation'];
    id = json['id'];
    array = json['array'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subcategoryId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['specifications'] = this.specifications;
    data['service_agreements'] = this.serviceAgreements;
    data['negotiation'] = this.negotiation;
    data['id'] = this.id;
    data['array'] = this.array;
    return data;
  }
}