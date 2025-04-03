class OrderRequestStatusUpdateModel {
  int? status;
  int? id;

  OrderRequestStatusUpdateModel({this.status, this.id});

  OrderRequestStatusUpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['id'] = this.id;
    return data;
  }
}