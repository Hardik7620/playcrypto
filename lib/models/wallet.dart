import 'dart:convert';

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  String? creditAccountId;
  int walletTypeId;
  String? name;
  String? code;
  String currencyType;
  double balance;
  int currencySymbol;
  String? imageUrl;
  String? crpCurrencyType;
  num? crpwithdrawAmount;
  num? cryptoRate;

  Wallet(
      {required this.creditAccountId,
      required this.walletTypeId,
      required this.name,
      required this.code,
      required this.currencyType,
      required this.balance,
      required this.currencySymbol,
      this.crpwithdrawAmount,
      this.cryptoRate,
      this.crpCurrencyType,
      required this.imageUrl});

  Wallet copyWith({
    String? creditAccountId,
    int? walletTypeId,
    String? name,
    String? code,
    String? currencyType,
    double? balance,
    int? currencySymbol,
    String? imageUrl,
    String? crpCurrencyType,
    num? crpwithdrawAmount,
    num? cryptoRate,
  }) =>
      Wallet(
        creditAccountId: creditAccountId ?? this.creditAccountId,
        walletTypeId: walletTypeId ?? this.walletTypeId,
        name: name ?? this.name,
        code: code ?? this.code,
        currencyType: currencyType ?? this.currencyType,
        balance: balance ?? this.balance,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        imageUrl: imageUrl ?? this.imageUrl,
        crpCurrencyType: crpCurrencyType ?? this.crpCurrencyType,
        crpwithdrawAmount: crpwithdrawAmount ?? this.crpwithdrawAmount,
        cryptoRate: cryptoRate ?? this.cryptoRate,
      );

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        creditAccountId: json["CreditAccountid"],
        walletTypeId: json["WalletTypeId"],
        name: json["Name"],
        code: json["Code"],
        currencyType: json["CurrencyType"],
        balance: json["Balance"],
        currencySymbol: int.tryParse(json["CurrencySymbol"]
                .toString()
                .replaceAll("&", "")
                .replaceAll(";", '')
                .replaceAll("#", '')) ??
            0,
        imageUrl: json["ImageURL"],
        crpCurrencyType: json["CrpCurrencyType"],
        crpwithdrawAmount: json["CrpwithdrawAmount"],
        cryptoRate: json["CryptoRate"],
      );

  Map<String, dynamic> toJson() => {
        "CreditAccountid": creditAccountId,
        "WalletTypeId": walletTypeId,
        "Name": name,
        "Code": code,
        "CurrencyType": currencyType,
        "Balance": balance,
        "CurrencySymbol": currencySymbol,
        "ImageURL": imageUrl,
        "CrpCurrencyType": crpCurrencyType,
        "CrpwithdrawAmount": crpwithdrawAmount,
        "CryptoRate": cryptoRate,
      };
}
