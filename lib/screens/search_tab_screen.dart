import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:playcrypto365/providers/games_provider.dart';
import 'package:playcrypto365/utils/extensions.dart';

import '../constants/global_constant.dart';
import '../models/game_model.dart';
import '../providers/user_auth.dart';
import 'game_launch_code.dart';
import 'login_screen.dart';
import '../providers/language_provider.dart';

class SearchTabScreen extends StatefulWidget {
  const SearchTabScreen({Key? key, this.gamesByType})
      : super(key: key);
  final List<GameModel>? gamesByType;

  @override
  State<SearchTabScreen> createState() =>
      _SearchTabScreenState();
}

class _SearchTabScreenState extends State<SearchTabScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = false;
  List<GameModel> allGames = [];
  var gameListData = [];
  bool isLoading = true;
  var _isInit = true;
  int _currentPage = 1;
  final int _itemsPerPage = 9;
  final ScrollController _controller = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);
  bool _showingFab = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);

    if (widget.gamesByType != null &&
        widget.gamesByType is List) {
      var uniqueGames =
          (widget.gamesByType ?? []).toSet().toList();
      allGames.addAll(uniqueGames);
      gameListData.addAll(uniqueGames);
      isLoading = false;
      isLoading = false;
      _fadeController.forward();
    } else {
      fetchAllGames();
    }

    _controller.addListener(() {
      if (_controller.position.pixels > 200 &&
          !_showingFab) {
        setState(() => _showingFab = true);
      } else if (_showingFab &&
          _controller.position.pixels < 200) {
        setState(() => _showingFab = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) checkUserLogin();
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future checkUserLogin() async {
    _isLogin = await Provider.of<UserAuthProvider>(context,
            listen: false)
        .isLoggedIn();
  }

  Future fetchAllGames() async {
    List<GameModel> gameList =
        await Provider.of<GamesProvider>(context,
                listen: false)
            .getAllGames();
    if (mounted) {
      setState(() {
        var uniqueGames = gameList.toSet().toList();
        allGames.addAll(uniqueGames);
        gameListData.addAll(uniqueGames);
        isLoading = false;
      });
      _fadeController.forward();
    }
  }

  void onSearchTextChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        gameListData.clear();
        gameListData.addAll(allGames);
        _currentPage = 1;
      });
      return;
    }

    _debouncer.run(() {
      String processedQuery =
          text.replaceAll(" ", "").toLowerCase();
      var results = allGames
          .where((e) =>
              match(e.name ?? '', processedQuery) ||
              match(e.product ?? '', processedQuery))
          .toList();
      setState(() {
        gameListData.clear();
        _currentPage = 1;
        gameListData.addAll(results);
      });
    });
  }

  bool match(String name, String processedQuery) {
    if (name.isEmpty) return false;
    name = name.replaceAll(" ", "").toLowerCase();

    if (name.contains(processedQuery)) return true;

    int maxErrorCount = 3, errorCount = 0;
    if (name.length < processedQuery.length) return false;

    // We only compare up to the length of processedQuery to avoid index out of bounds
    for (var i = 0; i < processedQuery.length; i++) {
      if (errorCount > maxErrorCount) return false;
      if (processedQuery[i] != name[i]) errorCount++;
    }
    return errorCount < maxErrorCount;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider =
        Provider.of<LanguageProvider>(context);
    Provider.of<GamesProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F4F8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6)
              ]),
          child: TextFormField(
            onChanged: (value) =>
                onSearchTextChanged(value),
            autofocus: true,
            style: GoogleFonts.poppins(
                height: 1.0, fontSize: 14),
            decoration: InputDecoration(
              floatingLabelBehavior:
                  FloatingLabelBehavior.never,
              suffixIcon: const Icon(Icons.search,
                  color: Colors.grey),
              hintText: langProvider.getString(
                  "home_screen", "search"),
              hintStyle:
                  GoogleFonts.poppins(color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
          ),
        ),
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: AnimatedScale(
        scale: _showingFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          elevation: 4,
          onPressed: () {
            HapticFeedback.lightImpact();
            _controller.animateTo(0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic);
          },
          child: const Icon(
              Icons.keyboard_arrow_up_outlined,
              color: GlobalConstant.kPrimaryColor),
        ),
      ),
      body: CustomScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 100),
            sliver: isLoading
                ? _buildGridSkeleton()
                : _buildGameGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    if (gameListData.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Center(
              child: Text(
                  Provider.of<LanguageProvider>(context, listen: false)
                      .getString("home_screen", "no_records_found"),
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey))),
        ),
      );
    }
    return SliverFadeTransition(
      opacity: _fadeAnimation,
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final gameIndex = index;
                // Throttle animations: Only animate the first few cards to prevent CPU spikes during scroll.
                final bool shouldAnimate = index < 12;
                
                return RepaintBoundary(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: shouldAnimate ? (250 + (index % 12) * 30) : 0),
                    curve: Curves.easeOutCubic,
                    builder: (ctx, value, child) {
                      if (value == 1.0) return child!;
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildGameCard(gameIndex),
                  ),
                );
              },
              childCount: (_currentPage * _itemsPerPage) > gameListData.length ? gameListData.length : (_currentPage * _itemsPerPage),
            ),
          ),
          if (gameListData.length > (_currentPage * _itemsPerPage))

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalConstant.kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                  child: Text(
                    Provider.of<LanguageProvider>(context, listen: false)
                        .getString("home_screen", "load_more"),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          HapticFeedback.lightImpact();
          if (_isLogin) {
            Navigator.pushNamed(
                    context, GameLaunchCode.routeName,
                    arguments: gameListData[index].game_id)
                .then((_) {
              Provider.of<UserAuthProvider>(context,
                      listen: false)
                  .notify();
            });
          } else {
            Navigator.pushNamed(
                context, LoginScreen.routeName);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(fit: StackFit.expand, children: [
              gameListData[index].url_thumb != ''
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          gameListData[index].displayUrl,
                      // Optimized dimensions for mobile grid decoding speed
                      memCacheWidth: 200,
                      memCacheHeight: 266,
                      fadeOutDuration: Duration.zero,
                      fadeInDuration: Duration.zero,
                      errorWidget: (context, url, error) =>
                          CachedNetworkImage(
                              imageUrl: gameListData[index]
                                  .displayFallbackUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                              memCacheHeight: 266,
                              fadeOutDuration: Duration.zero,
                              fadeInDuration: Duration.zero,
                              ),
                      placeholder: (context, url) =>
                          Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor:
                                  Colors.grey[100]!,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(12),
                                      color: Colors
                                          .grey[300]!))),
                    )
                  : Container(color: Colors.grey[200]),
              Positioned.fill(
                  child: Container(
                alignment: const Alignment(-0.8, 0.55),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent
                    ],
                        stops: const [
                      0.0,
                      0.5,
                      0.85
                    ])),
                child: Text(
                  gameListData[index].name ?? '',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF5E6C8),
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      height: 1.15,
                      shadows: [
                        Shadow(
                            blurRadius: 6,
                            color: Colors.black,
                            offset: Offset(0, 2)),
                      ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      delegate: SliverChildBuilderDelegate(
        (ctx, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12))),
        ),
        childCount: 12,
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer =
        Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
