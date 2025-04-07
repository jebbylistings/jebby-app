class PostOrderModel {
  int? userId;
  int? productId;
  String? rentStart;
  String? originalReturn;
  String? name;
  String? email;
  String? location;
  int? latitude;
  int? longitude;
  String? CurrentAddress;

  PostOrderModel({
    this.userId,
    this.productId,
    this.rentStart,
    this.originalReturn,
    this.name,
    this.email,
    this.location,
    this.latitude,
    this.longitude,
  });

  PostOrderModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    productId = json['product_id'];
    rentStart = json['rent_start'];
    originalReturn = json['original_return'];
    name = json['name'];
    email = json['email'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['rent_start'] = this.rentStart;
    data['original_return'] = this.originalReturn;
    data['name'] = this.name;
    data['email'] = this.email;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
