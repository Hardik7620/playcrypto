import 'dart:convert';

Coupon couponFromJson(String str) => Coupon.fromJson(json.decode(str));

String couponToJson(Coupon data) => json.encode(data.toJson());

class Coupon {
  String promotionCode;
  String title;
  String description;
  String category;
  double minimumDepositAmount;
  double depositAmount;
  int depositPercentage;
  int depositCount;
  double capLimit;
  int sort;
  bool isLocked;
  String vipLevelId;
  double wagering;
  int bonusCreditDays;

  Coupon({
    required this.promotionCode,
    required this.title,
    required this.description,
    required this.category,
    required this.minimumDepositAmount,
    required this.depositAmount,
    required this.depositPercentage,
    required this.depositCount,
    required this.capLimit,
    required this.sort,
    required this.isLocked,
    required this.vipLevelId,
    required this.wagering,
    required this.bonusCreditDays,
  });

  Coupon copyWith({
    String? promotionCode,
    String? title,
    String? description,
    String? category,
    double? minimumDepositAmount,
    double? depositAmount,
    int? depositPercentage,
    int? depositCount,
    double? capLimit,
    int? sort,
    String? vipLevelId,
    double? wagering,
    int? bonusCreditDays,
  }) =>
      Coupon(
        promotionCode: promotionCode ?? this.promotionCode,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        minimumDepositAmount: minimumDepositAmount ?? this.minimumDepositAmount,
        depositAmount: depositAmount ?? this.depositAmount,
        depositPercentage: depositPercentage ?? this.depositPercentage,
        depositCount: depositCount ?? this.depositCount,
        capLimit: capLimit ?? this.capLimit,
        sort: sort ?? this.sort,
        isLocked: isLocked,
        vipLevelId: vipLevelId ?? this.vipLevelId,
        wagering: wagering ?? this.wagering,
        bonusCreditDays: bonusCreditDays ?? this.bonusCreditDays,
      );

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        promotionCode: json["PromotionCode"] ?? "",
        title: json["Title"] ?? "",
        description: json["Description"] ?? "",
        category: json["Category"] ?? "",
        minimumDepositAmount: json["MinimumDepositAmount"]?.toDouble() ?? 0.0,
        depositAmount: json["DepositAmount"]?.toDouble() ?? 0.0,
        depositPercentage: json["DepositPercentage"] ?? 0,
        depositCount: json["DepositCount"] ?? 0,
        capLimit: json["CapLimit"]?.toDouble() ?? 0.0,
        sort: json["PromoSortOrder"] ?? 0,
        isLocked: json["IsLocked"] ?? false,
        vipLevelId: json["VIPLevelId"] ?? "",
        wagering: json["Wagering"]?.toDouble() ?? 0.0,
        bonusCreditDays: json["BonusCreditDays"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "PromotionCode": promotionCode,
        "Title": title,
        "Description": description,
        "MinimumDepositAmount": minimumDepositAmount,
        "DepositAmount": depositAmount,
        "DepositPercentage": depositPercentage,
        "DepositCount": depositCount,
        "Category": category,
        "CapLimit": capLimit,
        "PromoSortOrder": sort,
        "VIPLevelId": vipLevelId,
        "Wagering": wagering,
        "BonusCreditDays": bonusCreditDays,
      };
}
