import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/models/user.dart';
import 'package:playcrypto365/services/rest_api_service.dart';
import '../models/vip_configurations.dart';
import '../models/wallet.dart';

class VIPInfoProvider {
  //* Instance variables
  bool isInitialized = false;
  String? userId;
  String? userSegmentId;
  String? currentVIPTemplateID;
  VIPConfigurations? configurations;
  User? user;
  int _fetchTries = 0;
  Map<String, dynamic> cache = {};

  bool get shouldInitialize {
    return GlobalConstant.userWallet.code !=
        GlobalConstant.referWalletCode;
  }

  //* Instance methods
  Future<bool> initialize() async {
    print('going inside initialize $shouldInitialize');
    // if (!shouldInitialize) {
    //   currentVIPTemplateID = null;
    //   configurations = null;
    //   return false;
    // }
    try {
      var restAPIService = RestApiService();
      SharedPreferences preferences =
          await SharedPreferences.getInstance();
      if (GlobalConstant.userWallet.creditAccountId == "") {
        if (preferences.containsKey('userWallet')) {
          GlobalConstant.userWallet = Wallet.fromJson(
              json.decode(
                  preferences.getString("userWallet")!));
          if (GlobalConstant.userWallet.code ==
              GlobalConstant.referWalletCode) {
            return false;
          }
        } else {
          return false;
        }
      }
      if (!preferences.containsKey('LoginToken')) {
        return false;
      }
      print('after token check');
      user = await restAPIService.getUserDetail();
      if (user?.vipTemplateId != null &&
          user?.vipTemplateId != 0) {
        configurations = await restAPIService
            .fetchVIPTemplateInfo(user!.vipTemplateId!);
        isInitialized = true;
        await refreshProgress(false);
      }
      return isInitialized;
    } catch (e) {
      // Don't retry on backend data errors (e.g. DateTime cast failures)
      final errorStr = e.toString();
      if (errorStr.contains('System.DateTime') ||
          errorStr.contains('Result') ||
          errorStr.contains('Failed')) {
        print(
            'VIP initialize — backend data error, not retrying: $errorStr');
        isInitialized = false;
        return isInitialized;
      }
      // Only retry on network/timeout errors
      _fetchTries++;
      if (_fetchTries <= 3) {
        print('here initialize retry $_fetchTries');
        return await initialize();
      }
      print(
          'here initialize — giving up after $_fetchTries tries');
      isInitialized = false;
      print(e);
      return isInitialized;
    }
  }

  Future refreshProgress([bool fromCache = false]) async {
    try {
      if (!isInitialized) return;
      var restAPIService = RestApiService();
      if (configurations == null) {
        await initialize();
      } else {
        if (fromCache && cache['progress'] != null) {
          configurations!.progress = cache['progress'];
          return;
        }
        configurations!.progress =
            await restAPIService.getUserProgress();
        cache['progress'] = configurations!.progress;
      }
    } catch (e) {
      print('here refreshProgress');
      print(e);
    }
  }

  Future getUserBonusDetails(
      [bool fromCache = true]) async {
    try {
      if (!isInitialized) return;
      if (configurations == null) {
        await initialize();
      } else {
        configurations!.bonusDetails =
            await RestApiService()
                .getVIPBonusDetails(fromCache);
      }
    } catch (e) {
      print('here getUserBonusDetails');
      print(e);
    }
  }

  void dispose(VIPInfoProvider provider) {
    isInitialized = false;
  }
}
