class PayByPayPalModel {
  String? amount;
  String? vendorId;
  String? adminId;
  String? payerID;

  PayByPayPalModel({this.amount, this.vendorId, this.adminId, this.payerID});

  PayByPayPalModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    vendorId = json['vendorId'];
    adminId = json['adminId'];
    payerID = json['PayerID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['vendorId'] = this.vendorId;
    data['adminId'] = this.adminId;
    data['PayerID'] = this.payerID;
    return data;
  }
}
