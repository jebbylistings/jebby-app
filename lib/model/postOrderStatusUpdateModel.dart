class PostOrderStatusUpdateModel {
  int? id;
  int? status;
  String? description;

  PostOrderStatusUpdateModel({this.id, this.status, this.description});

  PostOrderStatusUpdateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['description'] = this.description;
    return data;
  }
}