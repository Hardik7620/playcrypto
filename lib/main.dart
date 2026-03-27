import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';
import 'package:playcrypto365/firebase_options.dart';
import 'package:playcrypto365/providers/games_provider.dart';
import 'package:playcrypto365/providers/vip_info_provider.dart';
import 'package:playcrypto365/providers/wallet_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'models/wallet.dart';
import 'providers/top_tab.dart';
import 'providers/user_auth.dart';
import 'constants/global_constant.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:playcrypto365/providers/language_provider.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        100 * 1024 * 1024; // 100 MB
    PaintingBinding.instance.imageCache.maximumSize = 100;
    await SharedPreferences.getInstance();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!GetIt.I.isRegistered<VIPInfoProvider>()) {
      VIPInfoProvider instance = VIPInfoProvider();
      GetIt.I.registerSingleton<VIPInfoProvider>(instance);
      instance.initialize().then((_) {
        print("VIP INITIALIZED main ${instance.isInitialized}");
      });
    }

    await setDefaultLocale();

    runApp(const AppProviders(child: Wrapper(child: MainScreen())));
  }, (exception, stackTrace) async {}, zoneSpecification:
      ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone,
          String message) {
    if (kDebugMode) {
      parent.print(zone, message);
    }
  }));
}

Future<void> setDefaultLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("userWallet") != null &&
      (GlobalConstant.userWallet.creditAccountId ?? "").isEmpty) {
    GlobalConstant.userWallet.creditAccountId =
        Wallet.fromJson(json.decode(prefs.getString("userWallet")!))
            .creditAccountId;
  }
  if (!prefs.containsKey('language_code')) {
    prefs.setString("language_code", "en");
    GlobalConstant.appLanguage = 'en';
  } else {
    GlobalConstant.appLanguage = prefs.getString("language_code")!;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();

  static MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  void setLocale(Locale value) {
    Provider.of<LanguageProvider>(context, listen: false)
        .setLanguage(value.languageCode);
    Provider.of<GamesProvider>(context, listen: false).reLocalizeAll();
  }

  Locale getLocale() {
    return Provider.of<LanguageProvider>(context, listen: false).currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OKToast(
      child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
        return MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('bn'),
            Locale('be'),
            Locale('hi'),
            Locale('te'),
            Locale('mr'),
          ],
          locale: languageProvider.currentLocale,
          debugShowCheckedModeBanner: false,
          title: GlobalConstant.kAppName,
          theme: ThemeData(
            useMaterial3: false,
            primarySwatch: Colors.blue,
            fontFamily: 'Poppins',
            textTheme: Theme.of(context).textTheme.copyWith(
                  labelLarge: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                  bodyLarge: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  bodyMedium: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
          navigatorObservers: [
            FirebaseAnalyticsObserver(
                analytics: FirebaseAnalytics.instance),
          ],
          home: const HomeScreen(),
        );
      }),
    );
  }
}

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TopTab(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserAuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GamesProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
      ],
      child: child,
    );
  }
}

class Wrapper extends StatelessWidget {
  final Widget child;

  const Wrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              if (constraints.maxHeight == 0 || constraints.maxWidth == 0) {
                return const SizedBox();
              }
              SizeConfig.init(constraints, orientation);
              return child;
            },
          );
        },
      ),
    );
  }
}
