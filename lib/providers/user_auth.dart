import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playcrypto365/providers/vip_info_provider.dart';
import 'package:playcrypto365/providers/wallet_provider.dart';
// import rest api service from lib/services/rest_api_service.dart
import 'package:playcrypto365/services/rest_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/utils/extensions.dart';
import '../providers/language_provider.dart';

class UserAuthProvider with ChangeNotifier {
  String _token = '';
  String _userId = '';
  Future<StatusModel> userLoginProvider(
      BuildContext context,
      String email,
      String password) async {
    StatusModel statusModel = StatusModel();
    RestApiService restApiService = RestApiService();
    final response = await restApiService.userLoginService(
        email, password);
    final responseData = json.decode(response.toString());
    if (responseData['error'] != null) {
      return statusModel
          .errorMessage(responseData['error']['message']);
    }
    if (responseData['LoginToken'] != null) {
      _token = responseData['LoginToken'];
      _userId = responseData['UserId'];
      // store data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('LoginToken', _token);
      await prefs.setString('UserId', _userId);
      // Store login input correctly based on type
      if (email.contains('@')) {
        await prefs.setString('email', email);
        await prefs.setBool('is_email_verified', true);
      } else {
        await prefs.setString('mobileNumber', email);
        await prefs.setBool('is_mobile_verified', true);
      }
      await prefs.setString(
          'UserName', responseData['UserName']);

      notifyListeners();
      FirebaseMessaging.instance.getToken().then((value) {
        RestApiService()
            .updateFCMTokenIfNecessary(value ?? "");
      });
      return statusModel.successMessage('Login Successful',
          '1', responseData['LoginToken']);
    }
    return statusModel.errorMessage(
        Provider.of<LanguageProvider>(context,
                listen: false)
            .getString("account", "loginfailed"));
  }

  //  get user balance
  Future<StatusModel> getUserBalance() async {
    StatusModel statusModel = StatusModel();

    // check if token exist in shared prefernces
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    if (prefs.getString('LoginToken') != null) {
      _token = prefs.getString('LoginToken')!;
      _userId = prefs.getString('UserId')!;
    } else {
      statusModel.ErrorMessage = 'Please login first';
      statusModel.ErrorCode = '0';
      return statusModel;
    }

    RestApiService restApiService = RestApiService();
    final response = await restApiService.getUserBalance();
    try {
      final responseData = json.decode(response.toString());
      if (responseData['ErrorCode'] != null) {
        if (responseData['ErrorCode'] == '1') {
          // notifyListeners()
          if (GlobalConstant.userWallet.balance !=
              (double.tryParse(responseData["Balance"]) ??
                  0.0)) {
            // ... comparison logic ...
          }
          GlobalConstant.userWallet.currencyType =
              responseData["CurrencyType"].toString();
          GlobalConstant.userWallet.balance =
              responseData["Balance"];
          return statusModel.successMessageResult(
              prefs.getString('UserName'),
              responseData['Balance'].toString());
        } else if (responseData['ErrorCode'] == '401' ||
            responseData['ErrorCode'] == 401) {
          // Session expired/Invalid token
          await logout();
          return statusModel.errorMessage(
              responseData['ErrorMessage'] ??
                  'Session expired. Please login again.');
        } else {
          // Other business error, don't logout
          return statusModel.errorMessage(
              responseData['ErrorMessage'] ??
                  'Failed to update balance');
        }
      }
    } catch (e) {
      debugPrint('Error parsing balance response: $e');
      // Network error or malformed JSON - DO NOT LOGOUT
      return statusModel.errorMessage(
          'Network error: Unable to fetch balance');
    }
    return statusModel.errorMessage('Something went wrong');
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    if (prefs.getString('LoginToken') != null) {
      return true;
    } else {
      return false;
    }
  }

  // logout user
  Future<void> logout() async {
    GlobalConstant.referEarningCreditAccountId = "";
    GlobalConstant.realMoneyCreditAccountId = "";
    GlobalConstant.referPlayCreditAccountId = "";
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    if (GetIt.I.isRegistered<VIPInfoProvider>()) {
      VIPInfoProvider vipInfoProvider =
          GetIt.I.get<VIPInfoProvider>();
      GlobalConstant.userWallet.code =
          GlobalConstant.realMoneyWalletCode;
      GetIt.I.unregister<VIPInfoProvider>(
        instance: vipInfoProvider,
        disposingFunction: vipInfoProvider.dispose,
      );
    }

    if (GetIt.I.isRegistered<WalletProvider>()) {
      final walletProvider = GetIt.I<WalletProvider>();
      walletProvider.reset();
      GetIt.I.unregister<WalletProvider>();
    }

    // var langId2 = prefs.getString('Locale');
    // var refUsed = prefs.getBool('refUsed') ?? false;
    // var rewardsSeen = prefs.containsKey('rewardsSeen');

    RestApiService.respCache.clear();

    // Selective cleanup to preserve language/site settings
    final keysToRemove = [
      'LoginToken',
      'UserId',
      'UserName',
      'email',
      'mobileNumber',
      'IsOtpLogin',
      'otp_login_method',
      'otp_verified_value',
      'is_email_verified',
      'is_mobile_verified'
    ];

    for (var key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  Future<void> notify() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    notifyListeners();
  }
  // create getter with notifire
}

class UserAuth {
  late String email;
  late String userId;
  late String userName;
  late String fName;
  late String lName;
  late String dateOfBirth;
  late String mobile;
  late String loginToken;
  late String statusId;
  late String referralCode;
  late String result;
  late String errorMessage;
  late String errorCode;

  UserAuth(
      {required this.email,
      required this.userId,
      required this.userName,
      required this.fName,
      required this.lName,
      required this.dateOfBirth,
      required this.mobile,
      required this.loginToken,
      required this.statusId,
      required this.referralCode,
      required this.result,
      required this.errorMessage,
      required this.errorCode});
}
