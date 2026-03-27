import 'dart:convert';

class ReferralBonusUser {
  String userId;
  String userName;
  double credit;
  String description;

  ReferralBonusUser({
    required this.userId,
    required this.userName,
    required this.credit,
    required this.description,
  });

  factory ReferralBonusUser.fromRawJson(String str) => ReferralBonusUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReferralBonusUser.fromJson(Map<String, dynamic> json) => ReferralBonusUser(
        userId: json["UserId"],
        userName: json["UserName"],
        credit: json["Credit"],
        description: json["Description"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "UserName": userName,
        "Credit": credit,
        "Description": description,
      };
}
