class PostNegotiationRequestModel {
  int? productId;
  int? userId;
  int? price;

  PostNegotiationRequestModel({this.productId, this.userId, this.price});

  PostNegotiationRequestModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    userId = json['user_id'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['user_id'] = this.userId;
    data['price'] = this.price;
    return data;
  }
}
