class CryptoCreatePaymentModel {
  final String? pgUserId;
  final String? passwordKey;
  final String? userName;
  final dynamic result;
  final String errorMessage;
  final String errorCode;
  final dynamic id;
   List<FiatCurrency>? fiatCurrencies;

  CryptoCreatePaymentModel({
    this.pgUserId,
    this.passwordKey,
    this.userName,
    this.result,
    required this.errorMessage,
    required this.errorCode,
    this.id,
    this.fiatCurrencies,
  });

  factory CryptoCreatePaymentModel.fromJson(Map<String, dynamic> json) {
    return CryptoCreatePaymentModel(
      pgUserId: json['PgUserId'] as String?,
      passwordKey: json['PasswordKey'] as String?,
      userName: json['UserName'] as String?,
      result: json['Result'],
      errorMessage: json['ErrorMessage'] as String,
      errorCode: json['ErrorCode'] as String,
      id: json['Id'],
      fiatCurrencies: json['FiatCurrencies'] != null
          ? (json['FiatCurrencies'] as List)
              .map((e) => FiatCurrency.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PgUserId': pgUserId,
      'PasswordKey': passwordKey,
      'UserName': userName,
      'Result': result,
      'ErrorMessage': errorMessage,
      'ErrorCode': errorCode,
      'Id': id,
      'FiatCurrencies': fiatCurrencies?.map((e) => e.toJson()).toList(),
    };
  }
}

class FiatCurrency {
  final num? fiatConvertRate;
  final String? fiatCurrencyType;
  final bool? isSelected;

  FiatCurrency({
    this.fiatConvertRate,
    this.fiatCurrencyType,
    this.isSelected,
  });

  factory FiatCurrency.fromJson(Map<String, dynamic> json) {
    return FiatCurrency(
      fiatConvertRate: json['FiatConvertRate'] as num?,
      fiatCurrencyType: json['FiatCurrencyType'] as String?,
      isSelected: json['isSelected'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FiatConvertRate': fiatConvertRate,
      'FiatCurrencyType': fiatCurrencyType,
      'isSelected': isSelected,
    };
  }

  FiatCurrency copyWith({
    num? fiatConvertRate,
    String? fiatCurrencyType,
    bool? isSelected,
  }) {
    return FiatCurrency(
      fiatConvertRate: fiatConvertRate ?? this.fiatConvertRate,
      fiatCurrencyType: fiatCurrencyType ?? this.fiatCurrencyType,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
