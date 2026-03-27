import 'package:flutter/material.dart';
import 'package:playcrypto365/models/wallet.dart';


class GlobalConstant {
  static const bool isLive = false; // Toggle this for Staging vs Production

  // Web URL
  static const String webURL = isLive
      ? 'https://playcrypto365.com'
      : 'https://feature-uat.playcrypto365-com.pages.dev';

  // Base API URL
  static const String baseURL = isLive
      ? 'https://userapi.coinbet91.com'
      : 'https://useruatapi.coinbet91.com';
  static const String kResourceUrl =
      'https://cdn.coinbet91.com';
  static const String appUrl =
      'https://main.playcrypto365-com.pages.dev/';
  static const String uatBaseUrl =
      'https://main.playcrypto365-com.pages.dev/';
  static const double kWebVersion = 26.2;
  static const String kAppVersion = "27";
  static String kAppCode = 'P65';
  static const String kBNAppCode = 'WBJ';
  static const String kINAppCode = 'WBI';
  static const bool kIsAppAvailable = true;
  static const Color kBotomNavigation =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kPrimaryColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kAppTopBarColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kAppAltTopBarColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kPrimaryButtonColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kTabButtonColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kTabActiveButtonColor =
      Color.fromARGB(255, 255, 205, 8);
  static const Color kTabButtonTextColor =
      Color.fromARGB(255, 255, 255, 255);
  static const Color kTabButtonActiveTextColor =
      Color.fromARGB(255, 255, 255, 255);
  static const Color kBrandTabIconColor =
      Color.fromARGB(255, 255, 255, 255);
  static const Color kGameTabIconColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kGameTabIconTextColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kGameTabIconBorderColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kTableTabTitleColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kModalBottomSheetIconColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kModalBottomSheetIconTextColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kWithdrawButtonColor =
      Color.fromARGB(255, 56, 9, 76);
  static const Color kWithdrawActiveButtonColor =
      Color(0xFFFFC107);
  static const Color kSuccessColor = Color(0xFF13C830);
  static const Color kDangerColor = Color(0xFFFC2D2D);

  // static const Color kTabButtonTextColor = Color.fromARGB(255, 255, 255, 255);

  static const String kAppLogo =
      'assets/images/logo_small_bc.png';
  // static const String kAppLogo = 'assets/images/logo.png';

  static const String kVIPLogo =
      "https://cdn-icons-png.flaticon.com/512/6941/6941697.png";
  static const String kSquareAppIcon =
      'assets/images/winbajiadicon.jpg';
  static const String kAppShortName = "Playcrypto";
  static const String kAppName =
      'Playcrypto365 - Live Online Sports Betting – Live Casino games in Bangla - Gambling for Real Money';
  static const String kClientSiteUrl = 'PlayCrypto365.com';


  static int lastPlayedGameCode = -1;
  static String appDownloadUrl = isLive
      ? "https://download.playcrypto365.com/playcrypto365_v1.apk"
      : "https://download.playcrypto365.com/playcrypto365_uat_v1.apk";
  static String appLanguage = 'en';
  static Wallet userWallet = Wallet(
    creditAccountId: "",
    walletTypeId: -1,
    name: "Real Money",
    code: "RMINR",
    currencySymbol: 2547,
    currencyType: "INR",
    balance: 0.0,
    crpCurrencyType: "Fiat",
    imageUrl:
        "https://cdn-icons-png.flaticon.com/512/10613/10613138.png",
  );

  static String referWalletCode = "RPINR";
  static int? WallettypeID;
  static String realMoneyWalletCode = "RMINR";
  static String realMoneyCreditAccountId = "";
  static String referPlayCreditAccountId = "";
  static String referEarningCreditAccountId = "";
  static bool referWalletEnabled = false;
  static String refKey = "";
  static double lastRealMoneyBalance = 0.0;

  static String get currentAppUrl {
    if (baseURL.contains("uat")) {
      return uatBaseUrl;
    } else {
      return baseURL;
    }
  }
}
