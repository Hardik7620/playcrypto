import 'dart:convert';

class User {
  String? id;
  int? audienceSegmentId;
  int? vipTemplateId;
  dynamic vipLevelName;
  String userName;
  String? fName;
  String? lName;
  DateTime dob;
  String mobile;
  String? email;
  int? vipLevelId;
  dynamic referralCode;
  dynamic walletCode;
  dynamic siteCode;
  dynamic currencyType;
  dynamic appType;
  dynamic userIdentifierAdid;
  dynamic userIdentifierAid;
  dynamic result;
  dynamic errorMessage;
  dynamic errorCode;
  DateTime? nextWithdrawalTime;
  bool isWithdrawApplicable;
  double? totalWithdrawAmount;
  double? sendOTPWithdrawAmount;

  User(
      {required this.audienceSegmentId,
      required this.vipTemplateId,
      required this.vipLevelId,
      required this.userName,
      required this.fName,
      required this.lName,
      required this.dob,
      required this.mobile,
      this.email,
      required this.referralCode,
      required this.walletCode,
      required this.siteCode,
      required this.currencyType,
      required this.appType,
      required this.userIdentifierAdid,
      required this.userIdentifierAid,
      required this.result,
      required this.errorMessage,
      required this.errorCode,
      required this.id,
      required this.isWithdrawApplicable,
      required this.nextWithdrawalTime,
      required this.totalWithdrawAmount,
      required this.sendOTPWithdrawAmount,
      this.vipLevelName});

  User copyWith({
    dynamic userId,
    dynamic vipLevelName,
    int? audienceSegmentId,
    int? vipTemplateId,
    String? userName,
    String? fName,
    String? lName,
    DateTime? dob,
    String? mobile,
    String? email,
    dynamic password,
    dynamic firstTimeLogin,
    dynamic loginToken,
    dynamic otp,
    int? statusId,
    dynamic referralCode,
    dynamic walletCode,
    dynamic siteCode,
    dynamic currencyType,
    dynamic appType,
    dynamic userIdentifierAdid,
    dynamic userIdentifierAid,
    dynamic result,
    dynamic errorMessage,
    dynamic errorCode,
    String? id,
    int? vipLevelId,
    DateTime? nextWithdrawalTime,
    bool? isWithdrawApplicable,
    double? totalWithdrawAmount,
    double? sendOTPWithdrawAmount,
  }) =>
      User(
        audienceSegmentId:
            audienceSegmentId ?? this.audienceSegmentId,
        vipLevelName: vipLevelName ?? this.vipLevelName,
        vipTemplateId: vipTemplateId ?? this.vipTemplateId,
        userName: userName ?? this.userName,
        fName: fName ?? this.fName,
        lName: lName ?? this.lName,
        dob: dob ?? this.dob,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        referralCode: referralCode ?? this.referralCode,
        walletCode: walletCode ?? this.walletCode,
        siteCode: siteCode ?? this.siteCode,
        currencyType: currencyType ?? this.currencyType,
        appType: appType ?? this.appType,
        userIdentifierAdid:
            userIdentifierAdid ?? this.userIdentifierAdid,
        userIdentifierAid:
            userIdentifierAid ?? this.userIdentifierAid,
        result: result ?? this.result,
        errorMessage: errorMessage ?? this.errorMessage,
        errorCode: errorCode ?? this.errorCode,
        id: id ?? this.id,
        vipLevelId: vipLevelId ?? this.vipLevelId,
        nextWithdrawalTime:
            nextWithdrawalTime ?? this.nextWithdrawalTime,
        isWithdrawApplicable: isWithdrawApplicable ??
            this.isWithdrawApplicable,
        totalWithdrawAmount:
            totalWithdrawAmount ?? this.totalWithdrawAmount,
        sendOTPWithdrawAmount: sendOTPWithdrawAmount ??
            this.sendOTPWithdrawAmount,
      );

  factory User.fromRawJson(String str) =>
      User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
      audienceSegmentId: json["AudienceSegmentId"],
      vipTemplateId: json["VipTemplateId"],
      vipLevelName: json["LevelName"],
      userName: json["UserName"],
      fName: json["FName"] ?? '',
      lName: json["LName"] ?? '',
      dob: DateTime.parse(json["DOB"]),
      mobile: json["Mobile"],
      email: json["Email"],
      referralCode: json["ReferralCode"],
      walletCode: json["WalletCode"],
      siteCode: json["SiteCode"],
      currencyType: json["CurrencyType"],
      appType: json["AppType"],
      userIdentifierAdid: json["UserIdentifierADID"],
      userIdentifierAid: json["UserIdentifierAID"],
      result: json["Result"],
      errorMessage: json["ErrorMessage"],
      errorCode: json["ErrorCode"],
      id: json["Id"],
      vipLevelId: json["VIPLevelId"],
      nextWithdrawalTime: json["NextWithdrawalTime"] != null
          ? DateTime.tryParse(json["NextWithdrawalTime"])
          : null,
      isWithdrawApplicable:
          json["IsWithdrawApplicable"] == 1,
      totalWithdrawAmount: json["totalWithdrawAmount"],
      sendOTPWithdrawAmount: json["SendOTPWithdrawAmount"]);

  Map<String, dynamic> toJson() => {
        "AudienceSegmentId": audienceSegmentId,
        "VipTemplateId": vipTemplateId,
        "UserName": userName,
        "FName": fName,
        "LName": lName,
        "DOB": dob.toIso8601String(),
        "Mobile": mobile,
        "Email": email,
        "ReferralCode": referralCode,
        "WalletCode": walletCode,
        "SiteCode": siteCode,
        "CurrencyType": currencyType,
        "AppType": appType,
        "UserIdentifierADID": userIdentifierAdid,
        "UserIdentifierAID": userIdentifierAid,
        "Result": result,
        "ErrorMessage": errorMessage,
        "ErrorCode": errorCode,
        "Id": id,
        "VIPLevelId": vipLevelId,
        "NextWithdrawalTime":
            nextWithdrawalTime?.toIso8601String(),
        "IsWithdrawApplicable":
            isWithdrawApplicable ? 1 : 0,
        "totalWithdrawAmount": totalWithdrawAmount,
        "SendOTPWithdrawAmount": sendOTPWithdrawAmount,
        "LevelName": vipLevelName
      };
}
