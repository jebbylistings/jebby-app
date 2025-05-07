class StripeVerificationModel {
  String? verificationSessionId;
  String? verificationUrl;
  String? status;
  String? userId;

  StripeVerificationModel({
    this.verificationSessionId,
    this.verificationUrl,
    this.status,
    this.userId,
  });

  StripeVerificationModel.fromJson(Map<String, dynamic> json) {
    verificationSessionId = json['verification_session_id'];
    verificationUrl = json['verification_url'];
    status = json['status'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['verification_session_id'] = this.verificationSessionId;
    data['verification_url'] = this.verificationUrl;
    data['status'] = this.status;
    data['user_id'] = this.userId;
    return data;
  }
}
