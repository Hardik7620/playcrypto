import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/models/game_model.dart';
import 'package:playcrypto365/models/recent_winner.dart';
import 'package:playcrypto365/models/rollover_details.dart';
import 'package:playcrypto365/models/spin_result.dart';
import 'package:playcrypto365/models/vip_configurations.dart';
import '../constants/global_constant.dart';
import '../constants/api_toggles.dart';
import '../models/bank_account.dart';
import '../models/coupon.dart';
import '../models/crypto_create_payment_model.dart';
import '../models/crypto_network_models.dart';
import '../models/crypto_payment_status_model.dart';
import '../models/home_banners.dart';
import '../models/promotion_config.dart';
import '../models/referral_bonus_user.dart';
import '../models/scratch_card.dart';
import '../models/social_handle.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import '../models/amount_bonus.dart';
import '../screens/deposit_screen.dart';

class RestApiService {
  static final RestApiService _instance =
      RestApiService._internal();

  RestApiService._internal();

  factory RestApiService() {
    return _instance;
  }

  static final myClient = http.Client();

  static final respCache = <String, dynamic>{};

  Future<String> userLoginService(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedPassword =
        Uri.encodeQueryComponent(password);

    final url =
        '${GlobalConstant.baseURL}/api/Login/UserLogin?Mobile=$encodedEmail&Password=$encodedPassword&SiteCode=${GlobalConstant.kAppCode}';

    print('===== userLoginService DEBUG =====');
    print('Email/Mobile: $email');
    print('Password: $password');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===== END userLoginService DEBUG =====');

    return response.body;
  }

  Future<String> getUserBalance() async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserBalanceV2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    print('===== getUserBalance DEBUG =====');
    print('URL: $url');
    print('Token: $token');
    print('UserId: $userId');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===== END getUserBalance DEBUG =====');

