import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/providers/user_auth.dart';
import 'package:playcrypto365/utils/extensions/context_extensions.dart';
import '../models/wallet.dart';
import '../services/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  List<Wallet> wallets = [];
  String currentWalletCode =
      ""; //GlobalConstant.realMoneyWalletCode;
  Wallet? realMoneyWallet, referEarnWallet, referPlayWallet;

  Future<void> setNewWallet(Wallet wallet) async {
    final Wallet referPlayWallet = wallets.firstWhere(
        (w) => w.code == "RP${wallet.code!.substring(2)}");
    final Wallet referEarnWallet = wallets.firstWhere(
        (w) => w.code == "RE${wallet.code!.substring(2)}");
    GlobalConstant.userWallet = wallet;
    GlobalConstant.realMoneyWalletCode = wallet.code!;
    GlobalConstant.referWalletCode =
        "RP${wallet.code!.substring(2)}";
    GlobalConstant.realMoneyCreditAccountId =
        wallet.creditAccountId!;
    GlobalConstant.referEarningCreditAccountId =
        referEarnWallet.creditAccountId!;
    GlobalConstant.referPlayCreditAccountId =
        referPlayWallet.creditAccountId!;

    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    prefs.setString('userWallet',
        json.encode(GlobalConstant.userWallet.toJson()));
    await saveSelectedWalletType(wallet.walletTypeId);

    notifyListeners();
  }

  Future<List<Wallet>> fetchWallets(
      BuildContext context) async {
    try {
      print(
          "fetchWallets -> currentWalletCode: ${currentWalletCode}");
      var response = await WalletRepository
          .getUserWalletTypeListWithBalance();
      wallets.clear();
      // Sort wallets: Fiat wallets first, then by walletTypeId
      // response.sort((a, b) {
      //   if (a.crpCurrencyType == 'Fiat' && b.crpCurrencyType != 'Fiat') return -1;
      //   if (a.crpCurrencyType != 'Fiat' && b.crpCurrencyType == 'Fiat') return 1;
      //   return a.walletTypeId.compareTo(b.walletTypeId);
      // });
      wallets.addAll(response);
      // if (wallets.any((wallet) => wallet.code == "RMINR")) {
      //   realMoneyWallet = wallets.firstWhere((wallet) => wallet.code == "RMINR");
      //   GlobalConstant.realMoneyCreditAccountId = realMoneyWallet!.creditAccountId!;
      //   notifyListeners();
      // }
      // if (wallets.any((wallet) => wallet.code == "REINR")) {
      //   referEarnWallet = wallets.firstWhere((wallet) => wallet.code == "REINR");
      //   GlobalConstant.referEarningCreditAccountId = referEarnWallet!.creditAccountId!;
      //   print("referEarnWallet ${referEarnWallet!.balance}");
      // }
      // if (wallets.any((wallet) => wallet.code == "RPINR")) {
      //   referPlayWallet = wallets.firstWhere((wallet) => wallet.code == "RPINR");
      //   GlobalConstant.referPlayCreditAccountId = referPlayWallet!.creditAccountId!;
      //   print("referPlayWallet ${referPlayWallet!.balance}");
      // }

      // Fiat RealMoney

      // GlobalConstant.userWallet.currencyType = wallets.firstWhere((wallet) => wallet.name== "Real Money" && wallet.crpCurrencyType =="Fiat").currencyType;

      if (GlobalConstant.userWallet.name !=
          "Referal Play") {
        if (currentWalletCode == "") {
          final match = wallets.where((wallet) =>
              wallet.name == "Real Money" &&
              wallet.crpCurrencyType == "Fiat");
          if (match.isNotEmpty) {
            GlobalConstant.userWallet = match.first;
          }
        } else {
          print(
              "currentWalletCode in else: ${currentWalletCode}");
          final match = wallets.where((wallet) =>
              wallet.name == "Real Money" &&
              wallet.crpCurrencyType == "Fiat" &&
              wallet.code == currentWalletCode);
          if (match.isNotEmpty) {
            GlobalConstant.userWallet = match.first;
          }
        }
      }

      if (wallets.any((wallet) =>
          wallet.code ==
          "RM${GlobalConstant.userWallet.currencyType}")) {
        realMoneyWallet = wallets.firstWhere((wallet) =>
            wallet.code ==
            "RM${GlobalConstant.userWallet.currencyType}");
        GlobalConstant.realMoneyCreditAccountId =
            realMoneyWallet!.creditAccountId!;
        notifyListeners();
      }

      if (wallets.any((wallet) =>
          wallet.code ==
          "RE${GlobalConstant.userWallet.currencyType}")) {
        referEarnWallet = wallets.firstWhere((wallet) =>
            wallet.code ==
            "RE${GlobalConstant.userWallet.currencyType}");
        GlobalConstant.referEarningCreditAccountId =
            referEarnWallet!.creditAccountId!;
        print(
            "referEarnWallet ${referEarnWallet!.balance}");
      }

      if (wallets.any((wallet) =>
          wallet.code ==
          "RP${GlobalConstant.userWallet.currencyType}")) {
        referPlayWallet = wallets.firstWhere((wallet) =>
            wallet.code ==
            "RP${GlobalConstant.userWallet.currencyType}");
        GlobalConstant.referPlayCreditAccountId =
            referPlayWallet!.creditAccountId!;
        print(
            "referPlayWallet ${referPlayWallet!.balance}");
      }

      notifyListeners();
      if (response.any((wallet) =>
          wallet.code == GlobalConstant.referWalletCode)) {
        GlobalConstant.referWalletEnabled = true;
      } else {
        GlobalConstant.referWalletEnabled = false;
      }
      notifyListeners();
      return response;
    } catch (e) {
      print(e);
      wallets.clear();
      GlobalConstant.userWallet.code =
          GlobalConstant.realMoneyWalletCode;
      currentWalletCode =
          GlobalConstant.realMoneyWalletCode;
      Provider.of<UserAuthProvider>(context, listen: false)
          .logout();
      Provider.of<UserAuthProvider>(context, listen: false)
          .notify();
      notifyListeners();
      return [];
    }
  }

  setCurrentWalletCode(String code) {
    currentWalletCode = code;
    notifyListeners();
  }

  Future<String> saveSelectedWalletType(
      int walletTypeId) async {
    var response = await WalletRepository
        .saveUserCreditAccountWalletType(
            walletTypeId.toString());
    return response;
  }

  Future switchWallet(
      BuildContext context, String walletCode) async {
    print(
        '🔄 [switchWallet] Started with walletCode: $walletCode');

    try {
      // Step 1: Show loader
      context.showLogoDesignLoading();
      print('🟢 [switchWallet] Loading indicator shown');

      // Step 2: Check if wallets are available
      print('📦 [switchWallet] Checking wallet list...');
      if (wallets.isEmpty) {
        print(
            '⚠️ [switchWallet] Wallet list empty — fetching from server...');
        wallets = await fetchWallets(context);
        print(
            '✅ [switchWallet] Wallets fetched: ${wallets.length}');
      } else {
        print(
            '💼 [switchWallet] Using existing wallets: ${wallets.length}');
      }

      // Step 3: Find target wallet
      print(
          '🔍 [switchWallet] Searching for wallet with code: $walletCode');
      final switchingWallet = wallets.firstWhere(
        (wallet) => wallet.code == walletCode,
        orElse: () {
          print(
              '❌ [switchWallet] Wallet not found for code: $walletCode');
          throw Exception('Wallet not found');
        },
      );

      print(
          '✅ [switchWallet] Found wallet: ${switchingWallet.code}');
      print(
          '💰 [switchWallet] Wallet balance: ${switchingWallet.balance}');
      print(
          '💱 [switchWallet] Wallet currency: ${switchingWallet.currencyType}');
      print(
          '🏦 [switchWallet] Wallet type ID: ${switchingWallet.walletTypeId}');
      print(
          '🏦 [switchWallet] Wallet creditAccountId: ${switchingWallet.creditAccountId}');

      // Step 4: Save wallet type
      print(
          '💾 [switchWallet] Saving selected wallet type...');
      await saveSelectedWalletType(
          switchingWallet.walletTypeId);
      print(
          '✅ [switchWallet] Wallet type saved successfully');

      // Step 5: Update global wallet reference
      GlobalConstant.userWallet = switchingWallet;
      print(
          '🌍 [switchWallet] GlobalConstant.userWallet updated');

      // Step 6: Save wallet to SharedPreferences
      print(
          '🗂️ [switchWallet] Saving wallet data locally...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userWallet',
          json.encode(GlobalConstant.userWallet.toJson()));
      print(
          '✅ [switchWallet] Wallet data saved to SharedPreferences');

      // Step 7: Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      print(
          '🚪 [switchWallet] Loading indicator dismissed');

      // Step 8: Update current wallet code and notify UI
      currentWalletCode = walletCode;
      print(
          '🔁 [switchWallet] currentWalletCode updated: $currentWalletCode');
      notifyListeners();
      print('📣 [switchWallet] Listeners notified');

      print('✅ [switchWallet] Completed successfully');
    } catch (e, stack) {
      Navigator.of(context, rootNavigator: true).pop();
      print('❌ [switchWallet] ERROR: $e');
      print('📜 Stack trace:\n$stack');
    }
  }

  notify() {
    notifyListeners();
  }

  void reset() {
    wallets.clear();
    currentWalletCode = "";
    notifyListeners();
  }
}
