import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show compute, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/global_constant.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  Map<String, dynamic> _localizedStrings = {};
  Map<String, String> _languageNames = {};
  bool _isLoading = true;

  // Base URL for all language JSON files
  static const String _cdnBase =
      'https://cdn.coinbet91.com/P65/Multilanguagejson';

  String _getProxyUrl(String url) {
    if (kIsWeb) {
      return 'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  // Per-page JSON files to fetch alongside homepage.json
  // Structure type:
  //   'normal'   = {lang}.{category}.{key}
  //   'inverted' = {categoryName}.{lang}.{key}
  static const List<Map<String, String>> _pageJsonConfigs =
      [
    {'file': 'myaccountpage.json', 'type': 'normal'},
    {'file': 'statementpage.json', 'type': 'inverted'},
    {'file': 'withdrawhistory.json', 'type': 'normal'},
    {'file': 'vipscreenpage.json', 'type': 'normal'},
    {'file': 'withdrawpage.json', 'type': 'normal'},
    {'file': 'depositpage.json', 'type': 'inverted'},
  ];

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  Map<String, String> get languageNames => _languageNames;

  LanguageProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromPrefs();
    await fetchLanguageData();
    if (_currentLocale.languageCode == 'en') {
      // If still default/en, try to detect location
      await detectAndSetLanguage();
    } else {
      debugPrint(
          'Skipping auto-detection because language is already set to ${_currentLocale.languageCode}');
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code');
    if (savedLang != null) {
      debugPrint('Loaded language from prefs: $savedLang');
      _currentLocale = Locale(savedLang);
      GlobalConstant.appLanguage = savedLang;
    } else {
      debugPrint('No language saved in prefs.');
    }
    notifyListeners();
  }

  Future<void> fetchLanguageData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch homepage.json first (has languageNames + strings)
      final response = await http.get(Uri.parse(
          _getProxyUrl('$_cdnBase/homepage.json')));
      if (response.statusCode == 200) {
        final data = await compute(
            json.decode, utf8.decode(response.bodyBytes));

        if (data['languageNames'] != null) {
          _languageNames = Map<String, String>.from(
              data['languageNames']);
        }

        if (data['strings'] != null) {
          _localizedStrings =
              Map<String, dynamic>.from(data['strings']);
        }
      } else {
        debugPrint(
            'Failed to load homepage language data: ${response.statusCode}');
      }

      // 2. Fetch all per-page JSONs in parallel
      final futures = _pageJsonConfigs.map((config) =>
          _fetchAndMergePageJson(
              config['file']!, config['type']!));
      await Future.wait(futures);

      // 3. Synthesize missing categories from existing ones
      _synthesizeCategories();

      debugPrint(
          'Language data loaded. Languages: ${_localizedStrings.keys.toList()}');
      debugPrint(
          'Categories for "en": ${_localizedStrings['en'] is Map ? (_localizedStrings['en'] as Map).keys.toList() : 'none'}');
    } catch (e) {
      debugPrint('Error fetching language data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// After all CDN JSONs are loaded, create synthetic categories by
  /// copying translated keys from existing categories into the
  /// categories used in code (e.g. "home_screen", "deposit").
  /// This ensures getString("home_screen", "casino") returns the
  /// translated value from getString("categories", "casino").
  void _synthesizeCategories() {
    // Redirect map: targetCategory → { targetKey: [sourceCategory, sourceKey] }
    const redirects = <String, Map<String, List<String>>>{
      'home_screen': {
        // From categories
        'casino': ['categories', 'casino'],
        'poker': ['categories', 'poker'],
        'slot': ['categories', 'slots'],
        'slots': ['categories', 'slots'],
        'roulette': ['categories', 'roulette'],
        'sports': ['categories', 'sports'],
        'crash': ['categories', 'crash'],
        'exclusive': ['categories', 'exclusive'],
        'table': ['categories', 'table'],
        'lottery': ['categories', 'lottery'],
        'search': ['categories', 'search'],
        // From common
        'daily': ['common', 'daily'],
        'weekly': ['common', 'weekly'],
        'coming_soon': ['common', 'coming_soon'],
        // From auth
        'login_now': ['auth', 'login'],
        // From bonus
        'bonus': ['bonus', 'title'],
        'total_bonus': ['bonus', 'total_bonus'],
        'deposit_bonus': ['bonus', 'deposit_bonus'],
        'rebate_bonus': ['bonus', 'rebate_bonus'],
        'fightback_bonus': ['bonus', 'fightback_bonus'],
        // From buttons
        'claim_all': ['buttons', 'claim_all'],
        // From bottom_nav
        'deposit': ['bottom_nav', 'deposit'],
        'promotion': ['bottom_nav', 'promotion'],
        'promotions': ['bottom_nav', 'promotion'],
      },
      'bottom_nav': {
        'livechat': ['bottom_nav', 'live_chat'],
        'promotions': ['bottom_nav', 'promotion'],
        'login': ['auth', 'login'],
        'register': ['auth', 'register'],
      },
      'deposit': {
        // Map deposit keys to crypto_deposit equivalents
        'deposit_address': [
          'crypto_deposit',
          'deposit_address'
        ],
        'deposit_currency': [
          'crypto_deposit',
          'deposit_currency'
        ],
        'choose_network': [
          'crypto_deposit',
          'choose_network'
        ],
        'convert_crypto_to_fiat': [
          'crypto_deposit',
          'convert_crypto_to_fiat'
        ],
        'min_deposit': ['crypto_deposit', 'min_deposit'],
        'copy': ['crypto_deposit', 'copy'],
        'check_status': ['crypto_deposit', 'check_status'],
        'select_bonus': ['crypto_deposit', 'choose_bonus'],
        'no_bonus': ['crypto_deposit', 'no_bonus'],
      },
    };

    for (final lang in _localizedStrings.keys) {
      final langData = _localizedStrings[lang];
      if (langData is! Map) continue;

      for (final entry in redirects.entries) {
        final targetCategory = entry.key;
        final keyMap = entry.value;

        // Create target category map if it doesn't exist
        langData[targetCategory] ??= <String, dynamic>{};
        final target = langData[targetCategory];
        if (target is! Map) continue;

        for (final kv in keyMap.entries) {
          final targetKey = kv.key;
          final srcCat = kv.value[0];
          final srcKey = kv.value[1];

          // Only copy if target doesn't already have the key
          if (target.containsKey(targetKey)) continue;

          final srcData = langData[srcCat];
          if (srcData is Map &&
              srcData.containsKey(srcKey)) {
            target[targetKey] = srcData[srcKey];
          }
        }
      }
    }

    debugPrint('Redirected CDN categories.');

    // ── Phase 2: inject inline translations for keys that do NOT
    // exist in any CDN JSON ──────────────────────────────
    const inlineTranslations =
        <String, Map<String, Map<String, String>>>{
      'home_screen': {
        'hi': {
          'games': 'गेम्स',
          'back': 'वापस',
          'load_more': 'और लोड करें',
          'tabelgame': 'टेबल गेम',
          'esport': 'ई-स्पोर्ट्स',
          'teenpatti': 'तीन पत्ती',
          'livedealer': 'लाइव डीलर',
          'mostpopular': 'सबसे लोकप्रिय',
          'baccarat': 'बैकरेट',
          'blackjack': 'ब्लैकजैक',
          'liveroulette': 'लाइव रूलेट',
          'topindiangames': 'टॉप इंडियन गेम्स',
          'wheellottery': 'व्हील और लॉटरी',
          'rebate': 'रिबेट',
          'lossback': 'लॉसबैक',
          'won': 'जीता',
          'live_winner': 'लाइव विनर',
          'seconds_ago': 'सेकंड पहले',
          'hi': 'हाय',
          'search': 'सर्च',
          'search_text': 'सर्च',
          'main_wallet': 'मेन वॉलेट',
          'referral_wallet': 'रेफरल वॉलेट',
          'expires_in': 'समाप्त होगा',
          'processing': 'प्रोसेसिंग',
          'amount': 'राशि',
          'follow_us': 'हमें फॉलो करें',
          'our_blog': 'हमारा ब्लॉग',
          'about_us': 'हमारे बारे में',
          'privacy_policy': 'प्राइवेसी पॉलिसी',
          'terms_and_conditions': 'नियम और शर्तें',
          'responsible_gaming': 'जिम्मेदार गेमिंग',
          'download': 'डाउनलोड',
          'login_now': 'लॉगिन करें',
          'ok': 'ठीक है',
          'okay': 'ठीक है',
          'oops': 'उफ़!',
          'vip_level': 'VIP लेवल',
          'referral_earning': 'रेफरल कमाई',
          'referral_lobby': 'रेफरल लॉबी',
          'referral_play_wallet': 'रेफरल प्ले वॉलेट',
          'transfer': 'ट्रांसफर',
          'transfer_to_play_wallet':
              'प्ले वॉलेट में ट्रांसफर करें',
          'back_to_lobby': 'लॉबी में वापस',
          'enter_a_valid_amount': 'एक वैध राशि दर्ज करें',
          'successfully_transferred_to_your_play_wallet':
              'आपके प्ले वॉलेट में सफलतापूर्वक ट्रांसफर हो गया',
          'enter_amount_to_transfer_to_play_wallet':
              'प्ले वॉलेट में ट्रांसफर करने के लिए राशि दर्ज करें',
          'refer_and_earn_unlimited_money':
              'रेफर करें और अनलिमिटेड पैसे कमाएं',
          'how_it_works': 'यह कैसे काम करता है',
          'get_unlimited_commission':
              'अनलिमिटेड कमीशन पाएं',
          'switch_to_referral_wallet':
              'रेफरल वॉलेट पर स्विच करें',
          'only_on_': 'केवल',
          'withdraw_unlimited_referral_money_in_your_bank_with_play_games':
              'गेम खेलकर अपने बैंक में अनलिमिटेड रेफरल पैसे निकालें',
          'daily': 'दैनिक',
          'weekly': 'साप्ताहिक',
          'coming_soon': 'जल्द आ रहा है',
          'welcometo': 'में आपका स्वागत है ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'लाइव चैट',
          'faq': 'सवाल-जवाब',
          'localeName': 'हिंदी',
          'refer_and_earn': 'रेफर और कमाएं',
          'refer_now': 'अभी रेफर करें',
          'my_earning': 'मेरी कमाई',
          'withdrawal': 'निकासी',
          'withdraw': 'निकालें',
          'withdraw_history': 'निकासी इतिहास',
          'statement_title': 'स्टेटमेंट',
          'and_earn_cash': 'और नकद कमाएं',
          'and_fund_transfer': 'और फंड ट्रांसफर',
          'crypto_currency': 'क्रिप्टो करेंसी',
          'join_winbaji_and_earn_money_use_my_referral_code':
              'Playcrypto365 में शामिल हों और पैसे कमाएं! मेरा रेफरल कोड इस्तेमाल करें',
          'your_referral_link': 'आपका रेफरल लिंक',
          'referral_code_copied_to_clipboard':
              'रेफरल कोड कॉपी हो गया',
          'tap_to_copy': 'कॉपी करने के लिए टैप करें',
          'how_referral_commission_works':
              'रेफरल कमीशन कैसे काम करता है',
          'how_to_play_games_using_referral_earning':
              'रेफरल कमाई से गेम कैसे खेलें',
          'how_to_withdraw': 'निकासी कैसे करें',
          'your_referral_earning_to_withdrawal_journey':
              'आपकी रेफरल कमाई से निकासी तक की यात्रा',
          'refer_to_friends': 'दोस्तों को रेफर करें',
          'referral_earning_get_in_live_wallet':
              'रेफरल कमाई लाइव वॉलेट में प्राप्त करें',
          'transfer_fund_to_play_wallet':
              'प्ले वॉलेट में फंड ट्रांसफर करें',
          'complete_turnover': 'टर्नओवर पूरा करें',
          'withdraw_in_bkash_or_nagad':
              'क्रिप्टो करेंसी में निकालें',
          'downloadwinbajinow':
              'अभी Playcrypto365 डाउनलोड करें',
          'transfer_to_main_wallet':
              'मुख्य वॉलेट में ट्रांसफर करें',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'अपने दोस्तों की हर जमा पर आजीवन कमीशन कमाएं',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'आप रेफ़री की चल रही जमा का एक प्रतिशत कमाते हैं जिसमें प्रत्यक्ष रेफ़रल, अप्रत्यक्ष रेफ़रल और विस्तारित रेफ़रल शामिल है',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'रेफ़रल कमाई से गेम खेलने के लिए, आपको अपनी लाइव रेफ़रल कमाई को रेफ़रल प्ले वॉलेट में ट्रांसफर करना होगा, निम्नलिखित ट्रांसफर सुविधा का उपयोग करके ',
          'screen_label': 'स्क्रीन',
          'referral_wallet_lobby_and_my_earning':
              'रेफ़रल वॉलेट लॉबी और मेरी कमाई',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'लाइव रेफ़रल कमाई बैलेंस को रेफ़रल प्ले वॉलेट में ट्रांसफर करने के बाद, आप उस बैलेंस का उपयोग गेम खेलने या सीधे अपने बैंक खाते में निकासी के लिए कर सकते हैं',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'आप रेफ़रल वॉलेट में टर्नओवर पूरा करने के बाद bKash या Nagad में रेफ़रल प्ले बैलेंस निकाल सकते हैं। आपके बैंक खाते में प्ले बैलेंस निकालने के लिए यहां सरल 5 कदम हैं',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. रेफ़रल वॉलेट लॉबी पर जाएं\n2. रेफ़र और कमाएं टैब पर क्लिक करें\n3. निकासी बटन पर क्लिक करें\n4. अपना निकासी मोड चुनें (bKash या Nagad)\n5. राशि चुनें और निकासी करें',
          'totals_earning': 'कुल कमाई',
          'direct_referrals': 'डायरेक्ट रेफरल',
          'indirect_referrals': 'इनडायरेक्ट रेफरल',
          'extended_referrals': 'एक्सटेंडेड रेफरल',
          'your_top_active_referrals':
              'आपके शीर्ष सक्रिय रेफरल',
          'no_referrals_found': 'कोई रेफरल नहीं मिला',
          'you_received': 'आपको मिला',
        },
        'te': {
          'games': 'గేమ్‌లు',
          'back': 'వెనుకకు',
          'load_more': 'మరిన్ని లోడ్ చేయండి',
          'tabelgame': 'టేబుల్ గేమ్',
          'esport': 'ఈ-స్పೋರ್ట్స్',
          'teenpatti': 'తీన్ పట్టి',
          'livedealer': 'లైవ్ డీలర్',
          'mostpopular': 'అత్యంత ప్రాచుర్యం',
          'baccarat': 'బాకరట్',
          'blackjack': 'బ్లాక్‌జాక్',
          'liveroulette': 'లైవ్ రూలెట్',
          'topindiangames': 'టాప్ ఇండియన్ గేమ్‌లు',
          'wheellottery': 'వీల్ & లాటరీ',
          'rebate': 'రిబేట్',
          'lossback': 'లాస్‌బ్యాక్',
          'won': 'గెలిచారు',
          'live_winner': 'లైవ్ విన్నర్',
          'seconds_ago': 'సెకన్ల క్రితం',
          'hi': 'హాయ్',
          'search': 'వెతకండి',
          'search_text': 'వెతకండి',
          'main_wallet': 'మెయిన్ వాలెట్',
          'referral_wallet': 'రిఫరల్ వాలెట్',
          'expires_in': 'గడువు ముగుస్తుంది',
          'processing': 'ప్రాసెసింగ్',
          'amount': 'మొత్తం',
          'follow_us': 'మమ్మల్ని ఫాలో అవ్వండి',
          'our_blog': 'మా బ్లాగ్',
          'about_us': 'మా గురించి',
          'privacy_policy': 'ప్రైవసీ పాలసీ',
          'terms_and_conditions': 'నిబంధనలు & షరతులు',
          'responsible_gaming': 'బాధ్యతాయుతమైన గేమింగ్',
          'download': 'డౌన్‌లోడ్',
          'login_now': 'లాగిన్ అవ్వండి',
          'ok': 'సరే',
          'okay': 'సరే',
          'oops': 'అయ్యో!',
          'vip_level': 'VIP స్థాయి',
          'referral_earning': 'రిఫరల్ ఆదాయం',
          'referral_lobby': 'రిఫరల్ లాబీ',
          'referral_play_wallet': 'రిఫరల్ ప్లే వాలెట్',
          'transfer': 'బదిలీ',
          'transfer_to_play_wallet':
              'ప్లే వాలెట్‌కు బదిలీ చేయండి',
          'back_to_lobby': 'లాబీకి తిరిగి',
          'enter_a_valid_amount':
              'చెల్లుబాటు అయ్యే మొత్తం నమోదు చేయండి',
          'successfully_transferred_to_your_play_wallet':
              'మీ ప్లే వాలెట్‌కు విజయవంతంగా బదిలీ అయింది',
          'enter_amount_to_transfer_to_play_wallet':
              'ప్లే వాలెట్‌కు బదిలీ చేయడానికి మొత్తం నమోదు చేయండి',
          'refer_and_earn_unlimited_money':
              'రిఫర్ చేసి అపరిమితంగా సంపాదించండి',
          'how_it_works': 'ఇది ఎలా పనిచేస్తుంది',
          'get_unlimited_commission':
              'అపరిమిత కమీషన్ పొందండి',
          'switch_to_referral_wallet':
              'రిఫరల్ వాలెట్‌కు మారండి',
          'only_on_': 'కేవలం',
          'withdraw_unlimited_referral_money_in_your_bank_with_play_games':
              'గేమ్‌లు ఆడి మీ బ్యాంకులో అపరిమిత రిఫరల్ డబ్బు విత్‌డ్రా చేయండి',
          'daily': 'రోజువారీ',
          'weekly': 'వారానికోసారి',
          'coming_soon': 'త్వరలో రాబోతోంది',
          'welcometo': 'స్వాగతం ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'లైవ్ చాట్',
          'faq': 'తరచుగా అడిగే ప్రశ్నలు',
          'localeName': 'తెలుగు',
          'refer_and_earn': 'రిఫర్ & ఆర్జించండి',
          'refer_now': 'ఇప్పుడు రిఫర్ చేయండి',
          'my_earning': 'నా ఆదాయం',
          'withdrawal': 'విత్‌డ్రాయల్',
          'withdraw': 'విత్‌డ్రా',
          'withdraw_history': 'విత్‌డ్రా చరిత్ర',
          'statement_title': 'స్టేట్‌మెంట్',
          'and_earn_cash': 'మరియు నగదు సంపాదించండి',
          'and_fund_transfer': 'మరియు ఫండ్ ట్రాన్స్‌ఫర్',
          'crypto_currency': 'క్రిప్టో కరెన్సీ',
          'your_referral_link': 'మీ రిఫరల్ లింక్',
          'tap_to_copy': 'కాపీ చేయడానికి ట్యాప్ చేయండి',
          'how_referral_commission_works':
              'రెఫరల్ కమీషన్ ఎలా పనిచేస్తుంది',
          'how_to_play_games_using_referral_earning':
              'రెఫరల్ ఆదాయంతో గేమ్‌లు ఎలా ఆడాలి',
          'how_to_withdraw': 'ఎలా విత్‌డ్రా చేయాలి',
          'your_referral_earning_to_withdrawal_journey':
              'మీ రిఫరల్ ఆదాయం నుండి విత్‌డ్రా వరకు ప్రయాణం',
          'refer_to_friends': 'స్నేహితులకు రిఫర్ చేయండి',
          'referral_earning_get_in_live_wallet':
              'రిఫరల్ ఆదాయం లైవ్ వాలెట్‌లో పొందండి',
          'transfer_fund_to_play_wallet':
              'ప్లే వాలెట్‌కు ఫండ్ ట్రాన్స్‌ఫర్ చేయండి',
          'complete_turnover': 'టర్నోవర్ పూర్తి చేయండి',
          'withdraw_in_bkash_or_nagad':
              'క్రిప్టో కరెన్సీలో విత్‌డ్రా చేయండి',
          'downloadwinbajinow':
              'ఇప్పుడే Playcrypto365 డౌన్‌లోడ్ చేయండి',
          'transfer_to_main_wallet':
              'ప్రధాన వాలెట్‌కు బదిలీ చేయండి',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'మీ స్నేహితుల ప్రతి డిపాజిట్‌పై జీవితకాల కమీషన్ సంపాదించండి',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'ప్రత్యక్ష రెఫరల్, పరోక్ష రెఫరల్ మరియు విస్తరించిన రెఫరల్‌తో సహా రెఫరీ యొక్క కొనసాగుతున్న డిపాజిట్‌లో మీరు శాతం సంపాదిస్తారు',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'రెఫరల్ ఆదాయంతో గేమ్‌లు ఆడటానికి, మీరు మీ లైవ్ రెఫరల్ ఆదాయాన్ని రెఫరల్ ప్లే వాలెట్‌కు బదిలీ చేయాలి, కింది బదిలీ ఫీచర్‌ని ఉపయోగించి ',
          'screen_label': 'స్క్రీన్',
          'referral_wallet_lobby_and_my_earning':
              'రెఫరల్ వాలెట్ లాబీ మరియు నా ఆదాయం',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'లైవ్ రెఫరల్ ఆదాయ బ్యాలెన్స్‌ను రెఫరల్ ప్లే వాలెట్‌కు బదిలీ చేసిన తర్వాత, మీరు ఆ బ్యాలెన్స్‌ను గేమ్‌లు ఆడటానికి లేదా నేరుగా మీ బ్యాంక్ ఖాతాకు విత్‌డ్రా చేయడానికి ఉపయోగించవచ్చు',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'రెఫరల్ వాలెట్‌లో టర్నోవర్ పూర్తి చేసిన తర్వాత bKash లేదా Nagadలో రెఫరల్ ప్లే బ్యాలెన్స్ విత్‌డ్రా చేయవచ్చు. మీ బ్యాంక్ ఖాతాలో ప్లే బ్యాలెన్స్ విత్‌డ్రా చేయడానికి ఇక్కడ సాధారణ 5 దశలు ఉన్నాయి',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. రెఫరల్ వాలెట్ లాబీకి వెళ్ళండి\n2. రెఫర్ మరియు ఆదాయం ట్యాబ్‌పై క్లిక్ చేయండి\n3. విత్‌డ్రాయల్ బటన్‌పై క్లిక్ చేయండి\n4. మీ విత్‌డ్రాయల్ మోడ్ ఎంచుకోండి (bKash లేదా Nagad)\n5. మొత్తం ఎంచుకోండి మరియు విత్‌డ్రా చేయండి',
          'totals_earning': 'మొత్తం ఆదాయం',
          'direct_referrals': 'డైరెక్ట్ రెఫరల్స్',
          'indirect_referrals': 'ఇన్‌డైరెక్ట్ రెఫరల్స్',
          'extended_referrals': 'ఎక్స్‌టెండెడ్ రెఫరల్స్',
          'your_top_active_referrals':
              'మీ టాప్ యాక్టివ్ రెఫరల్స్',
          'no_referrals_found': 'రెఫరల్స్ కనుగొనబడలేదు',
          'you_received': 'మీరు అందుకున్నారు',
        },
        'bn': {
          'games': 'গেমস',
          'back': 'পিছনে',
          'load_more': 'আরো লোড করুন',
          'tabelgame': 'টেবিল গেম',
          'esport': 'ই-স্পোর্টস',
          'teenpatti': 'তিন পত্তি',
          'livedealer': 'লাইভ ডিলার',
          'mostpopular': 'সর্বাধিক জনপ্রিয়',
          'baccarat': 'ব্যাকারেট',
          'blackjack': 'ব্ল্যাকজ্যাক',
          'liveroulette': 'লাইভ রুলেট',
          'topindiangames': 'টপ ইন্ডিয়ান গেমস',
          'wheellottery': 'হুইল ও লটারি',
          'rebate': 'রিবেট',
          'lossback': 'লসব্যাক',
          'won': 'জিতেছে',
          'live_winner': 'লাইভ উইনার',
          'seconds_ago': 'সেকেন্ড আগে',
          'hi': 'হাই',
          'search': 'সার্চ',
          'search_text': 'সার্চ',
          'main_wallet': 'মেইন ওয়ালেট',
          'referral_wallet': 'রেফারেল ওয়ালেট',
          'expires_in': 'শেষ হবে',
          'processing': 'প্রসেসিং',
          'amount': 'পরিমাণ',
          'follow_us': 'আমাদের ফলো করুন',
          'about_us': 'আমাদের সম্পর্কে',
          'privacy_policy': 'প্রাইভেসি পলিসি',
          'terms_and_conditions': 'শর্তাবলী',
          'responsible_gaming': 'দায়িত্বশীল গেমিং',
          'download': 'ডাউনলোড',
          'login_now': 'লগইন করুন',
          'ok': 'ঠিক আছে',
          'okay': 'ঠিক আছে',
          'daily': 'দৈনিক',
          'weekly': 'সাপ্তাহিক',
          'coming_soon': 'শীঘ্রই আসছে',
          'referral_lobby': 'রেফারেল লবি',
          'referral_play_wallet': 'রেফারেল প্লে ওয়ালেট',
          'transfer': 'ট্রান্সফার',
          'welcometo': ' এ স্বাগতম ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'লাইভ চ্যাট',
          'oops': 'উফ্!',
          'localeName': 'বাংলা',
          'refer_and_earn': 'রেফার এবং আয় করুন',
          'refer_now': 'এখনই রেফার করুন',
          'my_earning': 'আমার আয়',
          'withdrawal': 'উত্তোলন',
          'withdraw': 'উত্তোলন',
          'withdraw_history': 'উত্তোলনের ইতিহাস',
          'statement_title': 'স্টেটমেন্ট',
          'and_earn_cash': 'এবং নগদ আয় করুন',
          'and_fund_transfer': 'এবং ফান্ড ট্রান্সফার',
          'crypto_currency': 'ক্রিপ্টো কারেন্সি',
          'your_referral_link': 'আপনার রেফারেল লিংক',
          'tap_to_copy': 'কপি করতে ট্যাপ করুন',
          'how_referral_commission_works':
              'রেফারেল কমিশন কিভাবে কাজ করে',
          'how_to_play_games_using_referral_earning':
              'রেফারেল আয় দিয়ে গেম কিভাবে খেলবেন',
          'how_to_withdraw': 'কিভাবে উত্তোলন করবেন',
          'your_referral_earning_to_withdrawal_journey':
              'আপনার রেফারেল আয় থেকে উত্তোলনের যাত্রা',
          'refer_to_friends': 'বন্ধুদের রেফার করুন',
          'referral_earning_get_in_live_wallet':
              'রেফারেল আয় লাইভ ওয়ালেটে পান',
          'transfer_fund_to_play_wallet':
              'প্লে ওয়ালেটে ফান্ড ট্রান্সফার করুন',
          'complete_turnover': 'টার্নওভার সম্পূর্ণ করুন',
          'withdraw_in_bkash_or_nagad':
              'ক্রিপ্টো কারেন্সিতে উত্তোলন করুন',
          'downloadwinbajinow':
              'এখনই Playcrypto365 ডাউনলোড করুন',
          'transfer_to_main_wallet':
              'প্রধান ওয়ালেটে ট্রান্সফার করুন',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'আপনার বন্ধুদের প্রতিটি জমায় আজীবন কমিশন উপার্জন করুন',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'সরাসরি রেফারেল, পরোক্ষ রেফারেল এবং বর্ধিত রেফারেল সহ রেফারির চলমান জমার একটি শতাংশ আপনি উপার্জন করেন',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'রেফারেল আয় ব্যবহার করে গেম খেলতে, আপনাকে নিম্নলিখিত ট্রান্সফার ফিচার ব্যবহার করে আপনার লাইভ রেফারেল আয় রেফারেল প্লে ওয়ালেটে ট্রান্সফার করতে হবে ',
          'screen_label': 'স্ক্রিন',
          'referral_wallet_lobby_and_my_earning':
              'রেফারেল ওয়ালেট লবি এবং আমার আয়',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'লাইভ রেফারেল আয়ের ব্যালেন্স রেফারেল প্লে ওয়ালেটে ট্রান্সফার করার পর, আপনি সেই ব্যালেন্স গেম খেলতে বা সরাসরি আপনার ব্যাংক অ্যাকাউন্টে উত্তোলনের জন্য ব্যবহার করতে পারেন',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'রেফারেল ওয়ালেটে টার্নওভার সম্পন্ন করার পর bKash বা Nagad-এ রেফারেল প্লে ব্যালেন্স উত্তোলন করতে পারবেন। আপনার ব্যাংক অ্যাকাউন্টে প্লে ব্যালেন্স উত্তোলনের জন্য এখানে সহজ ৫টি ধাপ রয়েছে',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. রেফারেল ওয়ালেট লবিতে যান\n2. রেফার এবং আয় ট্যাবে ক্লিক করুন\n3. উত্তোলন বোতামে ক্লিক করুন\n4. আপনার উত্তোলন মোড নির্বাচন করুন (bKash বা Nagad)\n5. পরিমাণ নির্বাচন করুন এবং উত্তোলন করুন',
          'totals_earning': 'মোট আয়',
          'direct_referrals': 'ডাইরেক্ট রেফারেল',
          'indirect_referrals': 'ইনডাইরেক্ট রেফারেল',
          'extended_referrals': 'এক্সটেন্ডেড রেফারেল',
          'your_top_active_referrals':
              'আপনার শীর্ষ সক্রিয় রেফারেল',
          'no_referrals_found':
              'কোনো রেফারেল পাওয়া যায়নি',
          'you_received': 'আপনি পেয়েছেন',
        },
        'mr': {
          'games': 'गेम्स',
          'back': 'मागे',
          'load_more': 'अजून लोड करा',
          'tabelgame': 'टेबल गेम',
          'esport': 'ई-स्पोर्ट्स',
          'teenpatti': 'तीन पत्ती',
          'livedealer': 'लाइव डीलर',
          'mostpopular': 'सर्वात लोकप्रिय',
          'baccarat': 'बॅकरॅट',
          'blackjack': 'ब्लॅकजॅक',
          'liveroulette': 'लाइव रूलेट',
          'topindiangames': 'टॉप इंडियन गेम्स',
          'wheellottery': 'व्हील आणि लॉटरी',
          'rebate': 'रिबेट',
          'lossback': 'लॉसबॅक',
          'won': 'जिंकले',
          'live_winner': 'लाइव विनर',
          'seconds_ago': 'सेकंद पूर्वी',
          'hi': 'नमस्कार',
          'search': 'शोधा',
          'search_text': 'शोधा',
          'main_wallet': 'मेन वॉलेट',
          'referral_wallet': 'रेफरल वॉलेट',
          'amount': 'रक्कम',
          'follow_us': 'आम्हाला फॉलो करा',
          'about_us': 'आमच्याबद्दल',
          'privacy_policy': 'प्रायव्हसी पॉलिसी',
          'terms_and_conditions': 'अटी आणि शर्ती',
          'responsible_gaming': 'जबाबदार गेमिंग',
          'download': 'डाउनलोड',
          'login_now': 'लॉगिन करा',
          'ok': 'ठीक आहे',
          'okay': 'ठीक आहे',
          'daily': 'दैनिक',
          'weekly': 'साप्ताहिक',
          'coming_soon': 'लवकरच येत आहे',
          'referral_lobby': 'रेफरल लॉबी',
          'referral_play_wallet': 'रेफरल प्ले वॉलेट',
          'transfer': 'ट्रान्सफर',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'लाइव्ह चॅट',
          'oops': 'अरेरे!',
          'localeName': 'मराठी',
          'refer_and_earn': 'रेफर आणि कमवा',
          'refer_now': 'आता रेफर करा',
          'my_earning': 'माझी कमाई',
          'withdrawal': 'विदड्रॉ',
          'withdraw': 'काढा',
          'withdraw_history': 'विदड्रॉ इतिहास',
          'statement_title': 'स्टेटमेंट',
          'and_earn_cash': 'आणि रोख कमवा',
          'and_fund_transfer': 'आणि फंड ट्रान्सफर',
          'crypto_currency': 'क्रिप्टो करन्सी',
          'your_referral_link': 'तुमचा रेफरल लिंक',
          'tap_to_copy': 'कॉपी करण्यासाठी टॅप करा',
          'how_referral_commission_works':
              'रेफरल कमिशन कसे काम करते',
          'how_to_play_games_using_referral_earning':
              'रेफरल कमाई वापरून गेम कसे खेळायचे',
          'how_to_withdraw': 'विदड्रॉ कसे करावे',
          'your_referral_earning_to_withdrawal_journey':
              'तुमच्या रेफरल कमाई ते विदड्रॉ पर्यंतचा प्रवास',
          'refer_to_friends': 'मित्रांना रेफर करा',
          'referral_earning_get_in_live_wallet':
              'रेफरल कमाई लाइव्ह वॉलेटमध्ये मिळवा',
          'transfer_fund_to_play_wallet':
              'प्ले वॉलेटमध्ये फंड ट्रान्सफर करा',
          'complete_turnover': 'टर्नओव्हर पूर्ण करा',
          'withdraw_in_bkash_or_nagad':
              'क्रिप्टो करन्सीमध्ये विदड्रॉ करा',
          'downloadwinbajinow':
              'आता Playcrypto365 डाउनलोड करा',
          'transfer_to_main_wallet':
              'मुख्य वॉलेटमध्ये ट्रान्सफर करा',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'तुमच्या मित्रांच्या प्रत्येक डिपॉझिटवर आजीवन कमिशन कमवा',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'थेट रेफरल, अप्रत्यक्ष रेफरल आणि विस्तारित रेफरलसह रेफरीच्या सुरू असलेल्या डिपॉझिटचा एक टक्का तुम्ही कमवता',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'रेफरल कमाई वापरून गेम खेळण्यासाठी, तुम्हाला तुमची लाइव्ह रेफरल कमाई रेफरल प्ले वॉलेटमध्ये ट्रान्सफर करणे आवश्यक आहे, खालील ट्रान्सफर वैशिष्ट्य वापरून ',
          'screen_label': 'स्क्रीन',
          'referral_wallet_lobby_and_my_earning':
              'रेफरल वॉलेट लॉबी आणि माझी कमाई',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'लाइव्ह रेफरल कमाई बॅलन्स रेफरल प्ले वॉलेटमध्ये ट्रान्सफर केल्यानंतर, तुम्ही तो बॅलन्स गेम खेळण्यासाठी किंवा थेट तुमच्या बँक खात्यात विड्रॉ करण्यासाठी वापरू शकता',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'रेफरल वॉलेटमध्ये टर्नओव्हर पूर्ण केल्यानंतर bKash किंवा Nagad मध्ये रेफरल प्ले बॅलन्स काढता येतो. तुमच्या बँक खात्यात प्ले बॅलन्स काढण्यासाठी येथे सोप्या ५ पायऱ्या आहेत',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. रेफरल वॉलेट लॉबीवर जा\n2. रेफर आणि कमाई टॅबवर क्लिक करा\n3. विड्रॉ बटणावर क्लिक करा\n4. तुमचा विड्रॉ मोड निवडा (bKash किंवा Nagad)\n5. रक्कम निवडा आणि विड्रॉ करा',
          'totals_earning': 'एकूण कमाई',
          'direct_referrals': 'डायरेक्ट रेफरल',
          'indirect_referrals': 'इनडायरेक्ट रेफरल',
          'extended_referrals': 'एक्सटेंडेड रेफरल',
          'your_top_active_referrals':
              'तुमचे शीर्ष सक्रिय रेफरल',
          'no_referrals_found':
              'कोणतेही रेफरल सापडले नाहीत',
          'you_received': 'तुम्हाला मिळाले',
        },
        'ta': {
          'games': 'கேம்ஸ்',
          'back': 'பின்செல்',
          'load_more': 'மேலும் ஏற்று',
          'tabelgame': 'டேபிள் கேம்',
          'esport': 'ஈ-ஸ்போர்ட்ஸ்',
          'teenpatti': 'டீன் பட்டி',
          'livedealer': 'லைவ் டீலர்',
          'mostpopular': 'மிகவும் பிரபலமான',
          'baccarat': 'பாக்கரட்',
          'blackjack': 'பிளாக்ஜாக்',
          'liveroulette': 'லைவ் ரூலெட்',
          'topindiangames': 'டாப் இந்தியன் கேம்ஸ்',
          'wheellottery': 'வீல் & லாட்டரி',
          'rebate': 'ரிபேட்',
          'lossback': 'லாஸ்பேக்',
          'won': 'வென்றார்',
          'live_winner': 'லைவ் வின்னர்',
          'seconds_ago': 'வினாடிகள் முன்',
          'hi': 'ஹாய்',
          'search': 'தேடு',
          'search_text': 'தேடு',
          'amount': 'தொகை',
          'follow_us': 'எங்களைப் பின்தொடருங்கள்',
          'about_us': 'எங்களைப் பற்றி',
          'privacy_policy': 'தனியுரிமை கொள்கை',
          'terms_and_conditions':
              'விதிமுறைகள் & நிபந்தனைகள்',
          'responsible_gaming': 'பொறுப்பான கேமிங்',
          'download': 'டவுன்லோட்',
          'login_now': 'உள்நுழையுங்கள்',
          'ok': 'சரி',
          'okay': 'சரி',
          'daily': 'தினசரி',
          'weekly': 'வாராந்திர',
          'coming_soon': 'விரைவில்',
          'referral_lobby': 'ரெப்பரல் லாபி',
          'referral_play_wallet': 'ரெப்பரல் ப்லே வாலெட்',
          'transfer': 'பரிமாற்றம்',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'நேரடி அரட்டை',
          'oops': 'அட!',
          'localeName': 'தமிழ்',
          'refer_and_earn': 'ரெப்பர் & சம்பாதிக்கவும்',
          'refer_now': 'இப்போதே ரெப்பர் செய்யவும்',
          'my_earning': 'என் வருமானம்',
          'withdrawal': 'வித்ட்ராவல்',
          'withdraw': 'திரும்பப் பெறு',
          'withdraw_history': 'வித்ட்ரா வரலாறு',
          'statement_title': 'அறிக்கை',
          'and_earn_cash': 'மற்றும் நகது சம்பாதிக்கவும்',
          'and_fund_transfer': 'மற்றும் பண பரிமாற்றம்',
          'crypto_currency': 'கிரிப்டோ நாணயம்',
          'your_referral_link': 'உங்கள் ரெப்பரல் இணைப்பு',
          'tap_to_copy': 'நகலெடுக்க டாப் செய்யவும்',
          'how_referral_commission_works':
              'ரெஃபரல் கமிஷன் எப்படி வேலை செய்கிறது',
          'how_to_play_games_using_referral_earning':
              'ரெஃபரல் வருவாயைப் பயன்படுத்தி கேம்கள் எப்படி விளையாடுவது',
          'how_to_withdraw': 'எப்படி வித்ட்ரா செய்வது',
          'your_referral_earning_to_withdrawal_journey':
              'உங்கள் ரெப்பரல் வருமானம் முதல் வித்ட்ரா வரை பயணம்',
          'refer_to_friends':
              'நண்பர்களுக்கு ரெப்பர் செய்யுங்கள்',
          'referral_earning_get_in_live_wallet':
              'ரெப்பரல் வருமானம் லைவ் வாலெட்டில் பெறுங்கள்',
          'transfer_fund_to_play_wallet':
              'ப்லே வாலெட்டுக்கு பண பரிமாற்றம்',
          'complete_turnover':
              'டர்னோவர் பூர்த்தி செய்யுங்கள்',
          'withdraw_in_bkash_or_nagad':
              'கிரிப்டோ நாணயத்தில் வித்ட்ரா செய்யுங்கள்',
          'downloadwinbajinow':
              'இப்போதே Playcrypto365 பதிவிறக்குங்கள்',
          'transfer_to_main_wallet':
              'முதன்மை வாலட்டிற்கு மாற்றவும்',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'உங்கள் நண்பர்களின் ஒவ்வொரு வைப்பிலும் வாழ்நாள் கமிஷன் பெறுங்கள்',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'நேரடி பரிந்துரை, மறைமுக பரிந்துரை மற்றும் நீட்டிக்கப்பட்ட பரிந்துரை உள்ளிட்ட பரிந்துரையாளரின் தொடர்ச்சியான வைப்பில் நீங்கள் ஒரு சதவீதம் சம்பாதிப்பீர்கள்',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'பரிந்துரை வருவாயைப் பயன்படுத்தி கேம்கள் விளையாட, கீழ்காணும் பரிமாற்ற அம்சத்தைப் பயன்படுத்தி உங்கள் நேரடி பரிந்துரை வருவாயை பரிந்துரை ப்ளே வாலட்டிற்கு மாற்ற வேண்டும் ',
          'screen_label': 'திரை',
          'referral_wallet_lobby_and_my_earning':
              'பரிந்துரை வாலட் லாபி மற்றும் எனது வருவாய்',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'நேரடி பரிந்துரை வருவாய் இருப்பை பரிந்துரை ப்ளே வாலட்டிற்கு மாற்றிய பிறகு, அந்த இருப்பை கேம்கள் விளையாட அல்லது நேரடியாக உங்கள் வங்கிக் கணக்கிற்கு எடுக்க பயன்படுத்தலாம்',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'பரிந்துரை வாலட்டில் டர்னோவர் நிறைவுசெய்த பிறகு bKash அல்லது Nagad-ல் பரிந்துரை ப்ளே இருப்பை எடுக்கலாம். உங்கள் வங்கிக் கணக்கில் ப்ளே இருப்பை எடுக்க எளிய 5 படிகள் இங்கே உள்ளன',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. பரிந்துரை வாலட் லாபிக்குச் செல்லுங்கள்\n2. பரிந்துரை மற்றும் சம்பாதி டேபில் கிளிக் செய்யுங்கள்\n3. திரும்பப்பெறு பொத்தானைக் கிளிக் செய்யுங்கள்\n4. உங்கள் திரும்பப்பெறு முறையைத் தேர்வு செய்யுங்கள் (bKash அல்லது Nagad)\n5. தொகையைத் தேர்வு செய்து திரும்பப்பெறுங்கள்',
          'totals_earning': 'மொத்த வருவாய்',
          'direct_referrals': 'நேரடி பரிந்துரைகள்',
          'indirect_referrals': 'மறைமுக பரிந்துரைகள்',
          'extended_referrals':
              'நீட்டிக்கப்பட்ட பரிந்துரைகள்',
          'your_top_active_referrals':
              'உங்கள் சிறந்த செயலில் உள்ள பரிந்துரைகள்',
          'no_referrals_found':
              'பரிந்துரைகள் எதுவும் இல்லை',
          'you_received': 'நீங்கள் பெற்றீர்கள்',
        },
        'gu': {
          'games': 'ગેમ્સ',
          'back': 'પાછા',
          'load_more': 'વધુ લોડ કરો',
          'tabelgame': 'ટેબલ ગેમ',
          'esport': 'ઈ-સ્પોર્ટ્સ',
          'teenpatti': 'તીન પત્તી',
          'livedealer': 'લાઈવ ડીલર',
          'mostpopular': 'સૌથી લોકપ્રિય',
          'baccarat': 'બેકરેટ',
          'blackjack': 'બ્લેકજેક',
          'liveroulette': 'લાઈવ રૂલેટ',
          'topindiangames': 'ટોપ ઈન્ડિયન ગેમ્સ',
          'wheellottery': 'વ્હીલ અને લોટરી',
          'rebate': 'રિબેટ',
          'lossback': 'લોસબેક',
          'won': 'જીત્યા',
          'live_winner': 'લાઈવ વિનર',
          'seconds_ago': 'સેકન્ડ પહેલા',
          'hi': 'હાય',
          'search': 'શોધો',
          'search_text': 'શોધો',
          'amount': 'રકમ',
          'follow_us': 'અમને ફોલો કરો',
          'about_us': 'અમારા વિશે',
          'download': 'ડાઉનલોડ',
          'login_now': 'લોગિન કરો',
          'ok': 'ઠીક છે',
          'daily': 'દૈનિક',
          'weekly': 'સાપ્તાહિક',
          'coming_soon': 'ટૂંક સમયમાં આવી રહ્યું છે',
          'referral_lobby': 'રેફરલ લોબી',
          'referral_play_wallet': 'રેફરલ પ્લે વોલેટ',
          'transfer': 'ટ્રાન્સફર',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'લાઇવ ચેટ',
          'okay': 'ઠીક છે',
          'localeName': 'ગુજરાતી',
          'refer_and_earn': 'રેફર અને કમાઓ',
          'refer_now': 'અબ રેફર કરો',
          'my_earning': 'મારી કમાણી',
          'withdrawal': 'ઉઉપાડ',
          'withdraw': 'ઉપાડો',
          'withdraw_history': 'ઉઉપાડ ઇતિહાસ',
          'statement_title': 'સ્ટેટમેન્ટ',
          'and_earn_cash': 'અને રોકડ કમાઓ',
          'and_fund_transfer': 'અને ફંડ ટ્રાન્સફર',
          'crypto_currency': 'ક્રિપ્ટો કરન્સી',
          'your_referral_link': 'તમારી રેફરલ લિંક',
          'tap_to_copy': 'કોપી કરવા ટેપ કરો',
          'how_referral_commission_works':
              'રેફરલ કમિશન કેવી રીતે કામ કરે છે',
          'how_to_play_games_using_referral_earning':
              'રેફરલ કમાણીનો ઉપયોગ કરીને ગેમ કેવી રીતે રમવી',
          'how_to_withdraw': 'કેવી રીતે ઉઉપાડ કરવી',
          'your_referral_earning_to_withdrawal_journey':
              'તમારી રેફરલ કમાણીથી ઉઉપાડ સુધીની યાત્રા',
          'refer_to_friends': 'મિત્રોને રેફર કરો',
          'referral_earning_get_in_live_wallet':
              'રેફરલ કમાણી લાઇવ વોલેટમાં મેળવો',
          'transfer_fund_to_play_wallet':
              'પ્લે વોલેટમાં ફંડ ટ્રાન્સફર કરો',
          'complete_turnover': 'ટર્નઓવર પૂર્ણ કરો',
          'withdraw_in_bkash_or_nagad':
              'ક્રિપ્ટો કરન્સીમાં ઉઉપાડ કરો',
          'downloadwinbajinow':
              'અત્યારે Playcrypto365 ડાઉનલોડ કરો',
          'transfer_to_main_wallet':
              'મુખ્ય વોલેટમાં ટ્રાન્સફર કરો',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'તમારા મિત્રોના દરેક ડિપોઝિટ પર આજીવન કમિશન કમાઓ',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'પ્રત્યક્ષ રેફરલ, પરોક્ષ રેફરલ અને વિસ્તારિત રેફરલ સહિત રેફરીની ચાલુ ડિપોઝિટનો એક ટકા તમે કમાઓ છો',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'રેફરલ કમાણી વડે ગેમ રમવા માટે, તમારે નીચેની ટ્રાન્સફર સુવિધા વાપરીને તમારી લાઇવ રેફરલ કમાણી રેફરલ પ્લે વોલેટમાં ટ્રાન્સફર કરવી પડશે ',
          'screen_label': 'સ્ક્રીન',
          'referral_wallet_lobby_and_my_earning':
              'રેફરલ વોલેટ લોબી અને મારી કમાણી',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'લાઇવ રેફરલ કમાણી બેલેન્સ રેફરલ પ્લે વોલેટમાં ટ્રાન્સફર કર્યા પછી, તમે તે બેલેન્સ ગેમ રમવા અથવા સીધી તમારા બેંક ખાતામાં ઉપાડ માટે વાપરી શકો છો',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'રેફરલ વોલેટમાં ટર્નઓવર પૂર્ણ કર્યા પછી bKash અથવા Nagadમાં રેફરલ પ્લે બેલેન્સ ઉપાડી શકાય છે. તમારા બેંક ખાતામાં પ્લે બેલેન્સ ઉપાડવા માટે અહીં સરળ ૫ પગલાં છે',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. રેફરલ વોલેટ લોબીમાં જાઓ\n2. રેફર અને કમાઓ ટેબ પર ક્લિક કરો\n3. ઉપાડ બટન પર ક્લિક કરો\n4. તમારો ઉપાડ મોડ પસંદ કરો (bKash અથવા Nagad)\n5. રકમ પસંદ કરો અને ઉપાડ કરો',
          'totals_earning': 'કુલ કમાણી',
          'direct_referrals': 'ડાયરેક્ટ રેફરલ',
          'indirect_referrals': 'ઇનડાયરેક્ટ રેફરલ',
          'extended_referrals': 'એક્સટેન્ડેડ રેફરલ',
          'your_top_active_referrals':
              'તમારા ટોચના સક્રિય રેફરલ',
          'no_referrals_found': 'કોઈ રેફરલ મળ્યા નથી',
          'you_received': 'તમને મળ્યું',
        },
        'kn': {
          'games': 'ಗೇಮ್‌ಗಳು',
          'back': 'ಹಿಂದಕ್ಕೆ',
          'load_more': 'ಹೆಚ್ಚು ಲೋಡ್ ಮಾಡಿ',
          'tabelgame': 'ಟೇಬಲ್ ಗೇಮ್',
          'esport': 'ಈ-ಸ್ಪೋರ್ಟ್ಸ್',
          'teenpatti': 'ಟೀನ್ ಪಟ್ಟಿ',
          'livedealer': 'ಲೈವ್ ಡೀಲರ್',
          'mostpopular': 'ಅತ್ಯಂತ ಜನಪ್ರಿಯ',
          'baccarat': 'ಬ್ಯಾಕರಾಟ್',
          'blackjack': 'ಬ್ಲ್ಯಾಕ್‌ಜ್ಯಾಕ್',
          'liveroulette': 'ಲೈವ್ ರೂಲೆಟ್',
          'topindiangames': 'ಟಾಪ್ ಇಂಡಿಯನ್ ಗೇಮ್ಸ್',
          'wheellottery': 'ವೀಲ್ & ಲಾಟರಿ',
          'rebate': 'ರಿಬೇಟ್',
          'lossback': 'ಲಾಸ್‌ಬ್ಯಾಕ್',
          'won': 'ಗೆದ್ದರು',
          'live_winner': 'ಲೈವ್ ವಿನ್ನರ್',
          'seconds_ago': 'ಸೆಕೆಂಡುಗಳ ಹಿಂದೆ',
          'hi': 'ಹಾಯ್',
          'search': 'ಹುಡುಕಿ',
          'search_text': 'ಹುಡುಕಿ',
          'amount': 'ಮೊತ್ತ',
          'follow_us': 'ನಮ್ಮನ್ನು ಅನುಸರಿಸಿ',
          'about_us': 'ನಮ್ಮ ಬಗ್ಗೆ',
          'download': 'ಡೌನ್‌ಲೋಡ್',
          'login_now': 'ಲಾಗಿನ್ ಆಗಿ',
          'ok': 'ಸರಿ',
          'daily': 'ದೈನಂದಿನ',
          'weekly': 'ಸಾಪ್ತಾಹಿಕ',
          'coming_soon': 'ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'ಲೈವ್ ಚಾಟ್',
          'okay': 'ಸರಿ',
          'localeName': 'ಕನ್ನಡ',
          'refer_and_earn': 'ರೆಫರ್ & ಗಳಿಸಿ',
          'refer_now': 'ಈಗ ರೆಫರ್ ಮಾಡಿ',
          'my_earning': 'ನನ್ನ ಗಳಿಕೆ',
          'withdrawal': 'ಹಿಂತೆಗೆದುಕೊಳ್ಳುವಿಕೆ',
          'withdraw': 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
          'withdraw_history': 'ಹಿಂತೆಗೆದುಕೊಳ್ಳುವಿಕೆ ಇತಿಹಾಸ',
          'statement_title': 'ಸ್ಟೇಟ್‌ಮೆಂಟ್',
          'and_earn_cash': 'ಮತ್ತು ನಗದು ಗಳಿಸಿ',
          'and_fund_transfer': 'ಮತ್ತು ಫಂಡ್ ವರ್ಗಾವಣೆ',
          'crypto_currency': 'ಕ್ರಿಪ್ಟೋ ನಾಣ್ಯಮುದ್ರೆ',
          'referral_lobby': 'ರೆಫರಲ್ ಲಾಬಿ',
          'referral_play_wallet': 'ರೆಫರಲ್ ಪ್ಲೇ ವಾಲೆಟ್',
          'transfer': 'ವರ್ಗಾವಣೆ',
          'your_referral_link': 'ನಿಮ್ಮ ರೆಫರಲ್ ಲಿಂಕ್',
          'tap_to_copy': 'ನಕಲೆದುಕೊಳ್ಳಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
          'how_referral_commission_works':
              'ರೆಫರಲ್ ಕಮಿಷನ್ ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ',
          'how_to_play_games_using_referral_earning':
              'ರೆಫರಲ್ ಗಳಿಕೆಯನ್ನು ಬಳಸಿ ಆಟಗಳನ್ನು ಹೇಗೆ ಆಡುವುದು',
          'how_to_withdraw': 'ಹೇಗೆ ಹಿಂತೆಗೆದುಕೊಳ್ಳುವುದು',
          'your_referral_earning_to_withdrawal_journey':
              'ನಿಮ್ಮ ರೆಫರಲ್ ಗಳಿಕೆಯಿಂದ ಹಿಂತೆಗೆದುಕೊಳ್ಳುವಿಕೆವರೆಗಿನ ಪ್ರಯಾಣ',
          'refer_to_friends': 'ಸ್ನೇಹಿತರಿಗೆ ರೆಫರ್ ಮಾಡಿ',
          'referral_earning_get_in_live_wallet':
              'ರೆಫರಲ್ ಗಳಿಕೆ ಲೈವ್ ವಾಲೆಟ್‌ನಲ್ಲಿ ಪಡೆಯಿರಿ',
          'transfer_fund_to_play_wallet':
              'ಪ್ಲೇ ವಾಲೆಟ್‌ಗೆ ಫಂಡ್ ವರ್ಗಾವಣೆ ಮಾಡಿ',
          'complete_turnover': 'ಟರ್ನೊವರ್ ಪೂರ್ಣಗೊಳಿಸಿ',
          'withdraw_in_bkash_or_nagad':
              'ಕ್ರಿಪ್ಟೋ ನಾಣ್ಯಮುದ್ರೆಯಲ್ಲಿ ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
          'downloadwinbajinow':
              'ಈಗ Playcrypto365 ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
          'transfer_to_main_wallet':
              'ಮುಖ್ಯ ವಾಲೆಟ್‌ಗೆ ವರ್ಗಾವಣೆ ಮಾಡಿ',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'ನಿಮ್ಮ ಸ್ನೇಹಿತರ ಪ್ರತಿ ಠೇವಣಿಯ ಮೇಲೆ ಜೀವಿತಾವಧಿ ಕಮಿಷನ್ ಗಳಿಸಿ',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'ನೇರ ರೆಫರಲ್, ಪರೋಕ್ಷ ರೆಫರಲ್ ಮತ್ತು ವಿಸ್ತೃತ ರೆಫರಲ್ ಸೇರಿದಂತೆ ರೆಫರಿಯ ನಡೆಯುತ್ತಿರುವ ಠೇವಣಿಯ ಒಂದು ಶೇಕಡಾ ನೀವು ಗಳಿಸುತ್ತೀರಿ',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'ರೆಫರಲ್ ಗಳಿಕೆ ಬಳಸಿ ಆಟಗಳನ್ನು ಆಡಲು, ಕೆಳಗಿನ ವರ್ಗಾವಣೆ ವೈಶಿಷ್ಟ್ಯವನ್ನು ಬಳಸಿ ನಿಮ್ಮ ಲೈವ್ ರೆಫರಲ್ ಗಳಿಕೆಯನ್ನು ರೆಫರಲ್ ಪ್ಲೇ ವಾಲೆಟ್‌ಗೆ ವರ್ಗಾಯಿಸಬೇಕು ',
          'screen_label': 'ಪರದೆ',
          'referral_wallet_lobby_and_my_earning':
              'ರೆಫರಲ್ ವಾಲೆಟ್ ಲಾಬಿ ಮತ್ತು ನನ್ನ ಗಳಿಕೆ',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'ಲೈವ್ ರೆಫರಲ್ ಗಳಿಕೆ ಬ್ಯಾಲೆನ್ಸ್ ಅನ್ನು ರೆಫರಲ್ ಪ್ಲೇ ವಾಲೆಟ್‌ಗೆ ವರ್ಗಾಯಿಸಿದ ನಂತರ, ಆ ಬ್ಯಾಲೆನ್ಸ್ ಅನ್ನು ಆಟಗಳನ್ನು ಆಡಲು ಅಥವಾ ನೇರವಾಗಿ ನಿಮ್ಮ ಬ್ಯಾಂಕ್ ಖಾತೆಗೆ ಹಿಂತೆಗೆದುಕೊಳ್ಳಲು ಬಳಸಬಹುದು',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'ರೆಫರಲ್ ವಾಲೆಟ್‌ನಲ್ಲಿ ಟರ್ನೊವರ್ ಪೂರ್ಣಗೊಳಿಸಿದ ನಂತರ bKash ಅಥವಾ Nagadನಲ್ಲಿ ರೆಫರಲ್ ಪ್ಲೇ ಬ್ಯಾಲೆನ್ಸ್ ಹಿಂತೆಗೆದುಕೊಳ್ಳಬಹುದು. ನಿಮ್ಮ ಬ್ಯಾಂಕ್ ಖಾತೆಗೆ ಪ್ಲೇ ಬ್ಯಾಲೆನ್ಸ್ ಹಿಂತೆಗೆದುಕೊಳ್ಳಲು ಇಲ್ಲಿ ಸರಳ ೫ ಹಂತಗಳಿವೆ',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. ರೆಫರಲ್ ವಾಲೆಟ್ ಲಾಬಿಗೆ ಹೋಗಿ\n2. ರೆಫರ್ ಮತ್ತು ಗಳಿಸಿ ಟ್ಯಾಬ್ ಮೇಲೆ ಕ್ಲಿಕ್ ಮಾಡಿ\n3. ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ ಬಟನ್ ಮೇಲೆ ಕ್ಲಿಕ್ ಮಾಡಿ\n4. ನಿಮ್ಮ ಹಿಂತೆಗೆದುಕೊಳ್ಳುವ ಮೋಡ್ ಆಯ್ಕೆಮಾಡಿ (bKash ಅಥವಾ Nagad)\n5. ಮೊತ್ತ ಆಯ್ಕೆಮಾಡಿ ಮತ್ತು ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
          'totals_earning': 'ಒಟ್ಟು ಗಳಿಕೆ',
          'direct_referrals': 'ಡೈರೆಕ್ಟ್ ರೆಫರಲ್ಸ್',
          'indirect_referrals': 'ಇನ್‌ಡೈರೆಕ್ಟ್ ರೆಫರಲ್ಸ್',
          'extended_referrals': 'ಎಕ್ಸ್‌ಟೆಂಡೆಡ್ ರೆಫರಲ್ಸ್',
          'your_top_active_referrals':
              'ನಿಮ್ಮ ಉನ್ನತ ಸಕ್ರಿಯ ರೆಫರಲ್ಸ್',
          'no_referrals_found':
              'ಯಾವುದೇ ರೆಫರಲ್ಸ್ ಕಂಡುಬಂದಿಲ್ಲ',
          'you_received': 'ನೀವು ಪಡೆದಿರಿ',
        },
        'ml': {
          'games': 'ഗെയിമുകൾ',
          'back': 'മടങ്ങുക',
          'load_more': 'കൂടുതൽ ലോഡ് ചെയ്യുക',
          'tabelgame': 'ടേബിൾ ഗെയിം',
          'esport': 'ഇ-സ്പോർട്സ്',
          'teenpatti': 'ടീൻ പട്ടി',
          'livedealer': 'ലൈവ് ഡീലർ',
          'mostpopular': 'ഏറ്റവും ജനപ്രിയം',
          'baccarat': 'ബാക്കരറ്റ്',
          'blackjack': 'ബ്ലാക്ക്ജാക്ക്',
          'liveroulette': 'ലൈവ് റൂലറ്റ്',
          'topindiangames': 'ടോപ്പ് ഇന്ത്യൻ ഗെയിമുകൾ',
          'wheellottery': 'വീൽ & ലോട്ടറി',
          'rebate': 'റിബേറ്റ്',
          'lossback': 'ലോസ്ബാക്ക്',
          'won': 'ജയിച്ചു',
          'live_winner': 'ലൈവ് വിന്നർ',
          'seconds_ago': 'സെക്കന്റുകൾ മുമ്പ്',
          'hi': 'ഹായ്',
          'search': 'തിരയുക',
          'search_text': 'തിരയുക',
          'amount': 'തുക',
          'follow_us': 'ഞങ്ങളെ പിന്തുടരൂ',
          'about_us': 'ഞങ്ങളെക്കുറിച്ച്',
          'download': 'ഡൗൺലോഡ്',
          'login_now': 'ലോഗിൻ ചെയ്യുക',
          'ok': 'ശരി',
          'daily': 'ദിവസേന',
          'weekly': 'പ്രതിവാര',
          'coming_soon': 'ഉടൻ വരുന്നു',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'തത്സമയ ചാറ്റ്',
          'okay': 'ശരി',
          'localeName': 'മലയാളം',
          'refer_and_earn': 'റെഫർ & സമ്പാദിക്കുക',
          'refer_now': 'ഇപ്പോൾ റെഫർ ചെയ്യുക',
          'my_earning': 'എന്റെ സമ്പാദ്യം',
          'withdrawal': 'പിൻവലിക്കൽ',
          'withdraw': 'പിൻവലിക്കുക',
          'withdraw_history': 'പിൻവലിക്കൽ ചരിത്രം',
          'statement_title': 'സ്റ്റേറ്റ്‌മെന്റ്',
          'and_earn_cash': 'കൂടാതെ നഗദ് സമ്പാദിക്കുക',
          'and_fund_transfer': 'കൂടാതെ ഫണ്ട് ട്രാൻസ്ഫർ',
          'crypto_currency': 'ക്രിപ്ടോ കറൻസി',
          'referral_lobby': 'റെഫറൽ ലോബി',
          'referral_play_wallet': 'റെഫറൽ പ്ലേ വാലറ്റ്',
          'transfer': 'ട്രാൻസ്ഫർ',
          'your_referral_link': 'നിങ്ങളുടെ റെഫറൽ ലിങ്ക്',
          'tap_to_copy': 'കോപ്പി ചെയ്യാൻ ടാപ്പ് ചെയ്യുക',
          'how_referral_commission_works':
              'റഫറൽ കമ്മീഷൻ എങ്ങനെ പ്രവർത്തിക്കുന്നു',
          'how_to_play_games_using_referral_earning':
              'റഫറൽ വരുമാനം ഉപയോഗിച്ച് ഗെയിമുകൾ എങ്ങനെ കളിക്കാം',
          'how_to_withdraw': 'എങ്ങനെ പിൻവലിക്കാം',
          'your_referral_earning_to_withdrawal_journey':
              'നിങ്ങളുടെ റെഫറൽ സമ്പാദ്യം മുതൽ പിൻവലിക്കൽ വരെയുള്ള യാത്ര',
          'refer_to_friends': 'സുഹൃത്തുക്കളെ റെഫർ ചെയ്യുക',
          'referral_earning_get_in_live_wallet':
              'റെഫറൽ സമ്പാദ്യം ലൈവ് വാലറ്റിൽ പ്രാപിക്കുക',
          'transfer_fund_to_play_wallet':
              'പ്ലേ വാലറ്റിലേക്ക് ഫണ്ട് ട്രാൻസ്ഫർ ചെയ്യുക',
          'complete_turnover': 'ടേണോവർ പൂർത്തിയാക്കുക',
          'withdraw_in_bkash_or_nagad':
              'ക്രിപ്ടോ കറൻസിയിൽ പിൻവലിക്കുക',
          'downloadwinbajinow':
              'ഇപ്പോൾ Playcrypto365 ഡൗണ്‍ലോഡ് ചെയ്യുക',
          'transfer_to_main_wallet':
              'പ്രധാന വാലറ്റിലേക്ക് ട്രാന്‍സ്ഫര്‍ ചെയ്യുക',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'നിങ്ങളുടെ സുഹൃത്തുക്കളുടെ ഓരോ നിക്ഷേപത്തിലും ആജീവനാന്ത കമ്മീഷൻ നേടുക',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'നേരിട്ടുള്ള റഫറൽ, പരോക്ഷ റഫറൽ, വിപുലീകൃത റഫറൽ എന്നിവ ഉൾപ്പെടെ റഫറിയുടെ തുടരുന്ന നിക്ഷേപത്തിന്റെ ഒരു ശതമാനം നിങ്ങൾ നേടുന്നു',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'റഫറൽ വരുമാനം ഉപയോഗിച്ച് ഗെയിമുകൾ കളിക്കാൻ, താഴെ പറയുന്ന ട്രാൻസ്ഫർ ഫീച്ചർ ഉപയോഗിച്ച് നിങ്ങളുടെ ലൈവ് റഫറൽ വരുമാനം റഫറൽ പ്ലേ വാലറ്റിലേക്ക് മാറ്റണം ',
          'screen_label': 'സ്ക്രീൻ',
          'referral_wallet_lobby_and_my_earning':
              'റഫറൽ വാലറ്റ് ലോബിയും എന്റെ വരുമാനവും',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'ലൈവ് റഫറൽ വരുമാന ബാലൻസ് റഫറൽ പ്ലേ വാലറ്റിലേക്ക് മാറ്റിയ ശേഷം, ആ ബാലൻസ് ഗെയിമുകൾ കളിക്കാനോ നേരിട്ട് നിങ്ങളുടെ ബാങ്ക് അക്കൗണ്ടിലേക്ക് പിൻവലിക്കാനോ ഉപയോഗിക്കാം',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'റഫറൽ വാലറ്റിൽ ടേണോവർ പൂർത്തിയാക്കിയ ശേഷം bKash അല്ലെങ്കിൽ Nagad-ൽ റഫറൽ പ്ലേ ബാലൻസ് പിൻവലിക്കാം. നിങ്ങളുടെ ബാങ്ക് അക്കൗണ്ടിൽ പ്ലേ ബാലൻസ് പിൻവലിക്കാൻ ഇവിടെ ലളിതമായ 5 ഘട്ടങ്ങൾ ഉണ്ട്',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. റഫറൽ വാലറ്റ് ലോബിയിലേക്ക് പോകുക\n2. റഫർ ചെയ്ത് നേടുക ടാബിൽ ക്ലിക്ക് ചെയ്യുക\n3. പിൻവലിക്കൽ ബട്ടണിൽ ക്ലിക്ക് ചെയ്യുക\n4. നിങ്ങളുടെ പിൻവലിക്കൽ മോഡ് തിരഞ്ഞെടുക്കുക (bKash അല്ലെങ്കിൽ Nagad)\n5. തുക തിരഞ്ഞെടുത്ത് പിൻവലിക്കുക',
          'totals_earning': 'ആകെ വരുമാനം',
          'direct_referrals': 'ഡയറക്ട് റഫറൽസ്',
          'indirect_referrals': 'ഇൻഡയറക്ട് റഫറൽസ്',
          'extended_referrals': 'എക്സ്റ്റെൻഡഡ് റഫറൽസ്',
          'your_top_active_referrals':
              'നിങ്ങളുടെ മികച്ച സജീവ റഫറൽസ്',
          'no_referrals_found':
              'റഫറൽസ് ഒന്നും കണ്ടെത്തിയില്ല',
          'you_received': 'നിങ്ങൾക്ക് ലഭിച്ചു',
        },
        'pa': {
          'games': 'ਗੇਮਜ਼',
          'back': 'ਪਿੱਛੇ',
          'load_more': 'ਹੋਰ ਲੋਡ ਕਰੋ',
          'tabelgame': 'ਟੇਬਲ ਗੇਮ',
          'esport': 'ਈ-ਸਪੋਰਟਸ',
          'teenpatti': 'ਤੀਨ ਪੱਤੀ',
          'livedealer': 'ਲਾਈਵ ਡੀਲਰ',
          'mostpopular': 'ਸਭ ਤੋਂ ਪ੍ਰਸਿੱਧ',
          'baccarat': 'ਬੈਕਰੈਟ',
          'blackjack': 'ਬਲੈਕਜੈਕ',
          'liveroulette': 'ਲਾਈਵ ਰੂਲੇਟ',
          'topindiangames': 'ਟੌਪ ਇੰਡੀਅਨ ਗੇਮਜ਼',
          'wheellottery': 'ਵ੍ਹੀਲ ਅਤੇ ਲਾਟਰੀ',
          'rebate': 'ਰਿਬੇਟ',
          'lossback': 'ਲੌਸਬੈਕ',
          'won': 'ਜਿੱਤੇ',
          'live_winner': 'ਲਾਈਵ ਵਿਨਰ',
          'seconds_ago': 'ਸਕਿੰਟ ਪਹਿਲਾਂ',
          'hi': 'ਹਾਏ',
          'search': 'ਖੋਜੋ',
          'search_text': 'ਖੋਜੋ',
          'amount': 'ਰਕਮ',
          'follow_us': 'ਸਾਨੂੰ ਫੌਲੋ ਕਰੋ',
          'about_us': 'ਸਾਡੇ ਬਾਰੇ',
          'download': 'ਡਾਊਨਲੋਡ',
          'login_now': 'ਲੌਗਿਨ ਕਰੋ',
          'ok': 'ਠੀਕ ਹੈ',
          'daily': 'ਰੋਜ਼ਾਨਾ',
          'weekly': 'ਹਫਤਾਵਾਰੀ',
          'coming_soon': 'ਜਲਦ ਆ ਰਿਹਾ ਹੈ',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'ਲਾਈਵ ਚੈਟ',
          'okay': 'ਠੀਕ ਹੈ',
          'localeName': 'ਪੰਜਾਬੀ',
          'refer_and_earn': 'ਰੈਫਰ ਤੇ ਕਮਾਓ',
          'refer_now': 'ਹੁਣੇ ਰੈਫਰ ਕਰੋ',
          'my_earning': 'ਮੇਰੀ ਕਮਾਈ',
          'withdrawal': 'ਵਿਥਡ੍ਰਾਵਲ',
          'withdraw': 'ਕਢਵਾਓ',
          'withdraw_history': 'ਵਿਥਡ੍ਰਾ ਇਤਿਹਾਸ',
          'statement_title': 'ਸਟੇਟਮੈਂਟ',
          'and_earn_cash': 'ਅਤੇ ਨਕਦ ਕਮਾਓ',
          'and_fund_transfer': 'ਅਤੇ ਫੰਡ ਟ੍ਰਾਂਸਫਰ',
          'crypto_currency': 'ਕ੍ਰਿਪਟੋ ਕਰੰਸੀ',
          'referral_lobby': 'ਰੈਫਰਲ ਲੌਬੀ',
          'referral_play_wallet': 'ਰੈਫਰਲ ਪ੍ਲੇ ਵਾਲੇਟ',
          'transfer': 'ਟ੍ਰਾਂਸਫਰ',
          'your_referral_link': 'ਤੁਹਾਡਾ ਰੈਫਰਲ ਲਿੰਕ',
          'tap_to_copy': 'ਕਾਪੀ ਕਰਨ ਲਈ ਟੈਪ ਕਰੋ',
          'how_referral_commission_works':
              'ਰੈਫਰਲ ਕਮਿਸ਼ਨ ਕਿਵੇਂ ਕੰਮ ਕਰਦੀ ਹੈ',
          'how_to_play_games_using_referral_earning':
              'ਰੈਫਰਲ ਕਮਾਈ ਨਾਲ ਗੇਮ ਕਿਵੇਂ ਖੇਡਣੇ',
          'how_to_withdraw': 'ਕਿਵੇਂ ਵਿਥਡ੍ਰਾ ਕਰਨੀ',
          'your_referral_earning_to_withdrawal_journey':
              'ਤੁਹਾਡੀ ਰੈਫਰਲ ਕਮਾਈ ਤੋਂ ਵਿਥਡ੍ਰਾ ਤੱਕ ਦੀ ਯਾਤਰਾ',
          'refer_to_friends': 'ਦੋਸਤਾਂ ਨੂੰ ਰੈਫਰ ਕਰੋ',
          'referral_earning_get_in_live_wallet':
              'ਰੈਫਰਲ ਕਮਾਈ ਲਾਈਵ ਵਾਲੇਟ ਵਿੱਚ ਪ੍ਰਾਪਤ ਕਰੋ',
          'transfer_fund_to_play_wallet':
              'ਪ੍ਲੇ ਵਾਲੇਟ ਵਿੱਚ ਫੰਡ ਟ੍ਰਾਂਸਫਰ ਕਰੋ',
          'complete_turnover': 'ਟਰਨਓਵਰ ਪੂਰਾ ਕਰੋ',
          'withdraw_in_bkash_or_nagad':
              'ਕ੍ਰਿਪਟੋ ਕਰੰਸੀ ਵਿੱਚ ਵਿਥਡ੍ਰਾ ਕਰੋ',
          'downloadwinbajinow':
              'ਹੁਣੇ Playcrypto365 ਡਾਊਨਲੋਡ ਕਰੋ',
          'transfer_to_main_wallet':
              'ਮੁੱਖ ਵਾਲੇਟ ਵਿੱਚ ਟ੍ਰਾਂਸਫਰ ਕਰੋ',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'ਆਪਣੇ ਦੋਸਤਾਂ ਦੇ ਹਰ ਜਮ੍ਹਾਂ ਤੇ ਉਮਰ ਭਰ ਕਮਿਸ਼ਨ ਕਮਾਓ',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'ਸਿੱਧੇ ਰੈਫਰਲ, ਅਸਿੱਧੇ ਰੈਫਰਲ ਅਤੇ ਵਿਸਤ੍ਰਿਤ ਰੈਫਰਲ ਸਮੇਤ ਰੈਫਰੀ ਦੀ ਚੱਲ ਰਹੀ ਜਮ੍ਹਾਂ ਰਕਮ ਦਾ ਇੱਕ ਪ੍ਰਤੀਸ਼ਤ ਤੁਸੀਂ ਕਮਾਉਂਦੇ ਹੋ',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'ਰੈਫਰਲ ਕਮਾਈ ਨਾਲ ਗੇਮਾਂ ਖੇਡਣ ਲਈ, ਤੁਹਾਨੂੰ ਹੇਠ ਲਿਖੀ ਟ੍ਰਾਂਸਫਰ ਸੁਵਿਧਾ ਵਰਤ ਕੇ ਆਪਣੀ ਲਾਈਵ ਰੈਫਰਲ ਕਮਾਈ ਨੂੰ ਰੈਫਰਲ ਪਲੇ ਵਾਲੇਟ ਵਿੱਚ ਟ੍ਰਾਂਸਫਰ ਕਰਨਾ ਪਵੇਗਾ ',
          'screen_label': 'ਸਕ੍ਰੀਨ',
          'referral_wallet_lobby_and_my_earning':
              'ਰੈਫਰਲ ਵਾਲੇਟ ਲਾਬੀ ਅਤੇ ਮੇਰੀ ਕਮਾਈ',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'ਲਾਈਵ ਰੈਫਰਲ ਕਮਾਈ ਬੈਲੇਂਸ ਨੂੰ ਰੈਫਰਲ ਪਲੇ ਵਾਲੇਟ ਵਿੱਚ ਟ੍ਰਾਂਸਫਰ ਕਰਨ ਤੋਂ ਬਾਅਦ, ਤੁਸੀਂ ਉਹ ਬੈਲੇਂਸ ਗੇਮਾਂ ਖੇਡਣ ਜਾਂ ਸਿੱਧੇ ਆਪਣੇ ਬੈਂਕ ਖਾਤੇ ਵਿੱਚ ਕਢਵਾਉਣ ਲਈ ਵਰਤ ਸਕਦੇ ਹੋ',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'ਰੈਫਰਲ ਵਾਲੇਟ ਵਿੱਚ ਟਰਨਓਵਰ ਪੂਰਾ ਕਰਨ ਤੋਂ ਬਾਅਦ bKash ਜਾਂ Nagad ਵਿੱਚ ਰੈਫਰਲ ਪਲੇ ਬੈਲੇਂਸ ਕਢਵਾ ਸਕਦੇ ਹੋ। ਤੁਹਾਡੇ ਬੈਂਕ ਖਾਤੇ ਵਿੱਚ ਪਲੇ ਬੈਲੇਂਸ ਕਢਵਾਉਣ ਲਈ ਇੱਥੇ ਸੌਖੇ ੫ ਕਦਮ ਹਨ',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. ਰੈਫਰਲ ਵਾਲੇਟ ਲਾਬੀ ਤੇ ਜਾਓ\n2. ਰੈਫਰ ਅਤੇ ਕਮਾਓ ਟੈਬ ਤੇ ਕਲਿੱਕ ਕਰੋ\n3. ਕਢਵਾਉਣ ਬਟਨ ਤੇ ਕਲਿੱਕ ਕਰੋ\n4. ਆਪਣਾ ਕਢਵਾਉਣ ਮੋਡ ਚੁਣੋ (bKash ਜਾਂ Nagad)\n5. ਰਕਮ ਚੁਣੋ ਅਤੇ ਕਢਵਾਓ',
          'totals_earning': 'ਕੁੱਲ ਕਮਾਈ',
          'direct_referrals': 'ਡਾਇਰੈਕਟ ਰੈਫਰਲ',
          'indirect_referrals': 'ਇਨਡਾਇਰੈਕਟ ਰੈਫਰਲ',
          'extended_referrals': 'ਐਕਸਟੈਂਡਿਡ ਰੈਫਰਲ',
          'your_top_active_referrals':
              'ਤੁਹਾਡੇ ਸਿਖਰ ਦੇ ਸਰਗਰਮ ਰੈਫਰਲ',
          'no_referrals_found': 'ਕੋਈ ਰੈਫਰਲ ਨਹੀਂ ਮਿਲਿਆ',
          'you_received': 'ਤੁਸੀਂ ਪ੍ਰਾਪਤ ਕੀਤਾ',
        },
        'ur': {
          'games': 'گیمز',
          'back': 'واپس',
          'load_more': 'مزید لوڈ کریں',
          'tabelgame': 'ٹیبل گیم',
          'esport': 'ای-اسپورٹس',
          'teenpatti': 'تین پتی',
          'livedealer': 'لائیو ڈیلر',
          'mostpopular': 'سب سے مقبول',
          'baccarat': 'بیکارٹ',
          'blackjack': 'بلیک جیک',
          'liveroulette': 'لائیو رولیٹ',
          'topindiangames': 'ٹاپ انڈین گیمز',
          'wheellottery': 'وہیل اور لاٹری',
          'rebate': 'ریبیٹ',
          'lossback': 'لاس بیک',
          'won': 'جیتا',
          'live_winner': 'لائیو ونر',
          'seconds_ago': 'سیکنڈ پہلے',
          'hi': 'ہائے',
          'search': 'تلاش',
          'search_text': 'تلاش',
          'amount': 'رقم',
          'follow_us': 'ہمیں فالو کریں',
          'about_us': 'ہمارے بارے میں',
          'download': 'ڈاؤن لوڈ',
          'login_now': 'لاگ ان کریں',
          'ok': 'ٹھیک ہے',
          'daily': 'روزانہ',
          'weekly': 'ہفتہ وار',
          'coming_soon': 'جلد آ رہا ہے',
          'welcometo': 'Welcome to ',
          'scamalert': '',
          'appdescription': '',
          'livechat': 'لائیو چیٹ',
          'okay': 'ٹھیک ہے',
          'localeName': 'اردو',
          'refer_and_earn': 'ریفر اور کمائیں',
          'refer_now': 'ابھی ریفر کریں',
          'my_earning': 'میری کمائی',
          'withdrawal': 'نکاسی',
          'withdraw': 'نکالیں',
          'withdraw_history': 'نکاسی کی تاریخ',
          'statement_title': 'سٹیٹمنٹ',
          'and_earn_cash': 'اور نقد کمائیں',
          'and_fund_transfer': 'اور فنڈ ٹرانسفر',
          'crypto_currency': 'کرپٹو کرنسی',
          'referral_lobby': 'ریفرل لابی',
          'referral_play_wallet': 'ریفرل پلے والٹ',
          'transfer': 'ٹرانسفر',
          'your_referral_link': 'آپ کا ریفرل لنک',
          'tap_to_copy': 'کاپی کرنے کے لیے ٹیپ کریں',
          'how_referral_commission_works':
              'ریفرل کمیشن کیسے کام کرتا ہے',
          'how_to_play_games_using_referral_earning':
              'ریفرل کمائی سے گیم کیسے کھیلیں',
          'how_to_withdraw': 'نکاسی کیسے کریں',
          'your_referral_earning_to_withdrawal_journey':
              'آپ کی ریفرل کمائی سے نکاسی تک کا سفر',
          'refer_to_friends': 'دوستوں کو ریفر کریں',
          'referral_earning_get_in_live_wallet':
              'ریفرل کمائی لائیو والٹ میں حاصل کریں',
          'transfer_fund_to_play_wallet':
              'پلے والٹ میں فنڈ ٹرانسفر کریں',
          'complete_turnover': 'ٹرن اوور مکمل کریں',
          'withdraw_in_bkash_or_nagad':
              'کرپٹو کرنسی میں نکاسی کریں',
          'downloadwinbajinow':
              'ابھی Playcrypto365 ڈاؤن لوڈ کریں',
          'transfer_to_main_wallet':
              'مین والٹ میں ٹرانسفر کریں',
          'earn_life_time_commission_on_your_friends_every_deposit':
              'اپنے دوستوں کی ہر جمع پر تاحیات کمیشن کمائیں',
          'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
              'براہ راست ریفرل، بالواسطہ ریفرل اور توسیعی ریفرل سمیت ریفری کی جاری جمع کا ایک فیصد آپ کماتے ہیں',
          'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
              'ریفرل آمدنی سے گیمز کھیلنے کے لیے، آپ کو درج ذیل ٹرانسفر فیچر استعمال کر کے اپنی لائیو ریفرل آمدنی کو ریفرل پلے والٹ میں ٹرانسفر کرنا ہوگا ',
          'screen_label': 'اسکرین',
          'referral_wallet_lobby_and_my_earning':
              'ریفرل والٹ لابی اور میری آمدنی',
          'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
              'لائیو ریفرل آمدنی بیلنس کو ریفرل پلے والٹ میں ٹرانسفر کرنے کے بعد، آپ اس بیلنس کو گیمز کھیلنے یا براہ راست اپنے بینک اکاؤنٹ میں نکالنے کے لیے استعمال کر سکتے ہیں',
          'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
              'ریفرل والٹ میں ٹرن اوور مکمل کرنے کے بعد bKash یا Nagad میں ریفرل پلے بیلنس نکال سکتے ہیں۔ اپنے بینک اکاؤنٹ میں پلے بیلنس نکالنے کے لیے یہاں آسان ۵ اقدامات ہیں',
          'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
              '1. ریفرل والٹ لابی میں جائیں\n2. ریفر اور کمائیں ٹیب پر کلک کریں\n3. نکاسی بٹن پر کلک کریں\n4. اپنا نکاسی موڈ منتخب کریں (bKash یا Nagad)\n5. رقم منتخب کریں اور نکاسی کریں',
          'totals_earning': 'کل آمدنی',
          'direct_referrals': 'ڈائریکٹ ریفرلز',
          'indirect_referrals': 'ان ڈائریکٹ ریفرلز',
          'extended_referrals': 'ایکسٹینڈڈ ریفرلز',
          'your_top_active_referrals':
              'آپ کے ٹاپ ایکٹو ریفرلز',
          'no_referrals_found': 'کوئی ریفرل نہیں ملا',
          'you_received': 'آپ کو ملا',
        },
      },
      'auth': {
        'hi': {
          'login': 'लॉगिन',
          'register': 'रजिस्टर',
          'password': 'पासवर्ड',
          'oops': 'उफ़!',
          'okay': 'ठीक है',
          'forgotpassword': 'पासवर्ड भूल गए',
          'letssignyouin': 'चलिए साइन इन करते हैं',
          'pleaseprovidepassword': 'कृपया पासवर्ड दें',
          'invalidcredential': 'गलत क्रेडेंशियल',
          'submit': 'सबमिट',
          'resetyourpassword': 'अपना पासवर्ड रीसेट करें',
          'enterOTP': 'OTP दर्ज करें',
          'invalidOTP': 'अमान्य OTP',
          'newpassword': 'नया पासवर्ड',
          'passwordshould6characters':
              'पासवर्ड 6 अक्षर का होना चाहिए',
          'changepassword': 'पासवर्ड बदलें',
          'createyouraccounr': 'अपना अकाउंट बनाएं',
          'verify': 'वेरीफाई',
          'create': 'बनाएं',
          'add_bank_account': 'बैंक अकाउंट जोड़ें',
          'invalid_bank_name': 'अमान्य बैंक नाम',
          'invalidname': 'अमान्य नाम',
          'bankaccountholdername':
              'बैंक अकाउंट होल्डर का नाम',
          'bankaccountnumber': 'बैंक अकाउंट नंबर',
          'invalidaccountnumber': 'अमान्य अकाउंट नंबर',
          'add_account': 'अकाउंट जोड़ें',
          'my_accounts': 'मेरे अकाउंट्स',
          'account': 'अकाउंट',
          'invalidmobilenumber': 'अमान्य मोबाइल नंबर',
          'registration_completed': 'रजिस्ट्रेशन पूरा हुआ',
          'registration_successful': 'रजिस्ट्रेशन सफल',
          'youmayonlyperformthisactionevery30seconds':
              'आप यह क्रिया 30 सेकंड में एक बार कर सकते हैं',
          'rewards': 'रिवॉर्ड्स',
          'adddepositinyourwallet':
              'अपने वॉलेट में डिपॉजिट जोड़ें',
          'makearequestforwithdraw':
              'विदड्रॉ रिक्वेस्ट करें',
          'install_update': 'अपडेट इंस्टॉल करें',
          'restart': 'रीस्टार्ट',
          'logout_confirmation':
              'क्या आप लॉगआउट करना चाहते हैं?',
          'cancel': 'रद्द करें',
          'mobile_number': 'मोबाइल नंबर',
          'i_agree_terms':
              'मैं नियमों और शर्तों और गोपनीयता नीति से सहमत हूँ',
          'whatsapp_number': 'व्हाट्सएप नंबर',
          'enter_whatsapp_number':
              'व्हाट्सएप नंबर दर्ज करें',
          'please_enter_mobile_or_email':
              'कृपया अपना मोबाइल या ईमेल दर्ज करें',
          'enter_valid_email':
              'कृपया एक वैध ईमेल पता दर्ज करें',
          'send_otps': 'ओटीपी भेजें',
          'we_will_send_otp_info':
              'हम आपके व्हाट्सएप और ईमेल पर ओटीपी भेजेंगे।',
          'loss_back_title': '100% लॉस बैक',
          'loss_back_desc':
              'अपने पहले डिपॉजिट पर 100% लॉस बैक पाएं।',
          'please_enter_email':
              'कृपया अपना ईमेल पता दर्ज करें',
          'enter_whatsapp_otp': 'व्हाट्सएप ओटीपी दर्ज करें',
          'enter_email_otp': 'ईमेल ओटीपी दर्ज करें',
          'login_with_otp': 'ओटीपी से लॉगिन करें',
          'login_with_password': 'पासवर्ड से लॉगिन करें',
          'resend_otp': 'ओटीपी पुनः भेजें',
          'didntreceivecode':
              'कोड प्राप्त नहीं हुआ? पुनः भेजें',
          'enter_email_address': 'ईमेल पता दर्ज करें',
          'enter_password': 'अपना पासवर्ड दर्ज करें',
          'edit_email': 'ईमेल संपादित करें',
          'edit_mobile': 'मोबाइल नंबर संपादित करें',
          'enter_mobile': 'मोबाइल नंबर दर्ज करें',
          'field_required': 'यह क्षेत्र आवश्यक है',
          'invalid_email': 'कृपया एक वैध ईमेल दर्ज करें',
          'save_changes': 'बदलाव सहेजें',
          'update_success': 'सफलतापूर्वक अपडेट हुआ',
          'not_set': 'सेट नहीं है',
          'current_password': 'वर्तमान पासवर्ड',
          'enter_current_password':
              'वर्तमान पासवर्ड दर्ज करें',
          'enter_new_password': 'नया पासवर्ड दर्ज करें',
          'confirm_new_password': 'नया पासवर्ड पुष्टि करें',
          're_enter_password':
              'नया पासवर्ड दोबारा दर्ज करें',
          'please_enter_current_password':
              'कृपया अपना वर्तमान पासवर्ड दर्ज करें',
          'please_enter_new_password':
              'कृपया नया पासवर्ड दर्ज करें',
          'please_confirm_password':
              'कृपया अपना नया पासवर्ड पुष्टि करें',
          'passwords_do_not_match': 'पासवर्ड मेल नहीं खाते',
          'password_changed_success':
              'पासवर्ड सफलतापूर्वक बदला गया',
          'password_updated':
              'आपका पासवर्ड अपडेट हो गया है।',
          'secure_account_hint':
              'अपने अकाउंट को सुरक्षित करने के लिए\nएक मजबूत पासवर्ड बनाएं',
          'password_requirement_hint':
              'पासवर्ड कम से कम 6 अक्षर का होना चाहिए और इसमें अक्षरों और संख्याओं का मिश्रण होना चाहिए।',
          'settings': 'सेटिंग्स',
        },
        'te': {
          'login': 'లాగిన్',
          'register': 'రిజిస్టర్',
          'password': 'పాస్‌వర్డ్',
          'oops': 'అయ్యో!',
          'okay': 'సరే',
          'forgotpassword': 'పాస్‌వర్డ్ మర్చిపోయారా',
          'letssignyouin': 'సైన్ ఇన్ చేద్దాం',
          'pleaseprovidepassword':
              'దయచేసి పాస్‌వర్డ్ ఇవ్వండి',
          'invalidcredential': 'చెల్లని క్రెడెన్షియల్',
          'submit': 'సబ్మిట్',
          'resetyourpassword':
              'మీ పాస్‌వర్డ్ రీసెట్ చేయండి',
          'enterOTP': 'OTP నమోదు చేయండి',
          'invalidOTP': 'చెల్లని OTP',
          'newpassword': 'కొత్త పాస్‌వర్డ్',
          'passwordshould6characters':
              'పాస్‌వర్డ్ 6 అక్షరాలు ఉండాలి',
          'changepassword': 'పాస్‌వర్డ్ మార్చండి',
          'createyouraccounr': 'మీ ఖాతా సృష్టించండి',
          'verify': 'వెరిఫై',
          'create': 'సృష్టించు',
          'add_bank_account': 'బ్యాంక్ ఖాతా జోడించండి',
          'invalid_bank_name': 'చెల్లని బ్యాంక్ పేరు',
          'invalidname': 'చెల్లని పేరు',
          'bankaccountholdername':
              'బ్యాంక్ ఖాతా హోల్డర్ పేరు',
          'bankaccountnumber': 'బ్యాంక్ ఖాతా నంబర్',
          'invalidaccountnumber': 'చెల్లని ఖాతా నంబర్',
          'add_account': 'ఖాతా జోడించండి',
          'my_accounts': 'నా ఖాతాలు',
          'account': 'ఖాతా',
          'invalidmobilenumber': 'చెల్లని మొబైల్ నంబర్',
          'registration_completed':
              'రిజిస్ట్రేషన్ పూర్తయింది',
          'registration_successful':
              'రిజిస్ట్రేషన్ విజయవంతం',
          'play_games': 'గేమ్‌లు ఆడండి',
          'youmayonlyperformthisactionevery30seconds':
              'మీరు ఈ చర్యను 30 సెకన్లకు ఒకసారి చేయగలరు',
          'rewards': 'రివార్డ్‌లు',
          'adddepositinyourwallet':
              'మీ వాలెట్‌లో డిపాజిట్ జోడించండి',
          'makearequestforwithdraw':
              'విత్‌డ్రా రిక్వెస్ట్ చేయండి',
          'install_update': 'అప్‌డేట్ ఇన్‌స్టాల్ చేయండి',
          'restart': 'రీస్టార్ట్',
          'logout_confirmation':
              'మీరు లాగ్‌అవుట్ చేయాలనుకుంటున్నారా?',
          'cancel': 'రద్దు',
          'mobile_number': 'మొబైల్ నంబర్',
          'i_agree_terms':
              'నేను నిబంధనలు మరియు షరతులు మరియు గోప్యతా విధానానికి అంగీకరిస్తున్నాను',
          'whatsapp_number': 'వాట్సాప్ నంబర్',
          'enter_whatsapp_number':
              'వాట్సాప్ నంబర్ నమోదు చేయండి',
          'please_enter_mobile_or_email':
              'దయచేసి మీ మొబైల్ లేదా ఈమెయిల్ నమోదు చేయండి',
          'enter_valid_email':
              'దయచేసి చెల్లుబాటు అయ్యే ఈమెయిల్ అడ్రస్ నమోదు చేయండి',
          'send_otps': 'OTPలను పంపండి',
          'we_will_send_otp_info':
              'మేము మీ వాట్సాప్ మరియు ఈమెయిల్ కు OTPని పంపుతాము.',
          'loss_back_title': '100% లాస్ బ్యాక్',
          'loss_back_desc':
              'మీ మొదటి డిపాజిట్‌పై 100% లాస్ బ్యాక్ పొందండి.',
          'please_enter_email':
              'దయచేసి మీ ఇమెయిల్ చిరునామాను నమోదు చేయండి',
          'enter_whatsapp_otp':
              'వాట్సాప్ ఓటిపి ని నమోదు చేయండి',
          'enter_email_otp':
              'ఇమెయిల్ ఓటిపి ని నమోదు చేయండి',
          'login_with_otp': 'OTP తో లాగిన్ అవ్వండి',
          'login_with_password': 'పాస్‌వర్డ్ తో లాగిన్',
          'resend_otp': 'ఓటిపి ని మళ్ళీ పంపండి',
          'didntreceivecode': 'కోడ్ రాలేదా? మళ్ళీ పంపండి',
          'enter_email_address':
              'ఇమెయిల్ అడ్రస్ నమోదు చేయండి',
          'enter_password': 'మీ పాస్‌వర్డ్ నమోదు చేయండి',
          'email_otp': 'ఇమెయిల్ OTP',
          'mobile_or_email': 'మొబైల్ లేదా ఇమెయిల్',
          'enter_mobile_or_email':
              'మొబైల్ లేదా ఇమెయిల్ నమోదు చేయండి',
          'somethingwentwrong':
              'ఏదో తప్పు జరిగింది. దయచేసి మళ్ళీ ప్రయత్నించండి.',
          'select_verification_method':
              'ధృవీకరణ పద్ధతిని ఎంచుకోండి',
          'mobile': 'మొబైల్',
          'email': 'ఇమెయిల్',
          'enter_mobile_number':
              'మొబైల్ నంబర్ నమోదు చేయండి',
          'send_otp': 'OTP పంపండి',
          'otp_sent_to_mobile':
              'మేము మీ మొబైల్‌కు OTP పంపుతాము.',
          'otp_sent_to_email':
              'మేము మీ ఇమెయిల్‌కు OTP పంపుతాము.',
          'edit': 'మార్చండి',
          'enter_otp': 'OTP నమోదు చేయండి',
          'resend_in': 'మళ్ళీ పంపు',
          'edit_email': 'ఇమెయిల్ మార్చండి',
          'edit_mobile': 'మొబైల్ నంబర్ మార్చండి',
          'enter_mobile': 'మొబైల్ నంబర్ నమోదు చేయండి',
          'field_required': 'ఈ ఫీల్డ్ అవసరం',
          'invalid_email':
              'దయచేసి చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి',
          'save_changes': 'మార్పులు సేవ్ చేయండి',
          'update_success': 'విజయవంతంగా అప్‌డేట్ చేయబడింది',
          'not_set': 'సెట్ చేయబడలేదు',
          'current_password': 'ప్రస్తుత పాస్‌వర్డ్',
          'enter_current_password':
              'ప్రస్తుత పాస్‌వర్డ్ నమోదు చేయండి',
          'enter_new_password':
              'కొత్త పాస్‌వర్డ్ నమోదు చేయండి',
          'confirm_new_password':
              'కొత్త పాస్‌వర్డ్ నిర్ధారించండి',
          're_enter_password':
              'కొత్త పాస్‌వర్డ్ మళ్ళీ నమోదు చేయండి',
          'please_enter_current_password':
              'దయచేసి మీ ప్రస్తుత పాస్‌వర్డ్ నమోదు చేయండి',
          'please_enter_new_password':
              'దయచేసి కొత్త పాస్‌వర్డ్ నమోదు చేయండి',
          'please_confirm_password':
              'దయచేసి మీ కొత్త పాస్‌వర్డ్ నిర్ధారించండి',
          'passwords_do_not_match':
              'పాస్‌వర్డ్‌లు సరిపోలడం లేదు',
          'password_changed_success':
              'పాస్‌వర్డ్ విజయవంతంగా మార్చబడింది',
          'password_updated':
              'మీ పాస్‌వర్డ్ అప్‌డేట్ చేయబడింది.',
          'secure_account_hint':
              'మీ ఖాతాను భద్రపరచడానికి\nబలమైన పాస్‌వర్డ్ సృష్టించండి',
          'password_requirement_hint':
              'పాస్‌వర్డ్ కనీసం 6 అక్షరాల పొడవు ఉండాలి మరియు అక్షరాలు మరియు సంఖ్యల మిశ్రమాన్ని కలిగి ఉండాలి.',
          'settings': 'సెట్టింగ్‌లు',
        },
        'bn': {
          'login': 'লগইন',
          'register': 'রেজিস্টার',
          'password': 'পাসওয়ার্ড',
          'oops': 'উফ্!',
          'okay': 'ঠিক আছে',
          'forgotpassword': 'পাসওয়ার্ড ভুলে গেছেন',
          'letssignyouin': 'সাইন ইন করা যাক',
          'pleaseprovidepassword':
              'অনুগ্রহ করে পাসওয়ার্ড দিন',
          'invalidcredential': 'অবৈধ তথ্য',
          'submit': 'সাবমিট',
          'resetyourpassword':
              'আপনার পাসওয়ার্ড রিসেট করুন',
          'enterOTP': 'ওটিপি লিখুন',
          'invalidOTP': 'অবৈধ ওটিপি',
          'newpassword': 'নতুন পাসওয়ার্ড',
          'passwordshould6characters':
              'পাসওয়ার্ড 6 অক্ষরের হতে হবে',
          'changepassword': 'পাসওয়ার্ড পরিবর্তন করুন',
          'createyouraccounr': 'আপনার অ্যাকাউন্ট তৈরি করুন',
          'verify': 'ভেরিফাই',
          'create': 'তৈরি করুন',
          'add_bank_account': 'ব্যাংক অ্যাকাউন্ট যোগ করুন',
          'invalid_bank_name': 'অবৈধ ব্যাংক নাম',
          'invalidname': 'অবৈধ নাম',
          'bankaccountholdername':
              'ব্যাংক অ্যাকাউন্ট হোল্ডারের নাম',
          'bankaccountnumber': 'ব্যাংক অ্যাকাউন্ট নম্বর',
          'invalidaccountnumber': 'অবৈধ অ্যাকাউন্ট নম্বর',
          'add_account': 'অ্যাকাউন্ট যোগ করুন',
          'my_accounts': 'আমার অ্যাকাউন্টস',
          'account': 'অ্যাকাউন্ট',
          'invalidmobilenumber': 'অবৈধ মোবাইল নম্বর',
          'registration_completed': 'রেজিস্ট্রেশন সম্পন্ন',
          'registration_successful': 'রেজিস্ট্রেশন সফল',
          'play_games': 'গেম খেলুন',
          'youmayonlyperformthisactionevery30seconds':
              'আপনি এই ক্রিয়াটি 30 সেকেন্ডে একবার করতে পারবেন',
          'rewards': 'রিওয়ার্ডস',
          'adddepositinyourwallet':
              'আপনার ওয়ালেটে ডিপোজিট যোগ করুন',
          'makearequestforwithdraw':
              'উইথড্র রিকোয়েস্ট করুন',
          'install_update': 'আপডেট ইনস্টল করুন',
          'restart': 'রিস্টার্ট',
          'logout_confirmation': 'আপনি কি লগআউট করতে চান?',
          'cancel': 'বাতিল',
          'mobile_number': 'মোবাইল নম্বর',
          'i_agree_terms':
              'আমি নিয়ম ও শর্তাবলী এবং গোপনীয়তা নীতিতে সম্মত',
          'whatsapp_number': 'হোয়াটসঅ্যাপ নম্বর',
          'enter_whatsapp_number':
              'হোয়াটসঅ্যাপ নম্বর লিখুন',
          'please_enter_mobile_or_email':
              'অনুগ্রহ করে আপনার মোবাইল বা ইমেল লিখুন',
          'enter_valid_email':
              'অনুগ্রহ করে একটি বৈধ ইমেল ঠিকানা লিখুন',
          'send_otps': 'ওটিপি পাঠান',
          'we_will_send_otp_info':
              'আমরা আপনার হোয়াটসঅ্যাপ এবং ইমেলে ওটিপি পাঠাব।',
          'loss_back_title': '১০০% লস ব্যাক',
          'loss_back_desc':
              'আপনার প্রথম ডিপোজিটে ১০০% লস ব্যাক পান।',
          'please_enter_email':
              'অনুগ্রহ করে আপনার ইমেল ঠিকানা লিখুন',
          'enter_whatsapp_otp': 'হোয়াটসঅ্যাপ ওটিপি লিখুন',
          'enter_email_otp': 'ইমেল ওটিপি লিখুন',
          'login_with_otp': 'ওটিপি দিয়ে লগইন করুন',
          'login_with_password': 'পাসওয়ার্ড দিয়ে লগইন',
          'resend_otp': 'ওটিপি আবার পাঠান',
          'didntreceivecode': 'কোড পাননি? আবার পাঠান',
          'enter_email_address': 'ইমেল ঠিকানা লিখুন',
          'enter_password': 'আপনার পাসওয়ার্ড লিখুন',
          'edit_email': 'ইমেল সম্পাদনা করুন',
          'edit_mobile': 'মোবাইল নম্বর সম্পাদনা করুন',
          'enter_mobile': 'মোবাইল নম্বর লিখুন',
          'field_required': 'এই ক্ষেত্রটি আবশ্যক',
          'invalid_email': 'অনুগ্রহ করে সঠিক ইমেল দিন',
          'save_changes': 'পরিবর্তন সংরক্ষণ করুন',
          'update_success': 'সফলভাবে আপডেট হয়েছে',
          'not_set': 'সেট করা হয়নি',
          'current_password': 'বর্তমান পাসওয়ার্ড',
          'enter_current_password':
              'বর্তমান পাসওয়ার্ড লিখুন',
          'enter_new_password': 'নতুন পাসওয়ার্ড লিখুন',
          'confirm_new_password':
              'নতুন পাসওয়ার্ড নিশ্চিত করুন',
          're_enter_password': 'নতুন পাসওয়ার্ড আবার লিখুন',
          'please_enter_current_password':
              'অনুগ্রহ করে আপনার বর্তমান পাসওয়ার্ড লিখুন',
          'please_enter_new_password':
              'অনুগ্রহ করে নতুন পাসওয়ার্ড লিখুন',
          'please_confirm_password':
              'অনুগ্রহ করে আপনার নতুন পাসওয়ার্ড নিশ্চিত করুন',
          'passwords_do_not_match': 'পাসওয়ার্ড মিলছে না',
          'password_changed_success':
              'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে',
          'password_updated':
              'আপনার পাসওয়ার্ড আপডেট হয়েছে।',
          'secure_account_hint':
              'আপনার অ্যাকাউন্ট সুরক্ষিত করতে\nএকটি শক্তিশালী পাসওয়ার্ড তৈরি করুন',
          'password_requirement_hint':
              'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর দীর্ঘ হতে হবে এবং অক্ষর ও সংখ্যার মিশ্রণ থাকতে হবে।',
          'settings': 'সেটিংস',
        },
        'mr': {
          'login': 'लॉगिन',
          'register': 'रजिस्टर',
          'password': 'पासवर्ड',
          'oops': 'अरेरे!',
          'okay': 'ठीक आहे',
          'forgotpassword': 'पासवर्ड विसरलात',
          'letssignyouin': 'साइन इन करूया',
          'pleaseprovidepassword': 'कृपया पासवर्ड द्या',
          'invalidcredential': 'अवैध माहिती',
          'submit': 'सबमिट',
          'resetyourpassword': 'तुमचा पासवर्ड रीसेट करा',
          'enterOTP': 'ओटीपी प्रविष्ट करा',
          'invalidOTP': 'अवैध ओटीपी',
          'newpassword': 'नवीन पासवर्ड',
          'passwordshould6characters':
              'पासवर्ड 6 अक्षरांचा असावा',
          'changepassword': 'पासवर्ड बदला',
          'createyouraccounr': 'तुमचे अकाउंट तयार करा',
          'verify': 'व्हेरिफाय',
          'create': 'तयार करा',
          'add_bank_account': 'बँक अकाउंट जोडा',
          'invalid_bank_name': 'अवैध बँक नाव',
          'invalidname': 'अवैध नाव',
          'bankaccountholdername': 'बँक खातेधारकाचे नाव',
          'bankaccountnumber': 'बँक खाते क्रमांक',
          'invalidaccountnumber': 'अवैध खाते क्रमांक',
          'add_account': 'अकाउंट जोडा',
          'my_accounts': 'माझे अकाउंट्स',
          'account': 'अकाउंट',
          'invalidmobilenumber': 'अवैध मोबाइल नंबर',
          'registration_completed': 'नोंदणी पूर्ण झाली',
          'registration_successful': 'नोंदणी यशस्वी',
          'play_games': 'गेम खेळा',
          'youmayonlyperformthisactionevery30seconds':
              'तुम्ही ही क्रिया 30 सेकंदात एकदाच करू शकता',
          'rewards': 'रिवॉर्ड्स',
          'adddepositinyourwallet':
              'तुमच्या वॉलेटमध्ये डिपॉजिट जोडा',
          'makearequestforwithdraw':
              'विदड्रॉ रिक्वेस्ट करा',
          'install_update': 'अपडेट इन्स्टॉल करा',
          'restart': 'रीस्टार्ट',
          'logout_confirmation':
              'तुम्हाला लॉगआउट करायचे आहे का?',
          'cancel': 'रद्द करा',
          'mobile_number': 'मोबाइल नंबर',
          'i_agree_terms':
              'मी अटी आणि शर्ती आणि गोपनीयता धोरणाशी सहमत आहे',
          'whatsapp_number': 'व्हॉट्सॲप नंबर',
          'enter_whatsapp_number':
              'व्हॉट्सॲप नंबर प्रविष्ट करा',
          'please_enter_mobile_or_email':
              'कृपया तुमचा मोबाईल किंवा ईमेल प्रविष्ट करा',
          'enter_valid_email':
              'कृपया वैध ईमेल पत्ता प्रविष्ट करा',
          'send_otps': 'ओटीपी पाठवा',
          'we_will_send_otp_info':
              'आम्ही तुमच्या व्हॉट्सॲप आणि ईमेलवर ओटीपी पाठवू.',
          'loss_back_title': '100% लॉस बॅक',
          'loss_back_desc':
              'तुमच्या पहिल्या डिपॉझिटवर 100% लॉस बॅक मिळवा.',
          'please_enter_email':
              'कृपया आपला ईमेल पत्ता प्रविष्ट करा',
          'enter_whatsapp_otp':
              'व्हॉट्सॲप ओटीपी प्रविष्ट करा',
          'enter_email_otp': 'ईमेल ओटीपी प्रविष्ट करा',
          'login_with_otp': 'OTP सह लॉगिन करा',
          'login_with_password': 'पासवर्ड सह लॉगिन करा',
          'resend_otp': 'ओटीपी पुन्हा पाठवा',
          'didntreceivecode':
              'कोड मिळाला नाही? पुन्हा पाठवा',
          'enter_email_address': 'ईमेल पत्ता प्रविष्ट करा',
          'enter_password': 'तुमचा पासवर्ड प्रविष्ट करा',
          'edit_email': 'ईमेल संपादित करा',
          'edit_mobile': 'मोबाईल नंबर संपादित करा',
          'enter_mobile': 'मोबाईल नंबर प्रविष्ट करा',
          'field_required': 'हे क्षेत्र आवश्यक आहे',
          'invalid_email': 'कृपया वैध ईमेल प्रविष्ट करा',
          'save_changes': 'बदल जतन करा',
          'update_success': 'यशस्वीरित्या अद्ययावत केले',
          'not_set': 'सेट केलेले नाही',
          'current_password': 'सध्याचा पासवर्ड',
          'enter_current_password':
              'सध्याचा पासवर्ड प्रविष्ट करा',
          'enter_new_password': 'नवीन पासवर्ड प्रविष्ट करा',
          'confirm_new_password': 'नवीन पासवर्ड पुष्टी करा',
          're_enter_password':
              'नवीन पासवर्ड पुन्हा प्रविष्ट करा',
          'please_enter_current_password':
              'कृपया तुमचा सध्याचा पासवर्ड प्रविष्ट करा',
          'please_enter_new_password':
              'कृपया नवीन पासवर्ड प्रविष्ट करा',
          'please_confirm_password':
              'कृपया तुमचा नवीन पासवर्ड पुष्टी करा',
          'passwords_do_not_match': 'पासवर्ड जुळत नाहीत',
          'password_changed_success':
              'पासवर्ड यशस्वीरित्या बदलला',
          'password_updated':
              'तुमचा पासवर्ड अद्ययावत झाला आहे.',
          'secure_account_hint':
              'तुमचे खाते सुरक्षित करण्यासाठी\nएक मजबूत पासवर्ड तयार करा',
          'password_requirement_hint':
              'पासवर्ड किमान 6 अक्षरांचा असावा आणि त्यात अक्षरे आणि संख्यांचे मिश्रण असावे.',
          'settings': 'सेटिंग्ज',
        },
        'ta': {
          'login': 'உள்நுழைவு',
          'register': 'பதிவு',
          'password': 'கடவுச்சொல்',
          'oops': 'அட!',
          'okay': 'சரி',
          'forgotpassword': 'கடவுச்சொல் மறந்துவிட்டதா',
          'letssignyouin': 'உள்நுழையலாம்',
          'pleaseprovidepassword': 'கடவுச்சொல்லை வழங்கவும்',
          'invalidcredential': 'தவறான சான்றுகள்',
          'submit': 'சமர்ப்பிக்கவும்',
          'resetyourpassword':
              'உங்கள் கடவுச்சொல்லை மீட்டமைக்கவும்',
          'enterOTP': 'OTP ஐ உள்ளிடவும்',
          'invalidOTP': 'தவறான OTP',
          'newpassword': 'புதிய கடவுச்சொல்',
          'passwordshould6characters':
              'கடவுச்சொல் 6 எழுத்துகள் இருக்க வேண்டும்',
          'changepassword': 'கடவுச்சொல்லை மாற்றவும்',
          'createyouraccounr':
              'உங்கள் கணக்கை உருவாக்குங்கள்',
          'verify': 'சரிபார்க்கவும்',
          'create': 'உருவாக்கு',
          'add_bank_account': 'வங்கி கணக்கு சேர்க்கவும்',
          'invalid_bank_name': 'தவறான வங்கி பெயர்',
          'invalidname': 'தவறான பெயர்',
          'bankaccountholdername':
              'வங்கி கணக்கு வைத்திருப்பவர் பெயர்',
          'bankaccountnumber': 'வங்கி கணக்கு எண்',
          'invalidaccountnumber': 'தவறான கணக்கு எண்',
          'add_account': 'கணக்கு சேர்க்கவும்',
          'my_accounts': 'என் கணக்குகள்',
          'account': 'கணக்கு',
          'invalidmobilenumber': 'தவறான மொபைல் எண்',
          'registration_completed': 'பதிவு நிறைவடைந்தது',
          'registration_successful':
              'பதிவு வெற்றிகரமாக முடிந்தது',
          'play_games': 'விளையாட்டுகளை விளையாடுங்கள்',
          'youmayonlyperformthisactionevery30seconds':
              'இந்தச் செயலை 30 வினாடிகளுக்கு ஒருமுறை மட்டுமே செய்ய முடியும்',
          'rewards': 'ரிவார்ட்ஸ்',
          'adddepositinyourwallet':
              'உங்கள் வாலட்டில் டெபாசிட் சேர்க்கவும்',
          'makearequestforwithdraw':
              'வித்ட்ரா ரிக்வெஸ்ட் செய்யவும்',
          'install_update': 'அப்டேட் இன்ஸ்டால் செய்யவும்',
          'restart': 'ரீஸ்டார்ட்',
          'logout_confirmation':
              'நீங்கள் லாக்அவுட் செய்ய விரும்புகிறீர்களா?',
          'cancel': 'ரத்து',
          'mobile_number': 'மொபைல் எண்',
          'i_agree_terms':
              'நான் விதிமுறைகள் மற்றும் நிபந்தனைகள் மற்றும் தனியுரிமைக் கொள்கையை ஒப்புக்கொள்கிறேன்',
          'whatsapp_number': 'வாட்ஸ்அப் எண்',
          'enter_whatsapp_number':
              'வாட்ஸ்அப் எண்ணை உள்ளிடவும்',
          'please_enter_mobile_or_email':
              'தயவுசெய்து உங்கள் மொபைல் அல்லது மின்னஞ்சலை உள்ளிடவும்',
          'enter_valid_email':
              'தயவுசெய்து சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்',
          'send_otps': 'OTP களை அனுப்பவும்',
          'we_will_send_otp_info':
              'உங்கள் வாட்ஸ்அப் மற்றும் மின்னஞ்சலுக்கு OTP ஐ அனுப்புவோம்.',
          'loss_back_title': '100% லாஸ் பேக்',
          'loss_back_desc':
              'உங்கள் முதல் டெபாசிட்டில் 100% லாஸ் பேக் பெறுங்கள்.',
          'please_enter_email':
              'தயவுசெய்து உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும்',
          'enter_whatsapp_otp':
              'வாட்ஸ்அப் OTP ஐ உள்ளிடவும்',
          'enter_email_otp': 'மின்னஞ்சல் OTP ஐ உள்ளிடவும்',
          'login_with_otp': 'OTP மூலம் உள்நுழையவும்',
          'login_with_password':
              'கடவுச்சொல் மூலம் உள்நுழையவும்',
          'resend_otp': 'OTP ஐ மீண்டும் அனுப்பவும்',
          'didntreceivecode':
              'குறியீடு வரவில்லையா? மீண்டும் அனுப்பவும்',
          'enter_email_address':
              'மின்னஞ்சல் முகவரியை உள்ளிடவும்',
          'enter_password':
              'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
          'edit_email': 'மின்னஞ்சல் திருத்தவும்',
          'edit_mobile': 'மொபைல் எண்ணை திருத்தவும்',
          'enter_mobile': 'மொபைல் எண்ணை உள்ளிடவும்',
          'field_required': 'இந்த புலம் தேவை',
          'invalid_email': 'சரியான மின்னஞ்சலை உள்ளிடவும்',
          'save_changes': 'மாற்றங்களை சேமிக்கவும்',
          'update_success':
              'வெற்றிகரமாக புதுப்பிக்கப்பட்டது',
          'not_set': 'அமைக்கப்படவில்லை',
          'current_password': 'தற்போதைய கடவுச்சொல்',
          'enter_current_password':
              'தற்போதைய கடவுச்சொல்லை உள்ளிடவும்',
          'enter_new_password':
              'புதிய கடவுச்சொல்லை உள்ளிடவும்',
          'confirm_new_password':
              'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்',
          're_enter_password':
              'புதிய கடவுச்சொல்லை மீண்டும் உள்ளிடவும்',
          'please_enter_current_password':
              'தயவுசெய்து உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்',
          'please_enter_new_password':
              'தயவுசெய்து புதிய கடவுச்சொல்லை உள்ளிடவும்',
          'please_confirm_password':
              'தயவுசெய்து உங்கள் புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்',
          'passwords_do_not_match':
              'கடவுச்சொற்கள் பொருந்தவில்லை',
          'password_changed_success':
              'கடவுச்சொல் வெற்றிகரமாக மாற்றப்பட்டது',
          'password_updated':
              'உங்கள் கடவுச்சொல் புதுப்பிக்கப்பட்டது.',
          'secure_account_hint':
              'உங்கள் கணக்கைப் பாதுகாக்க\nவலுவான கடவுச்சொல்லை உருவாக்கவும்',
          'password_requirement_hint':
              'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் நீளமாக இருக்க வேண்டும் மற்றும் எழுத்துகள் மற்றும் எண்களின் கலவையைக் கொண்டிருக்க வேண்டும்.',
          'settings': 'அமைப்புகள்',
        },
        'gu': {
          'login': 'લોગિન',
          'register': 'રજિસ્ટર',
          'password': 'પાસવર્ડ',
          'oops': 'અરે!',
          'okay': 'ઠીક છે',
          'forgotpassword': 'પાસવર્ડ ભૂલી ગયા',
          'letssignyouin': 'ચાલો તમને સાઇન ઇન કરીએ',
          'pleaseprovidepassword': 'કૃપા કરીને પાસવર્ડ આપો',
          'invalidcredential': 'અમાન્ય ઓળખપત્ર',
          'submit': 'સબમિટ',
          'resetyourpassword': 'તમારો પાસવર્ડ રીસેટ કરો',
          'enterOTP': 'OTP દાખલ કરો',
          'invalidOTP': 'અમાન્ય OTP',
          'newpassword': 'નવો પાસવર્ડ',
          'passwordshould6characters':
              'પાસવર્ડ 6 અક્ષરનો હોવો જોઈએ',
          'changepassword': 'પાસવર્ડ બદલો',
          'createyouraccounr': 'તમારું એકાઉન્ટ બનાવો',
          'verify': 'વેરિફાય',
          'create': 'બનાવો',
          'add_bank_account': 'બેંક એકાઉન્ટ ઉમેરો',
          'invalid_bank_name': 'અમાન્ય બેંક નામ',
          'invalidname': 'અમાન્ય નામ',
          'bankaccountholdername':
              'બેંક એકાઉન્ટ ધારકનું નામ',
          'bankaccountnumber': 'બેંક એકાઉન્ટ નંબર',
          'invalidaccountnumber': 'અમાન્ય એકાઉન્ટ નંબર',
          'add_account': 'એકાઉન્ટ ઉમેરો',
          'my_accounts': 'મારા એકાઉન્ટ્સ',
          'account': 'એકાઉન્ટ',
          'invalidmobilenumber': 'અમાન્ય મોબાઇલ નંબર',
          'registration_completed': 'નોંધણી પૂર્ણ થઈ',
          'registration_successful': 'નોંધણી સફળ',
          'play_games': 'ગેમ્સ રમો',
          'youmayonlyperformthisactionevery30seconds':
              'તમે આ ક્રિયા દર 30 સેકન્ડમાં એકવાર કરી શકો છો',
          'rewards': 'રિવોર્ડ્સ',
          'adddepositinyourwallet':
              'તમારા વૉલેટમાં ડિપોઝિટ ઉમેરો',
          'makearequestforwithdraw':
              'વિથડ્રો રિક્વેસ્ટ કરો',
          'install_update': 'અપડેટ ઇન્સ્ટોલ કરો',
          'restart': 'રીસ્ટાર્ટ',
          'logout_confirmation':
              'શું તમે લોગઆઉટ કરવા માંગો છો?',
          'cancel': 'રદ કરો',
          'mobile_number': 'મોબાઈલ નંબર',
          'i_agree_terms':
              'હું નિયમો અને શરતો અને ગોપનીયતા નીતિ સાથે સંમત છું',
          'whatsapp_number': 'વોટ્સએપ નંબર',
          'enter_whatsapp_number': 'વોટ્સએપ નંબર દાખલ કરો',
          'please_enter_mobile_or_email':
              'કૃપા કરીને તમારો મોબાઇલ અથવા ઇમેઇલ દાખલ કરો',
          'enter_valid_email':
              'કૃપા કરીને માન્ય ઇમેઇલ સરનામું દાખલ કરો',
          'send_otps': 'OTP મોકલો',
          'we_will_send_otp_info':
              'અમે તમારા વોટ્સએપ અને ઇમેઇલ પર OTP મોકલીશું.',
          'loss_back_title': '100% લોસ બેક',
          'loss_back_desc':
              'તમારા પ્રથમ ડિપોઝિટ પર 100% લોસ બેક મેળવો.',
          'please_enter_email':
              'કૃપા કરીને તમારું ઇમેઇલ સરનામું દાખલ કરો',
          'enter_whatsapp_otp': 'વોટ્સએપ OTP દાખલ કરો',
          'enter_email_otp': 'ઇમેઇલ OTP દાખલ કરો',
          'login_with_otp': 'OTP સાથે લોગિન કરો',
          'login_with_password': 'પાસવર્ડ સાથે લોગિન કરો',
          'resend_otp': 'OTP ફરીથી મોકલો',
          'didntreceivecode': 'કોડ મળ્યો નથી? ફરીથી મોકલો',
          'enter_email_address': 'ઇમેઇલ સરનામું દાખલ કરો',
          'enter_password': 'તમારો પાસવર્ડ દાખલ કરો',
          'edit_email': 'ઇમેઇલ સંપાદિત કરો',
          'edit_mobile': 'મોબાઇલ નંબર સંપાદિત કરો',
          'enter_mobile': 'મોબાઇલ નંબર દાખલ કરો',
          'field_required': 'આ ક્ષેત્ર જરૂરી છે',
          'invalid_email': 'કૃપા કરી માન્ય ઇમેઇલ દાખલ કરો',
          'save_changes': 'ફેરફારો સાચવો',
          'update_success': 'સફળતાપૂર્વક અપડેટ થયું',
          'not_set': 'સેટ નથી',
          'current_password': 'વર્તમાન પાસવર્ડ',
          'enter_current_password':
              'વર્તમાન પાસવર્ડ દાખલ કરો',
          'enter_new_password': 'નવો પાસવર્ડ દાખલ કરો',
          'confirm_new_password': 'નવો પાસવર્ડ પુષ્ટિ કરો',
          're_enter_password': 'નવો પાસવર્ડ ફરીથી દાખલ કરો',
          'please_enter_current_password':
              'કૃપા કરીને તમારો વર્તમાન પાસવર્ડ દાખલ કરો',
          'please_enter_new_password':
              'કૃપા કરીને નવો પાસવર્ડ દાખલ કરો',
          'please_confirm_password':
              'કૃપા કરીને તમારો નવો પાસવર્ડ પુષ્ટિ કરો',
          'passwords_do_not_match': 'પાસવર્ડ મેળ ખાતા નથી',
          'password_changed_success':
              'પાસવર્ડ સફળતાપૂર્વક બદલાયો',
          'password_updated': 'તમારો પાસવર્ડ અપડેટ થયો છે.',
          'secure_account_hint':
              'તમારા ખાતાને સુરક્ષિત કરવા\nએક મજબૂત પાસવર્ડ બનાવો',
          'password_requirement_hint':
              'પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ અને તેમાં અક્ષરો અને સંખ્યાઓનું મિશ્રણ હોવું જોઈએ.',
          'settings': 'સેટિંગ્સ',
        },
        'kn': {
          'login': 'ಲಾಗಿನ್',
          'register': 'ನೋಂದಣಿ',
          'password': 'ಪಾಸ್‌ವರ್ಡ್',
          'oops': 'ಅಯ್ಯೋ!',
          'okay': 'ಸರಿ',
          'forgotpassword': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿದ್ದೀರಾ',
          'letssignyouin': 'ನಿಮ್ಮನ್ನು ಸೈನ್ ಇನ್ ಮಾಡೋಣ',
          'pleaseprovidepassword':
              'ದಯವಿಟ್ಟು ಪಾಸ್‌ವರ್ಡ್ ಒದಗಿಸಿ',
          'invalidcredential': 'ಅಮಾನ್ಯ ರುಜುವಾತುಗಳು',
          'submit': 'ಸಲ್ಲಿಸು',
          'resetyourpassword':
              'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ',
          'enterOTP': 'OTP ನಮೂದಿಸಿ',
          'invalidOTP': 'ಅಮಾನ್ಯ OTP',
          'newpassword': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್',
          'passwordshould6characters':
              'ಪಾಸ್‌ವರ್ಡ್ 6 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು',
          'changepassword': 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಯಿಸಿ',
          'createyouraccounr': 'ನಿಮ್ಮ ಖಾತೆ ರಚಿಸಿ',
          'verify': 'ವೆರಿಫೈ',
          'create': 'ರಚಿಸು',
          'add_bank_account': 'ಬ್ಯಾಂಕ್ ಖಾತೆ ಸೇರಿಸಿ',
          'invalid_bank_name': 'ಅಮಾನ್ಯ ಬ್ಯಾಂಕ್ ಹೆಸರು',
          'invalidname': 'ಅಮಾನ್ಯ ಹೆಸರು',
          'bankaccountholdername': 'ಬ್ಯಾಂಕ್ ಖಾತೆದಾರರ ಹೆಸರು',
          'bankaccountnumber': 'ಬ್ಯಾಂಕ್ ಖಾತೆ ಸಂಖ್ಯೆ',
          'invalidaccountnumber': 'ಅಮಾನ್ಯ ಖಾತೆ ಸಂಖ್ಯೆ',
          'add_account': 'ಖಾತೆ ಸೇರಿಸಿ',
          'my_accounts': 'ನನ್ನ ಖಾತೆಗಳು',
          'account': 'ಖಾತೆ',
          'invalidmobilenumber': 'ಅಮಾನ್ಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
          'registration_completed': 'ನೋಂದಣಿ ಪೂರ್ಣಗೊಂಡಿದೆ',
          'registration_successful': 'ನೋಂದಣಿ ಯಶಸ್ವಿಯಾಗಿದೆ',
          'play_games': 'ಆಟಗಳನ್ನು ಆಡಿ',
          'youmayonlyperformthisactionevery30seconds':
              'ನೀವು ಈ ಕ್ರಿಯೆಯನ್ನು ಪ್ರತಿ 30 ಸೆಕೆಂಡ್‌ಗಳಿಗೆ ಒಮ್ಮೆ ಮಾತ್ರ ನಿರ್ವಹಿಸಬಹುದು',
          'rewards': 'ರಿವಾರ್ಡ್‌ಗಳು',
          'adddepositinyourwallet':
              'ನಿಮ್ಮ ವಾಲೆಟ್‌ಗೆ ಡಿಪಾಸಿಟ್ ಸೇರಿಸಿ',
          'makearequestforwithdraw':
              'ವಿತ್‌ಡ್ರಾ ವಿನಂತಿ ಮಾಡಿ',
          'install_update': 'ಅಪ್‌ಡೇಟ್ ಸ್ಥಾಪಿಸಿ',
          'restart': 'ಮರುಪ್ರಾರಂಭಿಸಿ',
          'logout_confirmation':
              'ನೀವು ಲಾಗ್‌ಔಟ್ ಮಾಡಲು ಬಯಸುವಿರಾ?',
          'cancel': 'ರದ್ದುಮಾಡಿ',
          'mobile_number': 'ಮೊಬೈಲ್ ನಂಬರ್',
          'i_agree_terms':
              'ನಾನು ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು ಮತ್ತು ಗೌಪ್ಯತಾ ನೀತಿಗೆ ಒಪ್ಪುತ್ತೇನೆ',
          'whatsapp_number': 'ವಾಟ್ಸಾಪ್ ಸಂಖ್ಯೆ',
          'enter_whatsapp_number':
              'ವಾಟ್ಸಾಪ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
          'please_enter_mobile_or_email':
              'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಮೊಬೈಲ್ ಅಥವಾ ಇಮೇಲ್ ನಮೂದಿಸಿ',
          'enter_valid_email':
              'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ',
          'send_otps': 'OTP ಗಳನ್ನು ಕಳುಹಿಸಿ',
          'we_will_send_otp_info':
              'ನಿಮ್ಮ ವಾಟ್ಸಾಪ್ ಮತ್ತು ಇಮೇಲ್‌ಗೆ ನಾವು OTP ಕಳುಹಿಸುತ್ತೇವೆ.',
          'loss_back_title': '100% ಲಾಸ್ ಬ್ಯಾಕ್',
          'loss_back_desc':
              'ನಿಮ್ಮ ಮೊದಲ ಠೇವಣಿಯ ಮೇಲೆ 100% ಲಾಸ್ ಬ್ಯಾಕ್ ಪಡೆಯಿರಿ.',
          'please_enter_email':
              'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ',
          'enter_whatsapp_otp': 'ವಾಟ್ಸಾಪ್ OTP ನಮೂದಿಸಿ',
          'enter_email_otp': 'ಇಮೇಲ್ OTP ನಮೂದಿಸಿ',
          'login_with_otp': 'OTP ಯೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಿ',
          'login_with_password':
              'ಪಾಸ್‌ವರ್ಡ್‌ನೊಂದಿಗೆ ಲಾಗಿನ್',
          'resend_otp': 'OTP ಅನ್ನು ಮರುಕಳುಹಿಸಿ',
          'didntreceivecode':
              'ಕೋಡ್ ಸ್ವೀಕರಿಸಿಲ್ಲವೇ? ಮರುಕಳುಹಿಸಿ',
          'enter_email_address': 'ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ',
          'enter_password': 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
          'edit_email': 'ಇಮೇಲ್ ಸಂಪಾದಿಸಿ',
          'edit_mobile': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ಸಂಪಾದಿಸಿ',
          'enter_mobile': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ',
          'field_required': 'ಈ ಕ್ಷೇತ್ರ ಅಗತ್ಯವಿದೆ',
          'invalid_email': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಇಮೇಲ್ ನಮೂದಿಸಿ',
          'save_changes': 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ',
          'update_success': 'ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ',
          'not_set': 'ಹೊಂದಿಸಲಾಗಿಲ್ಲ',
          'current_password': 'ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್',
          'enter_current_password':
              'ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
          'enter_new_password': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
          'confirm_new_password':
              'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
          're_enter_password':
              'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಮರಳಿ ನಮೂದಿಸಿ',
          'please_enter_current_password':
              'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
          'please_enter_new_password':
              'ದಯವಿಟ್ಟು ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ',
          'please_confirm_password':
              'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ',
          'passwords_do_not_match':
              'ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ',
          'password_changed_success':
              'ಪಾಸ್‌ವರ್ಡ್ ಯಶಸ್ವಿಯಾಗಿ ಬದಲಾಯಿಸಲಾಗಿದೆ',
          'password_updated':
              'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನವೀಕರಿಸಲಾಗಿದೆ.',
          'secure_account_hint':
              'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಸುರಕ್ಷಿತಗೊಳಿಸಲು\nಬಲವಾದ ಪಾಸ್‌ವರ್ಡ್ ರಚಿಸಿ',
          'password_requirement_hint':
              'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳ ಉದ್ದವಿರಬೇಕು ಮತ್ತು ಅಕ್ಷರಗಳು ಮತ್ತು ಸಂಖ್ಯೆಗಳ ಮಿಶ್ರಣವನ್ನು ಒಳಗೊಂಡಿರಬೇಕು.',
          'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
        },
        'ml': {
          'login': 'ലോഗിൻ',
          'register': 'രജിസ്റ്റർ',
          'password': 'പാസ്‌വേഡ്',
          'oops': 'ഓ!',
          'okay': 'ശരി',
          'forgotpassword': 'പാസ്‌വേഡ് മറന്നോ',
          'letssignyouin': 'നിങ്ങളെ സൈൻ ഇൻ ചെയ്യാം',
          'pleaseprovidepassword': 'ദയവായി പാസ്‌വേഡ് നൽകുക',
          'invalidcredential': 'അസാധുവായ ക്രെഡൻഷ്യലുകൾ',
          'submit': 'സമർപ്പിക്കുക',
          'resetyourpassword':
              'നിങ്ങളുടെ പാസ്‌വേഡ് റീസെറ്റ് ചെയ്യുക',
          'enterOTP': 'OTP നൽകുക',
          'invalidOTP': 'അസാധുവായ OTP',
          'newpassword': 'പുതിയ പാസ്‌വേഡ്',
          'passwordshould6characters':
              'പാസ്‌വേഡ് 6 അക്ഷരങ്ങളായിരിക്കണം',
          'changepassword': 'പാസ്‌വേഡ് മാറ്റുക',
          'createyouraccounr':
              'നിങ്ങളുടെ അക്കൗണ്ട് സൃഷ്ടിക്കുക',
          'verify': 'വെരിഫൈ',
          'create': 'സൃഷ്ടിക്കുക',
          'add_bank_account': 'ബാങ്ക് അക്കൗണ്ട് ചേർക്കുക',
          'invalid_bank_name': 'അസാധുവായ ബാങ്ക് പേര്',
          'invalidname': 'അസാധുവായ പേര്',
          'bankaccountholdername':
              'ബാങ്ക് അക്കൗണ്ട് ഉടമയുടെ പേര്',
          'bankaccountnumber': 'ബാങ്ക് അക്കൗണ്ട് നമ്പർ',
          'invalidaccountnumber':
              'അസാധുവായ അക്കൗണ്ട് നമ്പർ',
          'add_account': 'അക്കൗണ്ട് ചേർക്കുക',
          'my_accounts': 'എന്റെ അക്കൗണ്ടുകൾ',
          'account': 'അക്കൗണ്ട്',
          'invalidmobilenumber': 'അസാധുവായ മൊബൈൽ നമ്പർ',
          'registration_completed':
              'രജിസ്ട്രേഷൻ പൂർത്തിയായി',
          'registration_successful': 'രജിസ്ട്രേഷൻ വിജയകരം',
          'play_games': 'ഗെയിമുകൾ കളിക്കുക',
          'youmayonlyperformthisactionevery30seconds':
              'നിങ്ങൾക്ക് ഈ പ്രവർത്തനം 30 സെക്കൻഡിൽ ഒരിക്കൽ മാത്രമേ ചെയ്യാൻ കഴിയൂ',
          'rewards': 'റിവാർഡുകൾ',
          'adddepositinyourwallet':
              'നിങ്ങളുടെ വാലറ്റിൽ ഡെപ്പോസിറ്റ് ചേർക്കുക',
          'makearequestforwithdraw':
              'വിഥ്ഡ്രോ ആവശ്യപ്പെടുക',
          'install_update': 'അപ്ഡേറ്റ് ഇൻസ്റ്റാൾ ചെയ്യുക',
          'restart': 'പുനരാരംഭിക്കുക',
          'logout_confirmation':
              'നിങ്ങൾ ലോഗൗട്ട് ചെയ്യാൻ ആഗ്രഹിക്കുന്നുണ്ടോ?',
          'cancel': 'റദ്ദാക്കുക',
          'mobile_number': 'മൊബൈൽ നമ്പർ',
          'i_agree_terms':
              'ഞാൻ നിബന്ധനകളും വ്യവസ്ഥകളും സ്വകാര്യതാ നയവും അംഗീകരിക്കുന്നു',
          'whatsapp_number': 'വാട്ട്‌സ്ആപ്പ് നമ്പർ',
          'enter_whatsapp_number':
              'വാട്ട്‌സ്ആപ്പ് നമ്പർ നൽകുക',
          'please_enter_mobile_or_email':
              'ദയവായി നിങ്ങളുടെ മൊബൈൽ അല്ലെങ്കിൽ ഇമെയിൽ നൽകുക',
          'enter_valid_email':
              'ദയവായി സാധുവായ ഒരു ഇമെയിൽ വിലാസം നൽകുക',
          'send_otps': 'OTP-കൾ അയയ്ക്കുക',
          'we_will_send_otp_info':
              'നിങ്ങളുടെ വാട്ട്‌സ്ആപ്പിലേക്കും ഇമെയിലിലേക്കും ഞങ്ങൾ OTP അയയ്ക്കും.',
          'loss_back_title': '100% ലോസ് ബാക്ക്',
          'loss_back_desc':
              'നിങ്ങളുടെ ആദ്യ നിക്ഷേപത്തിൽ 100% ലോസ് ബാക്ക് നേടുക.',
          'please_enter_email':
              'ദയവായി നിങ്ങളുടെ ഇമെയിൽ വിലാസം നൽകുക',
          'enter_whatsapp_otp': 'വാട്ട്‌സ്ആപ്പ് OTP നൽകുക',
          'enter_email_otp': 'ഇമെയിൽ OTP നൽകുക',
          'login_with_otp': 'OTP ഉപയോഗിച്ച് ലോഗിൻ ചെയ്യുക',
          'login_with_password':
              'പാസ്‌വേഡ് ഉപയോഗിച്ച് ലോഗിൻ',
          'resend_otp': 'OTP വീണ്ടും അയയ്ക്കുക',
          'didntreceivecode':
              'കോഡ് ലഭിച്ചില്ലേ? വീണ്ടും അയയ്ക്കുക',
          'enter_email_address': 'ഇമെയിൽ വിലാസം നൽകുക',
          'enter_password': 'നിങ്ങളുടെ പാസ്‌വേഡ് നൽകുക',
          'edit_email': 'ഇമെയിൽ എഡിറ്റ് ചെയ്യുക',
          'edit_mobile': 'മൊബൈൽ നമ്പർ എഡിറ്റ് ചെയ്യുക',
          'enter_mobile': 'മൊബൈൽ നമ്പർ നൽകുക',
          'field_required': 'ഈ ഫീൽഡ് ആവശ്യമാണ്',
          'invalid_email': 'ദയവായി സാധുവായ ഇമെയിൽ നൽകുക',
          'save_changes': 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക',
          'update_success': 'വിജയകരമായി അപ്ഡേറ്റ് ചെയ്തു',
          'not_set': 'സെറ്റ് ചെയ്തിട്ടില്ല',
          'current_password': 'നിലവിലെ പാസ്‌വേഡ്',
          'enter_current_password':
              'നിലവിലെ പാസ്‌വേഡ് നൽകുക',
          'enter_new_password': 'പുതിയ പാസ്‌വേഡ് നൽകുക',
          'confirm_new_password':
              'പുതിയ പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
          're_enter_password':
              'പുതിയ പാസ്‌വേഡ് വീണ്ടും നൽകുക',
          'please_enter_current_password':
              'ദയവായി നിങ്ങളുടെ നിലവിലെ പാസ്‌വേഡ് നൽകുക',
          'please_enter_new_password':
              'ദയവായി പുതിയ പാസ്‌വേഡ് നൽകുക',
          'please_confirm_password':
              'ദയവായി നിങ്ങളുടെ പുതിയ പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
          'passwords_do_not_match':
              'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല',
          'password_changed_success':
              'പാസ്‌വേഡ് വിജയകരമായി മാറ്റി',
          'password_updated':
              'നിങ്ങളുടെ പാസ്‌വേഡ് അപ്ഡേറ്റ് ചെയ്തു.',
          'secure_account_hint':
              'നിങ്ങളുടെ അക്കൗണ്ട് സുരക്ഷിതമാക്കാൻ\nശക്തമായ ഒരു പാസ്‌വേഡ് സൃഷ്ടിക്കുക',
          'password_requirement_hint':
              'പാസ്‌വേഡ് കുറഞ്ഞത് 6 അക്ഷരങ്ങൾ നീളമുള്ളതായിരിക്കണം, അക്ഷരങ്ങളുടെയും സംഖ്യകളുടെയും മിശ്രിതം ഉൾക്കൊള്ളണം.',
          'settings': 'ക്രമീകരണങ്ങൾ',
        },
        'pa': {
          'login': 'ਲੌਗਿਨ',
          'register': 'ਰਜਿਸਟਰ',
          'password': 'ਪਾਸਵਰਡ',
          'oops': 'ਉਫ਼!',
          'okay': 'ਠੀਕ ਹੈ',
          'forgotpassword': 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ',
          'letssignyouin': 'ਚਲੋ ਤੁਹਾਨੂੰ ਲੌਗਇਨ ਕਰੀਏ',
          'pleaseprovidepassword': 'ਕਿਰਪਾ ਕਰਕੇ ਪਾਸਵਰਡ ਦਿਓ',
          'invalidcredential': 'ਗਲਤ ਪ੍ਰਮਾਣ ਪੱਤਰ',
          'submit': 'ਸਬਮਿਟ',
          'resetyourpassword': 'ਆਪਣਾ ਪਾਸਵਰਡ ਰੀਸੈਟ ਕਰੋ',
          'enterOTP': 'OTP ਦਰਜ ਕਰੋ',
          'invalidOTP': 'ਗਲਤ OTP',
          'newpassword': 'ਨਵਾਂ ਪਾਸਵਰਡ',
          'passwordshould6characters':
              'ਪਾਸਵਰਡ 6 ਅੱਖਰਾਂ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ',
          'changepassword': 'ਪਾਸਵਰਡ ਬਦਲੋ',
          'createyouraccounr': 'ਆਪਣਾ ਅਕਾਊਂਟ ਬਣਾਓ',
          'verify': 'ਵੈਰੀਫਾਈ',
          'create': 'ਬਣਾਓ',
          'add_bank_account': 'ਬੈਂਕ ਅਕਾਊਂਟ ਜੋੜੋ',
          'invalid_bank_name': 'ਗਲਤ ਬੈਂਕ ਨਾਮ',
          'invalidname': 'ਗਲਤ ਨਾਮ',
          'bankaccountholdername':
              'ਬੈਂਕ ਅਕਾਊਂਟ ਹੋਲਡਰ ਦਾ ਨਾਮ',
          'bankaccountnumber': 'ਬੈਂਕ ਅਕਾਊਂਟ ਨੰਬਰ',
          'invalidaccountnumber': 'ਗਲਤ ਅਕਾਊਂਟ ਨੰਬਰ',
          'add_account': 'ਅਕਾਊਂਟ ਜੋੜੋ',
          'my_accounts': 'ਮੇਰੇ ਅਕਾਊਂਟਸ',
          'account': 'ਅਕਾਊਂਟ',
          'invalidmobilenumber': 'ਗਲਤ ਮੋਬਾਈਲ ਨੰਬਰ',
          'registration_completed': 'ਰਜਿਸਟ੍ਰੇਸ਼ਨ ਪੂਰੀ ਹੋਈ',
          'registration_successful': 'ਰਜਿਸਟ੍ਰੇਸ਼ਨ ਸਫਲ',
          'play_games': 'ਗੇਮਾਂ ਖੇਡੋ',
          'youmayonlyperformthisactionevery30seconds':
              'ਤੁਸੀਂ ਇਹ ਕਾਰਵਾਈ ਹਰ 30 ਸਕਿੰਟਾਂ ਵਿੱਚ ਇੱਕ ਵਾਰ ਹੀ ਕਰ ਸਕਦੇ ਹੋ',
          'rewards': 'ਰਿਵਾਰਡਸ',
          'adddepositinyourwallet':
              'ਆਪਣੇ ਵਾਲਿਟ ਵਿੱਚ ਡਿਪਾਜ਼ਿਟ ਜੋੜੋ',
          'makearequestforwithdraw': 'ਵਿਥਡ੍ਰਾ ਰਿਕੁਐਸਟ ਕਰੋ',
          'install_update': 'ਅੱਪਡੇਟ ਇੰਸਟਾਲ ਕਰੋ',
          'restart': 'ਰੀਸਟਾਰਟ',
          'logout_confirmation':
              'ਕੀ ਤੁਸੀਂ ਲੌਗਆਉਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?',
          'cancel': 'ਰੱਦ ਕਰੋ',
          'mobile_number': 'ਮੋਬਾਈਲ ਨੰਬਰ',
          'i_agree_terms':
              'ਮੈਂ ਨਿਯਮਾਂ ਅਤੇ ਸ਼ਰਤਾਂ ਅਤੇ ਗੋਪਨੀਯਤਾ ਨੀਤੀ ਨਾਲ ਸਹਿਮਤ ਹਾਂ',
          'whatsapp_number': 'ਵਟਸਐਪ ਨੰਬਰ',
          'enter_whatsapp_number': 'ਵਟਸਐਪ ਨੰਬਰ ਦਰਜ ਕਰੋ',
          'please_enter_mobile_or_email':
              'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਮੋਬਾਈਲ ਜਾਂ ਈਮੇਲ ਦਰਜ ਕਰੋ',
          'enter_valid_email':
              'ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਵੈਧ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ',
          'send_otps': 'OTP ਭੇਜੋ',
          'we_will_send_otp_info':
              'ਅਸੀਂ ਤੁਹਾਡੇ ਵਟਸਐਪ ਅਤੇ ਈਮੇਲ \'ਤੇ OTP ਭੇਜਾਂਗੇ।',
          'loss_back_title': '100% ਲੌਸ ਬੈਕ',
          'loss_back_desc':
              'ਆਪਣੇ ਪਹਿਲੇ ਡਿਪਾਜ਼ਿਟ \'ਤੇ 100% ਲੌਸ ਬੈਕ ਪ੍ਰਾਪਤ ਕਰੋ।',
          'please_enter_email':
              'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ',
          'enter_whatsapp_otp': 'ਵਟਸਐਪ OTP ਦਰਜ ਕਰੋ',
          'enter_email_otp': 'ਈਮੇਲ OTP ਦਰਜ ਕਰੋ',
          'login_with_otp': 'OTP ਨਾਲ ਲੌਗਇਨ ਕਰੋ',
          'login_with_password': 'ਪਾਸਵਰਡ ਨਾਲ ਲੌਗਇਨ ਕਰੋ',
          'resend_otp': 'OTP ਦੁਬਾਰਾ ਭੇਜੋ',
          'didntreceivecode':
              'ਕੋਡ ਪ੍ਰਾਪਤ ਨਹੀਂ ਹੋਇਆ? ਦੁਬਾਰਾ ਭੇਜੋ',
          'enter_email_address': 'ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ',
          'enter_password': 'ਆਪਣਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
          'edit_email': 'ਈਮੇਲ ਸੰਪਾਦਿਤ ਕਰੋ',
          'edit_mobile': 'ਮੋਬਾਈਲ ਨੰਬਰ ਸੰਪਾਦਿਤ ਕਰੋ',
          'enter_mobile': 'ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ',
          'field_required': 'ਇਹ ਖੇਤਰ ਲੋੜੀਂਦਾ ਹੈ',
          'invalid_email': 'ਕਿਰਪਾ ਕਰਕੇ ਸਹੀ ਈਮੇਲ ਦਰਜ ਕਰੋ',
          'save_changes': 'ਤਬਦੀਲੀਆਂ ਸੁਰੱਖਿਅਤ ਕਰੋ',
          'update_success': 'ਸਫਲਤਾਪੂਰਵਕ ਅੱਪਡੇਟ ਹੋਇਆ',
          'not_set': 'ਸੈੱਟ ਨਹੀਂ ਹੈ',
          'current_password': 'ਮੌਜੂਦਾ ਪਾਸਵਰਡ',
          'enter_current_password': 'ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
          'enter_new_password': 'ਨਵਾਂ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
          'confirm_new_password': 'ਨਵਾਂ ਪਾਸਵਰਡ ਪੁਸ਼ਟੀ ਕਰੋ',
          're_enter_password': 'ਨਵਾਂ ਪਾਸਵਰਡ ਦੁਬਾਰਾ ਦਰਜ ਕਰੋ',
          'please_enter_current_password':
              'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
          'please_enter_new_password':
              'ਕਿਰਪਾ ਕਰਕੇ ਨਵਾਂ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
          'please_confirm_password':
              'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਨਵਾਂ ਪਾਸਵਰਡ ਪੁਸ਼ਟੀ ਕਰੋ',
          'passwords_do_not_match': 'ਪਾਸਵਰਡ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ',
          'password_changed_success':
              'ਪਾਸਵਰਡ ਸਫਲਤਾਪੂਰਵਕ ਬਦਲਿਆ ਗਿਆ',
          'password_updated':
              'ਤੁਹਾਡਾ ਪਾਸਵਰਡ ਅੱਪਡੇਟ ਹੋ ਗਿਆ ਹੈ।',
          'secure_account_hint':
              'ਆਪਣੇ ਖਾਤੇ ਨੂੰ ਸੁਰੱਖਿਅਤ ਕਰਨ ਲਈ\nਇੱਕ ਮਜ਼ਬੂਤ ਪਾਸਵਰਡ ਬਣਾਓ',
          'password_requirement_hint':
              'ਪਾਸਵਰਡ ਘੱਟੋ-ਘੱਟ 6 ਅੱਖਰਾਂ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ ਅਤੇ ਇਸ ਵਿੱਚ ਅੱਖਰਾਂ ਅਤੇ ਨੰਬਰਾਂ ਦਾ ਮਿਸ਼ਰਣ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।',
          'settings': 'ਸੈਟਿੰਗਾਂ',
        },
        'ur': {
          'login': 'لاگ ان',
          'register': 'رجسٹر',
          'password': 'پاسورڈ',
          'oops': 'اوپس!',
          'okay': 'ٹھیک ہے',
          'forgotpassword': 'پاسورڈ بھول گئے',
          'letssignyouin': 'آئیے آپ کو سائن ان کرتے ہیں',
          'pleaseprovidepassword':
              'براہ کرم پاسورڈ فراہم کریں',
          'invalidcredential': 'غلط اسناد',
          'submit': 'جمع کریں',
          'resetyourpassword': 'اپنا پاسورڈ ری سیٹ کریں',
          'enterOTP': 'OTP درج کریں',
          'invalidOTP': 'غلط OTP',
          'newpassword': 'نیا پاسورڈ',
          'passwordshould6characters':
              'پاسورڈ کم از کم 6 حروف کا ہونا چاہیے',
          'changepassword': 'پاسورڈ تبدیل کریں',
          'createyouraccounr': 'اپنا اکاؤنٹ بنائیں',
          'verify': 'تصدیق',
          'create': 'بنائیں',
          'add_bank_account': 'بینک اکاؤنٹ شامل کریں',
          'invalid_bank_name': 'غلط بینک نام',
          'invalidname': 'غلط نام',
          'bankaccountholdername':
              'بینک اکاؤنٹ ہولڈر کا نام',
          'bankaccountnumber': 'بینک اکاؤنٹ نمبر',
          'invalidaccountnumber': 'غلط اکاؤنٹ نمبر',
          'add_account': 'اکاؤنٹ شامل کریں',
          'my_accounts': 'میرے اکاؤنٹس',
          'account': 'اکاؤنٹ',
          'invalidmobilenumber': 'غلط موبائل نمبر',
          'registration_completed': 'رجسٹریشن مکمل ہو گئی',
          'registration_successful': 'رجسٹریشن کامیاب',
          'play_games': 'گیمز کھیلیں',
          'youmayonlyperformthisactionevery30seconds':
              'آپ یہ عمل ہر 30 سیکنڈ میں صرف ایک بار کر سکتے ہیں',
          'rewards': 'انعامات',
          'adddepositinyourwallet':
              'اپنے والیٹ میں ڈپازٹ شامل کریں',
          'makearequestforwithdraw': 'وتھ ڈرا ریکوئسٹ کریں',
          'install_update': 'اپ ڈیٹ انسٹال کریں',
          'restart': 'ری اسٹارٹ',
          'logout_confirmation':
              'کیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟',
          'cancel': 'منسوخ',
          'mobile_number': 'موبائل نمبر',
          'i_agree_terms':
              'میں شرائط و ضوابط اور رازداری کی پالیسی سے متفق ہوں',
          'whatsapp_number': 'واٹس ایپ نمبر',
          'enter_whatsapp_number': 'واٹس ایپ نمبر درج کریں',
          'please_enter_mobile_or_email':
              'براہ کرم اپنا موبائل یا ای میل درج کریں',
          'enter_valid_email':
              'براہ کرم ایک درست ای میل ایڈریس درج کریں',
          'send_otps': 'OTP بھیجیں',
          'we_will_send_otp_info':
              'ہم آپ کے واٹس ایپ اور ای میل پر OTP بھیجیں گے۔',
          'loss_back_title': '100% لاس بیک',
          'loss_back_desc':
              'اپنی پہلی ڈپازٹ پر 100% لاس بیک حاصل کریں۔',
          'please_enter_email':
              'براہ کرم اپنا ای میل ایڈریس درج کریں',
          'enter_whatsapp_otp': 'واٹس ایپ OTP درج کریں',
          'enter_email_otp': 'ای میل OTP درج کریں',
          'login_with_otp': 'OTP کے ساتھ لاگ ان کریں',
          'login_with_password':
              'پاس ورڈ کے ساتھ لاگ ان کریں',
          'resend_otp': 'OTP دوبارہ بھیجیں',
          'didntreceivecode':
              'کوڈ موصول نہیں ہوا؟ دوبارہ بھیجیں',
          'enter_email_address': 'ای میل ایڈریس درج کریں',
          'enter_password': 'اپنا پاس ورڈ درج کریں',
          'edit_email': 'ای میل تبدیل کریں',
          'edit_mobile': 'موبائل نمبر تبدیل کریں',
          'enter_mobile': 'موبائل نمبر درج کریں',
          'field_required': 'یہ فیلڈ ضروری ہے',
          'invalid_email': 'براہ کرم درست ای میل درج کریں',
          'save_changes': 'تبدیلیاں محفوظ کریں',
          'update_success': 'کامیابی سے اپ ڈیٹ ہوا',
          'not_set': 'سیٹ نہیں ہے',
          'current_password': 'موجودہ پاسورڈ',
          'enter_current_password':
              'موجودہ پاسورڈ درج کریں',
          'enter_new_password': 'نیا پاسورڈ درج کریں',
          'confirm_new_password': 'نیا پاسورڈ تصدیق کریں',
          're_enter_password': 'نیا پاسورڈ دوبارہ درج کریں',
          'please_enter_current_password':
              'براہ کرم اپنا موجودہ پاسورڈ درج کریں',
          'please_enter_new_password':
              'براہ کرم نیا پاسورڈ درج کریں',
          'please_confirm_password':
              'براہ کرم اپنا نیا پاسورڈ تصدیق کریں',
          'passwords_do_not_match': 'پاسورڈ مماثل نہیں ہیں',
          'password_changed_success':
              'پاسورڈ کامیابی سے تبدیل ہو گیا',
          'password_updated':
              'آپ کا پاسورڈ اپ ڈیٹ ہو گیا ہے۔',
          'secure_account_hint':
              'اپنے اکاؤنٹ کو محفوظ بنانے کے لیے\nایک مضبوط پاسورڈ بنائیں',
          'password_requirement_hint':
              'پاسورڈ کم از کم 6 حروف کا ہونا چاہیے اور اس میں حروف اور اعداد کا امتزاج ہونا چاہیے۔',
          'settings': 'ترتیبات',
        },
      },
      'vip_screen': {
        'hi': {
          'vip_level': 'VIP लेवल',
          'unlocked': 'अनलॉक'
        },
        'te': {
          'vip_level': 'VIP స్థాయి',
          'unlocked': 'అన్‌లాక్'
        },
        'bn': {
          'vip_level': 'VIP লেভেল',
          'unlocked': 'আনলক'
        },
        'mr': {
          'vip_level': 'VIP लेवल',
          'unlocked': 'अनलॉक'
        },
        'ta': {
          'vip_level': 'VIP நிலை',
          'unlocked': 'அன்லாக்'
        },
        'gu': {
          'vip_level': 'VIP લેવલ',
          'unlocked': 'અનલોક'
        },
        'kn': {
          'vip_level': 'VIP ಮಟ್ಟ',
          'unlocked': 'ಅನ್‌ಲಾಕ್'
        },
        'ml': {
          'vip_level': 'VIP ലെവൽ',
          'unlocked': 'അൺലോക്ക്'
        },
        'pa': {
          'vip_level': 'VIP ਪੱਧਰ',
          'unlocked': 'ਅਨਲੌਕ'
        },
        'ur': {
          'vip_level': 'VIP لیول',
          'unlocked': 'ان لاک'
        },
      },
      'statement_screen': {
        'hi': {
          'statement_title': 'स्टेटमेंट',
          'description_copied': 'डिस्क्रिप्शन कॉपी हो गया',
          'crypto_currency': 'क्रिप्टो करेंसी',
          'status': 'स्टेटस',
          'no_records_found': 'कोई रिकॉर्ड नहीं मिला',
          'load_more': 'और लोड करें',
          'crypto_statement': 'क्रिप्टो स्टेटमेंट',
        },
        'te': {
          'statement_title': 'స్టేట్‌మెంట్',
          'description_copied': 'డిస్క్రిప్షన్ కాపీ అయింది',
          'crypto_currency': 'క్రిప్టో కరెన్సీ',
          'status': 'స్టేటస్',
          'no_records_found': 'రికార్డ్‌లు కనుగొనబడలేదు',
          'load_more': 'మరిన్ని లోడ్ చేయండి',
          'crypto_statement': 'క్రిప్టో స్టేట్‌మెంట్',
        },
        'bn': {
          'statement_title': 'স্টেটমেন্ট',
          'description_copied': 'ডিসক্রিপশন কপি হয়েছে',
          'crypto_currency': 'ক্রিপ্টো কারেন্সি',
          'status': 'স্ট্যাটাস',
          'no_records_found': 'কোনো রেকর্ড পাওয়া যায়নি',
          'load_more': 'আরো লোড করুন',
          'crypto_statement': 'ক্রিপ্টো স্টেটমেন্ট',
        },
        'mr': {
          'statement_title': 'स्टेटमेंट',
          'description_copied': 'डिस्क्रिप्शन कॉपी झाले',
          'status': 'स्टेटस',
          'no_records_found':
              'कोणतेही रेकॉर्ड सापडले नाहीत',
          'load_more': 'अजून लोड करा',
        },
        'ta': {
          'statement_title': 'அறிக்கை',
          'description_copied':
              'விளக்கம் காப்பி செய்யப்பட்டது',
          'status': 'நிலை',
          'no_records_found': 'பதிவுகள் இல்லை',
          'load_more': 'மேலும் ஏற்று',
        },
        'gu': {
          'statement_title': 'સ્ટેટમેન્ટ',
          'status': 'સ્ટેટસ',
          'no_records_found': 'કોઈ રેકોર્ડ મળ્યા નથી',
          'load_more': 'વધુ લોડ કરો'
        },
        'kn': {
          'statement_title': 'ಸ್ಟೇಟ್‌ಮೆಂಟ್',
          'status': 'ಸ್ಟೇಟಸ್',
          'no_records_found': 'ಯಾವುದೇ ದಾಖಲೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
          'load_more': 'ಹೆಚ್ಚು ಲೋಡ್ ಮಾಡಿ'
        },
        'ml': {
          'statement_title': 'സ്റ്റേറ്റ്‌മെന്റ്',
          'status': 'സ്റ്റേറ്റസ്',
          'no_records_found': 'രേഖകളൊന്നും കണ്ടെത്തിയില്ല',
          'load_more': 'കൂടുതൽ ലോഡ് ചെയ്യുക'
        },
        'pa': {
          'statement_title': 'ਸਟੇਟਮੈਂਟ',
          'status': 'ਸਟੇਟਸ',
          'no_records_found': 'ਕੋਈ ਰਿਕਾਰਡ ਨਹੀਂ ਮਿਲੇ',
          'load_more': 'ਹੋਰ ਲੋਡ ਕਰੋ'
        },
        'ur': {
          'statement_title': 'سٹیٹمنٹ',
          'status': 'اسٹیٹس',
          'no_records_found': 'کوئی ریکارڈ نہیں ملا',
          'load_more': 'مزید لوڈ کریں'
        },
      },
      'withdraw_screen': {
        'hi': {
          'secondary_wallet_only_enabled_after_limit':
              'प्राइमरी वॉलेट की निकासी सीमा पूरी होने के बाद ही सेकेंडरी वॉलेट सक्षम होता है',
          'something_went_wrong': 'कुछ गलत हो गया',
          'okay': 'ठीक है',
          'cancel': 'रद्द करें',
          'success': 'सफल',
          'oops': 'उफ़!',
          'select_payment_method': 'भुगतान विधि चुनें',
          'add_new_wallet': 'नया वॉलेट जोड़ें',
          'watch_now': 'अभी देखें',
          'select_bank_account': 'बैंक खाता चुनें',
          'you_dont_have_any_back_accounts_added':
              'आपके पास कोई बैंक खाता नहीं है',
          'add_bank_account': 'बैंक खाता जोड़ें',
          'primary_wallet': 'प्राइमरी वॉलेट',
          'secondary_wallet': 'सेकेंडरी वॉलेट',
          'account_balance': 'खाता शेष',
          'add_withdraw_amount': 'निकासी राशि जोड़ें',
          'min': 'न्यून.',
          'max': 'अधि.',
          'your_turnover_progress_': 'आपकी टर्नओवर प्रगति',
          'turnover_games': 'टर्नओवर गेम्स',
          'total': 'कुल',
          'total_withdraw_amount': 'कुल निकासी राशि',
          'withdraw_now': 'अभी निकालें',
          'please_select_bank_account':
              'कृपया बैंक खाता चुनें',
          'invalid_amount': 'अमान्य राशि',
          'insufficient_balance': 'अपर्याप्त शेष',
          'withdraw': 'निकालें',
          'you_have_reached_the_maximum_withdrawal_limit_of':
              'आपने अधिकतम निकासी सीमा पूरी कर ली है',
          'do_you_want_to_proceed_with_the_withdrawal':
              'क्या आप निकासी के साथ आगे बढ़ना चाहते हैं',
          'kindly_complete_turnover_before_proceeding_for_withdrawal':
              'कृपया निकासी से पहले टर्नओवर पूरा करें',
          'fill_in_carefully_according_to_the_specific':
              'कृपया निकासी पता सावधानी से भरें',
          'withdraw_amount': 'निकासी राशि',
          'available_balance_in': 'उपलब्ध शेष',
          'preview': 'पूर्वावलोकन',
          'turnover_progress': 'टर्नओवर प्रगति',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'सुरक्षा उद्देश्यों के लिए बड़ी या संदिग्ध निकासी में ऑडिट के लिए 1-6 घंटे लग सकते हैं',
          'withdraw_address': 'निकासी पता',
          'withdraw_currency': 'निकासी मुद्रा',
          'choose_coin_network': 'कॉइन नेटवर्क चुनें',
          'convert_rate': 'रूपांतरण दर',
          'your_balance': 'आपका शेष',
          'history': 'इतिहास',
          'convert_fiat_to_crypto':
              'फिएट को क्रिप्टो में बदलें',
          'confirm_withdraw_details':
              'निकासी विवरण की पुष्टि करें',
          'currency': 'मुद्रा',
          'address': 'पता',
          'please_enter_a_valid_amount':
              'कृपया एक वैध राशि दर्ज करें',
          'minimum_amount_is': 'न्यूनतम राशि है',
          'please_enter_an_address':
              'कृपया एक पता दर्ज करें',
          'please_enter_withdrawal_amount':
              'कृपया निकासी राशि दर्ज करें',
          'no_records_found': 'कोई रिकॉर्ड नहीं मिला',
          'refresh': 'रीफ्रेश',
          'id': 'आईडी',
          'status': 'स्टेटस',
          'datetime': 'तारीख और समय',
          'description': 'विवरण',
          'enter_withdrawal_address':
              'कृपया निकासी पता सावधानी से दर्ज करें',
          'complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins':
              'अपने टर्नओवर गेम्स पूरे करें और किसी भी क्रिप्टो सिक्कों के साथ अपना क्रिप्टो निकालें',
          'bonus_t_and_c': 'बोनस नियम व शर्तें',
          'please_enter_an_amount_greater_than_the_minimum_amount':
              'कृपया न्यूनतम राशि से अधिक राशि दर्ज करें',
          'please_enter_an_amount_less_than_the_maximum_withdrawal_amount':
              'कृपया अधिकतम निकासी राशि से कम राशि दर्ज करें',
          'currency_select': 'मुद्रा चुनें',
          'crypto_currency': 'क्रिप्टो करेंसी',
          'confirm': 'पुष्टि करें',
          'amount': 'राशि',
        },
        'te': {
          'secondary_wallet_only_enabled_after_limit':
              'ప్రైమరీ వాలెట్ యొక్క విత్‌డ్రా లిమిట్ చేరిన తర్వాత మాత్రమే సెకండరీ వాలెట్ ఎనేబుల్ అవుతుంది',
          'something_went_wrong': 'ఏదో తప్పు జరిగింది',
          'okay': 'సరే',
          'cancel': 'రద్దు చేయండి',
          'success': 'విజయం',
          'oops': 'అయ్యో!',
          'select_payment_method':
              'చెల్లింపు విధానం ఎంచుకోండి',
          'add_new_wallet': 'కొత్త వాలెట్ జోడించండి',
          'watch_now': 'ఇప్పుడు చూడండి',
          'select_bank_account': 'బ్యాంక్ ఖాతా ఎంచుకోండి',
          'you_dont_have_any_back_accounts_added':
              'మీకు ఏ బ్యాంక్ ఖాతాలు జోడించబడలేదు',
          'add_bank_account': 'బ్యాంక్ ఖాతా జోడించండి',
          'primary_wallet': 'ప్రైమరీ వాలెట్',
          'secondary_wallet': 'సెకండరీ వాలెట్',
          'account_balance': 'ఖాతా బ్యాలెన్స్',
          'add_withdraw_amount':
              'విత్‌డ్రా మొత్తం జోడించండి',
          'min': 'కనీస.',
          'max': 'గరిష్ట.',
          'your_turnover_progress_':
              'మీ టర్నోవర్ ప్రోగ్రెస్',
          'turnover_games': 'టర్నోవర్ గేమ్‌లు',
          'total': 'మొత్తం',
          'total_withdraw_amount':
              'మొత్తం విత్‌డ్రా మొత్తం',
          'withdraw_now': 'ఇప్పుడు విత్‌డ్రా చేయండి',
          'please_select_bank_account':
              'దయచేసి బ్యాంక్ ఖాతా ఎంచుకోండి',
          'invalid_amount': 'చెల్లని మొత్తం',
          'insufficient_balance': 'తగినంత బ్యాలెన్స్ లేదు',
          'withdraw': 'విత్‌డ్రా',
          'you_have_reached_the_maximum_withdrawal_limit_of':
              'మీరు గరిష్ట విత్‌డ్రాయల్ లిమిట్ చేరుకున్నారు',
          'do_you_want_to_proceed_with_the_withdrawal':
              'మీరు విత్‌డ్రాయల్‌తో కొనసాగించాలనుకుంటున్నారా',
          'kindly_complete_turnover_before_proceeding_for_withdrawal':
              'విత్‌డ్రాయల్ ముందు టర్నోవర్ పూర్తి చేయండి',
          'fill_in_carefully_according_to_the_specific':
              'దయచేసి విత్‌డ్రాయల్ అడ్రస్ జాగ్రత్తగా నమోదు చేయండి',
          'withdraw_amount': 'విత్‌డ్రా అమౌంట్',
          'available_balance_in':
              'అందుబాటులో ఉన్న బ్యాలెన్స్',
          'preview': 'ప్రీవ్యూ',
          'turnover_progress': 'టర్నోవర్ ప్రోగ్రెస్',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'భద్రతా కారణాల వల్ల పెద్ద లేదా అనుమానాస్పద విత్‌డ్రాయల్‌కు ఆడిట్ కోసం 1-6 గంటలు పట్టవచ్చు',
          'withdraw_address': 'విత్‌డ్రా అడ్రస్',
          'withdraw_currency': 'విత్‌డ్రా కరెన్సీ',
          'choose_coin_network':
              'కాయిన్ నెట్‌వర్క్ ఎంచుకోండి',
          'convert_rate': 'రూపాంతర రేటు',
          'your_balance': 'మీ బ్యాలెన్స్',
          'history': 'హిస్టరీ',
          'convert_fiat_to_crypto':
              'ఫియట్‌ను క్రిప్టోకు మార్చండి',
          'confirm_withdraw_details':
              'విత్‌డ్రా వివరాలు నిర్ధారించండి',
          'currency': 'కరెన్సీ',
          'address': 'అడ్రస్',
          'please_enter_a_valid_amount':
              'దయచేసి చెల్లుబాటు అయ్యే మొత్తం నమోదు చేయండి',
          'minimum_amount_is': 'కనీస మొత్తం',
          'please_enter_an_address':
              'దయచేసి అడ్రస్ నమోదు చేయండి',
          'please_enter_withdrawal_amount':
              'దయచేసి విత్‌డ్రా మొత్తం నమోదు చేయండి',
          'no_records_found': 'రికార్డ్‌లు కనుగొనబడలేదు',
          'refresh': 'రిఫ్రెష్',
          'id': 'ఐడి',
          'status': 'స్టేటస్',
          'datetime': 'తేదీ & సమయం',
          'description': 'వివరణ',
          'enter_withdrawal_address':
              'దయచేసి విత్‌డ్రాయల్ అడ్రస్ జాగ్రత్తగా నమోదు చేయండి',
          'complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins':
              'మీ టర్నోవర్ గేమ్లను పూర్తి చేయండి మరియు ఏదైనా క్రిప్టో కాయిన్లతో మీ క్రిప్టోను విత్డ్రా చేయండి',
          'bonus_t_and_c': 'బోనస్ నిబంధనలు & షరతులు',
          'please_enter_an_amount_greater_than_the_minimum_amount':
              'దయచేసి కనీస అమౌంట్ కంటే ఎక్కువ నమోదు చేయండి',
          'please_enter_an_amount_less_than_the_maximum_withdrawal_amount':
              'దయచేసి గరిష్ట విత్‌డ్రా అమౌంట్ కంటే తక్కువ నమోదు చేయండి',
          'currency_select': 'కరెన్సీ ఎంచుకోండి',
          'crypto_currency': 'క్రిప్టో కరెన్సీ',
          'confirm': 'నిర్ధారించు',
          'amount': 'అమౌంట్',
        },
        'bn': {
          'secondary_wallet_only_enabled_after_limit':
              'প্রাইমারি ওয়ালেটের উত্তোলন সীমা পূরণ হওয়ার পরেই সেকেন্ডারি ওয়ালেট সক্রিয় হবে',
          'something_went_wrong': 'কিছু ভুল হয়েছে',
          'okay': 'ঠিক আছে',
          'cancel': 'বাতিল',
          'success': 'সফল',
          'oops': 'উফ্!',
          'select_payment_method':
              'পেমেন্ট পদ্ধতি নির্বাচন করুন',
          'select_bank_account':
              'ব্যাংক অ্যাকাউন্ট নির্বাচন করুন',
          'primary_wallet': 'প্রাইমারি ওয়ালেট',
          'secondary_wallet': 'সেকেন্ডারি ওয়ালেট',
          'account_balance': 'অ্যাকাউন্ট ব্যালেন্স',
          'add_withdraw_amount':
              'উত্তোলনের পরিমাণ যোগ করুন',
          'min': 'সর্বনিম্ন',
          'max': 'সর্বোচ্চ',
          'total': 'মোট',
          'withdraw_now': 'এখনই উত্তোলন করুন',
          'withdraw': 'উত্তোলন',
          'invalid_amount': 'অবৈধ পরিমাণ',
          'insufficient_balance': 'অপর্যাপ্ত ব্যালেন্স',
          'fill_in_carefully_according_to_the_specific':
              'দয়া করে উত্তোলনের ঠিকানা সাবধানে পূরণ করুন',
          'withdraw_amount': 'উত্তোলনের পরিমাণ',
          'available_balance_in': 'উপলব্ধ ব্যালেন্স',
          'preview': 'পূর্বরূপ',
          'turnover_progress': 'টার্নওভার অগ্রগতি',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'নিরাপত্তার জন্য বড় বা সন্দেহজনক উত্তোলনে অডিটের জন্য ১-৬ ঘণ্টা সময় লাগতে পারে',
          'withdraw_address': 'উত্তোলনের ঠিকানা',
          'withdraw_currency': 'উত্তোলন মুদ্রা',
          'choose_coin_network':
              'কয়েন নেটওয়ার্ক চয়ন করুন',
          'convert_rate': 'রূপান্তর হার',
          'your_balance': 'আপনার ব্যালেন্স',
          'history': 'ইতিহাস',
          'convert_fiat_to_crypto':
              'ফিয়াট থেকে ক্রিপ্টোতে রূপান্তর করুন',
          'confirm_withdraw_details':
              'উত্তোলনের বিবরণ নিশ্চিত করুন',
          'currency': 'মুদ্রা',
          'address': 'ঠিকানা',
          'please_enter_a_valid_amount':
              'দয়া করে একটি বৈধ পরিমাণ লিখুন',
          'minimum_amount_is': 'সর্বনিম্ন পরিমাণ হল',
          'please_enter_an_address':
              'দয়া করে একটি ঠিকানা লিখুন',
          'please_enter_withdrawal_amount':
              'দয়া করে উত্তোলনের পরিমাণ লিখুন',
          'no_records_found': 'কোনো রেকর্ড পাওয়া যায়নি',
          'refresh': 'রিফ্রেশ',
          'id': 'আইডি',
          'status': 'স্ট্যাটাস',
          'datetime': 'তারিখ ও সময়',
          'description': 'বিবরণ',
          'enter_withdrawal_address':
              'দয়া করে সাবধানে উইথড্রয়াল অ্যাড্রেস লিখুন',
          'complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins':
              'আপনার টার্নওভার গেমগুলি সম্পূর্ণ করুন এবং যেকোনো ক্রিপ্টো কয়েন দিয়ে আপনার ক্রিপ্টো উত্তোলন করুন',
          'bonus_t_and_c': 'বোনাস শর্তাবলী',
          'please_enter_an_amount_greater_than_the_minimum_amount':
              'দয়া করে ন্যূনতম পরিমাণের চেয়ে বেশি লিখুন',
          'please_enter_an_amount_less_than_the_maximum_withdrawal_amount':
              'দয়া করে সর্বোচ্চ উইথড্র পরিমাণের চেয়ে কম লিখুন',
          'do_you_want_to_proceed_with_the_withdrawal':
              'আপনি কি উইথড্র নিয়ে এগিয়ে যেতে চান',
          'kindly_complete_turnover_before_proceeding_for_withdrawal':
              'দয়া করে উইথড্র আগে টার্নওভার সম্পূর্ণ করুন',
          'currency_select': 'কারেন্সি নির্বাচন',
          'crypto_currency': 'ক্রিপ্টো কারেন্সি',
          'confirm': 'নিশ্চিত',
          'amount': 'পরিমাণ',
          'add_new_wallet': 'নতুন ওয়ালেট যোগ করুন',
          'watch_now': 'এখনই দেখুন',
          'add_bank_account': 'ব্যাংক অ্যাকাউন্ট যোগ করুন',
          'you_dont_have_any_back_accounts_added':
              'আপনার কোনো ব্যাংক অ্যাকাউন্ট যোগ করা হয়নি',
          'your_turnover_progress_':
              'আপনার টার্নওভার অগ্রগতি',
          'turnover_games': 'টার্নওভার গেমস',
          'total_withdraw_amount': 'মোট উত্তোলনের পরিমাণ',
          'please_select_bank_account':
              'দয়া করে ব্যাংক অ্যাকাউন্ট নির্বাচন করুন',
          'you_have_reached_the_maximum_withdrawal_limit_of':
              'আপনি সর্বোচ্চ উত্তোলন সীমায় পৌঁছেছেন',
        },
        'mr': {
          'secondary_wallet_only_enabled_after_limit':
              'प्रायमरी वॉलेटची विदड्रॉ लिमिट पूर्ण झाल्यानंतरच सेकंडरी वॉलेट सक्रिय होतो',
          'something_went_wrong': 'काहीतरी चूक झाली',
          'okay': 'ठीक आहे',
          'cancel': 'रद्द करा',
          'success': 'यशस्वी',
          'oops': 'अरेरे!',
          'select_payment_method': 'पेमेंट पद्धत निवडा',
          'select_bank_account': 'बँक खाते निवडा',
          'primary_wallet': 'प्रायमरी वॉलेट',
          'secondary_wallet': 'सेकंडरी वॉलेट',
          'account_balance': 'खाते शिल्लक',
          'add_withdraw_amount': 'विदड्रॉ रक्कम जोडा',
          'min': 'किमान',
          'max': 'कमाल',
          'total': 'एकूण',
          'withdraw_now': 'आता काढा',
          'withdraw': 'काढा',
          'invalid_amount': 'अवैध रक्कम',
          'insufficient_balance': 'अपुरी शिल्लक',
          'fill_in_carefully_according_to_the_specific':
              'कृपया विदड्रॉ पत्ता काळजीपूर्वक भरा',
          'withdraw_amount': 'विदड्रॉ रक्कम',
          'available_balance_in': 'उपलब्ध शिल्लक',
          'preview': 'पूर्वावलोकन',
          'turnover_progress': 'टर्नओव्हर प्रगती',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'सुरक्षिततेसाठी मोठ्या किंवा संशयास्पद विदड्रॉसाठी ऑडिटला 1-6 तास लागू शकतात',
          'withdraw_address': 'विदड्रॉ पत्ता',
          'withdraw_currency': 'विदड्रॉ चलन',
          'choose_coin_network': 'कॉइन नेटवर्क निवडा',
          'convert_rate': 'रूपांतर दर',
          'your_balance': 'तुमची शिल्लक',
          'history': 'इतिहास',
          'convert_fiat_to_crypto':
              'फियात क्रिप्टोमध्ये बदला',
          'confirm_withdraw_details':
              'विदड्रॉ तपशील निश्चित करा',
          'currency': 'चलन',
          'address': 'पत्ता',
          'please_enter_a_valid_amount':
              'कृपया वैध रक्कम टाका',
          'minimum_amount_is': 'किमान रक्कम आहे',
          'please_enter_an_address': 'कृपया पत्ता टाका',
          'please_enter_withdrawal_amount':
              'कृपया विदड्रॉ रक्कम टाका',
          'no_records_found':
              'कोणतेही रेकॉर्ड सापडले नाहीत',
          'refresh': 'रिफ्रेश',
          'id': 'आयडी',
          'status': 'स्टेटस',
          'datetime': 'तारीख आणि वेळ',
          'description': 'वर्णन',
          'enter_withdrawal_address':
              'कृपया विड्रॉवल अ‍ॅड्रेस काळजीपूर्वक भरा',
          'complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins':
              'तुमचे टर्नओव्हर गेम्स पूर्ण करा आणि कोणत्याही क्रिप्टो कॉइन्सने तुमचे क्रिप्टो काढा',
          'bonus_t_and_c': 'बोनस अटी व शर्ती',
          'please_enter_an_amount_greater_than_the_minimum_amount':
              'कृपया किमान रकमेपेक्षा जास्त रक्कम टाका',
          'please_enter_an_amount_less_than_the_maximum_withdrawal_amount':
              'कृपया कमाल विड्रॉ रकमेपेक्षा कमी रक्कम टाका',
          'do_you_want_to_proceed_with_the_withdrawal':
              'तुम्हाला विड्रॉ सुरू ठेवायचे आहे का',
          'kindly_complete_turnover_before_proceeding_for_withdrawal':
              'कृपया विड्रॉ करण्यापूर्वी टर्नओव्हर पूर्ण करा',
          'currency_select': 'चलन निवडा',
          'crypto_currency': 'क्रिप्टो चलन',
          'confirm': 'पुष्टी करा',
          'amount': 'रक्कम',
          'add_new_wallet': 'नवीन वॉलेट जोडा',
          'watch_now': 'आता पहा',
          'add_bank_account': 'बँक खाते जोडा',
          'you_dont_have_any_back_accounts_added':
              'तुमच्याकडे कोणतीही बँक खाती जोडलेली नाहीत',
          'your_turnover_progress_':
              'तुमची टर्नओव्हर प्रगती',
          'turnover_games': 'टर्नओव्हर गेम्स',
          'total_withdraw_amount': 'एकूण विड्रॉ रक्कम',
          'please_select_bank_account':
              'कृपया बँक खाते निवडा',
          'you_have_reached_the_maximum_withdrawal_limit_of':
              'तुम्ही कमाल विड्रॉ मर्यादा गाठली आहे',
        },
        'ta': {
          'secondary_wallet_only_enabled_after_limit':
              'முதன்மை வாலட்டின் எடுப்பு வரம்பை அடைந்த பிறகே இரண்டாம் நிலை வாலட் செயல்படும்',
          'something_went_wrong': 'ஏதோ தவறு நடந்தது',
          'okay': 'சரி',
          'cancel': 'ரத்து செய்',
          'success': 'வெற்றி',
          'oops': 'அச்சச்சோ!',
          'select_payment_method':
              'கட்டண முறையைத் தேர்ந்தெடுக்கவும்',
          'select_bank_account':
              'வங்கி கணக்கைத் தேர்ந்தெடுக்கவும்',
          'primary_wallet': 'முதன்மை வாலட்',
          'secondary_wallet': 'இரண்டாம் நிலை வாலட்',
          'account_balance': 'கணக்கு இருப்பு',
          'add_withdraw_amount':
              'எடுப்பு தொகையைச் சேர்க்கவும்',
          'min': 'குறைந்தபட்சம்',
          'max': 'அதிகபட்சம்',
          'total': 'மொத்தம்',
          'withdraw_now': 'இப்போது எடுக்கவும்',
          'withdraw': 'எடு',
          'invalid_amount': 'தவறான தொகை',
          'insufficient_balance': 'போதிய இருப்பு இல்லை',
          'fill_in_carefully_according_to_the_specific':
              'எடுப்பு முகவரியை கவனமாக நிரப்பவும்',
          'withdraw_amount': 'எடுப்பு தொகை',
          'available_balance_in': 'கிடைக்கும் இருப்பு',
          'preview': 'முன்னோக்கு',
          'turnover_progress': 'டர்னோவர் முன்னேற்றம்',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'பாதுகாப்பு நோக்கங்களுக்காக பெரிய அல்லது சந்தேகத்திற்கிடமான எடுப்புக்கு தணிக்கைக்கு 1-6 மணி நேரம் ஆகலாம்',
          'withdraw_address': 'எடுப்பு முகவரி',
          'withdraw_currency': 'எடுப்பு நாணயம்',
          'choose_coin_network':
              'காயின் நெட்வொர்க் தேர்ந்தெடுக்கவும்',
          'convert_rate': 'மாற்று விகிதம்',
          'your_balance': 'உங்கள் இருப்பு',
          'history': 'வரலாறு',
          'convert_fiat_to_crypto':
              'ஃபியட்டை கிரிப்டோவாக மாற்றவும்',
          'confirm_withdraw_details':
              'எடுப்பு விவரங்களை உறுதிப்படுத்தவும்',
          'currency': 'நாணயம்',
          'address': 'முகவரி',
          'please_enter_a_valid_amount':
              'சரியான தொகையை உள்ளிடவும்',
          'minimum_amount_is': 'குறைந்தபட்ச தொகை',
          'please_enter_an_address': 'முகவரியை உள்ளிடவும்',
          'please_enter_withdrawal_amount':
              'எடுப்புத் தொகையை உள்ளிடவும்',
          'no_records_found': 'பதிவுகள் இல்லை',
          'refresh': 'புதுப்பிக்கவும்',
          'id': 'ஐடி',
          'status': 'நிலை',
          'datetime': 'தேதி & நேரம்',
          'description': 'விளக்கம்',
        },
        'gu': {
          'secondary_wallet_only_enabled_after_limit':
              'પ્રાઇમરી વૉલેટની ઉપાડ મર્યાદા પૂરી થયા પછી જ સેકન્ડરી વૉલેટ સક્રિય થશે',
          'something_went_wrong': 'કંઈક ખોટું થયું',
          'okay': 'ઠીક છે',
          'cancel': 'રદ કરો',
          'success': 'સફળ',
          'oops': 'અરે!',
          'select_payment_method': 'ચુકવણી પદ્ધતિ પસંદ કરો',
          'select_bank_account': 'બેંક ખાતું પસંદ કરો',
          'primary_wallet': 'પ્રાઇમરી વૉલેટ',
          'secondary_wallet': 'સેકન્ડરી વૉલેટ',
          'account_balance': 'ખાતું બેલેન્સ',
          'add_withdraw_amount': 'ઉપાડ રકમ ઉમેરો',
          'min': 'ન્યૂનતમ',
          'max': 'મહત્તમ',
          'total': 'કુલ',
          'withdraw_now': 'હવે ઉપાડો',
          'withdraw': 'ઉપાડો',
          'invalid_amount': 'અમાન્ય રકમ',
          'insufficient_balance': 'અપૂરતું બેલેન્સ',
          'fill_in_carefully_according_to_the_specific':
              'કૃપા કરીને ઉપાડ સરનામું કાળજીપૂર્વક ભરો',
          'withdraw_amount': 'ઉપાડ રકમ',
          'available_balance_in': 'ઉપલબ્ધ બેલેન્સ',
          'preview': 'પૂર્વાવલોકન',
          'turnover_progress': 'ટર્નઓવર પ્રગતિ',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'સુરક્ષા માટે મોટા અથવા શંકાસ્પદ ઉપાડ માટે ઓડિટ માટે 1-6 કલાક લાગી શકે છે',
          'withdraw_address': 'ઉપાડ સરનામું',
          'withdraw_currency': 'ઉપાડ ચલણ',
          'choose_coin_network': 'કોઈન નેટવર્ક પસંદ કરો',
          'convert_rate': 'રૂપાંતર દર',
          'your_balance': 'તમારું બેલેન્સ',
          'history': 'ઇતિહાસ',
          'convert_fiat_to_crypto':
              'ફિયાટને ક્રિપ્ટોમાં બદલો',
          'confirm_withdraw_details':
              'ઉપાડ વિગતો ની ખાતરી કરો',
          'currency': 'ચલણ',
          'address': 'સરનામું',
          'please_enter_a_valid_amount':
              'કૃપા કરીને માન્ય રકમ દાખલ કરો',
          'minimum_amount_is': 'ન્યૂનતમ રકમ છે',
          'please_enter_an_address':
              'કૃપા કરીને સરનામું દાખલ કરો',
          'please_enter_withdrawal_amount':
              'કૃપા કરીને ઉપાડ રકમ દાખલ કરો',
          'no_records_found': 'કોઈ રેકોર્ડ મળ્યા નથી',
          'refresh': 'રિફ્રેશ',
          'id': 'આઈડી',
          'status': 'સ્ટેટસ',
          'datetime': 'તારીખ અને સમય',
          'description': 'વર્ણન',
        },
        'kn': {
          'secondary_wallet_only_enabled_after_limit':
              'ಪ್ರೈಮರಿ ವಾಲೆಟ್ ಹಿಂಪಡೆಯುವಿಕೆ ಮಿತಿ ತಲುಪಿದ ನಂತರವೇ ಸೆಕೆಂಡರಿ ವಾಲೆಟ್ ಸಕ್ರಿಯಗೊಳ್ಳುತ್ತದೆ',
          'something_went_wrong': 'ಏನೋ ತಪ್ಪಾಗಿದೆ',
          'okay': 'ಸರಿ',
          'cancel': 'ರದ್ದುಮಾಡಿ',
          'success': 'ಯಶಸ್ಸು',
          'oops': 'ಅಯ್ಯೋ!',
          'select_payment_method': 'ಪಾವತಿ ವಿಧಾನ ಆಯ್ಕೆಮಾಡಿ',
          'select_bank_account': 'ಬ್ಯಾಂಕ್ ಖಾತೆ ಆಯ್ಕೆಮಾಡಿ',
          'primary_wallet': 'ಪ್ರೈಮರಿ ವಾಲೆಟ್',
          'secondary_wallet': 'ಸೆಕೆಂಡರಿ ವಾಲೆಟ್',
          'account_balance': 'ಖಾತೆ ಬ್ಯಾಲೆನ್ಸ್',
          'add_withdraw_amount': 'ಹಿಂಪಡೆಯುವ ಮೊತ್ತ ಸೇರಿಸಿ',
          'min': 'ಕನಿಷ್ಠ',
          'max': 'ಗರಿಷ್ಠ',
          'total': 'ಒಟ್ಟು',
          'withdraw_now': 'ಈಗ ಹಿಂಪಡೆಯಿರಿ',
          'withdraw': 'ಹಿಂಪಡೆಯಿರಿ',
          'invalid_amount': 'ಅಮಾನ್ಯ ಮೊತ್ತ',
          'insufficient_balance': 'ಸಾಕಷ್ಟು ಬ್ಯಾಲೆನ್ಸ್ ಇಲ್ಲ',
          'fill_in_carefully_according_to_the_specific':
              'ದಯವಿಟ್ಟು ಹಿಂಪಡೆಯುವಿಕೆ ವಿಳಾಸವನ್ನು ಜಾಗರೂಕವಾಗಿ ಭರ್ತಿ ಮಾಡಿ',
          'withdraw_amount': 'ಹಿಂಪಡೆಯುವ ಮೊತ್ತ',
          'available_balance_in': 'ಲಭ್ಯವಿರುವ ಬ್ಯಾಲೆನ್ಸ್',
          'preview': 'ಪೂರ್ವವೀಕ್ಷಣೆ',
          'turnover_progress': 'ಟರ್ನ್‌ಓವರ್ ಪ್ರಗತಿ',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'ಭದ್ರತೆಗಾಗಿ ದೊಡ್ಡ ಅಥವಾ ಅನುಮಾನಾಸ್ಪದ ಹಿಂಪಡೆಯುವಿಕೆಗೆ ಆಡಿಟ್‌ಗೆ 1-6 ಗಂಟೆಗಳು ತೆಗೆದುಕೊಳ್ಳಬಹುದು',
          'withdraw_address': 'ಹಿಂಪಡೆಯುವಿಕೆ ವಿಳಾಸ',
          'withdraw_currency': 'ಹಿಂಪಡೆಯುವಿಕೆ ಕರೆನ್ಸಿ',
          'choose_coin_network':
              'ಕಾಯಿನ್ ನೆಟ್‌ವರ್ಕ್ ಆಯ್ಕೆಮಾಡಿ',
          'convert_rate': 'ರೂಪಾಂತರ ದರ',
          'your_balance': 'ನಿಮ್ಮ ಬ್ಯಾಲೆನ್ಸ್',
          'history': 'ಇತಿಹಾಸ',
          'convert_fiat_to_crypto':
              'ಫಿಯಾಟ್ ಅನ್ನು ಕ್ರಿಪ್ಟೋಗೆ ಪರಿವರ್ತಿಸಿ',
          'confirm_withdraw_details':
              'ಹಿಂಪಡೆಯುವ ವಿವರಗಳನ್ನು ದೃಢೀಕರಿಸಿ',
          'currency': 'ಕರೆನ್ಸಿ',
          'address': 'ವಿಳಾಸ',
          'please_enter_a_valid_amount':
              'ಮಾನ್ಯ ಮೊತ್ತವನ್ನು ನಮೂದಿಸಿ',
          'minimum_amount_is': 'ಕನಿಷ್ಟ ಮೊತ್ತ',
          'please_enter_an_address': 'ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ',
          'please_enter_withdrawal_amount':
              'ಹಿಂಪಡೆಯುವ ಮೊತ್ತವನ್ನು ನಮೂದಿಸಿ',
          'no_records_found': 'ಯಾವುದೇ ದಾಖಲೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
          'refresh': 'ರಿಫ್ರೆಶ್',
          'id': 'ಐಡಿ',
          'status': 'ಸ್ಟೇಟಸ್',
          'datetime': 'ದಿನಾಂಕ ಮತ್ತು ಸಮಯ',
          'description': 'ವಿವರಣೆ',
        },
        'ml': {
          'secondary_wallet_only_enabled_after_limit':
              'പ്രൈമറി വാലറ്റിന്റെ പിൻവലിക്കൽ പരിധി എത്തിയ ശേഷം മാത്രമേ സെക്കൻഡറി വാലറ്റ് പ്രവർത്തിക്കൂ',
          'something_went_wrong': 'എന്തോ കുഴപ്പമായി',
          'okay': 'ശരി',
          'cancel': 'റദ്ദാക്കുക',
          'success': 'വിജയം',
          'oops': 'ഓ!',
          'select_payment_method':
              'പേയ്‌മെന്റ് രീതി തിരഞ്ഞെടുക്കുക',
          'select_bank_account':
              'ബാങ്ക് അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക',
          'primary_wallet': 'പ്രൈമറി വാലറ്റ്',
          'secondary_wallet': 'സെക്കൻഡറി വാലറ്റ്',
          'account_balance': 'അക്കൗണ്ട് ബാലൻസ്',
          'add_withdraw_amount': 'പിൻവലിക്കൽ തുക ചേർക്കുക',
          'min': 'കുറഞ്ഞത്',
          'max': 'കൂടിയത്',
          'total': 'ആകെ',
          'withdraw_now': 'ഇപ്പോൾ പിൻവലിക്കുക',
          'withdraw': 'പിൻവലിക്കുക',
          'invalid_amount': 'അസാധുവായ തുക',
          'insufficient_balance': 'അപര്യാപ്തമായ ബാലൻസ്',
          'fill_in_carefully_according_to_the_specific':
              'ദയവായി പിൻവലിക്കൽ വിലാസം ശ്രദ്ധാപൂർവ്വം പൂരിപ്പിക്കുക',
          'withdraw_amount': 'പിൻവലിക്കൽ തുക',
          'available_balance_in': 'ലഭ്യമായ ബാലൻസ്',
          'preview': 'പ്രിവ്യൂ',
          'turnover_progress': 'ടേണോവർ പുരോഗതി',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'സുരക്ഷാ ആവശ്യങ്ങൾക്കായി വലിയ അല്ലെങ്കിൽ സംശയാസ്പദമായ പിൻവലിക്കലിന് ഓഡിറ്റിന് 1-6 മണിക്കൂർ എടുത്തേക്കാം',
          'withdraw_address': 'പിൻവലിക്കൽ വിലാസം',
          'withdraw_currency': 'പിൻവലിക്കൽ കറൻസി',
          'choose_coin_network':
              'കോയിൻ നെറ്റ്‌വർക്ക് തിരഞ്ഞെടുക്കുക',
          'convert_rate': 'പരിവർത്തന നിരക്ക്',
          'your_balance': 'നിങ്ങളുടെ ബാലൻസ്',
          'history': 'ചരിത്രം',
          'convert_fiat_to_crypto':
              'ഫിയറ്റ് ക്രിപ്‌റ്റോയിലേക്ക് മാറ്റുക',
          'confirm_withdraw_details':
              'പിൻവലിക്കൽ വിശദാംശങ്ങൾ സ്ഥിരീകരിക്കുക',
          'currency': 'കറൻസി',
          'address': 'വിലാസം',
          'please_enter_a_valid_amount':
              'ദയവായി ശരിയായ തുക നൽകുക',
          'minimum_amount_is': 'ഏറ്റവും കുറഞ്ഞ തുക',
          'please_enter_an_address': 'ദയവായി വിലാസം നൽകുക',
          'please_enter_withdrawal_amount':
              'ദയവായി പിൻവലിക്കൽ തുക നൽകുക',
          'no_records_found': 'രേഖകളൊന്നും കണ്ടെത്തിയില്ല',
          'refresh': 'പുതുക്കുക',
          'id': 'ഐഡി',
          'status': 'സ്റ്റേറ്റസ്',
          'datetime': 'തീയതിയും സമയവും',
          'description': 'വിവരണം',
        },
        'pa': {
          'secondary_wallet_only_enabled_after_limit':
              'ਪ੍ਰਾਇਮਰੀ ਵਾਲਿਟ ਦੀ ਕਢਵਾਈ ਸੀਮਾ ਪੂਰੀ ਹੋਣ ਤੋਂ ਬਾਅਦ ਹੀ ਸੈਕੰਡਰੀ ਵਾਲਿਟ ਸਰਗਰਮ ਹੋਵੇਗੀ',
          'something_went_wrong': 'ਕੁਝ ਗਲਤ ਹੋ ਗਿਆ',
          'okay': 'ਠੀਕ ਹੈ',
          'cancel': 'ਰੱਦ ਕਰੋ',
          'success': 'ਸਫਲ',
          'oops': 'ਅੋਹ!',
          'select_payment_method': 'ਭੁਗਤਾਨ ਤਰੀਕਾ ਚੁਣੋ',
          'select_bank_account': 'ਬੈਂਕ ਖਾਤਾ ਚੁਣੋ',
          'primary_wallet': 'ਪ੍ਰਾਇਮਰੀ ਵਾਲਿਟ',
          'secondary_wallet': 'ਸੈਕੰਡਰੀ ਵਾਲਿਟ',
          'account_balance': 'ਖਾਤਾ ਬੈਲੰਸ',
          'add_withdraw_amount': 'ਕਢਵਾਈ ਰਕਮ ਜੋੜੋ',
          'min': 'ਘੱਟੋ-ਘੱਟ',
          'max': 'ਵੱਧ ਤੋਂ ਵੱਧ',
          'total': 'ਕੁੱਲ',
          'withdraw_now': 'ਹੁਣੇ ਕਢਵਾਓ',
          'withdraw': 'ਕਢਵਾਓ',
          'invalid_amount': 'ਅਵੈਧ ਰਕਮ',
          'insufficient_balance': 'ਨਾਕਾਫ਼ੀ ਬੈਲੰਸ',
          'fill_in_carefully_according_to_the_specific':
              'ਕਿਰਪਾ ਕਰਕੇ ਕਢਵਾਈ ਪਤਾ ਧਿਆਨ ਨਾਲ ਭਰੋ',
          'withdraw_amount': 'ਕਢਵਾਈ ਰਕਮ',
          'available_balance_in': 'ਉਪਲਬਧ ਬੈਲੰਸ',
          'preview': 'ਪੂਰਵਦਰਸ਼ਨ',
          'turnover_progress': 'ਟਰਨਓਵਰ ਪ੍ਰਗਤੀ',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'ਸੁਰੱਖਿਆ ਲਈ ਵੱਡੀ ਜਾਂ ਸ਼ੱਕੀ ਕਢਵਾਈ ਲਈ ਆਡਿਟ ਲਈ 1-6 ਘੰਟੇ ਲੱਗ ਸਕਦੇ ਹਨ',
          'withdraw_address': 'ਕਢਵਾਈ ਪਤਾ',
          'withdraw_currency': 'ਕਢਵਾਈ ਮੁਦਰਾ',
          'choose_coin_network': 'ਕੋਇਨ ਨੈੱਟਵਰਕ ਚੁਣੋ',
          'convert_rate': 'ਪਰਿਵਰਤਨ ਦਰ',
          'your_balance': 'ਤੁਹਾਡਾ ਬੈਲੰਸ',
          'history': 'ਇਤਿਹਾਸ',
          'convert_fiat_to_crypto':
              'ਫਿਐਟ ਨੂੰ ਕ੍ਰਿਪਟੋ ਵਿੱਚ ਬਦਲੋ',
          'confirm_withdraw_details':
              'ਕਢਵਾਈ ਵੇਰਵੇ ਪੱਕਾ ਕਰੋ',
          'currency': 'ਮੁਦਰਾ',
          'address': 'ਪਤਾ',
          'please_enter_a_valid_amount':
              'ਕਿਰਪਾ ਕਰਕੇ ਵੈਧ ਰਕਮ ਦਾਖਲ ਕਰੋ',
          'minimum_amount_is': 'ਘੱਟੋ-ਘੱਟ ਰਕਮ ਹੈ',
          'please_enter_an_address':
              'ਕਿਰਪਾ ਕਰਕੇ ਪਤਾ ਦਾਖਲ ਕਰੋ',
          'please_enter_withdrawal_amount':
              'ਕਿਰਪਾ ਕਰਕੇ ਕਢਵਾਈ ਰਕਮ ਦਾਖਲ ਕਰੋ',
          'no_records_found': 'ਕੋਈ ਰਿਕਾਰਡ ਨਹੀਂ ਮਿਲੇ',
          'refresh': 'ਰਿਫ੍ਰੈਸ਼',
          'id': 'ਆਈਡੀ',
          'status': 'ਸਟੇਟਸ',
          'datetime': 'ਤਾਰੀਖ ਅਤੇ ਸਮਾਂ',
          'description': 'ਵੇਰਵਾ',
        },
        'ur': {
          'secondary_wallet_only_enabled_after_limit':
              'پرائمری والٹ کی نکاسی کی حد پوری ہونے کے بعد ہی سیکنڈری والٹ فعال ہوگا',
          'something_went_wrong': 'کچھ غلط ہو گیا',
          'okay': 'ٹھیک ہے',
          'cancel': 'منسوخ',
          'success': 'کامیاب',
          'oops': 'افوہ!',
          'select_payment_method':
              'ادائیگی کا طریقہ منتخب کریں',
          'select_bank_account': 'بینک اکاؤنٹ منتخب کریں',
          'primary_wallet': 'پرائمری والٹ',
          'secondary_wallet': 'سیکنڈری والٹ',
          'account_balance': 'اکاؤنٹ بیلنس',
          'add_withdraw_amount': 'نکاسی رقم شامل کریں',
          'min': 'کم از کم',
          'max': 'زیادہ سے زیادہ',
          'total': 'کل',
          'withdraw_now': 'ابھی نکالیں',
          'withdraw': 'نکالیں',
          'invalid_amount': 'غلط رقم',
          'insufficient_balance': 'ناکافی بیلنس',
          'fill_in_carefully_according_to_the_specific':
              'براہ کرم نکاسی کا پتہ احتیاط سے بھریں',
          'withdraw_amount': 'نکاسی کی رقم',
          'available_balance_in': 'دستیاب بیلنس',
          'preview': 'پیش نظارہ',
          'turnover_progress': 'ٹرن اوور پیشرفت',
          'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
              'سیکیورٹی کے لیے بڑی یا مشکوک نکاسی کے لیے آڈٹ میں 1-6 گھنٹے لگ سکتے ہیں',
          'withdraw_address': 'نکاسی کا پتہ',
          'withdraw_currency': 'نکاسی کرنسی',
          'choose_coin_network': 'کوائن نیٹ ورک منتخب کریں',
          'convert_rate': 'تبادلے کی شرح',
          'your_balance': 'آپ کا بیلنس',
          'history': 'تاریخ',
          'convert_fiat_to_crypto':
              'فیاٹ کو کرپٹو میں تبدیل کریں',
          'confirm_withdraw_details':
              'نکاسی کی تفصیلات کی تصدیق کریں',
          'currency': 'کرنسی',
          'address': 'پتہ',
          'please_enter_a_valid_amount':
              'براہ کرم درست رقم درج کریں',
          'minimum_amount_is': 'کم از کم رقم ہے',
          'please_enter_an_address':
              'براہ کرم پتہ درج کریں',
          'please_enter_withdrawal_amount':
              'براہ کرم نکاسی کی رقم درج کریں',
          'no_records_found': 'کوئی ریکارڈ نہیں ملا',
          'refresh': 'ریفریش',
          'id': 'آئی ڈی',
          'status': 'اسٹیٹس',
          'datetime': 'تاریخ اور وقت',
          'description': 'تفصیل',
        },
      },
      'common_button': {
        'te': {
          'okay': 'సరే',
          'back': 'వెనుకకు',
          'cancel': 'రద్దు చేయండి',
          'submit': 'సబ్మిట్',
          'verify': 'ధృవీకరించండి',
          'play_games': 'గేమ్‌లు ఆడండి',
          'send_otp': 'OTP పంపండి',
          'resend': 'మళ్ళీ పంపండి',
        },
        'hi': {
          'okay': 'ठीक है',
          'back': 'वापस',
          'cancel': 'रद्द करें',
          'submit': 'सबमिट',
          'verify': 'वेरीफाई',
          'play_games': 'गेम्स खेलें',
          'send_otp': 'ओटीपी भेजें',
          'resend': 'पुनः भेजें',
        },
        'bn': {
          'okay': 'ঠিক আছে',
          'back': 'পিছনে',
          'cancel': 'বাতিল',
          'submit': 'সাবমিট',
          'verify': 'যাচাই',
          'play_games': 'গেম খেলুন',
          'send_otp': 'ওটিপি পাঠান',
          'resend': 'পুনরায় পাঠান',
        },
        'mr': {
          'okay': 'ठीक आहे',
          'back': 'मागे',
          'cancel': 'रद्द करा',
          'submit': 'सबमिट',
          'verify': 'सत्यापित करा',
          'play_games': 'गेम खेळा',
          'send_otp': 'ओटीपी पाठवा',
          'resend': 'पुन्हा पाठवा',
        },
      },
      'deposit': {
        'hi': {
          'crypto_deposit': 'क्रिप्टो जमा',
          'select_crypto_coin': 'क्रिप्टो कॉइन चुनें',
          'choose_network': 'नेटवर्क चुनें',
          'select_currency': 'मुद्रा चुनें',
          'choose_your_bonus': 'अपना बोनस चुनें',
          'deposit_address': 'जमा पता',
          'deposit_currency': 'जमा मुद्रा',
          'min_deposit': 'न्यूनतम जमा',
          'convert_crypto_to_fiat':
              'क्रिप्टो को फिएट में बदलें',
          'send_only': 'केवल भेजें',
          'to_this_deposit_address_transfer_below':
              'इस जमा पते पर। नीचे ट्रांसफर',
          'will_not_be_credited': 'जमा नहीं किया जाएगा',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'आपका जमा बोनस आपके लॉक्ड रैकबैक बोनस बैलेंस में जमा किया जाएगा।',
          'bonus_t_and_c': 'बोनस नियम और शर्तें',
          'bonus': 'बोनस',
          'no_bonus': 'कोई बोनस उपलब्ध नहीं',
          'select_bonus': 'बोनस चुनें',
          'copy': 'कॉपी',
          'address_copied_to_clipboard':
              'पता क्लिपबोर्ड पर कॉपी किया गया',
          'apply': 'लागू करें',
          'remove': 'हटाएं',
          'check_status': 'स्थिति जांचें',
          'checking': 'जांच हो रही है...',
          'order_id': 'ऑर्डर आईडी:',
          'loading': 'लोड हो रहा है...',
          'fetching_transaction_status':
              'लेनदेन की स्थिति प्राप्त हो रही है...',
          'something_went_wrong': 'कुछ गलत हो गया',
          'something_went_wrong_promotions':
              'प्रमोशन लोड करने में कुछ गड़बड़ हुई',
          'retry': 'पुनः प्रयास करें',
          'refresh': 'रिफ्रेश',
          'no_promotions_available':
              'कोई प्रमोशन उपलब्ध नहीं है।',
          'please_select_crypto_coin':
              'कृपया जमा करने के लिए एक क्रिप्टो कॉइन चुनें।',
          'okay': 'ठीक है',
        },
        'te': {
          'crypto_deposit': 'క్రిప్టో డిపాజిట్',
          'select_crypto_coin': 'క్రిప్టో కాయిన్ ఎంచుకోండి',
          'choose_network': 'నెట్‌వర్క్ ఎంచుకోండి',
          'select_currency': 'కరెన్సీ ఎంచుకోండి',
          'choose_your_bonus': 'మీ బోనస్ ఎంచుకోండి',
          'deposit_address': 'డిపాజిట్ అడ్రస్',
          'deposit_currency': 'డిపాజిట్ కరెన్సీ',
          'min_deposit': 'కనీస డిపాజిట్',
          'convert_crypto_to_fiat':
              'క్రిప్టోను ఫియట్‌కు మార్చండి',
          'send_only': 'మాత్రమే పంపండి',
          'to_this_deposit_address_transfer_below':
              'ఈ డిపాజిట్ అడ్రస్‌కు. దిగువ బదిలీ',
          'will_not_be_credited': 'జమ చేయబడదు',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'మీ డిపాజిట్ బోనస్ మీ లాక్ చేసిన రాక్‌బ్యాక్ బోనస్ బ్యాలెన్స్‌లో జమ చేయబడుతుంది.',
          'bonus_t_and_c': 'బోనస్ నిబంధనలు & షరతులు',
          'bonus': 'బోనస్',
          'no_bonus': 'బోనస్ అందుబాటులో లేదు',
          'select_bonus': 'బోనస్ ఎంచుకోండి',
          'copy': 'కాపీ',
          'address_copied_to_clipboard':
              'అడ్రస్ క్లిప్‌బోర్డ్‌కు కాపీ చేయబడింది',
          'apply': 'వర్తించు',
          'remove': 'తొలగించు',
          'check_status': 'స్టేటస్ చెక్ చేయండి',
          'checking': 'తనిఖీ చేస్తోంది...',
          'order_id': 'ఆర్డర్ ఐడి:',
          'loading': 'లోడ్ అవుతోంది...',
          'fetching_transaction_status':
              'లావాదేవీ స్థితి పొందుతోంది...',
          'something_went_wrong': 'ఏదో తప్పు జరిగింది',
          'something_went_wrong_promotions':
              'ప్రమోషన్లను లోడ్ చేయడంలో ఏదో తప్పు జరిగింది',
          'retry': 'మళ్ళీ ప్రయత్నించండి',
          'refresh': 'రిఫ్రెష్',
          'no_promotions_available':
              'ప్రమోషన్లు అందుబాటులో లేవు.',
          'please_select_crypto_coin':
              'దయచేసి డిపాజిట్ చేయడానికి ఒక క్రిప్టో కాయిన్‌ను ఎంచుకోండి.',
          'okay': 'సరే',
        },
        'bn': {
          'crypto_deposit': 'ক্রিপ্টো জমা',
          'select_crypto_coin':
              'ক্রিপ্টো কয়েন নির্বাচন করুন',
          'choose_network': 'নেটওয়ার্ক নির্বাচন করুন',
          'select_currency': 'মুদ্রা নির্বাচন করুন',
          'choose_your_bonus': 'আপনার বোনাস নির্বাচন করুন',
          'deposit_address': 'জমা ঠিকানা',
          'deposit_currency': 'জমা মুদ্রা',
          'min_deposit': 'ন্যূনতম জমা',
          'convert_crypto_to_fiat':
              'ক্রিপ্টো ফিয়াটে রূপান্তর করুন',
          'send_only': 'শুধুমাত্র পাঠান',
          'to_this_deposit_address_transfer_below':
              'এই জমা ঠিকানায়। নীচে ট্রান্সফার',
          'will_not_be_credited': 'জমা হবে না',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'আপনার জমা বোনাস আপনার লক করা র‍্যাকব্যাক বোনাস ব্যালেন্সে জমা করা হবে।',
          'bonus_t_and_c': 'বোনাস শর্তাবলী',
          'bonus': 'বোনাস',
          'no_bonus': 'কোনো বোনাস নেই',
          'select_bonus': 'বোনাস নির্বাচন করুন',
          'copy': 'কপি',
          'address_copied_to_clipboard':
              'ঠিকানা ক্লিপবোর্ডে কপি করা হয়েছে',
          'apply': 'প্রয়োগ',
          'remove': 'সরান',
          'check_status': 'স্ট্যাটাস চেক করুন',
          'checking': 'চেক হচ্ছে...',
          'order_id': 'অর্ডার আইডি:',
          'loading': 'লোড হচ্ছে...',
          'fetching_transaction_status':
              'লেনদেনের স্থিতি আনা হচ্ছে...',
          'something_went_wrong': 'কিছু ভুল হয়েছে',
          'something_went_wrong_promotions':
              'প্রমোশন লোড করতে সমস্যা হয়েছে',
          'retry': 'আবার চেষ্টা করুন',
          'refresh': 'রিফ্রেশ',
          'no_promotions_available':
              'কোনো প্রমোশন উপলব্ধ নেই।',
          'please_select_crypto_coin':
              'জমা দেওয়ার জন্য দয়া করে একটি ক্রিপ্টো কয়েন নির্বাচন করুন।',
        },
        'mr': {
          'crypto_deposit': 'क्रिप्टो जमा',
          'select_crypto_coin': 'क्रिप्टो कॉइन निवडा',
          'choose_network': 'नेटवर्क निवडा',
          'select_currency': 'चलन निवडा',
          'choose_your_bonus': 'आपला बोनस निवडा',
          'deposit_address': 'जमा पत्ता',
          'deposit_currency': 'जमा चलन',
          'min_deposit': 'किमान जमा',
          'convert_crypto_to_fiat':
              'क्रिप्टो फिएटमध्ये रूपांतरित करा',
          'send_only': 'फक्त पाठवा',
          'to_this_deposit_address_transfer_below':
              'या जमा पत्त्यावर. खाली हस्तांतरण',
          'will_not_be_credited': 'जमा केले जाणार नाही',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'तुमचा जमा बोनस तुमच्या लॉक केलेल्या रॅकबॅक बोनस बॅलन्समध्ये जमा केला जाईल.',
          'bonus_t_and_c': 'बोनस अटी आणि शर्ती',
          'bonus': 'बोनस',
          'no_bonus': 'बोनस उपलब्ध नाही',
          'select_bonus': 'बोनस निवडा',
          'copy': 'कॉपी',
          'address_copied_to_clipboard':
              'पत्ता क्लिपबोर्डवर कॉपी केला',
          'apply': 'लागू करा',
          'remove': 'काढा',
          'check_status': 'स्थिती तपासा',
          'checking': 'तपासत आहे...',
          'order_id': 'ऑर्डर आयडी:',
          'loading': 'लोड होत आहे...',
          'fetching_transaction_status':
              'व्यवहार स्थिती मिळवत आहे...',
          'something_went_wrong': 'काहीतरी चूक झाली',
          'something_went_wrong_promotions':
              'प्रमोशन लोड करताना काहीतरी चूक झाली',
          'retry': 'पुन्हा प्रयत्न करा',
          'refresh': 'रिफ्रेश',
          'no_promotions_available':
              'कोणतेही प्रमोशन उपलब्ध नाही.',
          'please_select_crypto_coin':
              'कृपया डिपॉझिट करण्यासाठी एक क्रिप्टो कॉइन निवडा.',
          'okay': 'ठीक आहे',
        },
        'ta': {
          'crypto_deposit': 'கிரிப்டோ டெபாசிட்',
          'select_crypto_coin':
              'கிரிப்டோ காயின் தேர்ந்தெடுக்கவும்',
          'choose_network': 'நெட்வொர்க் தேர்ந்தெடுக்கவும்',
          'select_currency': 'நாணயம் தேர்ந்தெடுக்கவும்',
          'choose_your_bonus':
              'உங்கள் போனஸை தேர்ந்தெடுக்கவும்',
          'deposit_address': 'டெபாசிட் முகவரி',
          'deposit_currency': 'டெபாசிட் நாணயம்',
          'min_deposit': 'குறைந்தபட்ச டெபாசிட்',
          'convert_crypto_to_fiat':
              'கிரிப்டோவை ஃபியட்டாக மாற்றவும்',
          'send_only': 'மட்டும் அனுப்பவும்',
          'to_this_deposit_address_transfer_below':
              'இந்த டெபாசிட் முகவரிக்கு. கீழே பரிமாற்றம்',
          'will_not_be_credited': 'வரவு வைக்கப்படாது',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'உங்கள் டெபாசிட் போனஸ் உங்கள் லாக் செய்யப்பட்ட ராக்பேக் போனஸ் பேலன்ஸில் வரவு வைக்கப்படும்.',
          'bonus_t_and_c': 'போனஸ் விதிமுறைகள்',
          'bonus': 'போனஸ்',
          'no_bonus': 'போனஸ் இல்லை',
          'select_bonus': 'போனஸ் தேர்ந்தெடுக்கவும்',
          'copy': 'நகல்',
          'address_copied_to_clipboard':
              'முகவரி கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது',
          'apply': 'விண்ணப்பி',
          'remove': 'நீக்கு',
          'check_status': 'நிலை சரிபார்க்கவும்',
          'checking': 'சரிபார்க்கிறது...',
          'order_id': 'ஆர்டர் ஐடி:',
          'loading': 'ஏற்றுகிறது...',
          'fetching_transaction_status':
              'பரிவர்த்தனை நிலையைப் பெறுகிறது...',
          'something_went_wrong': 'ஏதோ தவறு ஏற்பட்டது',
          'something_went_wrong_promotions':
              'விளம்பரங்களை ஏற்றுவதில் ஏதோ தவறு',
          'retry': 'மீண்டும் முயற்சிக்கவும்',
          'refresh': 'புதுப்பி',
          'no_promotions_available':
              'விளம்பரங்கள் எதுவும் கிடைக்கவில்லை.',
          'please_select_crypto_coin':
              'டெபாசிட் செய்ய கிரிப்டோ காயினைத் தேர்ந்தெடுக்கவும்.',
          'okay': 'சரி',
        },
        'gu': {
          'crypto_deposit': 'ક્રિપ્ટો ડિપોઝિટ',
          'select_crypto_coin': 'ક્રિપ્ટો કોઈન પસંદ કરો',
          'choose_network': 'નેટવર્ક પસંદ કરો',
          'select_currency': 'ચલણ પસંદ કરો',
          'choose_your_bonus': 'તમારો બોનસ પસંદ કરો',
          'deposit_address': 'ડિપોઝિટ સરનામું',
          'deposit_currency': 'ડિપોઝિટ ચલણ',
          'min_deposit': 'ન્યૂનતમ ડિપોઝિટ',
          'convert_crypto_to_fiat':
              'ક્રિપ્ટોને ફિયાટમાં રૂપાંતરિત કરો',
          'send_only': 'ફક્ત મોકલો',
          'to_this_deposit_address_transfer_below':
              'આ ડિપોઝિટ સરનામા પર. નીચે ટ્રાન્સફર',
          'will_not_be_credited': 'જમા થશે નહીં',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'તમારો ડિપોઝિટ બોનસ તમારા લૉક કરેલ રેકબેક બોનસ બેલેન્સમાં જમા કરવામાં આવશે.',
          'bonus_t_and_c': 'બોનસ નિયમો અને શરતો',
          'bonus': 'બોનસ',
          'no_bonus': 'કોઈ બોનસ ઉપલબ્ધ નથી',
          'select_bonus': 'બોનસ પસંદ કરો',
          'copy': 'કૉપિ',
          'address_copied_to_clipboard':
              'સરનામું ક્લિપબોર્ડ પર કૉપિ થયું',
          'apply': 'લાગુ કરો',
          'remove': 'દૂર કરો',
          'check_status': 'સ્થિતિ તપાસો',
          'checking': 'તપાસ ચાલુ છે...',
          'order_id': 'ઓર્ડર આઈડી:',
          'loading': 'લોડ થઈ રહ્યું છે...',
          'fetching_transaction_status':
              'વ્યવહારની સ્થિતિ મેળવી રહ્યા છીએ...',
          'something_went_wrong': 'કંઈક ખોટું થયું',
          'something_went_wrong_promotions':
              'પ્રમોશન લોડ કરવામાં કંઈક ખોટું થયું',
          'retry': 'ફરી પ્રયાસ કરો',
          'refresh': 'રિફ્રેશ',
          'no_promotions_available':
              'કોઈ પ્રમોશન ઉપલબ્ધ નથી.',
          'please_select_crypto_coin':
              'ડિપોઝિટ કરવા માટે કૃપા કરીને ક્રિપ્ટો કોઈન પસંદ કરો.',
          'okay': 'ઠીક છે',
        },
        'kn': {
          'crypto_deposit': 'ಕ್ರಿಪ್ಟೋ ಠೇವಣಿ',
          'select_crypto_coin': 'ಕ್ರಿಪ್ಟೋ ಕಾಯಿನ್ ಆಯ್ಕೆಮಾಡಿ',
          'choose_network': 'ನೆಟ್‌ವರ್ಕ್ ಆಯ್ಕೆಮಾಡಿ',
          'select_currency': 'ಕರೆನ್ಸಿ ಆಯ್ಕೆಮಾಡಿ',
          'choose_your_bonus': 'ನಿಮ್ಮ ಬೋನಸ್ ಆಯ್ಕೆಮಾಡಿ',
          'deposit_address': 'ಠೇವಣಿ ವಿಳಾಸ',
          'deposit_currency': 'ಠೇವಣಿ ಕರೆನ್ಸಿ',
          'min_deposit': 'ಕನಿಷ್ಠ ಠೇವಣಿ',
          'convert_crypto_to_fiat':
              'ಕ್ರಿಪ್ಟೋವನ್ನು ಫಿಯಾಟ್‌ಗೆ ಪರಿವರ್ತಿಸಿ',
          'send_only': 'ಮಾತ್ರ ಕಳುಹಿಸಿ',
          'to_this_deposit_address_transfer_below':
              'ಈ ಠೇವಣಿ ವಿಳಾಸಕ್ಕೆ. ಕೆಳಗೆ ವರ್ಗಾವಣೆ',
          'will_not_be_credited': 'ಜಮಾ ಆಗುವುದಿಲ್ಲ',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'ನಿಮ್ಮ ಠೇವಣಿ ಬೋನಸ್ ನಿಮ್ಮ ಲಾಕ್ ಮಾಡಿದ ರಾಕ್‌ಬ್ಯಾಕ್ ಬೋನಸ್ ಬ್ಯಾಲೆನ್ಸ್‌ನಲ್ಲಿ ಜಮಾ ಆಗುತ್ತದೆ.',
          'bonus_t_and_c': 'ಬೋನಸ್ ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು',
          'bonus': 'ಬೋನಸ್',
          'no_bonus': 'ಬೋನಸ್ ಲಭ್ಯವಿಲ್ಲ',
          'select_bonus': 'ಬೋನಸ್ ಆಯ್ಕೆಮಾಡಿ',
          'copy': 'ನಕಲಿಸಿ',
          'address_copied_to_clipboard':
              'ವಿಳಾಸ ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ',
          'apply': 'ಅನ್ವಯಿಸಿ',
          'remove': 'ತೆಗೆದುಹಾಕಿ',
          'check_status': 'ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ',
          'checking': 'ಪರಿಶೀಲಿಸುತ್ತಿದೆ...',
          'order_id': 'ಆರ್ಡರ್ ಐಡಿ:',
          'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
          'fetching_transaction_status':
              'ವಹಿವಾಟಿನ ಸ್ಥಿತಿಯನ್ನು ಪಡೆಯಲಾಗುತ್ತಿದೆ...',
          'something_went_wrong': 'ಏನೋ ತಪ್ಪಾಯಿತು',
          'something_went_wrong_promotions':
              'ಪ್ರಮೋಷನ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ತಪ್ಪಾಯಿತು',
          'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
          'refresh': 'ರಿಫ್ರೆಶ್',
          'no_promotions_available':
              'ಯಾವುದೇ ಪ್ರಮೋಷನ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ.',
          'please_select_crypto_coin':
              'ಠೇವಣಿ ಮಾಡಲು ದಯವಿಟ್ಟು ಕ್ರಿಪ್ಟೋ ಕಾಯಿನ್ ಆಯ್ಕೆಮಾಡಿ.',
          'okay': 'ಸರಿ',
        },
        'ml': {
          'crypto_deposit': 'ക്രിപ്‌റ്റോ നിക്ഷേപം',
          'select_crypto_coin':
              'ക്രിപ്‌റ്റോ കോയിൻ തിരഞ്ഞെടുക്കുക',
          'choose_network': 'നെറ്റ്‌വർക്ക് തിരഞ്ഞെടുക്കുക',
          'select_currency': 'കറൻസി തിരഞ്ഞെടുക്കുക',
          'choose_your_bonus':
              'നിങ്ങളുടെ ബോണസ് തിരഞ്ഞെടുക്കുക',
          'deposit_address': 'നിക്ഷേപ വിലാസം',
          'deposit_currency': 'നിക്ഷേപ കറൻസി',
          'min_deposit': 'ഏറ്റവും കുറഞ്ഞ നിക്ഷേപം',
          'convert_crypto_to_fiat':
              'ക്രിപ്‌റ്റോ ഫിയറ്റിലേക്ക് മാറ്റുക',
          'send_only': 'മാത്രം അയയ്ക്കുക',
          'to_this_deposit_address_transfer_below':
              'ഈ നിക്ഷേപ വിലാസത്തിലേക്ക്. താഴെ ട്രാൻസ്ഫർ',
          'will_not_be_credited':
              'ക്രെഡിറ്റ് ചെയ്യപ്പെടില്ല',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'നിങ്ങളുടെ നിക്ഷേപ ബോണസ് നിങ്ങളുടെ ലോക്ക് ചെയ്ത റാക്ക്‌ബാക്ക് ബോണസ് ബാലൻസിൽ ക്രെഡിറ്റ് ചെയ്യപ്പെടും.',
          'bonus_t_and_c': 'ബോണസ് നിബന്ധനകൾ',
          'bonus': 'ബോണസ്',
          'no_bonus': 'ബോണസ് ലഭ്യമല്ല',
          'select_bonus': 'ബോണസ് തിരഞ്ഞെടുക്കുക',
          'copy': 'പകർത്തുക',
          'address_copied_to_clipboard':
              'വിലാസം ക്ലിപ്‌ബോർഡിലേക്ക് പകർത്തി',
          'apply': 'പ്രയോഗിക്കുക',
          'remove': 'നീക്കം ചെയ്യുക',
          'check_status': 'സ്ഥിതി പരിശോധിക്കുക',
          'checking': 'പരിശോധിക്കുന്നു...',
          'order_id': 'ഓർഡർ ഐഡി:',
          'loading': 'ലോഡ് ചെയ്യുന്നു...',
          'fetching_transaction_status':
              'ഇടപാട് നില ലഭ്യമാക്കുന്നു...',
          'something_went_wrong': 'എന്തോ കുഴപ്പം സംഭവിച്ചു',
          'something_went_wrong_promotions':
              'പ്രമോഷനുകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്',
          'retry': 'വീണ്ടും ശ്രമിക്കുക',
          'refresh': 'പുതുക്കുക',
          'no_promotions_available': 'പ്രമോഷനുകൾ ലഭ്യമല്ല.',
          'please_select_crypto_coin':
              'നിക്ഷേപിക്കാൻ ദയവായി ഒരു ക്രിപ്‌റ്റോ കോയിൻ തിരഞ്ഞെടുക്കുക.',
          'okay': 'ശരി',
        },
        'pa': {
          'crypto_deposit': 'ਕ੍ਰਿਪਟੋ ਜਮ੍ਹਾ',
          'select_crypto_coin': 'ਕ੍ਰਿਪਟੋ ਕੋਇਨ ਚੁਣੋ',
          'choose_network': 'ਨੈੱਟਵਰਕ ਚੁਣੋ',
          'select_currency': 'ਮੁਦਰਾ ਚੁਣੋ',
          'choose_your_bonus': 'ਆਪਣਾ ਬੋਨਸ ਚੁਣੋ',
          'deposit_address': 'ਜਮ੍ਹਾ ਪਤਾ',
          'deposit_currency': 'ਜਮ੍ਹਾ ਮੁਦਰਾ',
          'min_deposit': 'ਘੱਟੋ-ਘੱਟ ਜਮ੍ਹਾ',
          'convert_crypto_to_fiat':
              'ਕ੍ਰਿਪਟੋ ਨੂੰ ਫਿਏਟ ਵਿੱਚ ਬਦਲੋ',
          'send_only': 'ਸਿਰਫ਼ ਭੇਜੋ',
          'to_this_deposit_address_transfer_below':
              'ਇਸ ਜਮ੍ਹਾ ਪਤੇ \'ਤੇ। ਹੇਠਾਂ ਟ੍ਰਾਂਸਫ਼ਰ',
          'will_not_be_credited': 'ਜਮ੍ਹਾ ਨਹੀਂ ਕੀਤਾ ਜਾਵੇਗਾ',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'ਤੁਹਾਡਾ ਜਮ੍ਹਾ ਬੋਨਸ ਤੁਹਾਡੇ ਲਾਕ ਕੀਤੇ ਰੈਕਬੈਕ ਬੋਨਸ ਬੈਲੇਂਸ ਵਿੱਚ ਜਮ੍ਹਾ ਕੀਤਾ ਜਾਵੇਗਾ।',
          'bonus_t_and_c': 'ਬੋਨਸ ਨਿਯਮ ਅਤੇ ਸ਼ਰਤਾਂ',
          'bonus': 'ਬੋਨਸ',
          'no_bonus': 'ਕੋਈ ਬੋਨਸ ਉਪਲਬਧ ਨਹੀਂ',
          'select_bonus': 'ਬੋਨਸ ਚੁਣੋ',
          'copy': 'ਕਾਪੀ',
          'address_copied_to_clipboard':
              'ਪਤਾ ਕਲਿੱਪਬੋਰਡ \'ਤੇ ਕਾਪੀ ਹੋ ਗਿਆ',
          'apply': 'ਲਾਗੂ ਕਰੋ',
          'remove': 'ਹਟਾਓ',
          'check_status': 'ਸਥਿਤੀ ਜਾਂਚੋ',
          'checking': 'ਚੈੱਕ ਹੋ ਰਿਹਾ ਹੈ...',
          'order_id': 'ਆਰਡਰ ਆਈਡੀ:',
          'loading': 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...',
          'fetching_transaction_status':
              'ਲੈਣ‑ਦੇਣ ਦੀ ਸਥਿਤੀ ਪ੍ਰਾਪਤ ਹੋ ਰਹੀ ਹੈ...',
          'something_went_wrong': 'ਕੁਝ ਗਲਤ ਹੋ ਗਿਆ',
          'something_went_wrong_promotions':
              'ਪ੍ਰਮੋਸ਼ਨ ਲੋਡ ਕਰਨ ਵਿੱਚ ਗੜਬੜ ਹੋਈ',
          'retry': 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
          'refresh': 'ਰਿਫ੍ਰੈਸ਼',
          'no_promotions_available':
              'ਕੋਈ ਪ੍ਰਮੋਸ਼ਨ ਉਪਲਬਧ ਨਹੀਂ।',
          'please_select_crypto_coin':
              'ਜਮ੍ਹਾ ਕਰਨ ਲਈ ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਕ੍ਰਿਪਟੋ ਕੋਇਨ ਚੁਣੋ।',
          'okay': 'ਠੀਕ ਹੈ',
        },
        'ur': {
          'crypto_deposit': 'کرپٹو ڈپازٹ',
          'select_crypto_coin': 'کرپٹو کوائن منتخب کریں',
          'choose_network': 'نیٹ ورک منتخب کریں',
          'select_currency': 'کرنسی منتخب کریں',
          'choose_your_bonus': 'اپنا بونس منتخب کریں',
          'deposit_address': 'ڈپازٹ ایڈریس',
          'deposit_currency': 'ڈپازٹ کرنسی',
          'min_deposit': 'کم از کم ڈپازٹ',
          'convert_crypto_to_fiat':
              'کرپٹو کو فیاٹ میں تبدیل کریں',
          'send_only': 'صرف بھیجیں',
          'to_this_deposit_address_transfer_below':
              'اس ڈپازٹ ایڈریس پر۔ نیچے ٹرانسفر',
          'will_not_be_credited': 'جمع نہیں کیا جائے گا',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'آپ کا ڈپازٹ بونس آپ کے لاک شدہ ریک بیک بونس بیلنس میں جمع کیا جائے گا۔',
          'bonus_t_and_c': 'بونس شرائط و ضوابط',
          'bonus': 'بونس',
          'no_bonus': 'کوئی بونس دستیاب نہیں',
          'select_bonus': 'بونس منتخب کریں',
          'copy': 'کاپی',
          'address_copied_to_clipboard':
              'ایڈریس کلپ بورڈ پر کاپی ہو گیا',
          'apply': 'لاگو کریں',
          'remove': 'ہٹائیں',
          'check_status': 'اسٹیٹس چیک کریں',
          'checking': 'چیک ہو رہا ہے...',
          'order_id': 'آرڈر آئی ڈی:',
          'loading': 'لوڈ ہو رہا ہے...',
          'fetching_transaction_status':
              'ٹرانزیکشن کی حالت حاصل ہو رہی ہے...',
          'something_went_wrong': 'کچھ غلط ہو گیا',
          'something_went_wrong_promotions':
              'پروموشنز لوڈ کرنے میں کچھ غلطی ہوئی',
          'retry': 'دوبارہ کوشش کریں',
          'refresh': 'ریفریش',
          'no_promotions_available':
              'کوئی پروموشن دستیاب نہیں۔',
          'please_select_crypto_coin':
              'ڈپازٹ کرنے کے لیے براہ کرم ایک کرپٹو کوائن منتخب کریں۔',
          'okay': 'ٹھیک ہے',
        },
        'be': {
          'crypto_deposit': 'ক্রিপ্টো জমা',
          'select_crypto_coin':
              'ক্রিপ্টো কয়েন নির্বাচন করুন',
          'choose_network': 'নেটওয়ার্ক নির্বাচন করুন',
          'select_currency': 'মুদ্রা নির্বাচন করুন',
          'choose_your_bonus': 'আপনার বোনাস নির্বাচন করুন',
          'deposit_address': 'জমা ঠিকানা',
          'deposit_currency': 'জমা মুদ্রা',
          'min_deposit': 'ন্যূনতম জমা',
          'convert_crypto_to_fiat':
              'ক্রিপ্টো ফিয়াটে রূপান্তর করুন',
          'send_only': 'শুধুমাত্র পাঠান',
          'to_this_deposit_address_transfer_below':
              'এই জমা ঠিকানায়। নীচে ট্রান্সফার',
          'will_not_be_credited': 'জমা হবে না',
          'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
              'আপনার জমা বোনাস আপনার লক করা র‍্যাকব্যাক বোনাস ব্যালেন্সে জমা করা হবে।',
          'bonus_t_and_c': 'বোনাস শর্তাবলী',
          'bonus': 'বোনাস',
          'no_bonus': 'কোনো বোনাস নেই',
          'select_bonus': 'বোনাস নির্বাচন করুন',
          'copy': 'কপি',
          'address_copied_to_clipboard':
              'ঠিকানা ক্লিপবোর্ডে কপি করা হয়েছে',
          'apply': 'প্রয়োগ',
          'remove': 'সরান',
          'check_status': 'স্ট্যাটাস চেক করুন',
          'checking': 'চেক হচ্ছে...',
          'order_id': 'অর্ডার আইডি:',
          'loading': 'লোড হচ্ছে...',
          'fetching_transaction_status':
              'লেনদেনের স্থিতি আনা হচ্ছে...',
          'something_went_wrong': 'কিছু ভুল হয়েছে',
          'something_went_wrong_promotions':
              'প্রমোশন লোড করতে সমস্যা হয়েছে',
          'retry': 'আবার চেষ্টা করুন',
          'refresh': 'রিফ্রেশ',
          'no_promotions_available':
              'কোনো প্রমোশন উপলব্ধ নেই।',
          'please_select_crypto_coin':
              'জমা দেওয়ার জন্য দয়া করে একটি ক্রিপ্টো কয়েন নির্বাচন করুন।',
          'okay': 'ঠিক আছে',
        },
      },
    };

    // Inject inline translations into _localizedStrings
    for (final catEntry in inlineTranslations.entries) {
      final category = catEntry.key;
      for (final langEntry in catEntry.value.entries) {
        final lang = langEntry.key;
        final translations = langEntry.value;

        // Create language entry if not loaded from CDN
        _localizedStrings[lang] ??= <String, dynamic>{};
        final langData = _localizedStrings[lang];
        if (langData is! Map) continue;

        langData[category] ??= <String, dynamic>{};
        final target = langData[category];
        if (target is! Map) continue;

        for (final kv in translations.entries) {
          // Only inject if NOT already present (CDN/redirect takes priority)
          if (!target.containsKey(kv.key)) {
            target[kv.key] = kv.value;
          }
        }
      }
    }

    debugPrint(
        'Synthesized categories + inline translations for all languages.');
  }

  /// Fetches a single per-page JSON and merges its data into [_localizedStrings].
  ///
  /// Handles two structural patterns:
  /// - **normal**: `{lang}.{category}.{key}` (e.g., myaccountpage.json)
  /// - **inverted**: `{categoryName}.{lang}.{key}` (e.g., statementpage.json, depositpage.json)
  Future<void> _fetchAndMergePageJson(
      String fileName, String structureType) async {
    try {
      final response = await http.get(
          Uri.parse(_getProxyUrl('$_cdnBase/$fileName')));
      if (response.statusCode != 200) {
        debugPrint(
            'Failed to fetch $fileName: ${response.statusCode}');
        return;
      }

      final data =
          json.decode(utf8.decode(response.bodyBytes));
      if (data is! Map) {
        debugPrint(
            '$fileName: unexpected format (not a Map)');
        return;
      }

      if (structureType == 'inverted') {
        _mergeInvertedStructure(data, fileName);
      } else {
        _mergeNormalStructure(data, fileName);
      }
    } catch (e) {
      debugPrint('Error fetching/parsing $fileName: $e');
    }
  }

  /// Merges data with normal structure: `{lang}.{category}.{key}`
  void _mergeNormalStructure(
      Map<dynamic, dynamic> data, String fileName) {
    for (final langCode in data.keys) {
      final langData = data[langCode];
      if (langData is! Map) continue;

      // Ensure the language entry exists in _localizedStrings
      _localizedStrings[langCode] ??= {};

      // Merge each category
      for (final category in langData.keys) {
        final categoryData = langData[category];
        if (categoryData is! Map) continue;

        if (_localizedStrings[langCode] is Map) {
          (_localizedStrings[langCode] as Map)[category] ??=
              {};
          final existingCategory =
              (_localizedStrings[langCode]
                  as Map)[category];
          if (existingCategory is Map) {
            existingCategory.addAll(
                Map<String, dynamic>.from(categoryData));
          } else {
            (_localizedStrings[langCode] as Map)[category] =
                Map<String, dynamic>.from(categoryData);
          }
        }
      }
    }
    debugPrint(
        'Merged $fileName (normal structure) into localizedStrings');
  }

  /// Merges data with inverted structure: `{categoryName}.{lang}.{key}`
  /// Normalizes to: `{lang}.{categoryName}.{key}`
  void _mergeInvertedStructure(
      Map<dynamic, dynamic> data, String fileName) {
    for (final categoryName in data.keys) {
      final categoryLangData = data[categoryName];
      if (categoryLangData is! Map) continue;

      for (final langCode in categoryLangData.keys) {
        final translations = categoryLangData[langCode];
        if (translations is! Map) continue;

        // Ensure the language entry exists
        _localizedStrings[langCode] ??= {};

        if (_localizedStrings[langCode] is Map) {
          (_localizedStrings[langCode]
              as Map)[categoryName] ??= {};
          final existingCategory =
              (_localizedStrings[langCode]
                  as Map)[categoryName];
          if (existingCategory is Map) {
            existingCategory.addAll(
                Map<String, dynamic>.from(translations));
          } else {
            (_localizedStrings[langCode]
                    as Map)[categoryName] =
                Map<String, dynamic>.from(translations);
          }
        }
      }
    }
    debugPrint(
        'Merged $fileName (inverted structure) into localizedStrings');
  }

  Future<void> detectAndSetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language_code')) {
      debugPrint(
          'User has already selected a language: ${prefs.getString('language_code')}. Skipping auto-detection.');
      return;
    }

    try {
      debugPrint('Detecting location via IP API...');
      final response =
          await http.get(Uri.parse('https://ipwho.is/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode =
            data['country_code'] ?? data['countryCode'];
        debugPrint('Location detected: $countryCode');

        String? detectedLang;
        if (countryCode == 'BD') {
          detectedLang = 'bn';
        } else if (countryCode == 'IN') {
          detectedLang = 'hi';
        } else {
          debugPrint(
              'Country $countryCode does not trigger specific language switch.');
        }

        if (detectedLang != null &&
            _languageNames.containsKey(detectedLang)) {
          debugPrint(
              'Setting language to $detectedLang based on location.');
          await setLanguage(detectedLang);
        }
      } else {
        debugPrint(
            'Failed to get location: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error detecting location: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    GlobalConstant.appLanguage =
        languageCode; // Update global constant if used elsewhere

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    notifyListeners();
  }

  // Categories that share translations and should cross-fallback
  // to each other when a key is not found in the primary category.
  static const Map<String, List<String>> _categorySiblings =
      {
    'account': ['auth'],
    'auth': ['account'],
    'bottom_nav': ['home_screen'],
    'home_screen': ['bottom_nav'],
  };

  String getString(String category, String key) {
    // 1. Try to get from the map for the current locale
    final langCode = _currentLocale.languageCode;

    if (_localizedStrings.containsKey(langCode)) {
      final categoryData =
          _localizedStrings[langCode][category];
      if (categoryData != null &&
          categoryData is Map &&
          categoryData.containsKey(key)) {
        return categoryData[key].toString();
      }

      // 1b. Try sibling categories for the current locale
      final siblings = _categorySiblings[category];
      if (siblings != null) {
        for (final sibling in siblings) {
          final siblingData =
              _localizedStrings[langCode][sibling];
          if (siblingData != null &&
              siblingData is Map &&
              siblingData.containsKey(key)) {
            return siblingData[key].toString();
          }
        }
      }
    }

    // 2. Fallback to English 'en'
    if (_localizedStrings.containsKey('en')) {
      final categoryData =
          _localizedStrings['en'][category];
      if (categoryData != null &&
          categoryData is Map &&
          categoryData.containsKey(key)) {
        return categoryData[key].toString();
      }

      // 2b. Try sibling categories for English
      final siblings = _categorySiblings[category];
      if (siblings != null) {
        for (final sibling in siblings) {
          final siblingData =
              _localizedStrings['en'][sibling];
          if (siblingData != null &&
              siblingData is Map &&
              siblingData.containsKey(key)) {
            return siblingData[key].toString();
          }
        }
      }
    }

    // 3. Fallback to built-in English defaults
    final builtInCategory = _builtInFallbacks[category];
    if (builtInCategory != null &&
        builtInCategory.containsKey(key)) {
      return builtInCategory[key]!;
    }

    // 3b. Try sibling built-in fallbacks
    final siblings = _categorySiblings[category];
    if (siblings != null) {
      for (final sibling in siblings) {
        final siblingBuiltIn = _builtInFallbacks[sibling];
        if (siblingBuiltIn != null &&
            siblingBuiltIn.containsKey(key)) {
          return siblingBuiltIn[key]!;
        }
      }
    }

    // 4. Fallback to key itself if nothing found
    return key;
  }

  /// Built-in English fallback strings for categories that may be
  /// missing from the remote CDN JSON. This prevents raw key names
  /// (e.g. "search_text", "vip_level") from appearing on screen.
  static const Map<String, Map<String, String>>
      _builtInFallbacks = {
    'auth': {
      'login': 'Login',
      'register': 'Register',
      'forgot_password': 'Forgot Password',
      'mobile_or_email': 'Mobile or Email',
      'enter_mobile_or_email': 'Enter Mobile or Email',
      'password': 'Password',
      'enter_password': 'Enter Password',
      'confirm_password': 'Confirm Password',
      'enter_confirm_password': 'Enter Confirm Password',
      'oops': 'Oops!',
      'error': 'Error',
      'forgotpassword': 'Forgot Password',
      'pleaseprovidepassword': 'Please provide password',
      'passwordshould6characters':
          'Password should be at least 6 characters',
      'loginfailed': 'Login Failed',
      'mobile': 'Mobile',
      'email': 'Email',
      'mobile_number': 'Mobile Number',
      'enter_mobile_number': 'Enter Mobile Number',
      'enter_email_address': 'Enter Email Address',
      'send_otp': 'Send OTP',
      'otp_sent_to_mobile':
          'We will send OTP to your mobile.',
      'otp_sent_to_email':
          'We will send OTP to your email.',
      'select_verification_method':
          'Select Verification Method',
      'edit': 'Edit',
      'enter_otp': 'Enter OTP',
      'enter_whatsapp_otp': 'Enter WhatsApp OTP',
      'enter_email_otp': 'Enter Email OTP',
      'login_with_otp': 'Login with OTP',
      'login_with_password': 'Login with Password',
      'resend_in': 'Resend in',
      'resend_otp': 'Resend OTP',
      'email_otp': 'Email OTP',
      'we_will_send_otp_info':
          'We\'ll send OTP to WhatsApp and Email.',
      'loss_back_title': '100% Loss Back',
      'loss_back_desc':
          'Play risk-free! Get 100% of your first loss returned.',
      'i_agree_terms': 'I agree to the Terms & Conditions',
      'whatsapp_number': 'WhatsApp Number',
      'enter_whatsapp_number': 'Enter WhatsApp Number',
      'please_enter_mobile_or_email':
          'Please enter mobile number or email',
      'please_enter_email':
          'Please enter your email address',
      'send_otps': 'Send OTPs',
      'invalidcredential':
          'Invalid credentials. Please try again.',
      'somethingwentwrong':
          'Something went wrong. Please try again.',
      'youmayonlyperformthisactionevery30seconds':
          'You may only perform this action every 30 seconds.',
      'invalidOTP': 'Invalid OTP. Please try again.',
      'registration_completed': 'Registration Completed',
      'registration_successful': 'Registration Successful',
      'please_agree_terms':
          'Please agree to the Terms and Conditions',
    },
    'common_button': {
      'okay': 'Okay',
      'back': 'Back',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'verify': 'Verify',
      'play_games': 'Play Games',
      'send_otp': 'Send OTP',
      'resend': 'Resend',
    },
    'categories': {
      'casino': 'Casino',
      'search': 'Search',
    },
    'home_screen': {
      // Greetings & general
      'hi': 'Hi',
      'localeName': 'English',
      'search': 'Search',
      'search_text': 'Search',
      'games': 'Games',
      'back': 'Back',
      'load_more': 'Load More',
      'coming_soon': 'Coming Soon',
      'welcometo': 'Welcome to',
      'appdescription': '',
      'scamalert': '',
      'livechat': 'Live Chat',
      'login_now': 'Login Now',
      'ok': 'OK',
      'okay': 'Okay',
      'oops': 'Oops!',
      'expires_in': 'Expires In',
      'processing': 'Processing',
      'amount': 'Amount',

      // Wallet & balance
      'main_wallet': 'Main Wallet',
      'referral_wallet': 'Referral Wallet',
      'referral_earning': 'Referral Earning',
      'referral_lobby': 'Referral Lobby',
      'referral_play_wallet': 'Referral Play Wallet',
      'transfer': 'Transfer',
      'transfer_to_play_wallet': 'Transfer To Play Wallet',
      'enter_amount_to_transfer_to_play_wallet':
          'Enter Amount To Transfer To Play Wallet',
      'enter_a_valid_amount': 'Enter A Valid Amount',
      'successfully_transferred_to_your_play_wallet':
          'Successfully Transferred To Your Play Wallet',
      'back_to_lobby': 'Back To Lobby',
      'switch_to': 'Switch To',
      'switch_to_referral_wallet':
          'Switch To Referral Wallet',

      // Game categories & types
      'casino': 'Casino',
      'poker': 'Poker',
      'slot': 'Slot',
      'slots': 'Slots',
      'crash': 'Crash',
      'tabelgame': 'Table Game',
      'lottery': 'Lottery',
      'esport': 'E-Sports',
      'roulette': 'Roulette',
      'teenpatti': 'Teen Patti',
      'livedealer': 'Live Dealer',
      'sports': 'Sports',
      'exclusive': 'Exclusive',
      'table': 'Table',

      // Game sub-categories
      'mostpopular': 'Most Popular',
      'baccarat': 'Baccarat',
      'blackjack': 'Blackjack',
      'liveroulette': 'Live Roulette',
      'topindiangames': 'Top Indian Games',
      'wheellottery': 'Wheel & Lottery',

      // Bonus & earnings
      'bonus': 'Bonus',
      'deposit': 'Deposit',
      'rebate': 'Rebate',
      'lossback': 'Lossback',
      'total_bonus': 'Total Bonus',
      'deposit_bonus': 'Deposit Bonus',
      'rebate_bonus': 'Rebate Bonus',
      'fightback_bonus': 'Fightback Bonus',
      'won': 'Won',
      'claim_all': 'Claim All',

      // Refer & Earn
      'refer_and_earn_unlimited_money':
          'Refer & Earn Unlimited Money',
      'withdraw_unlimited_referral_money_in_your_bank_with_play_games':
          'Withdraw Unlimited Referral Money In Your Bank With Play Games',
      'only_on_': 'Only On',
      'how_it_works': 'How It Works',
      'get_unlimited_commission':
          'Get Unlimited Commission',
      'faq': 'FAQ',

      // VIP
      'vip_level': 'VIP Level',
      'unlocked': 'Unlocked',
      'your_vip_level': 'Your VIP Level',

      // Home page referral journey
      'your_referral_earning_to_withdrawal_journey':
          'Your Referral Earning to Withdrawal Journey',
      'refer_to_friends': 'Refer To Friends',
      'referral_earning_get_in_live_wallet':
          'Referral Earning Get In Live Wallet',
      'transfer_fund_to_play_wallet':
          'Transfer Fund To Play Wallet',
      'complete_turnover': 'Complete Turnover',
      'withdraw_in_bkash_or_nagad':
          'Withdraw in crypto currency',

      // Navigation & actions
      'promotions': 'Promotions',
      'promotion': 'Promotion',
      'logout': 'Logout',
      'install_update': 'Install Update',
      'restart': 'Restart',
      'reload': 'Reload',
      'daily': 'Daily',
      'weekly': 'Weekly',

      // Live winners
      'live_winner': 'Live Winner',
      'seconds_ago': 'seconds ago',

      // Download
      'download_app': 'Download App',
      'download_ios_app': 'Download iOS App',
      'download_android_app': 'Download Android App',
      'downloadwinbajinow': 'Download Playcrypto365 Now',
      'transfer_to_main_wallet': 'Transfer to Main Wallet',
      'download': 'Download',

      // Refer wallet tabs
      'refer_now': 'Refer Now',
      'refer_and_earn': 'Refer & Earn',
      'my_earnings': 'My Earnings',
      'my_earning': 'My Earning',
      'withdraw': 'Withdraw',
      'withdrawal': 'Withdrawal',
      'withdraw_history': 'Withdraw History',
      'statement_title': 'Statement',
      'and_earn_cash': 'And Earn Cash',
      'and_fund_transfer': 'And Fund Transfer',
      'crypto_currency': 'Crypto Currency',
      'total_referrals': 'Total Referrals',
      'total_earnings': 'Total Earnings',
      'share_link': 'Share Link',
      'copy_link': 'Copy Link',
      'invite_friends': 'Invite Friends',
      'referral_code': 'Referral Code',
      'commission': 'Commission',
      'level': 'Level',
      'direct': 'Direct',
      'indirect': 'Indirect',
      'earning': 'Earning',
      'total': 'Total',
      'date': 'Date',
      'username': 'Username',
      'status': 'Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'join_winbaji_and_earn_money_use_my_referral_code':
          'Join Playcrypto365 and earn money! Use my referral code',
      'your_referral_link': 'Your Referral Link',
      'referral_code_copied_to_clipboard':
          'Referral Code Copied To Clipboard',
      'tap_to_copy': 'Tap To Copy',
      'how_referral_commission_works':
          'How Referral Commission Works',
      'how_to_play_games_using_referral_earning':
          'How To Play Games Using Referral Earning',
      'how_to_withdraw': 'How To Withdraw',
      'earn_life_time_commission_on_your_friends_every_deposit':
          'Earn life time commission on your friends every deposit',
      'you_earn_a_percent_of_the_referees_ongoing_deposit_including_direct_referral_indirect_referral_and_extended_referral':
          'You earn a percent of the referees ongoing deposit including direct referral, indirect referral and extended referral',
      'playing_games_using_referral_earning_you_have_to_transfer_your_live_referral_earning_to_referral_play_wallet_using_following_transfer_feature_on_':
          'Playing games using referral earning, you have to transfer your live referral earning to referral play wallet using following transfer feature on ',
      'referral_wallet_lobby_and_my_earning':
          'Referral Wallet Lobby and My Earning',
      'after_transfer_live_referral_earning_balance_to_referral_play_wallet_you_can_use_that_balance_for_play_games_or_withdrawal_direct_to_your_bank_account':
          'After transfer live referral earning balance to referral play wallet, you can use that balance for play games or withdrawal direct to your bank account',
      'you_can_withdrawal_referral_play_balance_in_bkash_or_nagad_after_completing_turnover_completing_in_referral_wallet_here_is_simple_5_stapes_to_withdrawal_your_play_balance_in_your_bank_account':
          'You can withdrawal referral play balance in bKash or Nagad after completing turnover completing in referral wallet. Here is simple 5 stapes to withdrawal your play balance in your bank account',
      'go_to_referral_wallet_lobby_2_click_on_refer_and_earn_tab_3__click_on_withdrawal_button_4_select_your_withdrawal_mode_bkash_or_nagad_5__select_amount_and_withdrawal':
          '1. Go to Referral Wallet Lobby\n2. Click on Refer and Earn Tab\n3. Click on Withdrawal Button\n4. Select your withdrawal mode (bKash or Nagad)\n5. Select amount and withdrawal',

      // Footer
      'about_us': 'About Us',
      'terms_conditions': 'Terms & Conditions',
      'privacy_policy': 'Privacy Policy',
      'responsible_gaming': 'Responsible Gaming',
      'contact_us': 'Contact Us',

      // Coins card
      'coins': 'Coins',
      'exchange': 'Exchange',
      'market': 'Market',
      'buy': 'Buy',
      'sell': 'Sell',
      'price': 'Price',
      'change': 'Change',

      // Brand tabs
      'all': 'All',
      'providers': 'Providers',

      // Added missing keys
      'no_records_found': 'No Records Found',
      'get_daily_login_bonus': 'Get Daily Login Bonus',
      'claim_reward': 'Claim Reward',
      'deposit_daily_to_ensure_next_daily_login_bonus':
          'Deposit Daily To Ensure Next Daily Login Bonus',
      'how_to_deposit': 'How To Deposit',
      'availablepromotions': 'Availablepromotions',
      'details': 'Details',
      'history': 'History',
      'scratch_cards': 'Scratch Cards',
      'scratch_here': 'Scratch Here',
      'fun_wheel': 'Fun Wheel',
      'winners_list': 'Winners List',
      'winning_records': 'Winning Records',
      'secs_ago': 'Secs Ago',
      'spin_wheel': 'Spin Wheel',
      'your_rewards': 'Your Rewards',
      'wallet_in_use': 'Wallet In Use',
      'selected': 'Selected',
      'select': 'Select',
      'follow_us': 'Follow Us',
      'our_blog': 'Our Blog',
      'terms_and_conditions': 'Terms And Conditions',
      'comingsoon': 'Comingsoon',
      'recent_games': 'Recent Games',
      'totals_earning': 'Totals Earning',
      'direct_referrals': 'Direct Referrals',
      'indirect_referrals': 'Indirect Referrals',
      'extended_referrals': 'Extended Referrals',
      'your_top_active_referrals':
          'Your Top Active Referrals',
      'no_referrals_found': 'No Referrals Found',
      'you_received': 'You Received',
      'loading': 'Loading',
      'better_luck_next_time': 'Better Luck Next Time',
      'bonus_received': 'Bonus Received',
      'screen_label': 'screen',
    },
    'bottom_nav': {
      'home': 'Home',
      'livechat': 'Live Chat',
      'live_chat': 'Live Chat',
      'promotions': 'Promotions',
      'promotion': 'Promotion',
      'deposit': 'Deposit',
      'account': 'Account',
      'refer_now': 'Refer Now',
      'my_earning': 'My Earning',
      'withdraw': 'Withdraw',
      'chatwithoursupportteam':
          'Chat With Our Support Team',
      'callback': 'Callback',
      'makearequestcallback': 'Make A Request Callback',
      'whatsappisnotinstalledonthedevice':
          'WhatsApp Is Not Installed On The Device',
      'requestacallback': 'Request A Callback',
      'yes': 'Yes',
      'no': 'No',
      'login': 'Login',
      'register': 'Register',
      'localeName': 'English',
    },
    'deposit': {
      'deposit': 'Deposit',
      'wallets': 'Wallets',
      'amount': 'Amount',
      'total': 'Total',
      'bonus': 'Bonus',
      'oops': 'Oops!',
      'okay': 'Okay',
      'deposit_currency': 'Deposit Currency',
      'choose_network': 'Choose Network',
      'convert_crypto_to_fiat': 'Convert Crypto To Fiat',
      'min_deposit': 'Min. Deposit',
      'your_deposit_bonus_will_be_credited_in_your_locked_rackbak_bonus_balance':
          'Your deposit bonus will be credited in your locked rackback bonus balance.',
      'bonus_t_and_c': 'Bonus T&C',
      'deposit_address': 'Deposit Address',
      'address_copied_to_clipboard':
          'Address Copied To Clipboard',
      'send_only': 'Send Only',
      'to_this_deposit_address_transfer_below':
          'To This Deposit Address. Transfer Below',
      'will_not_be_credited': 'Will Not Be Credited',
      'remove': 'Remove',
      'apply': 'Apply',
      'locked': 'Locked',
      'minimum_deposit_amount_criteria_not_met':
          'Minimum Deposit Amount Criteria Not Met',
      'received_on': 'Received On',
      'payment_info': 'Payment Info',
      'payment_in_verification': 'Payment In Verification',
      'play_games': 'Play Games',
      'deposit_amount': 'Deposit Amount',
      'deposit_bonus': 'Deposit Bonus',
      'daily_bonus': 'Daily Bonus',
      'weekly_bonus': 'Weekly Bonus',
      'promotion_bonus': 'Promotion Bonus',
      'total_with_bonuses': 'Total With Bonuses',
      'rollover': 'Rollover',
      'select_bonus': 'Select Bonus',
      'no_bonus': 'No Bonus Available',
      'copy': 'Copy',
      'check_status': 'Check Status',

      // Added missing keys
      'crypto_deposit': 'Crypto Deposit',
      'select_crypto_coin': 'Select Crypto Coin',
      'more': 'More',
      'something_went_wrong': 'Something Went Wrong',
      'retry': 'Retry',
      'choose_your_bonus': 'Choose Your Bonus',
      'promotions': 'Promotions',
      'select_real_wallet_first':
          'Select Real Wallet First',
      'payment_methods': 'Payment Methods',
      'invaliddepositamount': 'Invaliddepositamount',
      'everyday': 'Everyday',
      'deposit_details': 'Deposit Details',
      'confirm': 'Confirm',
      'daily_bonus_pack_note': 'Daily Bonus Pack Note',
      'warning': 'Warning',
      'claim_warning': 'Claim Warning',
      'claim': 'Claim',
      'claimed': 'Claimed',
      'checking': 'Checking...',
      'order_id': 'Order ID:',
      'select_currency': 'Select Currency',
      'loading': 'Loading...',
      'fetching_transaction_status':
          'Fetching transaction status...',
      'something_went_wrong_promotions':
          'Something went wrong, while fetching promotions',
      'refresh': 'Refresh',
      'no_promotions_available': 'No promotions available.',
      'please_select_crypto_coin':
          'Please select a crypto coin to deposit.',
    },
    'withdraw_screen': {
      // These keys exist in CDN JSON already, but adding
      // as safety fallback
      'withdraw': 'Withdraw',
      'history': 'History',
      'your_balance': 'Your Balance',
      'withdraw_currency': 'Withdraw Currency',
      'choose_coin_network': 'Choose Coin Network',
      'convert_rate': 'Convert Rate',
      'withdraw_address': 'Withdraw Address',
      'withdraw_amount': 'Withdraw Amount',
      'available_balance': 'Available Balance',
      'min': 'Min',
      'max': 'Max',
      'preview': 'Preview',
      'turnover_progress': 'Turnover Progress',
      'turnover_games': 'Turnover Games',
      'total': 'Total',

      // Keys NOT in CDN JSON — these are the broken ones
      'oops': 'Oops!',
      'okay': 'Okay',
      'cancel': 'Cancel',
      'success': 'Success',
      'amount': 'Amount',
      'balance': 'Balance:',
      'status': 'Status',
      'id': 'ID',
      'description': 'Description',
      'datetime': 'Date & Time',
      'refresh': 'Refresh',
      'no_records_found': 'No Records Found',
      'transfer_first_bonus_money_warning':
          'Please transfer bonus money first before withdrawing.',
      'pending_rollover_info': 'Pending Rollover Info',
      'more_games': 'More Games',
      'withdrawal_limit': 'Withdrawal Limit',
      'invalid_bank_name': 'Invalid Bank Name',
      'account': 'Account',
      'invalid_amount': 'Invalid Amount',
      'please_wait_for_withdrawal':
          'Please Wait For Withdrawal',
      'need_an_account':
          'You need a bank account to withdraw.',
      'add_account': 'Add Account',
      'enter_otp': 'Enter OTP Sent To ',
      'if_you_didnt_receive_a_code_':
          'If you didn\'t receive a code,',
      'select_payment_method': 'Select Payment Method',
      'add_new_wallet': 'Add New Wallet',
      'watch_now': 'Watch Now',
      'add_more_bank_accounts': 'Add More Bank Accounts',
      'select_bank_account': 'Select Bank Account',
      'you_dont_have_any_back_accounts_added':
          'You don\'t have any bank accounts added.',
      'add_bank_account': 'Add Bank Account',
      'primary_wallet': 'Primary Wallet',
      'secondary_wallet': 'Secondary Wallets',
      'account_balance': 'Account Balance',
      'add_withdraw_amount': 'Add Withdraw Amount',
      'your_turnover_progress_': 'Your Turnover Progress',
      'search_text': 'Search',
      'submitted': 'Submitted',
      'rejected': 'Rejected',
      'approved': 'Approved',
      'processing': 'Processing',
      'pending': 'Pending',
      'bank_name': 'Bank Name',
      'account_holder_name': 'Account Holder Name',
      'account_number': 'Account Number',
      'ifsc_code': 'IFSC Code',
      'upi_id': 'UPI ID',
      'confirm': 'Confirm',
      'submit': 'Submit',
      'resend': 'Resend',
      'verify': 'Verify',
      'otp_verified': 'OTP Verified',
      'close': 'Close',
      'cancel_withdraw': 'Cancel Withdraw',
      'are_you_sure': 'Are You Sure?',
      'yes': 'Yes',
      'no': 'No',

      // Added missing keys
      'withdraw_history': 'Withdraw History',
      'something_went_wrong': 'Something Went Wrong',
      'retry': 'Retry',
      'convert_fiat_to_crypto': 'Convert Fiat To Crypto',
      'rate_display': '1 {fiat} = {rate} {crypto}',
      'fill_in_carefully_according_to_the_specific':
          'Please fill in the withdrawal address carefully',
      'available_balance_in': 'Available Balance In',
      'please_enter_a_valid_amount':
          'Please Enter A Valid Amount',
      'minimum_amount_is': 'Minimum Amount Is',
      'please_enter_an_address': 'Please Enter An Address',
      'please_enter_withdrawal_amount':
          'Please Enter Withdrawal Amount',
      'please_enter_an_amount_greater_than_the_minimum_amount':
          'Please Enter An Amount Greater Than The Minimum Amount',
      'confirm_withdraw_details':
          'Confirm Withdraw Details',
      'currency': 'Currency',
      'address': 'Address',
      'do_you_want_to_proceed_with_the_withdrawal':
          'Do You Want To Proceed With The Withdrawal',
      'for_security_purposes_large_or_suspicious_withdrawal_may_take_1_6_hourse_for_audit_process_we_appreciate_your_patience':
          'For Security Purposes Large Or Suspicious Withdrawal May Take 1 6 Hours For Audit',
      'complete_your_turnover_games_and_withdraw_your_crypto_with_any_crypto_coins':
          'Complete Your Turnover Games And Withdraw Your Crypto',
      'bonus_t_and_c': 'Bonus T And C',
      'currency_select': 'Currency Select',
      'crypto_currency': 'Crypto Currency',
      'please_enter_an_amount_less_than_the_maximum_withdrawal_amount':
          'Please Enter An Amount Less Than The Maximum Withdrawal Amount',
      'deposit_withdraw_issue': 'Deposit Withdraw Issue',
      'withdrawal_details': 'Withdrawal Details',
      'bankdetail': 'Bank Detail',
      'withdrawal_status': 'Withdrawal Status',
      'total_withdraw_amount': 'Total Withdraw Amount',
      'withdraw_now': 'Withdraw Now',
      'please_select_bank_account':
          'Please Select Bank Account',
      'insufficient_balance': 'Insufficient Balance',
      'kindly_complete_turnover_before_proceeding_for_withdrawal':
          'Kindly Complete Turnover Before Proceeding For Withdrawal',
      'you_have_reached_the_maximum_withdrawal_limit_of':
          'You Have Reached The Maximum Withdrawal Limit Of',
      'add_new_edit_wallet': 'Add New Edit Wallet',
      'withdraw_verification': 'Withdraw Verification',
      'enter_otp_email_instruction':
          'Enter Otp Email Instruction',
      'wallet_added_successfully':
          'Wallet Added Successfully',
      'error': 'Error',
      'resend_code': 'Resend Code',
      'edit_wallet': 'Edit Wallet',
      'a_sixdigit_code_will_be_sent_to__your_phone_number':
          'A 6-digit Code Will Be Sent To Your Phone Number',
      'enter_your_phone_number_label':
          'Enter Your Phone Number Label',
      'enter_your_phone_number': 'Enter Your Phone Number',
      'please_enter_your_phone_number':
          'Please Enter Your Phone Number',
      'please_wait': 'Please Wait',
      'send_code': 'Send Code',
      'primary_account_use_for_up_to_50000_secondary_wallets_for_withdrawals_above_50000_in_one_day':
          'Primary Account Use For Up To 50000 Secondary Wallets',
      'default_text': 'Default Text',
      'message': 'Message',
    },
    'account': {
      'title': 'My Account',
      'deposit': 'Deposit',
      'withdraw': 'Withdraw',
      'vip': 'VIP',
      'email': 'Email',
      'mobile_number': 'Mobile Number',
      'date_of_birth': 'Date Of Birth',
      'statement': 'Statement',
      'view_statement': 'View your statement',
      'crypto_statement': 'Crypto Statement',
      'view_crypto_statement': 'View your crypto statement',
      'change_language': 'Change Language',
      'logout': 'Logout',
      'id': 'ID',
      'login': 'Login',
      'register': 'Register',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'oops': 'Oops!',
      'okay': 'Okay',
      'forgotpassword': 'Forgot Password',
      'letssignyouin': 'Let\'s Sign You In',
      'pleaseprovidepassword': 'Please Provide Password',
      'invalidcredential':
          'Invalid credentials. Please try again.',
      'submit': 'Submit',
      'resetyourpassword': 'Reset Your Password',
      'enterOTP': 'Enter OTP',
      'invalidOTP': 'Invalid OTP. Please try again.',
      'newpassword': 'New Password',
      'passwordshould6characters':
          'Password should be at least 6 characters',
      'changepassword': 'Change Password',
      'createyouraccounr': 'Create Your Account',
      'verify': 'Verify',
      'create': 'Create',
      'add_bank_account': 'Add Bank Account',
      'invalid_bank_name': 'Invalid Bank Name',
      'invalidname': 'Invalid Name',
      'bankaccountholdername': 'Bank Account Holder Name',
      'bankaccountnumber': 'Bank Account Number',
      'invalidaccountnumber': 'Invalid Account Number',
      'add_account': 'Add Account',
      'my_accounts': 'My Accounts',
      'account': 'Account',
      'invalidmobilenumber': 'Invalid Mobile Number',
      'registration_completed': 'Registration Completed',
      'registration_successful': 'Registration Successful',
      'play_games': 'Play Games',
      'youmayonlyperformthisactionevery30seconds':
          'You may only perform this action every 30 seconds.',
      'rewards': 'Rewards',
      'adddepositinyourwallet':
          'Add deposit in your wallet',
      'makearequestforwithdraw':
          'Make a request for withdraw',
      'install_update': 'Install Update',
      'restart': 'Restart',
      'logout_confirmation':
          'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'mobile_or_email': 'Mobile / Email',
      'enter_mobile_or_email':
          'Enter Mobile Number or Email',
      'please_enter_mobile_or_email':
          'Please enter mobile number or email',
      'somethingwentwrong':
          'Something went wrong. Please try again.',
      'whatsapp_number': 'WhatsApp Number',
      'enter_whatsapp_number': 'Enter WhatsApp Number',
      'enter_email': 'Enter Email Address',
      'enter_email_address': 'Enter Email Address',
      'please_enter_email':
          'Please enter your email address',
      'enter_valid_email':
          'Please enter a valid email address',
      'send_otp': 'Send OTP',
      'send_otps': 'Send OTPs',
      'otp_sent_info': 'We will send OTP to your WhatsApp.',
      'we_will_send_otp_info':
          'We\'ll send OTP to WhatsApp and Email.',
      'enter_otp': 'Enter OTP',
      'enter_whatsapp_otp': 'Enter WhatsApp OTP',
      'enter_email_otp': 'Enter Email OTP',
      'login_with_otp': 'Login with OTP',
      'login_with_password': 'Login with Password',
      'edit': 'Edit',
      'resend_otp': 'Resend OTP',
      'resend_in': 'Resend in',
      'please_agree_terms':
          'Please agree to the terms and conditions',
      'i_agree_terms':
          'I agree to the Terms & Conditions and Privacy Policy',
      'loginfailed': 'Login Failed',
      'email_otp': 'Email OTP',
      'didntreceivecode': 'Didn\'t receive code? Resend',
      'mobile': 'Mobile',
      'enter_mobile_number': 'Enter Mobile Number',
      'otp_sent_to_mobile':
          'We will send OTP to your mobile.',
      'otp_sent_to_email':
          'We will send OTP to your email.',
      'select_verification_method':
          'Select Verification Method',
      'loss_back_title': '100% Loss Back',
      'loss_back_desc':
          'Play risk-free! Get 100% of your first\ndeposit loss returned.',
      'edit_email': 'Edit Email',
      'edit_mobile': 'Edit Mobile Number',
      'enter_mobile': 'Enter Mobile Number',
      'field_required': 'This field is required',
      'invalid_email': 'Please enter a valid email address',
      'save_changes': 'Save Changes',
      'update_success': 'Updated successfully',
      'not_set': 'Not Set',
      'current_password': 'Current Password',
      'enter_current_password': 'Enter current password',
      'enter_new_password': 'Enter new password',
      'confirm_new_password': 'Confirm New Password',
      're_enter_password': 'Re-enter new password',
      'please_enter_current_password':
          'Please enter your current password',
      'please_enter_new_password':
          'Please enter a new password',
      'please_confirm_password':
          'Please confirm your new password',
      'passwords_do_not_match': 'Passwords do not match',
      'password_changed_success':
          'Password Changed Successfully',
      'password_updated': 'Your password has been updated.',
      'secure_account_hint':
          'Create a strong password to secure\nyour account',
      'password_requirement_hint':
          'Password must be at least 6 characters long and include a mix of letters and numbers.',
      'settings': 'Settings',
    },
    'vip_screen': {
      'deposit': 'Deposit',
      'bet': 'Bet',
      'remaining': 'Remaining',
      'benefits': 'Benefits',
      'upgrade_bonus': 'Upgrade Bonus',
      'claim': 'Claim',
      'vip_level': 'VIP Level',
      'unlocked': 'Unlocked',

      // Added missing keys
      'rewards': 'Rewards',
      'total_rewards_claimed_': 'Total Rewards Claimed',
      'vip_levels': 'Vip Levels',
      'monthly_bonus': 'Monthly Bonus',
    },
    'statement_screen': {
      'title': 'Statement',
      'statement_title': 'Statement',
      'id': 'ID',
      'credit': 'Credit',
      'debit': 'Debit',
      'balance': 'Balance',
      'description': 'Description',
      'online_transaction': 'Online Transaction',
      'withdraw_request': 'Withdraw Request',
      'withdraw_cancelled':
          'Withdraw Request Cancelled by User',
      'bet_description': 'Bet Placed for (C2)',
      'win_description': 'Win Placed for (C2)',
      'round_title': 'Round ID',
      'date': 'Date',
      'description_copied': 'Description Copied',
      'crypto_currency': 'Crypto Currency',
      'status': 'Status',
      'no_records_found': 'No Records Found',
      'load_more': 'Load More',
      'crypto_statement': 'Crypto Statement',
    },
  };
}