    try {
      final decoded = json.decode(response.body);

      // Fix TypeError: 'JsonMap' is not a subtype of type 'Iterable<dynamic>'
      // Check if it's an error object instead of a list of wallets
      if (decoded is Map<String, dynamic>) {
        print(
            'getUserBalance returned an error Map: $decoded');
        return response
            .body; // Return as-is, the caller handles error codes
      }

      Iterable list = decoded ?? [];

      List<Wallet> wallets =
          list.map((e) => Wallet.fromJson(e)).toList();
      int indexOf = wallets.indexWhere((e) =>
          e.walletTypeId ==
          GlobalConstant.userWallet.walletTypeId);

      if (indexOf != -1) {
        GlobalConstant.userWallet = wallets[indexOf];
      }
    } catch (e) {
      print('Error parsing getUserBalance: $e');
    }
    return response.body;
  }

  Future<String> getUserStatement(int pageNumber) async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserStatementV2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final bodyData = {
      'PageNumber': pageNumber.toString(),
      'RecordCount': '20',
      'CreditAccountId':
          GlobalConstant.userWallet.creditAccountId,
    };

    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getUserCryptoStatement(
      int pageNumber) async {
    final url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetDepositStatementList?PageNo=$pageNumber&PageSize=20';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final bodyData = {
      'PageNumber': pageNumber.toString(),
      'RecordCount': '20',
      'CreditAccountId':
          GlobalConstant.userWallet.creditAccountId,
    };

    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getGetGameList(String gameType, {int page = 1, int limit = 20}) async {
    String url =
        '${GlobalConstant.baseURL}/api/GameV1/GetGameList?GameCategory=$gameType&SiteCode=${GlobalConstant.kAppCode}&PageNumber=$page&RecordCount=$limit';

    final prefs = await SharedPreferences.getInstance();
    final langCode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langCode,
      'SiteCode': GlobalConstant.kAppCode,
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
      'Accept': '*/*',
      'Content-Type': 'application/json',
    };
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getTurnOverGameList(String gameType, {int page = 1, int limit = 20}) async {
    String url =
        '${GlobalConstant.baseURL}/api/GameV1/GetTurnoverGameList?GameCategory=$gameType&SiteCode=P65&PageNumber=$page&RecordCount=$limit';

    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode =
          prefs.getString('language_code') ?? 'en';
      final headers = {
        'LanguageCode': langCode,
        'SiteCode': GlobalConstant.kAppCode,
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
        'Accept': '*/*',
        'Content-Type': 'application/json',
      };
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      return response.body;
    } catch (e) {
      return "ERROR";
    }
  }

  Future<String> getGameSubCategoryList(
      String gameType) async {
    String url =
        '${GlobalConstant.baseURL}/api/GameV1/GetGameBySubCategory?SubCategory=$gameType&SiteCode=${GlobalConstant.kAppCode}';
    if (respCache['gameSubCategory-$gameType'] != null) {
      return respCache['gameSubCategory-$gameType'];
    }
    final prefs = await SharedPreferences.getInstance();
    final langCode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langCode,
      'SiteCode': GlobalConstant.kAppCode,
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
      'Accept': '*/*',
      'Content-Type': 'application/json',
    };
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    respCache['gameSubCategory-$gameType'] = response.body;
    return response.body;
  }

  Future<String> getWithdrawalStatus(
      [bool fromCache = true]) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetWithdrawalStatementV2?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    print(url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(headers);

    if (fromCache &&
        respCache['withdrawalStatus'] != null) {
      return respCache['withdrawalStatus'];
    }
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      respCache['withdrawalStatus'] = response.body;
    }
    return response.body;
  }

  Future<String> getLobyGameUrl(String gameCode) async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetGameUrlLobby';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final bodyData = {
      'platform': 'GPL_MOBILE',
      'game_code': gameCode
    };

    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getUrlBasedOnGameProvider(
      String gameCode) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUrlBasedOnGameProviderV2?game_id=$gameCode&CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };
    respCache.remove('recentGames');
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> registerGenerateOTP(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/GenerateOTPV2?Mobile=$email&SiteCode=${GlobalConstant.kAppCode}';
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> registerGenerateOTPV2(String mobile,
      String email, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
      'accept': '/',
      'content-type': 'application/json'
    };

    final encodedMobile = Uri.encodeQueryComponent(mobile);
    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedCountryCode =
        Uri.encodeQueryComponent(countryCode);
    final encodedSiteCode =
        Uri.encodeQueryComponent(GlobalConstant.kAppCode);

    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/GenerateOTPV2?Mobile=$encodedMobile&Email=$encodedEmail&SiteCode=$encodedSiteCode&countryCode=$encodedCountryCode&type=emailmobile';

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> registerVerifyOTP(
      String mobileNumber, String otp) async {
    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/VerifyOTP?Mobile=$mobileNumber&OTP=$otp&SiteCode=${GlobalConstant.kAppCode}';
    final prefs = await SharedPreferences.getInstance();
    final langCode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langCode,
      'SiteCode': GlobalConstant.kAppCode,
    };
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> registerVerifyOTPV2(String mobileNumber,
      String email, String otp, String emailOtp) async {
    final prefs = await SharedPreferences.getInstance();
    final langCode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langCode,
      'SiteCode': GlobalConstant.kAppCode,
      'accept': '/',
      'content-type': 'application/json'
    };

    final encodedMobile =
        Uri.encodeQueryComponent(mobileNumber);
    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedOtp = Uri.encodeQueryComponent(otp);
    final encodedEmailOtp =
        Uri.encodeQueryComponent(emailOtp);
    final encodedSiteCode =
        Uri.encodeQueryComponent(GlobalConstant.kAppCode);

    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/VerifyOTP?Mobile=$encodedMobile&Email=$encodedEmail&OTP=$encodedOtp&EmailOTP=$encodedEmailOtp&SiteCode=$encodedSiteCode';

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> sendOneTimeOTP({
    required String value,
    required String type, // 'email' or 'mobile'
    String countryCode = '60',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
      'accept': 'application/json',
      'content-type': 'application/json'
    };

    final encodedValue = Uri.encodeQueryComponent(value);
    final encodedSiteCode =
        Uri.encodeQueryComponent(GlobalConstant.kAppCode);
    final encodedCountryCode =
        Uri.encodeQueryComponent(countryCode);
    final encodedType = Uri.encodeQueryComponent(type);

    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/GenerateOneTimeOTPV2?Mobile=$encodedValue&SiteCode=$encodedSiteCode&countryCode=$encodedCountryCode&type=$encodedType';

    print('===== sendOneTimeOTP DEBUG =====');
    print('Type: $type');
    print('Value: $value');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===== END sendOneTimeOTP DEBUG =====');

    return response.body;
  }

  Future<String> verifyOneTimeOTP({
    required String value,
    required String otp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
      'accept': '/',
    };

    // Standard URI encoding for the mobile/email value
    final encodedValue = Uri.encodeQueryComponent(value);
    final encodedOtp = Uri.encodeQueryComponent(otp);
    final encodedSiteCode =
        Uri.encodeQueryComponent(GlobalConstant.kAppCode);

    // Auto-detect type to match new API requirement (Type=email or Type=mobile)
    final type = value.contains('@') ? 'email' : 'mobile';

    String url =
        '${GlobalConstant.baseURL}/api/RegisterUser/VerifyOneTimeOTP?Mobile=$encodedValue&OTP=$encodedOtp&SiteCode=$encodedSiteCode&Type=$type';

    print('===== verifyOneTimeOTP DEBUG =====');
    print('Value: $value');
    print('OTP: $otp');
    print('Type: $type');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===== END verifyOneTimeOTP DEBUG =====');

    return response.body;
  }

  Future<String> signupUser(
      Map<String, String> authData) async {
    authData['SiteCode'] = GlobalConstant.kAppCode;
    const url =
        '${GlobalConstant.baseURL}/api/RegisterUser/SignupUserV2';
    final response = await http
        .post(Uri.parse(url), body: authData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> makeCallBackRequest() async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/RequestCallbackV2?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getSportLink() async {
    const url =
        '${GlobalConstant.baseURL}/api/usergame/GetGamelaunchURL';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final headers = {
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final bodyData = jsonEncode(
        {'token': token, 'game_code': 'sap_lobby'});

    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getPromotions() async {
    String url =
        '${GlobalConstant.kResourceUrl}/P65/promotions/promotions.json';

    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    return utf8.decode(response.bodyBytes);
  }

  Future<String> cancelWithdrawal(
      String withdrawId, String crpCurreny) async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/CancellWithdrawRequest';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final langcode =
        prefs.getString('language_code') ?? 'en';

    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    final bodyData = {
      'Id': withdrawId,
      'CrpCurrency': crpCurreny,
    };

    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> requestWithdrawal(
      Map<String, String> requestData) async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/WithdrawRequestV2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode =
        prefs.getString('language_code') ?? 'en';
    final headers = {
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };
    respCache.remove('withdrawalStatus');
    print(headers);
    print(requestData);
    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: requestData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> generateOTPForgotPassword(
      String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final langcode =
        prefs.getString('language_code') ?? 'enR';
    final headers = {
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    const url =
        '${GlobalConstant.baseURL}/api/RegisterUser/GenerateOTPForgotPassword';

    final bodyData = {
      'Mobile': mobileNumber,
      'SiteCode': GlobalConstant.kAppCode
    };
    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> resetPassword(String mobileNumber,
      String otp, String password) async {
    const url =
        '${GlobalConstant.baseURL}/api/RegisterUser/ResetPassword';

    final bodyData = {
      'Mobile': mobileNumber,
      'OTP': otp,
      'Password': password,
      'SiteCode': GlobalConstant.kAppCode
    };
    final response = await http
        .post(Uri.parse(url), body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> depositRequest(
      String amount,
      String promoCode,
      String pgTypeCode,
      String? depositAmountId) async {
    const url =
        '${GlobalConstant.baseURL}/api/MyProfile/AppDepositAmountV2';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    //final LangCode = prefs.getString('LanguageCode');
    final headers = {
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
      //'LanguageCode': '$LangCode'
    };

    final bodyData = {
      'Amount': amount,
      "CreditAccountId":
          GlobalConstant.userWallet.creditAccountId,
      "PromotionCode": promoCode,
      "PGTypeCode": pgTypeCode,
      "DepositAmountId": depositAmountId,
      "AppVersion": GlobalConstant.kAppVersion
    };

    final response = await http
        .post(Uri.parse(url),
            headers: headers, body: bodyData)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<User> getUserDetail(
      [bool fromCache = true]) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserDetailV1?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final userMobileNo = prefs.getString('email');
    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    if (fromCache && respCache['user'] != null) {
      print(
          'from cache and use cache is${respCache['user']}');
      return User.fromJson(json.decode(respCache['user']));
    }

    print('===== getUserDetail DEBUG =====');
    print('URL: $url');
    print('Token: $token');
    print('UserId: $userId');
    print('Stored Email: $userMobileNo');
    print('===== END getUserDetail DEBUG =====');

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print(
          'getUserDetail Response Status: ${response.statusCode}');
      print(
          'getUserDetail Response Body: ${response.body}');

      if (response.body == "null")
        return Future.error(response.body);
      if (response.statusCode == 200) {
        // Check if the response is an error from backend
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> &&
            decoded['Result'] == 'Failed') {
          print(
              'getUserDetail API error: ${response.body}');
          return Future.error(
              decoded['ErrorMessage'] ?? 'Unknown error');
        }
        respCache['user'] = response.body;
        return User.fromJson(decoded);
      }
      return Future.error(response.body);
    } catch (e) {
      print('Error in getUserDetail: $e');
      return Future.error(e);
    }
  }

  /// Update user profile field (mobile or email).
  /// LEGACY – kept for backward compatibility.
  Future<Map<String, dynamic>> updateUserProfile({
    required String fieldType, // 'mobile' or 'email'
    required String value,
  }) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/UpdateUserProfile';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final body = json.encode({
      'FieldType': fieldType, // 'mobile' or 'email'
      'Value': value,
    });

    try {
      final response = await http
          .post(Uri.parse(url),
              headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Invalidate user cache so next fetch gets updated data
        respCache['user'] = null;

        // Persist email locally if updated
        if (fieldType == 'email') {
          await prefs.setString('email', value);
        }

        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'ErrorCode': '1'};
      }
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage':
            'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage': e.toString(),
      };
    }
  }

  // ── Send OTP for updating email or phone ──
  Future<Map<String, dynamic>> sendOTPForProfileUpdate({
    required String fieldType, // 'mobile' or 'email'
    required String value,
    String countryCode = '60',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langCode =
        prefs.getString('language_code') ?? 'en';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': langCode,
    };

    final encodedValue = Uri.encodeQueryComponent(value);
    String url;

    if (fieldType == 'email') {
      // GET /api/user/SendOTPEmail?Email=...
      url =
          '${GlobalConstant.baseURL}/api/user/SendOTPEmail?Email=$encodedValue';
    } else {
      // GET /api/user/SendOTPMobile?Mobile=...&countryCode=...
      final encodedCountry =
          Uri.encodeQueryComponent(countryCode);
      url =
          '${GlobalConstant.baseURL}/api/user/SendOTPMobile?Mobile=$encodedValue&countryCode=$encodedCountry';
    }

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'ErrorCode': '1'};
      }
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage':
            'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage': e.toString(),
      };
    }
  }

  // ── Update user email with OTP verification ──
  Future<Map<String, dynamic>> updateUserEmail({
    required String email,
    required String otp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langCode = prefs.getString('language_code');

    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedOtp = Uri.encodeQueryComponent(otp);

    final url =
        '${GlobalConstant.baseURL}/api/user/UpdateUserEmail?Email=$encodedEmail&OTP=$encodedOtp';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': langCode ?? '',
    };

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        respCache['user'] = null;
        await prefs.setString('email', email);

        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'ErrorCode': '1'};
      }
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage':
            'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage': e.toString(),
      };
    }
  }

  // ── Update user mobile number with OTP verification ──
  Future<Map<String, dynamic>> updateUserNumber({
    required String mobile,
    required String otp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langCode = prefs.getString('language_code');

    final encodedMobile = Uri.encodeQueryComponent(mobile);
    final encodedOtp = Uri.encodeQueryComponent(otp);

    final url =
        '${GlobalConstant.baseURL}/api/user/UpdateUserNumber?Mobile=$encodedMobile&OTP=$encodedOtp';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': langCode ?? '',
    };

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        respCache['user'] = null;

        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'ErrorCode': '1'};
      }
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage':
            'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage': e.toString(),
      };
    }
  }

  // ── Change Password API ──
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    const url =
        '${GlobalConstant.baseURL}/api/user/ChangePassword';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
    };

    final body = json.encode({
      'CurrentPassword': currentPassword,
      'NewPassword': newPassword,
      'ConfirmPassword': confirmPassword,
    });

    try {
      final response = await http
          .post(Uri.parse(url),
              headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'ErrorCode': '1'};
      }
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage':
            'Server returned ${response.statusCode}',
      };
    } catch (e) {
      return {
        'status': 'error',
        'ErrorCode': '0',
        'ErrorMessage': e.toString(),
      };
    }
  }

  Future<String> getAppVersion() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/appVersion.txt';
    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getWhatsappNumber() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/whatsapp.txt';

    final response = await myClient.get(Uri.parse(url));
    return response.body;
  }

  Future<bool> checkIfOTPisAvailable() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/isotpon.txt';
    final response = await myClient.get(Uri.parse(url));
    try {
      return response.body.trim().toString() == "1";
    } catch (e) {
      return false;
    }
  }

  Future<Map> getLatestApkInfo() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/downloadplaycrypto365app.json';
    final response = await myClient.get(Uri.parse(url));
    try {
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<String> getChatLink() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('UserId');
    String url;
    if (GlobalConstant.currentAppUrl.contains('uat')) {
      url =
          '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/chaturluat.txt';
    } else {
      url =
          '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/chaturl.txt';
    }

    final response = await myClient.get(Uri.parse(url));
    String chatUrl = response.body;

    // Adding query params
    chatUrl =
        "$chatUrl?userId=$userId&siteCode=${GlobalConstant.kAppCode}";
    return chatUrl;
  }

  // Note: Toggles have been moved to lib/constants/api_toggles.dart

  Future<String> getGameAllGameList() async {
    // ── LOCAL ASSET MODE (for testing scroll-lag) ──
    if (ApiToggles.useLocalGameList) {
      return await rootBundle.loadString('assets/allgames_list.json');
    }

    // ── ORIGINAL REMOTE API MODE ──
    String url = ApiToggles.useOldV2GameList
        ? '${GlobalConstant.kResourceUrl}/P65/gamelist/allgames_v2old.json'
        : '${GlobalConstant.kResourceUrl}/P65/gamelist/allgames_v2.json';
    // String url =
    //     '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/gamelist/allgames_v2.json';
    // String url =
    //     '${GlobalConstant.baseURL}/api/GameV1/GetAllGameList?siteCode=${GlobalConstant.kAppCode}';
    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getGameNameByLanguage(
      String langCode) async {
    final url =
        '${GlobalConstant.baseURL}/api/common/GetGameNameByLanguage?SiteCode=${GlobalConstant.kAppCode}';
    final headers = {
      'LanguageCode': langCode,
    };
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<List<HomeBanners>> getBannerData(
      Locale locale) async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/banner/homebanner_en.json';
    final response = await myClient.get(Uri.parse(url));
    Iterable data = json.decode(response.body);
    return data
        .map((e) => HomeBanners(
            link: e['url'] ?? '',
            redirectTo: e['redirect_to'] ?? ''))
        .toList();
  }

  Future<String> getLobbyImageData() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/banner/gamebanner.json';
    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> getGameBannerData() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/brandlist/gamebannerlist.json';
    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<String> walletType() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/wallettype/wallet.json';

    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    return response.body;
  }

  Future<List<AmountBonus>> getTransactionList() async {
    // String url =
    //     '${GlobalConstant.baseURL}/api/MyProfile/GetDepositAmountList?WalletTypeId=${GlobalConstant.userWallet.walletTypeId}';
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('LoginToken');
    // final userId = prefs.getString('UserId');
    // final langcode = prefs.getString('language_code');
    // final headers = <String, String>{
    //   'Accept': 'application/json',
    //   'Token': '$token',
    //   'UserId': '$userId',
    //   'LanguageCode': '$langcode',
    //   'SiteCode': GlobalConstant.kAppCode,
    // };
    // final response = await http.get(Uri.parse(url), headers: headers);
    List<Map<String, dynamic>> response = [
      {
        "DepositAmountId": "1",
        "LevelId": "1",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "1",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "1",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "1",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "1",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "1",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "2",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "2",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "2",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "2",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "2",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "2",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "3",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "3",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "3",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "3",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "3",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "3",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "4",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "4",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "4",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "4",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "4",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "4",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "5",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "1",
        "LevelId": "6",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "6",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "6",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "6",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "6",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "6",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "7",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "7",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "7",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "7",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "7",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "7",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "1",
        "LevelId": "8",
        "Amount": 200.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "2",
        "LevelId": "8",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "8",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "8",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "8",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "6",
        "LevelId": "8",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "6",
        "LevelId": "5",
        "Amount": 30000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 6
      },
      {
        "DepositAmountId": "2",
        "LevelId": "5",
        "Amount": 1000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 2
      },
      {
        "DepositAmountId": "3",
        "LevelId": "5",
        "Amount": 3000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 3
      },
      {
        "DepositAmountId": "4",
        "LevelId": "5",
        "Amount": 5000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 4
      },
      {
        "DepositAmountId": "5",
        "LevelId": "5",
        "Amount": 10000.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 5
      },
      {
        "DepositAmountId": "7",
        "LevelId": "1",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "2",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "3",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "4",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "5",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "6",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "7",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      },
      {
        "DepositAmountId": "7",
        "LevelId": "8",
        "Amount": 400.0000,
        "BonusPercentage": 3,
        "Wagering": 1.00,
        "Sorting": 1
      }
    ];
    try {
      return response
          .map((e) => AmountBonus(
                depositAmountId: e['DepositAmountId'],
                levelId: e['LevelId'],
                amount: e['Amount'],
                bonusPercentage: e['BonusPercentage'],
                sorting: e['Sorting'],
                wagering: e['Wagering'],
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<GameModel>> getRecentGames() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    if (respCache['recentGames'] != null) {
      Iterable data = json.decode(respCache['recentGames']);
      return data
          .map((e) => GameModel(
              game_id: e['Id'],
              name: e['GameName'],
              url_thumb: e['ImageUrl']))
          .toList();
    }
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserRecentPlayedGameList';
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    try {
      respCache['recentGames'] = response.body;
      Iterable data = json.decode(response.body);
      return data
          .map((e) => GameModel(
              game_id: e['Id'],
              name: e['GameName'],
              url_thumb: e['ImageUrl']))
          .toList();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Coupon>> getPromotionCoupons(
      String creditAccountId) async {
    final dat2 = [
      {
        "PromotionCode": "PROMO50",
        "Title": "50%",
        "Description":
            "Get 50% bonus on Crash and Slots games 10X wagering",
        "MinimumDepositAmount": 200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 50,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 1,
        "VIPLevelId": "0",
        "Wagering": 10.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PROMO100",
        "Title": "100%",
        "Description":
            "Get 100% bonus on Crash and Slots games 15X wagering",
        "MinimumDepositAmount": 1200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 100,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 2,
        "VIPLevelId": "3",
        "Wagering": 15.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PROMO150",
        "Title": "150%",
        "Description":
            "Get 150% bonus on Crash and Slots games 20X wagering",
        "MinimumDepositAmount": 1200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 150,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 3,
        "VIPLevelId": "3",
        "Wagering": 20.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PROMO200",
        "Title": "200%",
        "Description":
            "Get 200% bonus on Crash and Slots games 25X wagering",
        "MinimumDepositAmount": 1200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 200,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 4,
        "VIPLevelId": "3",
        "Wagering": 25.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PROMO300",
        "Title": "300%",
        "Description":
            "Get 300% bonus on Crash and Slots games 35X wagering",
        "MinimumDepositAmount": 1200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 300,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 5,
        "VIPLevelId": "3",
        "Wagering": 35.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PROMO500",
        "Title": "500%",
        "Description":
            "Get 500% bonus for VIP 3 on Crash and Slots, 45X wagering.",
        "MinimumDepositAmount": 1200.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 500,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Welcome",
        "SubCategory": "Slot",
        "PromoSortOrder": 6,
        "VIPLevelId": "4",
        "Wagering": 45.00,
        "BonusCreditDays": 0
      },
      {
        "PromotionCode": "PLB250",
        "Title": "50 ৳",
        "Description":
            "Deposit 250 and Get 50 Bonus for Next 7 Days",
        "MinimumDepositAmount": 250.0000,
        "DepositAmount": 0.0000,
        "DepositPercentage": 0,
        "DepositCount": 0,
        "CapLimit": 0.0,
        "Category": "Daily Bonus Pack",
        "SubCategory": "Daily",
        "PromoSortOrder": 7,
        "VIPLevelId": "0",
        "Wagering": 1.00,
        "BonusCreditDays": 7
      }
    ];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetDepositPromotionListV2?CreditAccountId=$creditAccountId';
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    try {
      Iterable data = json.decode(response.body);
      return data.map((e) => Coupon.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ScratchCard>> getPendingScratchCards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetDepositBonusViaScratchCard?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    try {
      Iterable data = json.decode(response.body);
      return data
          .map((e) => ScratchCard.fromJson(e))
          .toList();
    } catch (err) {
      return [];
    }
  }

  Future<String> saveScratchCardAction(
      String scratchCardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/AddDepostScratchCardBonus?Id=$scratchCardId';
    return http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15))
        .then((value) {
      return value.body;
    });
  }

  Future<List<SocialHandle>> getSocialMediaHandles() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/support/socials.json';
    final response = await myClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    try {
      Iterable data = json.decode(response.body);
      return data
          .map((e) => SocialHandle.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BankAccount>> getUsersBankDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      if (prefs.getString("userWallet") != null &&
          (GlobalConstant.userWallet.creditAccountId ?? "")
              .isEmpty) {
        GlobalConstant
            .userWallet.creditAccountId = Wallet.fromJson(
                json.decode(prefs.getString("userWallet")!))
            .creditAccountId;
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$token',
        'UserId': '$userId',
        'LanguageCode': '$langcode',
        'SiteCode': GlobalConstant.kAppCode,
      };
      print(
          "Real money credit account id: ${GlobalConstant.realMoneyCreditAccountId}");
      String url =
          '${GlobalConstant.baseURL}/api/MyProfile/GetUsersBankDetails?CreditAccountId=${GlobalConstant.realMoneyCreditAccountId.isEmpty ? GlobalConstant.userWallet.creditAccountId : GlobalConstant.realMoneyCreditAccountId}';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      Iterable data = json.decode(response.body);
      if (response.statusCode == 200) {
        respCache['banks'] = response.body;
      }
      return data
          .map((e) => BankAccount.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map> saveUserBankDetails(
      Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      if (prefs.getString("userWallet") != null &&
          (GlobalConstant.userWallet.creditAccountId ?? "")
              .isEmpty) {
        GlobalConstant
            .userWallet.creditAccountId = Wallet.fromJson(
                json.decode(prefs.getString("userWallet")!))
            .creditAccountId;
      }
      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$token',
        'UserId': '$userId',
        'LanguageCode': '$langcode',
        'SiteCode': GlobalConstant.kAppCode,
      };
      respCache.remove('banks');
      body.putIfAbsent('CreditAccountId',
          () => GlobalConstant.realMoneyCreditAccountId!);
      body.putIfAbsent('UserId', () => userId!);
      String url =
          '${GlobalConstant.baseURL}/api/MyProfile/SaveUserBankDetails';
      var response = await http
          .post(Uri.parse(url),
              headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
      return json.decode(response.body);
    } catch (e) {
      print('error $e');
      return Future.error(e);
    }
  }

  Future claimSpinWheelResult(
      String category, String creditAccountId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    Map body = {
      "Category": category,
      "CreditAccountId": creditAccountId,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/ClaimPromotionSpinWheel';
    var response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 15));
    Map<String, dynamic> responseBody =
        json.decode(response.body);
    if (responseBody.containsKey("ErrorMessage") &&
        responseBody["ErrorMessage"].length == 0) {
      return SpinResult.fromJson(responseBody);
    } else {
      responseBody.putIfAbsent(
          "ErrorMessage", () => "Something went wrong!");
      return Future.error(responseBody["ErrorMessage"]);
    }
  }

  Future<List<SpinResult>> getSpinWheelPrizes(
      String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langcode = prefs.getString('language_code');
      if (prefs.getString("userWallet") != null &&
          (GlobalConstant.userWallet.creditAccountId ?? "")
              .isEmpty) {
        GlobalConstant
            .userWallet.creditAccountId = Wallet.fromJson(
                json.decode(prefs.getString("userWallet")!))
            .creditAccountId;
      }
      final headers = <String, String>{
        'Accept': 'application/json',
        'LanguageCode': '$langcode',
        'SiteCode': GlobalConstant.kAppCode,
      };
      String url =
          '${GlobalConstant.baseURL}/api/common/GetPromotionSpinWheelList?SiteCode=${GlobalConstant.kAppCode}&Category=$type';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      Iterable data = json.decode(response.body);
      return data
          .map((e) => SpinResult.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SpinResult>> getSpinResultByType(
      String category, String creditAccountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$token',
        'UserId': '$userId',
        'LanguageCode': '$langcode',
        'SiteCode': GlobalConstant.kAppCode,
      };
      String url =
          '${GlobalConstant.baseURL}/api/MyProfile/GetPromotionSpinWheelDataViaType?CreditAccountId=$creditAccountId&Category=$category';
      try {
        final response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 15));
        Iterable data = json.decode(response.body);
        return data
            .map((e) => SpinResult.fromJson(e))
            .toList();
      } catch (err) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future claimSpinResultBonus(int spinResultId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    Map body = {
      "Id": spinResultId.toString(),
      "CreditAccountId":
          GlobalConstant.userWallet.creditAccountId,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/ClaimPromotionSpinWheel';
    await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 15));
  }

  Future<List<RecentWinner>> getRecentSpinWheel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    String url =
        '${GlobalConstant.baseURL}/api/GameV1/GetRecentSpinWheel?siteCode=${GlobalConstant.kAppCode}';
    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    Iterable data = json.decode(response.body);
    return data
        .map((e) => RecentWinner.fromJson(e))
        .toList();
  }

  Future<VIPConfigurations> fetchVIPTemplateInfo(
      int templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    if (respCache['vipTemplate'] != null) {
      print(
          'from cache and use cache is${respCache['vipTemplate']}');
      return VIPConfigurations.fromJson(
          respCache['vipTemplate']);
    }
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetVIPTemplateDetails?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}&VipTemplateId=$templateId';
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        respCache['vipTemplate'] =
            json.decode(response.body);
      }
      var data = json.decode(response.body);
      return VIPConfigurations.fromJson(data);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<PromotionConfig> getPromotionConfig() async {
    String url =
        '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/constant/app_config_v2.json';
    try {
      if (respCache['promotionConfig'] != null) {
        return PromotionConfig.fromJson(
            json.decode(respCache['promotionConfig']));
      }
      final response = await myClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      respCache['promotionConfig'] = response.body;
      return PromotionConfig.fromJson(
          json.decode(response.body));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<VipProgress?> getUserProgress() async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserProgressDetails?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    try {
      Iterable data = json.decode(response.body);
      return VipProgress.fromJson(data.first);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<RolloverDetails> getUserRolloverDetails(
      [bool updateCache = false]) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserRolloverWithdrawalDetails?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(
        'rolloverDetails${(respCache['rolloverDetails${GlobalConstant.userWallet.creditAccountId}'])}');

    if (respCache[
                'rolloverDetails${GlobalConstant.userWallet.creditAccountId}'] !=
            null &&
        !updateCache) {
      return RolloverDetails.fromJson(respCache[
          'rolloverDetails${GlobalConstant.userWallet.creditAccountId}']);
    }

    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    var body = json.decode(response.body);
    if (response.statusCode == 200) {
      respCache[
              'rolloverDetails${GlobalConstant.userWallet.creditAccountId}'] =
          body;
    }
    return RolloverDetails.fromJson(body ?? {});
  }

  Future<bool> saveUserLevelAchievedDetails() async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/SaveUserLevelAchievedDetails?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    Map body = json.decode(response.body);
    return body.containsKey('ErrorCode') &&
        body["ErrorCode"] == "1";
  }

  Future<bool> updateFCMTokenIfNecessary(
      String token) async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString('fcmToken');
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    if (token == fcmToken) {
      // Already exists
      return true;
    }

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/UpdateUserNotificationToken?fcmToken=$token';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      prefs.setString('fcmToken', token);
      return true;
    } else {
      return false;
    }
  }

  Future<String> saveUserClaimRewardBonus(
      String rewardType, String vipLevelId) async {
    assert(rewardType == "Daily" ||
        rewardType == "Monthly" ||
        rewardType == "Weekly");
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/Save${rewardType}ClaimUserVipBonus';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    final body = <String, String>{
      "LevelId": vipLevelId,
      "CreditAccountId":
          GlobalConstant.userWallet.creditAccountId ?? "",
      "SiteCode": GlobalConstant.kAppCode,
    };

    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 15));

    var responseBody = json.decode(response.body);

    if (responseBody["ErrorCode"] != "1") {
      return responseBody["ErrorMessage"];
    }

    return "";
  }

  Future<VipBonusDetails> getVIPBonusDetails(
      [bool fromCache = true]) async {
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUserBonusEligibility';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };

    if (respCache['vipBonusDetails'] != null && fromCache) {
      print(
          'from cache and use cache is${respCache['vipBonusDetails']}');

      return VipBonusDetails(
        eligibleForDailyBonus: respCache['vipBonusDetails']
                ["DayBonusEligible"] ==
            1,
        eligibleForWeeklyBonus: respCache['vipBonusDetails']
                ["WeekBonusEligible"] ==
            1,
        eligibleForMonthlyBonus:
            respCache['vipBonusDetails']
                    ["MonthBonusEligible"] ==
                1,
        totalBonusClaimed: respCache['vipBonusDetails']
            ["TotalBonusTaken"],
        dayStreak:
            respCache['vipBonusDetails']["DayStreak"] ?? 0,
      );
    }

    final body = <String, String>{
      "CreditAccountId":
          GlobalConstant.userWallet.creditAccountId ?? "",
      "SiteCode": GlobalConstant.kAppCode,
    };

    final response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 15));

    respCache['vipBonusDetails'] =
        json.decode(response.body);

    var responseBody = json.decode(response.body);

    return VipBonusDetails(
      eligibleForDailyBonus:
          responseBody["DayBonusEligible"] == 1,
      eligibleForWeeklyBonus:
          responseBody["WeekBonusEligible"] == 1,
      eligibleForMonthlyBonus:
          responseBody["MonthBonusEligible"] == 1,
      totalBonusClaimed: responseBody["TotalBonusTaken"],
      dayStreak: responseBody["DayStreak"] ?? 0,
    );
  }

  Future<Map> lossDepositScratchCardBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/AddLossBackScratchCardBonus?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    return json.decode(response.body);
  }

  Future<List<GameModel>> getGamesByRolloverType(
      {required String type}) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetgameListByType?Type=$type';

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 15));
    try {
      Iterable data = json.decode(response.body);
      return data
          .map((e) => GameModel(
              game_id: e['game_id'],
              name: e['name'],
              url_thumb: e['url_thumb'],
              gameCode: e['game_code']))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map> addDailyBonusPack() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/AddDailyBonusPack?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };
    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map> generateOTPForWithdrawal(
      String mobile, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    String url;
    if (type == 'AB') {
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/GenerateOTPForWithdrawal?type=$type';
    } else {
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/GenerateOTPForPryWithdrawal';
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(headers);

    var response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body:
              json.encode({"Mobile": mobile, "type": type}),
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<Map> generateOTPForCryptoWithdrawal(
      String email) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    String url;

    url =
        '${GlobalConstant.baseURL}/api/MyProfile/WithdrawGenerateOTP?Mobile=$email&SiteCode=${GlobalConstant.kAppCode}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(headers);

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<Map> generateOTPForPryWithdrawal(
      String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    String url;
    url =
        '${GlobalConstant.baseURL}/api/MyProfile/GenerateOTPForPryWithdrawal';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(headers);

    var response = await http
        .post(
          Uri.parse(url),
          headers: headers,
          body:
              json.encode({"Mobile": mobile, "type": "AB"}),
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<Map> verifyOTPForWithdrawal(
      String mobileNumber, String otp, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url;
    if (type == 'AB') {
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/VerifyOTP?Mobile=$mobileNumber&OTP=$otp';
    } else {
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/VerifyOTPPry?Mobile=$mobileNumber&OTP=$otp';
    }
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map> verifyOTPForCryptoWithdrawal(
    String mobileNumber,
    String otp,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url;

    url =
        '${GlobalConstant.baseURL}/api/MyProfile/WithdrawVerifyOTP?Mobile=$mobileNumber&OTP=$otp&SiteCode=${GlobalConstant.kAppCode}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map> verifyOTPForPryWithdrawal(
      String mobileNumber, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url;
    url =
        '${GlobalConstant.baseURL}/api/MyProfile/VerifyOTPPry?Mobile=$mobileNumber&OTP=$otp';
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    return data;
  }

  Future<Map> deleteUserBankDetails(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/DeleteUserBankDetails?Id=$id';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<Map> getUsersReferralBonusDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetUsersReferralBonusDetails?CreditAccountId=${GlobalConstant.referEarningCreditAccountId}';

    print(url);

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<List<ReferralBonusUser>>
      getTopUsersReferralList() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetTopUsersReferralList?CreditAccountId=${GlobalConstant.referEarningCreditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    Iterable data = json.decode(response.body);
    print('Referral Bonus User List: $data');
    return data
        .map((e) => ReferralBonusUser.fromJson(e))
        .toList();
  }

  Future<Map> transferReferralBalance(String amount) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/MyProfile/TransferReferalBalance?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}&TransferAmount=$amount';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<Map> getDailyDepositRebateBonusDetails() async {
    print('Fetching Daily Deposit Rebate Bonus Details');
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    // print("creditAccountId:${GlobalConstant.realMoneyCreditAccountId}");
    print(
        "creditAccountId:${GlobalConstant.userWallet.creditAccountId}");

    String url =
        '${GlobalConstant.baseURL}/api/user/GetDailyDepositRebateBonusDetails?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';
    // String url =
    //     '${GlobalConstant.baseURL}/api/user/GetDailyDepositRebateBonusDetails?creditAccountId=${GlobalConstant.realMoneyCreditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print("In getDailyDepositRebateBonusDetails()");
    print(data);
    print(
        "creditAccountId:${GlobalConstant.userWallet.creditAccountId}");
    // print("creditAccountId:${GlobalConstant.realMoneyCreditAccountId}");
    return data;
  }

  Future<Map> getWeeklyDepositRebateBonusDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/user/GetWeeklyDepositRebateBonusDetails?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print("getWeeklyDepositRebateBonusDetails()");
    print(data);
    return data;
  }

  Future<Map> claimDailyDepositRebateBonusDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/user/ClaimDailyDepositRebateBonusDetails?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);

    print("claimDailyDepositRebateBonusDetails()");
    print(data);
    return data;
  }

  Future<Map> claimWeeklyDepositRebateBonusDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');

    String url =
        '${GlobalConstant.baseURL}/api/user/ClaimWeeklyDepositRebateBonusDetails?creditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'SiteCode': GlobalConstant.kAppCode,
      'LanguageCode': langcode.toString(),
    };

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));
    var data = json.decode(response.body);
    print("claimWeeklyDepositRebateBonusDetails()");
    print(data);
    return data;
  }

  Future<List<CryptoNetworkModels>> getCryptoNetworks(
      String walletTypeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');

      String url =
          '${GlobalConstant.baseURL}/api/MyProfile/GetCRPNetworkWalletLists?WalletTypeId=$walletTypeId';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'SiteCode': GlobalConstant.kAppCode,
        'LanguageCode': langcode.toString(),
      };

      var response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      if (data is List) {
        return data
            .map((e) => CryptoNetworkModels.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } on Exception catch (e) {
      print('Error fetching crypto networks: $e');
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<CryptoCreatePaymentModel> createCryptoPayment(
      {required String creditAccountId,
      required String cryptoCode}) async {
    final d = {
      "PgUserId": null,
      "PasswordKey": null,
      "UserName": null,
      "Result": "P65981724",
      "ErrorMessage": "PENDING",
      "ErrorCode": "1",
      "Id": "TLr1hUggZKGaH5e4C35wBiHp6rWxRis7j3",
      "FiatCurrencies": [
        {
          "FiatConvertRate": 23.2300,
          "FiatCurrencyType": "INR",
          "isSelected": true
        },
        {
          "FiatCurrencyType": "USD",
          "FiatConvertRate": 0.2789,
          "isSelected": false
        }
      ]
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      String url;
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/CreateUserCrpPaymentV1';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'LanguageCode': langcode.toString(),
        'SiteCode': GlobalConstant.kAppCode,
      };

      print(headers);

      var response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({
              "CreditAccountId": creditAccountId,
              "CryptoCode": cryptoCode,
              "SiteCode": "BCG"
            }),
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      print(data);
      return CryptoCreatePaymentModel.fromJson(data);
    } on Exception catch (e) {
      print('Error creating crypto payment: $e');
      rethrow;
    }
  }

  Future<Map> updateCryptoPaymentCurrency(
      {required String requestId,
      required String rate,
      required String usd}) async {
    final d = {
      "PgUserId": null,
      "PasswordKey": null,
      "UserName": null,
      "Result": "P65981724",
      "ErrorMessage": "PENDING",
      "ErrorCode": "1",
      "Id": "TLr1hUggZKGaH5e4C35wBiHp6rWxRis7j3",
      "FiatCurrencies": [
        {
          "FiatConvertRate": 23.2300,
          "FiatCurrencyType": "INR",
          "isSelected": true
        },
        {
          "FiatCurrencyType": "USD",
          "FiatConvertRate": 0.2789,
          "isSelected": false
        }
      ]
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      String url;
      url =
          '${GlobalConstant.baseURL}/api/user/UpdateUsdCrpRateToPaymentTransaction?RequestId=$requestId&UsdRate=$rate&CurrencyType=$usd';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'LanguageCode': langcode.toString(),
        'SiteCode': GlobalConstant.kAppCode,
      };

      print(headers);

      var response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      print(data);
      return data;
    } on Exception catch (e) {
      print('Error creating crypto payment: $e');
      rethrow;
    }
  }

  Future<CryptoPaymentStatusModel?>
      checkCryptoPaymentStatus(String transactionId) async {
    // final data2 = {
    //   "Result": "PAID",
    //   "ErrorMessage": "successful",
    //   "ErrorCode": "200",
    //   "Id": null
    // };
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');

      String url =
          '${GlobalConstant.baseURL}/api/MyProfile/CheckCrpPaymentStatusV1?TransactionId=$transactionId';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'SiteCode': GlobalConstant.kAppCode,
        'LanguageCode': langcode.toString(),
      };

      var response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      return CryptoPaymentStatusModel.fromJson(data);
    } catch (e) {
      print('Error fetching crypto networks: $e');
      return null;

      // rethrow;
    }
  }

  Future<CryptoCreatePaymentModel>
      createCryptoWithdrawRequest(
          {required String amount,
          required String cryptoCurrency,
          required String accountAddress,
          required String creditAccountId,
          required String currencyType}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      String url;
      url =
          '${GlobalConstant.baseURL}/api/MyProfile/CrpWithdrawRequestV2';

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'LanguageCode': langcode.toString(),
        'SiteCode': GlobalConstant.kAppCode,
      };

      print(headers);

      var response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({
              "Amount": amount,
              "CrpCurrency": cryptoCurrency,
              "AccountAddress": accountAddress,
              "CreditAccountId": creditAccountId,
              "CrpNetworkCode": cryptoCurrency,
              "CurrencyType": currencyType,
            }),
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      print(data);
      return CryptoCreatePaymentModel.fromJson(data);
    } on Exception catch (e) {
      print('Error creating crypto payment: $e');
      rethrow;
    }
  }

  Future<Map> getCryptoConversionRate(
      {required String creditAccountId,
      required String currencyType,
      required String cryptoCurrency}) async {
    final prefs = await SharedPreferences.getInstance();
    final loginToken = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('language_code');
    String url;

    url =
        '${GlobalConstant.baseURL}/api/MyProfile/GetCrpWithdrawalAmountOnCrpRate?creditAccountId=$creditAccountId&CurrencyType=$currencyType&CryptoCurrency=$cryptoCurrency';

    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$loginToken',
      'UserId': '$userId',
      'Content-Type': 'application/json',
      'LanguageCode': langcode.toString(),
      'SiteCode': GlobalConstant.kAppCode,
    };

    print(headers);

    var response = await http
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    var data = json.decode(response.body);
    print(data);
    return data;
  }

  Future<CryptoCreatePaymentModel> updatePromoCode(
      {required String requestId,
      String? promoCode}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginToken = prefs.getString('LoginToken');
      final userId = prefs.getString('UserId');
      final langcode = prefs.getString('language_code');
      String url;
      if (promoCode != null && promoCode.isNotEmpty) {
        url =
            '${GlobalConstant.baseURL}/api/user/UpdatePromoCodeToPaymentTransaction?RequestId=$requestId&PromoCode=$promoCode';
      } else {
        url =
            '${GlobalConstant.baseURL}/api/user/UpdatePromoCodeToPaymentTransaction?RequestId=$requestId&PromoCode=';
      }

      final headers = <String, String>{
        'Accept': 'application/json',
        'Token': '$loginToken',
        'UserId': '$userId',
        'Content-Type': 'application/json',
        'LanguageCode': langcode.toString(),
        'SiteCode': GlobalConstant.kAppCode,
      };

      print(headers);

      var response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
      var data = json.decode(response.body);
      print(data);
      return CryptoCreatePaymentModel.fromJson(data);
    } on Exception catch (e) {
      print('Error creating crypto payment: $e');
      rethrow;
    }
  }
}
