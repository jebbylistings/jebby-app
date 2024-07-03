class PayWithStripeModel {
  int? cardNumber;
  String? expMonth;
  String? expYear;
  int? cvc;
  int? amount;
  String? vendorAccountId;

  PayWithStripeModel(
      {this.cardNumber,
      this.expMonth,
      this.expYear,
      this.cvc,
      this.amount,
      this.vendorAccountId});

  PayWithStripeModel.fromJson(Map<String, dynamic> json) {
    cardNumber = json['cardNumber'];
    expMonth = json['exp_month'];
    expYear = json['exp_year'];
    cvc = json['cvc'];
    amount = json['amount'];
    vendorAccountId = json['vendorAccountId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cardNumber'] = this.cardNumber;
    data['exp_month'] = this.expMonth;
    data['exp_year'] = this.expYear;
    data['cvc'] = this.cvc;
    data['amount'] = this.amount;
    data['vendorAccountId'] = this.vendorAccountId;
    return data;
  }
}