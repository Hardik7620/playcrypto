import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/models/wallet.dart';
import '../constants/global_constant.dart';
import 'package:http/http.dart' as http;

import '../models/promo_bonus.dart';

class WalletRepository {
  static Future<List<Wallet>>
      getUserWalletTypeListWithBalance() async {
    String url =
        '${GlobalConstant.baseURL}/api/WalletType/GetUserWalletTypeListWithBalance';

    final sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('LoginToken');
    final userId = sharedPreferences.getString('UserId');

    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };

    return http
        .get(Uri.parse(url), headers: headers)
        .then((response) {
      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body) ?? [];
        return list.map((e) => Wallet.fromJson(e)).toList();
      } else {
        return Future.error(response);
      }
    });
  }

  static Future<String> saveUserCreditAccountWalletType(
      String walletTypeId) async {
    String url =
        "${GlobalConstant.baseURL}/api/WalletType/SaveUserCreditAccountWalletType?WalletTypeId=$walletTypeId";
    final sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('LoginToken');
    final userId = sharedPreferences.getString('UserId');

    final headers = {
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };
    return http
        .get(Uri.parse(url), headers: headers)
        .then((response) {
      if (response.statusCode == 200) {
        Map res = json.decode(response.body);
        return res['Result'];
      } else {
        return "false";
      }
    });
  }
// forgot password pcode

  static Future<List<PromoBonus>>
      getPendingDepositBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('Locale');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/WalletType/GetPendingDepositBonus?CreditAccountId=${GlobalConstant.userWallet.creditAccountId}';

    final response =
        await http.get(Uri.parse(url), headers: headers);
    try {
      Iterable data = json.decode(response.body);
      return data
          .map((e) => PromoBonus.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> claimDepositBonusAmount(
      int paymentTransactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final langcode = prefs.getString('Locale');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'LanguageCode': '$langcode',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/WalletType/ClaimDepositBonusAmount?PaymentTransactionId=$paymentTransactionId';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    try {
      Map data = json.decode(response.body);
      return data.containsKey("Result") &&
          data["Result"] is String &&
          data["Result"] == "Success";
    } catch (e) {
      return false;
    }
  }

  static Future<bool> transferAmountToRealMoneyWallet(
      String creditAccountId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('LoginToken');
    final userId = prefs.getString('UserId');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Token': '$token',
      'UserId': '$userId',
      'SiteCode': GlobalConstant.kAppCode,
    };
    String url =
        '${GlobalConstant.baseURL}/api/WalletType/TransferAmountToRealMoneyWallet?CreditAccountId=$creditAccountId';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    try {
      Map data = json.decode(response.body);
      return data.containsKey("Result") &&
          data["Result"] is String &&
          data["Result"] == "Success";
    } catch (e) {
      return false;
    }
  }
}
