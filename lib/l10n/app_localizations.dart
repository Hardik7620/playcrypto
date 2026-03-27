import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('be'),
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('te')
  ];

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'SignUp'**
  String get join;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @casino.
  ///
  /// In en, this message translates to:
  /// **'Casino'**
  String get casino;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @poker.
  ///
  /// In en, this message translates to:
  /// **'Poker'**
  String get poker;

  /// No description provided for @esport.
  ///
  /// In en, this message translates to:
  /// **'E-Sport'**
  String get esport;

  /// No description provided for @roulette.
  ///
  /// In en, this message translates to:
  /// **'Roulette'**
  String get roulette;

  /// No description provided for @tablegame.
  ///
  /// In en, this message translates to:
  /// **'Table Game'**
  String get tablegame;

  /// No description provided for @teenpatti.
  ///
  /// In en, this message translates to:
  /// **'Teen Patti'**
  String get teenpatti;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slots'**
  String get slot;

  /// No description provided for @tabelgame.
  ///
  /// In en, this message translates to:
  /// **'Table game'**
  String get tabelgame;

  /// No description provided for @lottery.
  ///
  /// In en, this message translates to:
  /// **'Lottery'**
  String get lottery;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @availablepromotions.
  ///
  /// In en, this message translates to:
  /// **'Available Promotions'**
  String get availablepromotions;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'menu'**
  String get menu;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search for Games'**
  String get search;

  /// No description provided for @mobilenumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number (eg. 018XXXXXXXX)'**
  String get mobilenumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @cretaeaaccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE AN ACCOUNT'**
  String get cretaeaaccount;

  /// No description provided for @forgotpassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotpassword;

  /// No description provided for @letssignyouin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Sign You In'**
  String get letssignyouin;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createyouraccounr.
  ///
  /// In en, this message translates to:
  /// **'Create Your Free Account'**
  String get createyouraccounr;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get username;

  /// No description provided for @firstname.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstname;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullname;

  /// No description provided for @lastname.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastname;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get create;

  /// No description provided for @dateofbirth.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dateofbirth;

  /// No description provided for @invalidmobilenumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Mobile Number'**
  String get invalidmobilenumber;

  /// No description provided for @pleaseprovidepassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide password'**
  String get pleaseprovidepassword;

  /// No description provided for @invalidOTP.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOTP;

  /// No description provided for @providefirstname.
  ///
  /// In en, this message translates to:
  /// **'Provide first name'**
  String get providefirstname;

  /// No description provided for @providelasttname.
  ///
  /// In en, this message translates to:
  /// **'Provide last name'**
  String get providelasttname;

  /// No description provided for @passwordshould6characters.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters'**
  String get passwordshould6characters;

  /// No description provided for @dateofbirthcannotbeinfuture.
  ///
  /// In en, this message translates to:
  /// **'Date of birth cannot be in the future'**
  String get dateofbirthcannotbeinfuture;

  /// No description provided for @selectdateofbirth.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get selectdateofbirth;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOTP;

  /// No description provided for @resetyourpassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your Password'**
  String get resetyourpassword;

  /// No description provided for @changepassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changepassword;

  /// No description provided for @newpassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newpassword;

  /// No description provided for @livechat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get livechat;

  /// No description provided for @chatwithoursupportteam.
  ///
  /// In en, this message translates to:
  /// **'Chat with our support team'**
  String get chatwithoursupportteam;

  /// No description provided for @whatsaap.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get whatsaap;

  /// No description provided for @chatusingwhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat using whatsapp'**
  String get chatusingwhatsapp;

  /// No description provided for @callback.
  ///
  /// In en, this message translates to:
  /// **'Callback'**
  String get callback;

  /// No description provided for @requestacallback.
  ///
  /// In en, this message translates to:
  /// **'Request a call back?'**
  String get requestacallback;

  /// No description provided for @loginrequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginrequired;

  /// No description provided for @makearequestcallback.
  ///
  /// In en, this message translates to:
  /// **'Make a request for callback'**
  String get makearequestcallback;

  /// No description provided for @termcondition.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termcondition;

  /// No description provided for @readourterms.
  ///
  /// In en, this message translates to:
  /// **'Read our terms & conditions'**
  String get readourterms;

  /// No description provided for @adddepositinyourwallet.
  ///
  /// In en, this message translates to:
  /// **'Add deposit in your wallet'**
  String get adddepositinyourwallet;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @makearequestforwithdraw.
  ///
  /// In en, this message translates to:
  /// **'Make a request for withdraw'**
  String get makearequestforwithdraw;

  /// No description provided for @statement_title.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statement_title;

  /// No description provided for @viewyourstatement.
  ///
  /// In en, this message translates to:
  /// **'View your statement'**
  String get viewyourstatement;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @viewyourdetails.
  ///
  /// In en, this message translates to:
  /// **'View your details'**
  String get viewyourdetails;

  /// No description provided for @whatsappisnotinstalledonthedevice.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed on the device'**
  String get whatsappisnotinstalledonthedevice;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes!'**
  String get yes;

  /// No description provided for @addmoneytoyourwallet.
  ///
  /// In en, this message translates to:
  /// **'Add money to your wallet'**
  String get addmoneytoyourwallet;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get amount;

  /// No description provided for @invaliddepositamount.
  ///
  /// In en, this message translates to:
  /// **'Invalid deposit amount'**
  String get invaliddepositamount;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @descriptioncopied.
  ///
  /// In en, this message translates to:
  /// **'Description copied'**
  String get descriptioncopied;

  /// No description provided for @userstatement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get userstatement;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @loadmore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadmore;

  /// No description provided for @myaccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myaccount;

  /// No description provided for @withdrawaldetails.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Status'**
  String get withdrawaldetails;

  /// No description provided for @bankdetail.
  ///
  /// In en, this message translates to:
  /// **'Wallet details'**
  String get bankdetail;

  /// No description provided for @withdrawalstatus.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Status'**
  String get withdrawalstatus;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @datetime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get datetime;

  /// No description provided for @crypto_statement.
  ///
  /// In en, this message translates to:
  /// **'Crypto Statement'**
  String get crypto_statement;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @bankaccountholdername.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get bankaccountholdername;

  /// No description provided for @invalidname.
  ///
  /// In en, this message translates to:
  /// **'Invalid name'**
  String get invalidname;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @bankaccountnumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get bankaccountnumber;

  /// No description provided for @invalidaccountnumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Account Number'**
  String get invalidaccountnumber;

  /// No description provided for @bankname.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get bankname;

  /// No description provided for @invalidbankname.
  ///
  /// In en, this message translates to:
  /// **'Invalid Wallet name'**
  String get invalidbankname;

  /// No description provided for @invalidamount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidamount;

  /// No description provided for @opps.
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get opps;

  /// No description provided for @invalidcredential.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get invalidcredential;

  /// No description provided for @comingsoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon !'**
  String get comingsoon;

  /// No description provided for @loginfailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginfailed;

  /// No description provided for @loginsuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginsuccessful;

  /// No description provided for @pleaseloginfirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get pleaseloginfirst;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get back;

  /// No description provided for @livedealer.
  ///
  /// In en, this message translates to:
  /// **'Live Dealer'**
  String get livedealer;

  /// No description provided for @mostpopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostpopular;

  /// No description provided for @baccarat.
  ///
  /// In en, this message translates to:
  /// **'Baccarat'**
  String get baccarat;

  /// No description provided for @blackjack.
  ///
  /// In en, this message translates to:
  /// **'Blackjack'**
  String get blackjack;

  /// No description provided for @liveroulette.
  ///
  /// In en, this message translates to:
  /// **'Live Roulette'**
  String get liveroulette;

  /// No description provided for @topindiangames.
  ///
  /// In en, this message translates to:
  /// **'Top Games'**
  String get topindiangames;

  /// No description provided for @wheellottery.
  ///
  /// In en, this message translates to:
  /// **'Wheel & Lottery'**
  String get wheellottery;

  /// No description provided for @youmayonlyperformthisactionevery30seconds.
  ///
  /// In en, this message translates to:
  /// **'You may only perform this action every 30 seconds.'**
  String get youmayonlyperformthisactionevery30seconds;

  /// No description provided for @refCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get refCode;

  /// No description provided for @registration_completed.
  ///
  /// In en, this message translates to:
  /// **'Registration Completed'**
  String get registration_completed;

  /// No description provided for @registration_successful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registration_successful;

  /// No description provided for @play_games.
  ///
  /// In en, this message translates to:
  /// **'Play Games'**
  String get play_games;

  /// No description provided for @update_available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get update_available;

  /// No description provided for @install_update.
  ///
  /// In en, this message translates to:
  /// **'New App update is available'**
  String get install_update;

  /// No description provided for @payment_info.
  ///
  /// In en, this message translates to:
  /// **'Payment information'**
  String get payment_info;

  /// No description provided for @payment_in_verification.
  ///
  /// In en, this message translates to:
  /// **'Your payment is in verification, and will update in your balance soon'**
  String get payment_in_verification;

  /// No description provided for @how_to_withdraw.
  ///
  /// In en, this message translates to:
  /// **'How to withdraw'**
  String get how_to_withdraw;

  /// No description provided for @how_to_deposit.
  ///
  /// In en, this message translates to:
  /// **'How to deposit'**
  String get how_to_deposit;

  /// No description provided for @downloadwinbajinow.
  ///
  /// In en, this message translates to:
  /// **'Download the Playcrypto365 app and get FREE Login Bonus Everyday!'**
  String get downloadwinbajinow;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @recent_games.
  ///
  /// In en, this message translates to:
  /// **'Recent Games'**
  String get recent_games;

  /// No description provided for @real_money.
  ///
  /// In en, this message translates to:
  /// **'Real money'**
  String get real_money;

  /// No description provided for @bonus_money.
  ///
  /// In en, this message translates to:
  /// **'Bonus money'**
  String get bonus_money;

  /// No description provided for @available_promotions.
  ///
  /// In en, this message translates to:
  /// **'Available Promotions'**
  String get available_promotions;

  /// No description provided for @deposit_more.
  ///
  /// In en, this message translates to:
  /// **'Deposit %a% more to avail the promotion'**
  String get deposit_more;

  /// No description provided for @follow_us.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get follow_us;

  /// No description provided for @our_blog.
  ///
  /// In en, this message translates to:
  /// **'Our blog'**
  String get our_blog;

  /// No description provided for @about_us.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get about_us;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_and_conditions;

  /// No description provided for @responsible_gaming.
  ///
  /// In en, this message translates to:
  /// **'Responsible Gaming'**
  String get responsible_gaming;

  /// No description provided for @bonuses_received.
  ///
  /// In en, this message translates to:
  /// **'Bonuses Received'**
  String get bonuses_received;

  /// No description provided for @received_on.
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get received_on;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Send only TRX to this deposit address. Transfer below 5 TRX will not be credited'**
  String get warning;

  /// No description provided for @claim_warning.
  ///
  /// In en, this message translates to:
  /// **'If you claim this bonus amount, you\'ll lose your old bonus amount, and the new one will take its place.'**
  String get claim_warning;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimed;

  /// No description provided for @bank_name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bank_name;

  /// No description provided for @bank_ifsc_code.
  ///
  /// In en, this message translates to:
  /// **'Bank IFSC Code'**
  String get bank_ifsc_code;

  /// No description provided for @invalid_bank_name.
  ///
  /// In en, this message translates to:
  /// **'Invalid Bank Name'**
  String get invalid_bank_name;

  /// No description provided for @enter_bank_ifsc_code.
  ///
  /// In en, this message translates to:
  /// **'Enter Bank IFSC Code'**
  String get enter_bank_ifsc_code;

  /// No description provided for @bank_branch_name.
  ///
  /// In en, this message translates to:
  /// **'Bank Branch Name'**
  String get bank_branch_name;

  /// No description provided for @invalid_bank_branch_name.
  ///
  /// In en, this message translates to:
  /// **'Invalid Branch Name'**
  String get invalid_bank_branch_name;

  /// No description provided for @transfer_money.
  ///
  /// In en, this message translates to:
  /// **'Transfer money'**
  String get transfer_money;

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile_number;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @transfer_first_bonus_money_warning.
  ///
  /// In en, this message translates to:
  /// **'To Withdraw Bonus Money you must first transfer it into Real Money wallet'**
  String get transfer_first_bonus_money_warning;

  /// No description provided for @select_wallet.
  ///
  /// In en, this message translates to:
  /// **'SELECT WALLET'**
  String get select_wallet;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @wallet_in_use.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get wallet_in_use;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @scratch_here.
  ///
  /// In en, this message translates to:
  /// **'Scratch Here!'**
  String get scratch_here;

  /// No description provided for @bonus_received.
  ///
  /// In en, this message translates to:
  /// **'Bonus Received'**
  String get bonus_received;

  /// No description provided for @select_real_wallet_first.
  ///
  /// In en, this message translates to:
  /// **'Please First Select a Real Money Wallet to deposit funds into.'**
  String get select_real_wallet_first;

  /// No description provided for @you_will_receive.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive'**
  String get you_will_receive;

  /// No description provided for @no_records_found.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get no_records_found;

  /// No description provided for @spinandwin.
  ///
  /// In en, this message translates to:
  /// **'Spin & Win'**
  String get spinandwin;

  /// No description provided for @claim_reward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get claim_reward;

  /// No description provided for @your_rewards.
  ///
  /// In en, this message translates to:
  /// **'Your Rewards'**
  String get your_rewards;

  /// No description provided for @spinning_wheel_desc.
  ///
  /// In en, this message translates to:
  /// **'Rewards from spinning wheel'**
  String get spinning_wheel_desc;

  /// No description provided for @scratch_cards.
  ///
  /// In en, this message translates to:
  /// **'Scratch Cards'**
  String get scratch_cards;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: '**
  String get remaining;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logout_confirmation;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @live_winner.
  ///
  /// In en, this message translates to:
  /// **'Live Winners'**
  String get live_winner;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @seconds_ago.
  ///
  /// In en, this message translates to:
  /// **'seconds ago'**
  String get seconds_ago;

  /// No description provided for @fun_wheel.
  ///
  /// In en, this message translates to:
  /// **'Fun Wheel'**
  String get fun_wheel;

  /// No description provided for @winners_list.
  ///
  /// In en, this message translates to:
  /// **'Winner\'s List'**
  String get winners_list;

  /// No description provided for @winning_records.
  ///
  /// In en, this message translates to:
  /// **'Winning Records'**
  String get winning_records;

  /// No description provided for @spin_wheel.
  ///
  /// In en, this message translates to:
  /// **'Spin Wheel'**
  String get spin_wheel;

  /// No description provided for @your_reward.
  ///
  /// In en, this message translates to:
  /// **'Your Reward'**
  String get your_reward;

  /// No description provided for @secs_ago.
  ///
  /// In en, this message translates to:
  /// **'secs ago'**
  String get secs_ago;

  /// No description provided for @win_scratch_card.
  ///
  /// In en, this message translates to:
  /// **'more to get an assured scratch card'**
  String get win_scratch_card;

  /// No description provided for @get_assured_scratch_card.
  ///
  /// In en, this message translates to:
  /// **'Win guaranteed cash reward from scratch card, between 1 tk and 99,999 tk.'**
  String get get_assured_scratch_card;

  /// No description provided for @add_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Add Bank Account'**
  String get add_bank_account;

  /// No description provided for @add_account.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get add_account;

  /// No description provided for @my_accounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get my_accounts;

  /// No description provided for @enroll_bank.
  ///
  /// In en, this message translates to:
  /// **'Enroll Bank'**
  String get enroll_bank;

  /// No description provided for @add_your_bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Add your bank accounts'**
  String get add_your_bank_accounts;

  /// No description provided for @vip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vip;

  /// No description provided for @vip_levels.
  ///
  /// In en, this message translates to:
  /// **'VIP levels'**
  String get vip_levels;

  /// No description provided for @vip_level.
  ///
  /// In en, this message translates to:
  /// **'VIP level'**
  String get vip_level;

  /// No description provided for @bet.
  ///
  /// In en, this message translates to:
  /// **'Bet'**
  String get bet;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @daily_bonus.
  ///
  /// In en, this message translates to:
  /// **'Daily Bonus'**
  String get daily_bonus;

  /// No description provided for @monthly_bonus.
  ///
  /// In en, this message translates to:
  /// **'Monthly Bonus'**
  String get monthly_bonus;

  /// No description provided for @weekly_bonus.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bonus'**
  String get weekly_bonus;

  /// No description provided for @upgrade_bonus.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Bonus'**
  String get upgrade_bonus;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pending_rollover.
  ///
  /// In en, this message translates to:
  /// **'Pending Rollover'**
  String get pending_rollover;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @pending_rollover_info.
  ///
  /// In en, this message translates to:
  /// **'Pending Turnover Info'**
  String get pending_rollover_info;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @rollover_details.
  ///
  /// In en, this message translates to:
  /// **'Rollover Details'**
  String get rollover_details;

  /// No description provided for @withdrawal_limit.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Limit'**
  String get withdrawal_limit;

  /// No description provided for @need_an_account.
  ///
  /// In en, this message translates to:
  /// **'You need to add an account before to withdraw money'**
  String get need_an_account;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @unqualified.
  ///
  /// In en, this message translates to:
  /// **'Unqualified'**
  String get unqualified;

  /// No description provided for @download_android_app.
  ///
  /// In en, this message translates to:
  /// **'To claim your rewards you need to download android app of Winbaji!'**
  String get download_android_app;

  /// No description provided for @daily_login_bonus_criteria_not_met.
  ///
  /// In en, this message translates to:
  /// **'Make sure to deposit %atk daily to ensure your Daily bonus'**
  String get daily_login_bonus_criteria_not_met;

  /// No description provided for @weekly_login_bonus_criteria_not_met.
  ///
  /// In en, this message translates to:
  /// **'Make daily deposits for %b days, adding up to %atk to receive you Weekly bonus!'**
  String get weekly_login_bonus_criteria_not_met;

  /// No description provided for @monthly_login_bonus_criteria_not_met.
  ///
  /// In en, this message translates to:
  /// **'Make daily deposits for %b days, adding up to %atk to receive you Monthly bonus!'**
  String get monthly_login_bonus_criteria_not_met;

  /// No description provided for @deposit_withdraw_issue.
  ///
  /// In en, this message translates to:
  /// **'Due to ongoing problems and the curfew in the country, your withdrawal will be delayed. We apologize for any inconvenience and expect to be back to normal very soon.'**
  String get deposit_withdraw_issue;

  /// No description provided for @expires_in.
  ///
  /// In en, this message translates to:
  /// **'Expires In'**
  String get expires_in;

  /// No description provided for @promotion_applied_successfully.
  ///
  /// In en, this message translates to:
  /// **'Promotion Applied Successfully'**
  String get promotion_applied_successfully;

  /// No description provided for @select_deposit_promotion.
  ///
  /// In en, this message translates to:
  /// **'Select Deposit Promotion'**
  String get select_deposit_promotion;

  /// No description provided for @promotion_not_available.
  ///
  /// In en, this message translates to:
  /// **'Promotion not available'**
  String get promotion_not_available;

  /// No description provided for @please_wait_for_withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Note: You can place your next withdrawal after the mentioned time.'**
  String get please_wait_for_withdrawal;

  /// No description provided for @better_luck_next_time.
  ///
  /// In en, this message translates to:
  /// **'Better Luck Next Time'**
  String get better_luck_next_time;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @minimum_deposit_amount_criteria_not_met.
  ///
  /// In en, this message translates to:
  /// **'Minimum deposit amount'**
  String get minimum_deposit_amount_criteria_not_met;

  /// No description provided for @deposit_details.
  ///
  /// In en, this message translates to:
  /// **'Deposit Details'**
  String get deposit_details;

  /// No description provided for @deposit_amount.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount'**
  String get deposit_amount;

  /// No description provided for @amount_bonus.
  ///
  /// In en, this message translates to:
  /// **'Amount Bonus'**
  String get amount_bonus;

  /// No description provided for @promotion_bonus.
  ///
  /// In en, this message translates to:
  /// **'Promotion Bonus'**
  String get promotion_bonus;

  /// No description provided for @rollover.
  ///
  /// In en, this message translates to:
  /// **'Rollover'**
  String get rollover;

  /// No description provided for @payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get payment_methods;

  /// No description provided for @total_with_bonuses.
  ///
  /// In en, this message translates to:
  /// **'Total with Bonuses'**
  String get total_with_bonuses;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @daily_bonus_pack_note.
  ///
  /// In en, this message translates to:
  /// **'Your deposit will be split into 50 Taka daily credits for {X} days. Missing a login means losing that day’s claim. Enjoy an extra few days of 50 Taka as a bonus!'**
  String daily_bonus_pack_note(Object X);

  /// No description provided for @for_x_days.
  ///
  /// In en, this message translates to:
  /// **'For {X} days'**
  String for_x_days(Object X);

  /// No description provided for @welcometo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcometo;

  /// No description provided for @scamalert.
  ///
  /// In en, this message translates to:
  /// **'Scam Alert : Dear Members, Please do not share your login credentials, payment receipt and OTP with anyone to ensure your account is secure. If you need assistance, contact us via livechat below right. '**
  String get scamalert;

  /// No description provided for @appdescription.
  ///
  /// In en, this message translates to:
  /// **'Live Online Sports Betting - Live Casino Games - Gambling for Real Money'**
  String get appdescription;

  /// No description provided for @turnover_games.
  ///
  /// In en, this message translates to:
  /// **'Turnover Games'**
  String get turnover_games;

  /// No description provided for @more_games.
  ///
  /// In en, this message translates to:
  /// **'More Games'**
  String get more_games;

  /// No description provided for @turnover_progress.
  ///
  /// In en, this message translates to:
  /// **'Your Turnover Progress'**
  String get turnover_progress;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @change_to.
  ///
  /// In en, this message translates to:
  /// **'Change to'**
  String get change_to;

  /// No description provided for @get_daily_login_bonus.
  ///
  /// In en, this message translates to:
  /// **'Get Daily Login Bonus'**
  String get get_daily_login_bonus;

  /// No description provided for @deposit_daily_to_ensure_next_daily_login_bonus.
  ///
  /// In en, this message translates to:
  /// **'Deposit daily to ensure next daily login bonus'**
  String get deposit_daily_to_ensure_next_daily_login_bonus;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @refer_now.
  ///
  /// In en, this message translates to:
  /// **'Refer Now'**
  String get refer_now;

  /// No description provided for @refer_and_earn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get refer_and_earn;

  /// No description provided for @primary_account_use_for_up_to_50000_secondary_wallets_for_withdrawals_above_50000_in_one_day.
  ///
  /// In en, this message translates to:
  /// **'Primary Account use for up to 25000\nSecondary wallets for withdrawals above 50000 in one day'**
  String
      get primary_account_use_for_up_to_50000_secondary_wallets_for_withdrawals_above_50000_in_one_day;

  /// No description provided for @enter_your_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get enter_your_phone_number;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get please_wait;

  /// No description provided for @send_code.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get send_code;

  /// No description provided for @please_enter_a_valid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get please_enter_a_valid_phone_number;

  /// No description provided for @please_enter_your_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get please_enter_your_phone_number;

  /// No description provided for @a_sixdigit_code_will_be_sent_to__your_phone_number.
  ///
  /// In en, this message translates to:
  /// **'A six-digit code will be sent to\n your phone number.'**
  String get a_sixdigit_code_will_be_sent_to__your_phone_number;

  /// No description provided for @add_new_wallet.
  ///
  /// In en, this message translates to:
  /// **'Add New Wallet'**
  String get add_new_wallet;

  /// No description provided for @edit_wallet.
  ///
  /// In en, this message translates to:
  /// **'Edit Wallet'**
  String get edit_wallet;

  /// No description provided for @add_new_edit_wallet.
  ///
  /// In en, this message translates to:
  /// **'Add New/Edit Wallet'**
  String get add_new_edit_wallet;

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resend_code;

  /// No description provided for @if_you_didnt_receive_a_code_.
  ///
  /// In en, this message translates to:
  /// **'If you didn’t receive a code?'**
  String get if_you_didnt_receive_a_code_;

  /// No description provided for @wallet_added_successfully.
  ///
  /// In en, this message translates to:
  /// **'Wallet Added Successfully'**
  String get wallet_added_successfully;

  /// No description provided for @referral_wallet.
  ///
  /// In en, this message translates to:
  /// **'REFERRAL WALLET'**
  String get referral_wallet;

  /// No description provided for @main_wallet.
  ///
  /// In en, this message translates to:
  /// **'MAIN WALLET'**
  String get main_wallet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @switch_to.
  ///
  /// In en, this message translates to:
  /// **'SWITCH TO'**
  String get switch_to;

  /// No description provided for @do_you_want_to_proceed_with_the_withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Do you want to proceed with the withdrawal?'**
  String get do_you_want_to_proceed_with_the_withdrawal;

  /// No description provided for @you_have_reached_the_maximum_withdrawal_limit_of.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum withdrawal limit of'**
  String get you_have_reached_the_maximum_withdrawal_limit_of;

  /// No description provided for @kindly_complete_turnover_before_proceeding_for_withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Kindly complete turnover before proceeding for withdrawal'**
  String get kindly_complete_turnover_before_proceeding_for_withdrawal;

  /// No description provided for @insufficient_balance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficient_balance;

  /// No description provided for @invalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get invalid_amount;

  /// No description provided for @withdraw_now.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Now'**
  String get withdraw_now;

  /// No description provided for @total_withdraw_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Withdraw Amount'**
  String get total_withdraw_amount;

  /// No description provided for @your_turnover_progress_.
  ///
  /// In en, this message translates to:
  /// **'Your turnover progress'**
  String get your_turnover_progress_;

  /// No description provided for @add_withdraw_amount.
  ///
  /// In en, this message translates to:
  /// **'Add Withdraw Amount'**
  String get add_withdraw_amount;

  /// No description provided for @account_balance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance:'**
  String get account_balance;

  /// No description provided for @primary_wallet.
  ///
  /// In en, this message translates to:
  /// **'Primary Wallet'**
  String get primary_wallet;

  /// No description provided for @secondary_wallet.
  ///
  /// In en, this message translates to:
  /// **'Secondary Wallet'**
  String get secondary_wallet;

  /// No description provided for @you_dont_have_any_back_accounts_added.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any back accounts added'**
  String get you_dont_have_any_back_accounts_added;

  /// No description provided for @select_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Select Bank Account:'**
  String get select_bank_account;

  /// No description provided for @add_more_bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Add more bank accounts'**
  String get add_more_bank_accounts;

  /// No description provided for @select_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method:'**
  String get select_payment_method;

  /// No description provided for @go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal.
  ///
  /// In en, this message translates to:
  /// **'1- Go to Referral wallet lobby\n2- Click on Refer & Earn tab\n3 - Click on Withdrawal button\n4- Select your withdrawal mode  - Select amount and withdrawal'**
  String
      get go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal;

  /// No description provided for @you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account.
  ///
  /// In en, this message translates to:
  /// **'You can withdrawal Referral Play Balance  after completing turnover completing in Referral wallet. Here is simple 5 stapes to withdrawal your Play balance in your bank account.'**
  String
      get you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account;

  /// No description provided for @after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account.
  ///
  /// In en, this message translates to:
  /// **'After transfer Live Referral earning balance to Referral play wallet you can use that balance for play games or withdrawal direct to your bank account.'**
  String
      get after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account;

  /// No description provided for @playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_.
  ///
  /// In en, this message translates to:
  /// **'Playing games using referral earning you have to transfer your live referral earning to referral play wallet using following transfer feature on '**
  String
      get playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_;

  /// No description provided for @referral_wallet_lobby_and_my_earning.
  ///
  /// In en, this message translates to:
  /// **'Referral Wallet Lobby & My Earning'**
  String get referral_wallet_lobby_and_my_earning;

  /// No description provided for @how_to_play_games_using_referral_earning.
  ///
  /// In en, this message translates to:
  /// **'How to Play Games Using Referral Earning?'**
  String get how_to_play_games_using_referral_earning;

  /// No description provided for @you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral.
  ///
  /// In en, this message translates to:
  /// **'You earn a % of the referee\'s ongoing deposit. including Direct Referral, Indirect Referral and Extended Referral'**
  String
      get you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral;

  /// No description provided for @how_referral_commission_works.
  ///
  /// In en, this message translates to:
  /// **'How Referral Commission Works?'**
  String get how_referral_commission_works;

  /// No description provided for @earn_life_time_commission_on_your_friends_every_deposit.
  ///
  /// In en, this message translates to:
  /// **'Earn life time commission on your friends every deposit'**
  String get earn_life_time_commission_on_your_friends_every_deposit;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @tap_to_copy.
  ///
  /// In en, this message translates to:
  /// **'Tap to Copy'**
  String get tap_to_copy;

  /// No description provided for @referral_code_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard'**
  String get referral_code_copied_to_clipboard;

  /// No description provided for @your_referral_link.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Link'**
  String get your_referral_link;

  /// No description provided for @refer_and_earn_unlimited_money.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn\nUnlimited Money'**
  String get refer_and_earn_unlimited_money;

  /// No description provided for @only_on_.
  ///
  /// In en, this message translates to:
  /// **'Only on'**
  String get only_on_;

  /// No description provided for @you_received.
  ///
  /// In en, this message translates to:
  /// **'You Received'**
  String get you_received;

  /// No description provided for @no_referrals_found.
  ///
  /// In en, this message translates to:
  /// **'No Referrals Found'**
  String get no_referrals_found;

  /// No description provided for @your_top_active_referrals.
  ///
  /// In en, this message translates to:
  /// **'Your top Active Referrals'**
  String get your_top_active_referrals;

  /// No description provided for @extended_referrals.
  ///
  /// In en, this message translates to:
  /// **'Extended\nReferrals'**
  String get extended_referrals;

  /// No description provided for @indirect_referrals.
  ///
  /// In en, this message translates to:
  /// **'Indirect\nReferrals'**
  String get indirect_referrals;

  /// No description provided for @direct_referrals.
  ///
  /// In en, this message translates to:
  /// **'Direct\nReferrals'**
  String get direct_referrals;

  /// No description provided for @totals_earning.
  ///
  /// In en, this message translates to:
  /// **'Total\'s Earning'**
  String get totals_earning;

  /// No description provided for @referral_earning.
  ///
  /// In en, this message translates to:
  /// **'Referral Earning'**
  String get referral_earning;

  /// No description provided for @referral_play_wallet.
  ///
  /// In en, this message translates to:
  /// **'REFERRAL PLAY WALLET'**
  String get referral_play_wallet;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @enter_a_valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enter_a_valid_amount;

  /// No description provided for @back_to_lobby.
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get back_to_lobby;

  /// No description provided for @successfully_transferred_to_your_play_wallet.
  ///
  /// In en, this message translates to:
  /// **'Successfully Transferred\nto your Play Wallet'**
  String get successfully_transferred_to_your_play_wallet;

  /// No description provided for @transfer_to_play_wallet.
  ///
  /// In en, this message translates to:
  /// **'Transfer To Play Wallet'**
  String get transfer_to_play_wallet;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @enter_amount_to_transfer_to_play_wallet.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to Transfer to Play Wallet'**
  String get enter_amount_to_transfer_to_play_wallet;

  /// No description provided for @get_unlimited_commission.
  ///
  /// In en, this message translates to:
  /// **'Get Unlimited Commission on your friend’s lifetime deposit!'**
  String get get_unlimited_commission;

  /// No description provided for @how_it_works.
  ///
  /// In en, this message translates to:
  /// **'HOW IT WORKS?'**
  String get how_it_works;

  /// No description provided for @switch_to_referral_wallet.
  ///
  /// In en, this message translates to:
  /// **'Switch to Referral Wallet'**
  String get switch_to_referral_wallet;

  /// No description provided for @login_now.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get login_now;

  /// No description provided for @withdraw_unlimited_referral_money_in_your_bank_with_play_games.
  ///
  /// In en, this message translates to:
  /// **'Withdraw unlimited referral money in your bank with Play Games!'**
  String get withdraw_unlimited_referral_money_in_your_bank_with_play_games;

  /// No description provided for @my_earning.
  ///
  /// In en, this message translates to:
  /// **'My Earning'**
  String get my_earning;

  /// No description provided for @description_copied.
  ///
  /// In en, this message translates to:
  /// **'Description copied'**
  String get description_copied;

  /// No description provided for @scratch_card.
  ///
  /// In en, this message translates to:
  /// **'Scratch Card'**
  String get scratch_card;

  /// No description provided for @total_rewards_claimed_.
  ///
  /// In en, this message translates to:
  /// **'Total Rewards Claimed: '**
  String get total_rewards_claimed_;

  /// No description provided for @in_bkash_or_nagad.
  ///
  /// In en, this message translates to:
  /// **'in BKash or Nagad'**
  String get in_bkash_or_nagad;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @and_fund_transfer.
  ///
  /// In en, this message translates to:
  /// **'& Fund Transfer'**
  String get and_fund_transfer;

  /// No description provided for @and_earn_cash.
  ///
  /// In en, this message translates to:
  /// **'& Earn Cash'**
  String get and_earn_cash;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @withdraw_history.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdraw_history;

  /// No description provided for @join_winbaji_and_earn_money_use_my_referral_code.
  ///
  /// In en, this message translates to:
  /// **'Join Playcrypto365 and earn money! Use my referral code'**
  String get join_winbaji_and_earn_money_use_my_referral_code;

  /// No description provided for @your_referral_earning_to_withdrawal_journey.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Earning To Withdrawal Journey'**
  String get your_referral_earning_to_withdrawal_journey;

  /// No description provided for @refer_to_friends.
  ///
  /// In en, this message translates to:
  /// **'Refer to Friends'**
  String get refer_to_friends;

  /// No description provided for @referral_earning_get_in_live_wallet.
  ///
  /// In en, this message translates to:
  /// **'Referral Earning Get In Live Wallet'**
  String get referral_earning_get_in_live_wallet;

  /// No description provided for @transfer_fund_to_play_wallet.
  ///
  /// In en, this message translates to:
  /// **'Transfer Fund To Play Wallet'**
  String get transfer_fund_to_play_wallet;

  /// No description provided for @complete_turnover.
  ///
  /// In en, this message translates to:
  /// **'Complete Turnover'**
  String get complete_turnover;

  /// No description provided for @withdraw_in_bkash_or_nagad.
  ///
  /// In en, this message translates to:
  /// **'Withdraw in crypto currency'**
  String get withdraw_in_bkash_or_nagad;

  /// No description provided for @refer_earn_and_win_cash.
  ///
  /// In en, this message translates to:
  /// **'REFER, EARN & WIN CASH'**
  String get refer_earn_and_win_cash;

  /// No description provided for @unlimited_commission_and_referral_cash_wallet.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Commission\n& Referral Cash Wallet'**
  String get unlimited_commission_and_referral_cash_wallet;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @rebate.
  ///
  /// In en, this message translates to:
  /// **'REBATE'**
  String get rebate;

  /// No description provided for @lossback.
  ///
  /// In en, this message translates to:
  /// **'FIGHTBACK'**
  String get lossback;

  /// No description provided for @total_bonus.
  ///
  /// In en, this message translates to:
  /// **'TOTAL BONUS'**
  String get total_bonus;

  /// No description provided for @claim_all.
  ///
  /// In en, this message translates to:
  /// **'CLAIM ALL'**
  String get claim_all;

  /// No description provided for @please_select_bank_account.
  ///
  /// In en, this message translates to:
  /// **'Please select a bank account'**
  String get please_select_bank_account;

  /// No description provided for @withdraw_verification.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Verification'**
  String get withdraw_verification;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code sent to\n your phone number '**
  String get enter_otp;

  /// No description provided for @brand_ambassdor.
  ///
  /// In en, this message translates to:
  /// **'Brand Ambassdor'**
  String get brand_ambassdor;

  /// No description provided for @watch_now.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watch_now;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalid_email;

  /// No description provided for @crypto_deposit.
  ///
  /// In en, this message translates to:
  /// **'Crypto Deposit'**
  String get crypto_deposit;

  /// No description provided for @select_crypto_coin.
  ///
  /// In en, this message translates to:
  /// **'Select Crypto Coin'**
  String get select_crypto_coin;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @deposit_currency.
  ///
  /// In en, this message translates to:
  /// **'Deposit Currency'**
  String get deposit_currency;

  /// No description provided for @choose_network.
  ///
  /// In en, this message translates to:
  /// **'Choose Network'**
  String get choose_network;

  /// No description provided for @convert_crypto_to_fiat.
  ///
  /// In en, this message translates to:
  /// **'Convert Crypto To Fiat'**
  String get convert_crypto_to_fiat;

  /// No description provided for @min_deposit.
  ///
  /// In en, this message translates to:
  /// **'Min. deposit:'**
  String get min_deposit;

  /// No description provided for @choose_your_bonus.
  ///
  /// In en, this message translates to:
  /// **'Choose your bonus'**
  String get choose_your_bonus;

  /// No description provided for @your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance.
  ///
  /// In en, this message translates to:
  /// **'Your deposit bonus will be credited in your locked rackback bonus balance.'**
  String
      get your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance;

  /// No description provided for @bonus_t_and_c.
  ///
  /// In en, this message translates to:
  /// **'Bonus T&C'**
  String get bonus_t_and_c;

  /// No description provided for @deposit_address.
  ///
  /// In en, this message translates to:
  /// **'Deposit Address'**
  String get deposit_address;

  /// No description provided for @address_copied_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Address Copied to Clipboard.'**
  String get address_copied_to_clipboard;

  /// No description provided for @copy_address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get copy_address;

  /// No description provided for @send_only.
  ///
  /// In en, this message translates to:
  /// **'Send only'**
  String get send_only;

  /// No description provided for @to_this_deposit_address_transfer_below.
  ///
  /// In en, this message translates to:
  /// **'to this deposit address. Transfer below'**
  String get to_this_deposit_address_transfer_below;

  /// No description provided for @will_not_be_credited.
  ///
  /// In en, this message translates to:
  /// **'will not be credited'**
  String get will_not_be_credited;

  /// No description provided for @your_balance.
  ///
  /// In en, this message translates to:
  /// **'Your Balance:'**
  String get your_balance;

  /// No description provided for @withdraw_currency.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Currency'**
  String get withdraw_currency;

  /// No description provided for @choose_coin_network.
  ///
  /// In en, this message translates to:
  /// **'Choose Coin Network'**
  String get choose_coin_network;

  /// No description provided for @convert_fiat_to_crypto.
  ///
  /// In en, this message translates to:
  /// **'Convert Fiat To Crypto Rate'**
  String get convert_fiat_to_crypto;

  /// No description provided for @withdraw_address.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Address'**
  String get withdraw_address;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @fill_in_carefully_according_to_the_specific.
  ///
  /// In en, this message translates to:
  /// **'Fill in carefully according to the specific'**
  String get fill_in_carefully_according_to_the_specific;

  /// No description provided for @withdraw_amount.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Amount'**
  String get withdraw_amount;

  /// No description provided for @available_balance_in.
  ///
  /// In en, this message translates to:
  /// **'Available Balance in'**
  String get available_balance_in;

  /// No description provided for @please_enter_a_valid_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get please_enter_a_valid_amount;

  /// No description provided for @please_enter_an_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address.'**
  String get please_enter_an_address;

  /// No description provided for @please_enter_withdrawal_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter withdrawal amount.'**
  String get please_enter_withdrawal_amount;

  /// No description provided for @please_enter_an_amount_less_than_the_maximum_withdrawal_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount less than the maximum withdrawal amount'**
  String get please_enter_an_amount_less_than_the_maximum_withdrawal_amount;

  /// No description provided for @please_enter_an_amount_greater_than_the_minimum_amount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount more than the minimum amount'**
  String get please_enter_an_amount_greater_than_the_minimum_amount;

  /// No description provided for @confirm_withdraw_details.
  ///
  /// In en, this message translates to:
  /// **'Confirm Withdraw Details'**
  String get confirm_withdraw_details;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency:'**
  String get currency;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get address;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience.
  ///
  /// In en, this message translates to:
  /// **'For security purposes, large or suspicious withdrawal may take 1-6 hours for audit process. We appreciate your patience.'**
  String
      get for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience;

  /// No description provided for @complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins.
  ///
  /// In en, this message translates to:
  /// **'Complete your Turnover Games and withdraw your crypto with any Crypto coins'**
  String
      get complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins;

  /// No description provided for @currency_select.
  ///
  /// In en, this message translates to:
  /// **'Currency Select'**
  String get currency_select;

  /// No description provided for @search_text.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_text;

  /// No description provided for @crypto_currency.
  ///
  /// In en, this message translates to:
  /// **'Crypto currency'**
  String get crypto_currency;

  /// No description provided for @view_crypto_statement.
  ///
  /// In en, this message translates to:
  /// **'View your crypto statement'**
  String get view_crypto_statement;

  /// No description provided for @online_transaction.
  ///
  /// In en, this message translates to:
  /// **'Online Transaction'**
  String get online_transaction;

  /// No description provided for @withdraw_request.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request'**
  String get withdraw_request;

  /// No description provided for @withdraw_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request Cancelled by User'**
  String get withdraw_cancelled;

  /// No description provided for @withdraw_cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request Cancelled by User'**
  String get withdraw_cancelled_by_user;

  /// No description provided for @bet_description.
  ///
  /// In en, this message translates to:
  /// **'Bet Placed for (C2)'**
  String get bet_description;

  /// No description provided for @win_description.
  ///
  /// In en, this message translates to:
  /// **'Win Placed for (C2)'**
  String get win_description;

  /// No description provided for @round_title.
  ///
  /// In en, this message translates to:
  /// **'Round ID'**
  String get round_title;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Cancelled by User'**
  String get cancelled_by_user;

  /// No description provided for @order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get order_id;

  /// No description provided for @select_currency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get select_currency;

  /// No description provided for @no_bonus.
  ///
  /// In en, this message translates to:
  /// **'No Bonus Available'**
  String get no_bonus;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @check_status.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get check_status;

  /// No description provided for @available_balance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get available_balance;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @convert_rate.
  ///
  /// In en, this message translates to:
  /// **'Convert Fiat To Crypto Rate'**
  String get convert_rate;

  /// No description provided for @bonus_info.
  ///
  /// In en, this message translates to:
  /// **'Your deposit bonus will be credited in your locked rackback bonus balance.'**
  String get bonus_info;

  /// No description provided for @bonus_tc.
  ///
  /// In en, this message translates to:
  /// **'Bonus T&C'**
  String get bonus_tc;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @default_text.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_text;

  /// No description provided for @enter_your_phone_number_label.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number:'**
  String get enter_your_phone_number_label;

  /// No description provided for @enter_otp_email_instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code sent to your email {email}'**
  String enter_otp_email_instruction(String email);

  /// No description provided for @minimum_amount_is.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is {amount} {currency}'**
  String minimum_amount_is(String amount, String currency);

  /// No description provided for @rate_display.
  ///
  /// In en, this message translates to:
  /// **'1 {fiat} = {rate} {crypto}'**
  String rate_display(String fiat, String rate, String crypto);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'be',
        'bn',
        'en',
        'hi',
        'mr',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
