class CryptoNetworkModels {

  final String id;
  final String crpWalletId;
  final String cryptoCode;
  final String cryptoNetworkCode;
  final String cryptoCurrency;

  CryptoNetworkModels({
    required this.id,
    required this.crpWalletId,
    required this.cryptoCode,
    required this.cryptoNetworkCode,
    required this.cryptoCurrency,
  });

  factory CryptoNetworkModels.fromJson(Map<String, dynamic> json) {
    return CryptoNetworkModels(
      id: json['Id'] as String,
      crpWalletId: json['CRPWalletId'] as String,
      cryptoCode: json['CryptoCode'] as String,
      cryptoNetworkCode: json['CryptoNetworkCode'] as String,
      cryptoCurrency: json['CryptoCurrency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CRPWalletId': crpWalletId,
      'CryptoCode': cryptoCode,
      'CryptoNetworkCode': cryptoNetworkCode,
      'CryptoCurrency': cryptoCurrency,
    };
  }

}
