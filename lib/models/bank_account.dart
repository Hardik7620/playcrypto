import 'dart:convert';

class BankAccount {
  String id;
  String accountNumber;
  String accountHolderName;
  String bankName;
  dynamic ifscCode;
  DateTime createdDate;
  String creditAccountId;
  dynamic userId;

  BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountHolderName,
    required this.bankName,
    required this.ifscCode,
    required this.createdDate,
    required this.creditAccountId,
    required this.userId,
  });

  BankAccount copyWith({
    String? id,
    String? accountNumber,
    String? accountHolderName,
    String? bankName,
    dynamic ifscCode,
    DateTime? createdDate,
    String? creditAccountId,
    dynamic userId,
  }) =>
      BankAccount(
        id: id ?? this.id,
        accountNumber: accountNumber ?? this.accountNumber,
        accountHolderName: accountHolderName ?? this.accountHolderName,
        bankName: bankName ?? this.bankName,
        ifscCode: ifscCode ?? this.ifscCode,
        createdDate: createdDate ?? this.createdDate,
        creditAccountId: creditAccountId ?? this.creditAccountId,
        userId: userId ?? this.userId,
      );

  factory BankAccount.fromRawJson(String str) => BankAccount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json["Id"],
        accountNumber: json["AccountNumber"],
        accountHolderName: json["AccountHolderName"],
        bankName: json["BankName"],
        ifscCode: json["IFSCCode"],
        createdDate: DateTime.parse(json["CreatedDate"]),
        creditAccountId: json["CreditAccountId"],
        userId: json["UserId"],
      );

  Map<String, String> toJson() => {
        "Id": id,
        "AccountNumber": accountNumber,
        "AccountHolderName": accountHolderName,
        "BankName": bankName,
        "IFSCCode": ifscCode,
        "CreatedDate": createdDate.toIso8601String(),
        "CreditAccountId": creditAccountId,
        "UserId": userId,
      };
}
