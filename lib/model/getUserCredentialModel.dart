class GetUserCredentialModel {
  var status;
  List<Data>? data;
  String? message;

  GetUserCredentialModel({this.status, this.data, this.message});

  GetUserCredentialModel.fromJson(Map<String, dynamic> json) {
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
  var id;
  String? image;
  String? name;
  String? email;
  String? number;
  String? address;
  var userId;
  var latitude;
  var longitude;
  String? backImage;
  String? paypalEmail;
  String? stripeEmail;
  String? stripeAccountType;
  String? accountId;

  Data(
      {this.id,
      this.image,
      this.name,
      this.email,
      this.number,
      this.address,
      this.userId,
      this.latitude,
      this.longitude,
      this.backImage,
      this.paypalEmail,
      this.stripeEmail,
      this.stripeAccountType,
      this.accountId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    number = json['number'];
    address = json['address'];
    userId = json['user_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    backImage = json['back_image'];
    paypalEmail = json['paypal_email'];
    stripeEmail = json['stripe_email'];
    stripeAccountType = json['stripe_account_type'];
    accountId = json['account_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['name'] = this.name;
    data['email'] = this.email;
    data['number'] = this.number;
    data['address'] = this.address;
    data['user_id'] = this.userId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['back_image'] = this.backImage;
    data['paypal_email'] = this.paypalEmail;
    data['stripe_email'] = this.stripeEmail;
    data['stripe_account_type'] = this.stripeAccountType;
    data['account_id'] = this.accountId;
    return data;
  }
}