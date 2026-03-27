import 'dart:convert';

List<PromoBonus> promoBonusFromJson(String str) =>
    List<PromoBonus>.from(json.decode(str).map((x) => PromoBonus.fromJson(x)));

String promoBonusToJson(List<PromoBonus> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PromoBonus {
  int paymentTransactionId;
  String promotionCode;
  double bonusAmount;
  String status;
  String? remarks;
  DateTime createdDate;

  PromoBonus({
    required this.paymentTransactionId,
    required this.promotionCode,
    required this.bonusAmount,
    required this.status,
    required this.remarks,
    required this.createdDate,
  });

  PromoBonus copyWith({
    int? paymentTransactionId,
    String? promotionCode,
    double? bonusAmount,
    String? status,
    String? remarks,
    DateTime? createdDate,
  }) =>
      PromoBonus(
        paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
        promotionCode: promotionCode ?? this.promotionCode,
        bonusAmount: bonusAmount ?? this.bonusAmount,
        status: status ?? this.status,
        remarks: remarks ?? this.remarks,
        createdDate: createdDate ?? this.createdDate,
      );

  factory PromoBonus.fromJson(Map<String, dynamic> json) => PromoBonus(
        paymentTransactionId: json["PaymentTransactionId"],
        promotionCode: json["PromotionCode"],
        bonusAmount: json["BonusAmount"]?.toDouble(),
        status: json["Status"],
        remarks: json["Remarks"],
        createdDate: DateTime.parse(json["CreatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "PaymentTransactionId": paymentTransactionId,
        "PromotionCode": promotionCode,
        "BonusAmount": bonusAmount,
        "Status": status,
        "Remarks": remarks,
        "CreatedDate": createdDate.toIso8601String(),
      };
}
