import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:playcrypto365/providers/vip_info_provider.dart';
import 'package:playcrypto365/providers/wallet_provider.dart';
import 'package:playcrypto365/screens/search_tab_screen.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:playcrypto365/widgets/home/footer_section_widget.dart';
import 'package:playcrypto365/widgets/home/home_bonuses_pageview.dart';
import 'dart:ui';
import '../constants/global_constant.dart';
import 'package:playcrypto365/providers/language_provider.dart';
import 'package:playcrypto365/providers/games_provider.dart';
import '../providers/user_auth.dart';
import '../widgets/app_bar_top.dart';
import '../widgets/bounce_tap.dart';
import '../widgets/car_slider.dart';
import '../widgets/home/providers_of_game_type.dart';
import '../widgets/home/table_inner_games.dart';
import '../widgets/home/transfer_refer_earn_2_play_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastLocale;
  final Map<String, String> _gameCategories = {
    "Exclusive": "turnover",
    "Casino": "LiveGame",
    "Sports": "Esports",
    "Poker": "Poker",
    "Slots": "Slots",
    "Crash": "Crash Games",
    "Table": "TableGame",
    "Lottery": "Lottery",
    "Roulette": "Roulette",
    "Search": "Search"
  };
  final Map<String, String> _gameCategoriesImages = {
    "Exclusive": "assets/images/exclusive.png",
    "Casino": "assets/images/ld.svg",
    "Sports": "assets/images/sb.svg",
    "Poker": "assets/images/table.svg",
    "Slots": "assets/images/slots.png",
    "Crash": "assets/images/crash.svg",
    "Table": "assets/images/casino.png",
    "Lottery": "assets/images/lottery.png",
    "Roulette": "assets/images/roulette.png",
    "Search": "Search"
  };
  final ScrollController _scrollController = ScrollController();
  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        html.window.postMessage("flutter-first-frame", "*");
      });
    }
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.setAnalyticsCollectionEnabled(true);
    analytics.logAppOpen(parameters: {
      'AppVersion': "1.0.0+26",
    });
    setUserIdInAnalytics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale =
        Provider.of<LanguageProvider>(context, listen: false)
            .getString("home_screen", "localeName");
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      Provider.of<GamesProvider>(context, listen: false).reLocalizeAll();
    }
  }

  void setUserIdInAnalytics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('UserId');
    if (userId != null) {
      FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      analytics.setUserId(id: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    var walletProvider = context.watch<WalletProvider?>();
    final mediaQuerySize = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        mediaQuerySize.width < 1000
            ? SafeArea(
                top: false,
                bottom: true,
                child: Scaffold(
                  appBar: const AppBarTop(),
                  backgroundColor:
                      walletProvider!.currentWalletCode ==
                              GlobalConstant.referWalletCode
                          ? const Color(0xFF27262B)
                          : null,
                  body: VisibilityDetector(
                    key: const Key("home-screen"),
                    onVisibilityChanged: (info) {
                      // Home screen visible
                    },
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: <Widget>[
                        const SliverToBoxAdapter(child: BannerWidget()),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 8),
                        ),
                        if (walletProvider.currentWalletCode ==
                            GlobalConstant.referWalletCode)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 3.w),
                              child: Divider(
                                color: walletProvider.currentWalletCode ==
                                        GlobalConstant.referWalletCode
                                    ? Colors.white
                                    : const Color.fromARGB(
                                        122, 54, 54, 54),
                                thickness: 1.2,
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                            child: ReferralJourneyWidget()),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RawScrollbar(
                                    radius:
                                        const Radius.circular(8),
                                    trackRadius:
                                        const Radius.circular(8),
                                    controller: _scrollController,
                                    thumbColor: GlobalConstant
                                        .kTabActiveButtonColor,
                                    trackColor:
                                        const Color(0xFFCCCCCC),
                                    trackVisibility: true,
                                    thumbVisibility: true,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: 2.h),
                                      height: 12.h,
                                      width: 100.w,
                                      child: ListView.builder(
                                        controller:
                                            _scrollController,
                                        scrollDirection:
                                            Axis.horizontal,
                                        itemCount: _gameCategories
                                                .length -
                                            1,
                                        itemBuilder:
                                            (context, index) {
                                          String assetName =
                                              "${_gameCategoriesImages[_gameCategories.keys.elementAt(index)]}";
                                          return Padding(
                                            padding:
                                                const EdgeInsets
                                                    .all(6.0),
                                            child: BounceTap(
                                              onPressed: () {
                                                setState(() {
                                                  selectedCategory =
                                                      index;
                                                });
                                              },
                                              child: Container(
                                                width: 23.w,
                                                height:
                                                    checkIfIsWebAndIsSafari()
                                                        ? 16.h
                                                        : 15.h,
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  gradient: selectedCategory ==
                                                          index
                                                      ? LinearGradient(
                                                          colors: [
                                                            GlobalConstant
                                                                .kTabActiveButtonColor
                                                                .withOpacity(
                                                                    0.7),
                                                            GlobalConstant
                                                                .kTabActiveButtonColor,
                                                          ],
                                                          begin: Alignment
                                                              .topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        )
                                                      : null,
                                                  color: selectedCategory ==
                                                          index
                                                      ? null
                                                      : const Color(
                                                          0xFF333333),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: selectedCategory ==
                                                              index
                                                          ? GlobalConstant
                                                              .kTabActiveButtonColor
                                                              .withOpacity(
                                                                  0.5)
                                                          : Colors
                                                              .black
                                                              .withOpacity(
                                                                  0.25),
                                                      blurRadius: selectedCategory ==
                                                              index
                                                          ? 8
                                                          : 4,
                                                      offset: Offset(
                                                          0,
                                                          selectedCategory ==
                                                                  index
                                                              ? 4
                                                              : 2),
                                                      spreadRadius: selectedCategory ==
                                                              index
                                                          ? 2
                                                          : 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    assetName.contains(
                                                            "svg")
                                                        ? SvgPicture
                                                            .asset(
                                                            assetName,
                                                            width:
                                                                30,
                                                            height:
                                                                30,
                                                            color: selectedCategory ==
                                                                    index
                                                                ? Colors
                                                                    .black
                                                                : Colors
                                                                    .white,
                                                          )
                                                        : Image
                                                            .asset(
                                                            assetName,
                                                            width:
                                                                30,
                                                            height:
                                                                30,
                                                            color: selectedCategory ==
                                                                    index
                                                                ? Colors
                                                                    .black
                                                                : Colors
                                                                    .white,
                                                            errorBuilder:
                                                                (context,
                                                                    error,
                                                                    stackTrace) {
                                                              return Icon(
                                                                Icons
                                                                    .search,
                                                                size:
                                                                    30,
                                                                color: selectedCategory ==
                                                                        index
                                                                    ? Colors.black
                                                                    : Colors.white,
                                                              );
                                                            },
                                                          ),
                                                    Text(
                                                      Provider.of<LanguageProvider>(
                                                              context)
                                                          .getString(
                                                              "categories",
                                                              _gameCategories
                                                                  .keys
                                                                  .elementAt(
                                                                      index)
                                                                  .toLowerCase()),
                                                      textAlign:
                                                          TextAlign
                                                              .center,
                                                      style:
                                                          TextStyle(
                                                        fontSize:
                                                            11,
                                                        fontWeight: selectedCategory ==
                                                                index
                                                            ? FontWeight
                                                                .bold
                                                            : FontWeight
                                                                .normal,
                                                        color: selectedCategory ==
                                                                index
                                                            ? Colors
                                                                .black
                                                            : Colors
                                                                .white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 12.h,
                                  margin:
                                      EdgeInsets.only(bottom: 2.h),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(6.0),
                                    child: BounceTap(
                                      onPressed: () {
                                        Future.delayed(
                                            const Duration(
                                                milliseconds: 100),
                                            () {
                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              fullscreenDialog: true,
                                              builder: (context) {
                                                return const SearchTabScreen();
                                              },
                                            ),
                                          );
                                        });
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20),
                                          child: Container(
                                            width: 23.w,
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              gradient:
                                                  const LinearGradient(
                                                colors: [
                                                  Color(0xFFE2B05E),
                                                  Color(0xFFB58925),
                                                ],
                                                begin: Alignment
                                                    .topLeft,
                                                end: Alignment
                                                    .bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          10),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(
                                                        0.4),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black
                                                      .withOpacity(
                                                          0.2),
                                                  blurRadius: 10,
                                                  spreadRadius: -1,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .search_rounded,
                                                  size: 30,
                                                  color:
                                                      Colors.white,
                                                ),
                                                Text(
                                                  langProvider
                                                      .getString(
                                                          'categories',
                                                          'search'),
                                                  textAlign:
                                                      TextAlign
                                                          .center,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight
                                                            .normal,
                                                    color: Colors
                                                        .white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selectedCategory == 0)
                          TableInnerGames(
                            _gameCategories.values
                                .elementAt(selectedCategory),
                            key: const ValueKey('category_0'),
                          )
                        else
                          ProvidersOfGameType(
                            key: ValueKey(
                                'category_$selectedCategory'),
                            categoryName: _gameCategories.keys
                                .elementAt(selectedCategory),
                            selectedCategory: _gameCategories
                                .values
                                .elementAt(selectedCategory),
                          ),
                        const SliverToBoxAdapter(
                          child: FooterSectionWidgetMobile(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/background.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
        const SizedBox.shrink(),
      ],
    );
  }

  checkIfIsWebAndIsSafari() {
    if (kIsWeb) {
      if (html.window.navigator.userAgent.contains('Safari')) {
        return true;
      }
    }
    return false;
  }
}

class ReferralJourneyWidget extends StatelessWidget {
  const ReferralJourneyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var walletProvider = context.watch<WalletProvider?>();
    if (walletProvider!.currentWalletCode ==
        GlobalConstant.referWalletCode) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        HomeBonusesPageview(
          key: ValueKey(GlobalConstant.lastPlayedGameCode),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  @override
  Widget build(BuildContext context) {
    var walletProvider = context.watch<WalletProvider?>();
    if (walletProvider!.currentWalletCode ==
        GlobalConstant.referWalletCode) {
      return const TransferReferEarn2PlayBanner();
    } else {
      return const SizedBox(
        width: double.infinity,
        child: CarSlider(),
      );
    }
  }
}
