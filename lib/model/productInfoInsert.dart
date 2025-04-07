class ProductInfoInsert {
  int? productId;
  int? userId;
  int? price;
  int? per;
  int? subcatId;
  int? fp;
  int? lbd;
  String? pastart;
  String? paend;
  String? dastart;
  String? daend;
  int? price1;
  int? discount;

  ProductInfoInsert({
    this.productId,
    this.userId,
    this.price,
    this.per,
    this.subcatId,
    this.fp,
    this.lbd,
    this.pastart,
    this.paend,
    this.dastart,
    this.daend,
    this.price1,
    this.discount,
  });

  ProductInfoInsert.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    userId = json['user_id'];
    price = json['price'];
    per = json['per'];
    subcatId = json['subcat_id'];
    fp = json['fp'];
    lbd = json['lbd'];
    pastart = json['pastart'];
    paend = json['paend'];
    dastart = json['dastart'];
    daend = json['daend'];
    price1 = json['price1'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['user_id'] = this.userId;
    data['price'] = this.price;
    data['per'] = this.per;
    data['subcat_id'] = this.subcatId;
    data['fp'] = this.fp;
    data['lbd'] = this.lbd;
    data['pastart'] = this.pastart;
    data['paend'] = this.paend;
    data['dastart'] = this.dastart;
    data['daend'] = this.daend;
    data['price1'] = this.price1;
    data['discount'] = this.discount;
    return data;
  }
}
