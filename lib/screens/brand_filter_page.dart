import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:playcrypto365/models/game_model.dart';
import 'package:playcrypto365/screens/search_tab_screen.dart';
import 'package:playcrypto365/utils/extensions.dart';

import '../../constants/global_constant.dart';
import '../../providers/user_auth.dart';
import '../../providers/games_provider.dart';
import '../../screens/game_launch_code.dart';
import '../../screens/login_screen.dart';
import '../providers/language_provider.dart';

class BrandsFilterPage extends StatefulWidget {
  final List<String> providers;
  final List<GameModel> games;
  final String selectedCategory;
  final String selectedProvider;
  final String categoryDisplayName;
  const BrandsFilterPage({
    super.key,
    required this.games,
    required this.providers,
    required this.selectedCategory,
    required this.selectedProvider,
    required this.categoryDisplayName,
  });

  @override
  State<BrandsFilterPage> createState() =>
      _BrandsFilterPageState();
}

class _BrandsFilterPageState
    extends State<BrandsFilterPage> {
  final Map<String, String> _gameCategories = {
    "Casino": "LiveGame",
    "Sports": "Esports",
    "Poker": "Poker",
    "Slots": "Slots",
    "Crash": "Crash Games",
    "Table": "TableGame",
    "Lottery": "Lottery",
    "Roulette": "Roulette",
  };

  List<GameModel> filteredGames = [];
  Map<String, List<GameModel>> _allGames = {};
  List<int> _currentPages = [1];
  final int _itemsPerPage = 9;

  Map<String, String> providerImages = {
    "Evolution Gaming": "evolution_gaming.svg",
    "Red Tiger": "red-tiger.svg",
    "NetEnt": "netent.svg",
    "Spribe": "spribe.svg",
    "Ezugi": "ezugi.svg",
    "Play'n Go": "playngo.png",
    "Betsolutions": "betgames.png",
    "Pragmatic Play": "pragmatic-play.svg",
    "Habanero": "habanero.svg",
    "Quickspin": "quickspin.svg",
    "Nolimit City": "nolimit-city.svg",
    "Relax Gaming": "relax-gaming.svg",
    "PGSoft": "pgsoft.svg",
    "Jili Games": "jilli.png",
    "3 Oaks Gaming": "3oaks.svg",
    "AE Sexy": "ae-sexy.png",
    "Smartsoft Gaming": "smartsoft.svg",
    "TVBet": "tvbet.webp",
    "Playtech": "playtech.png",
    "Charismatic": "charismatic.webp",
    "Fantasma Games": "fantasma-games.webp",
    "Gamzix": "gamzix.png",
    "Aura Gaming": "aura_gaming.png",
    "Kingmaker": "kingmaker.png",
    "Naga Gaming": "naga-gaming.png",
    "Playtech Live": "playtech-live.png"
  };
  final ScrollController _controller = ScrollController();
  bool _showingFab = false;
  late String _selectedProvider;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.selectedProvider;
    _gameCategories.remove(widget.selectedCategory);
    widget.providers.remove(_selectedProvider);
    widget.providers.remove('All');
    widget.providers.insert(0, _selectedProvider);
    widget.providers.insert(0, "All");

    _filterGames();
    List<int> gameIds = [
      2706,
      2550,
      2069,
      2067,
      2071,
      2244,
      2054,
      2059,
      2031,
      2065,
      2064,
      2070,
      3,
      507,
      879,
      2386
    ];

    // Register games for localization tracking
    Provider.of<GamesProvider>(context, listen: false)
        .registerGames(widget.games);

    if (filteredGames
        .any((e) => gameIds.contains(e.game_id))) {
      List<GameModel> game = filteredGames
          .where((e) => gameIds.contains(e.game_id))
          .toList();
      game.forEach((element) {
        filteredGames.remove(element);
        filteredGames.insert(0, element);
      });
    }

    _controller.addListener(() {
      if (_controller.position.pixels > 200 &&
          !_showingFab) {
        setState(() {
          _showingFab = true;
        });
      } else if (_showingFab &&
          _controller.position.pixels < 200) {
        setState(() {
          _showingFab = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // Listen to GamesProvider to ensure UI updates when game names are localized
    Provider.of<GamesProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: GlobalConstant.kPrimaryColor,
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Text(widget.categoryDisplayName),
      ),
      floatingActionButton: _showingFab
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.grey[100],
              onPressed: () {
                _controller.animateTo(0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut);
              },
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_up_outlined,
                  color: Colors.grey,
                ),
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 7.h,
                  width: 78.w,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.providers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: widget.providers[index] ==
                                _selectedProvider
                            ? GlobalConstant.kPrimaryColor
                            : Colors.white,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedProvider =
                                  widget.providers[index];
                              print(_selectedProvider);
                              _filterGames();
                            });
                          },
                          child: Container(
                            width: 24.w,
                            height: 7.h,
                            padding:
                                const EdgeInsets.all(4),
                            alignment: Alignment.center,
                            child: providerImages
                                    .containsKey(widget
                                        .providers[index])
                                ? providerImages[widget
                                                .providers[
                                            index]]!
                                        .contains('.svg')
                                    ? SvgPicture.network(
                                        'assets/images/providers/${providerImages[widget.providers[index]]}'
                                            .res,
                                        color: widget.providers[
                                                    index] ==
                                                _selectedProvider
                                            ? Colors.white
                                            : null,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: 'assets/images/providers/${providerImages[widget.providers[index]]}'
                                            .res,
                                        fit: BoxFit.fill,
                                        color: widget.providers[
                                                    index] ==
                                                _selectedProvider
                                            ? Colors.white
                                            : null,
                                      )
                                : Text(
                                    widget.providers[index],
                                    textAlign:
                                        TextAlign.center,
                                    style: TextStyle(
                                      color: widget.providers[
                                                  index] ==
                                              _selectedProvider
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  color: GlobalConstant.kPrimaryColor,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SearchTabScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 15.w,
                      height: 6.h,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            filteredGames.isEmpty
                ? Center(
                    child: Text(
                      Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "no_records_found"),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  )
            : Expanded(
                child: CustomScrollView(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryDisplayName.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GlobalConstant.kTableTabTitleColor,
                            ),
                          ),
                          const Divider(
                            height: 5,
                            color: GlobalConstant.kTableTabTitleColor,
                            thickness: 1,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final game = filteredGames[index];
                          return InkWell(
                            key: ValueKey(game.game_id),
                            onTap: () async {
                              bool result = await Provider.of<UserAuthProvider>(context, listen: false).isLoggedIn();
                              if (result) {
                                Navigator.pushNamed(
                                  context,
                                  GameLaunchCode.routeName,
                                  arguments: game.game_id,
                                ).then((_) {
                                  Provider.of<UserAuthProvider>(context, listen: false).notify();
                                });
                              } else {
                                Navigator.pushNamed(context, LoginScreen.routeName);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                      CachedNetworkImage(
                                        key: ValueKey('image_${game.game_id}'),
                                        fit: BoxFit.cover,
                                        imageUrl: game.displayUrl,
                                        fadeOutDuration: Duration.zero,
                                        fadeInDuration: Duration.zero,
                                        errorWidget: (context, url, error) {
                                          return CachedNetworkImage(
                                            imageUrl: game.displayFallbackUrl,
                                            fit: BoxFit.cover,
                                            fadeOutDuration: Duration.zero,
                                            fadeInDuration: Duration.zero,
                                          );
                                        },
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        alignment: const Alignment(-0.8, 0.55),
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.85),
                                              Colors.black.withOpacity(0.4),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.5, 0.85],
                                          ),
                                        ),
                                        child: Text(
                                          game.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFF5E6C8),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                            height: 1.1,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: ( _currentPages[0] * _itemsPerPage) > filteredGames.length ? filteredGames.length : (_currentPages[0] * _itemsPerPage),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          if (filteredGames.length > (_currentPages[0] * _itemsPerPage))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalConstant.kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _currentPages[0]++;
                                  });
                                },
                                child: Text(
                                  Provider.of<LanguageProvider>(context, listen: false)
                                      .getString("home_screen", "load_more"),
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    for (var entry in _allGames.entries) ...[
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: GlobalConstant.kTableTabTitleColor,
                              ),
                            ),
                            const Divider(
                              height: 5,
                              color: GlobalConstant.kTableTabTitleColor,
                              thickness: 1,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final game = entry.value[index];
                            return InkWell(
                              key: ValueKey(game.game_id),
                              onTap: () async {
                                bool result = await Provider.of<UserAuthProvider>(context, listen: false).isLoggedIn();
                                if (result) {
                                  Navigator.pushNamed(
                                    context,
                                    GameLaunchCode.routeName,
                                    arguments: game.game_id,
                                  ).then((_) {
                                    Provider.of<UserAuthProvider>(context, listen: false).notify();
                                  });
                                } else {
                                  Navigator.pushNamed(context, LoginScreen.routeName);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        key: ValueKey('image_${game.game_id}'),
                                        fit: BoxFit.cover,
                                        imageUrl: game.displayUrl,
                                        fadeOutDuration: Duration.zero,
                                        fadeInDuration: Duration.zero,
                                        errorWidget: (context, url, error) {
                                          return CachedNetworkImage(
                                            imageUrl: game.displayFallbackUrl,
                                            fit: BoxFit.cover,
                                            fadeOutDuration: Duration.zero,
                                            fadeInDuration: Duration.zero,
                                          );
                                        },
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                          alignment: const Alignment(-0.8, 0.55),
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.85),
                                                Colors.black.withOpacity(0.4),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.5, 0.85],
                                            ),
                                          ),
                                          child: Text(
                                            game.name ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFFF5E6C8),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.2,
                                              height: 1.1,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 4,
                                                  color: Colors.black,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: ( _currentPages[_allGames.keys.toList().indexOf(entry.key) + 1] * _itemsPerPage) > entry.value.length ? entry.value.length : (_currentPages[_allGames.keys.toList().indexOf(entry.key) + 1] * _itemsPerPage),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            if (entry.value.length > (_currentPages[_allGames.keys.toList().indexOf(entry.key) + 1] * _itemsPerPage))
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: GlobalConstant.kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      final index = _allGames.keys.toList().indexOf(entry.key) + 1;
                                      _currentPages[index]++;
                                    });
                                  },
                                  child: Text(
                                    Provider.of<LanguageProvider>(context, listen: false)
                                        .getString("home_screen", "load_more"),
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _filterGames() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) _controller.jumpTo(0);
    });
    
    _allGames.clear();
    _currentPages.clear();
    _currentPages.add(1); // Default batch size
    
    // Filter and group in a more efficient way
    for (var game in widget.games) {
      if (game.product == _selectedProvider) {
        final cat = game.gamecategory;
        if (cat != null && cat != widget.selectedCategory) {
          _allGames.putIfAbsent(cat, () => []).add(game);
        }
      }
    }
    
    // Pre-fill show counts for each category
    for (int i = 0; i < _allGames.length; i++) {
      _currentPages.add(1);
    }

    setState(() {
      filteredGames.clear();
      final result = widget.games.where((e) {
        if (_selectedProvider == "All") {
          return e.category == widget.selectedCategory || e.gamecategory == widget.selectedCategory;
        } else {
          return e.product == _selectedProvider;
        }
      });
      filteredGames.addAll(result);
      
      // Special sorting for specific game
      const int specialGameId = 2386;
      final int specialIdx = filteredGames.indexWhere((e) => e.game_id == specialGameId);
      if (specialIdx != -1) {
        final game = filteredGames.removeAt(specialIdx);
        filteredGames.insert(0, game);
      }
    });
  }
}
