class CryptoPaymentStatusModel {
  final String result;
  final String errorMessage;
  final String errorCode;
  final dynamic id;

  CryptoPaymentStatusModel({
    required this.result,
    required this.errorMessage,
    required this.errorCode,
    this.id,
  });

  factory CryptoPaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return CryptoPaymentStatusModel(
      result: json['Result'] as String,
      errorMessage: json['ErrorMessage'] as String,
      errorCode: json['ErrorCode'] as String,
      id: json['Id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result,
      'ErrorMessage': errorMessage,
      'ErrorCode': errorCode,
      'Id': id,
    };
  }
}
