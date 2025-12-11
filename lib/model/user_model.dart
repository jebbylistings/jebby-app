class UserModel {
  int? status;
  String? name;
  String? email;
  String? phoneNumber;
  String? id;
  String? role;
  String? source;
  String? token;
  bool? isGuest;

  UserModel({
    this.status,
    this.name,
    this.email,
    this.id,
    this.role,
    this.source,
    this.token,
    this.isGuest = false,
    this.phoneNumber,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    name = json['name'];
    email = json['email'];
    id = json['id'];
    role = json['role'];
    source = json['source'];
    token = json['token'];
    isGuest = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['name'] = this.name;
    data['email'] = this.email;
    data['id'] = this.id;
    data['role'] = this.role;
    data['source'] = this.source;
    data['token'] = this.token;
    data['isGuest'] = this.isGuest;
    return data;
  }
}

class UpdatedModel {
  int? status;
  List<Data>? data;
  String? message;

  UpdatedModel({this.status, this.data, this.message});

  UpdatedModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? image;
  String? name;
  String? email;
  String? number;
  String? address;
  String? userId;
  String? latitude;
  String? longitude;

  Data({
    this.id,
    this.image,
    this.name,
    this.email,
    this.number,
    this.address,
    this.userId,
    this.latitude,
    this.longitude,
    required String phoneNumber,
  });

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
    return data;
  }
}
