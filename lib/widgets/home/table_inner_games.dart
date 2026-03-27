import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:playcrypto365/providers/games_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:skeletonizer/skeletonizer.dart';

import '../../constants/global_constant.dart';
import '../../models/game_model.dart';
import '../../providers/user_auth.dart';
import '../../screens/game_launch_code.dart';
import '../../screens/login_screen.dart';
import '../../services/rest_api_service.dart';
import '../../providers/language_provider.dart';
import '../bounce_tap.dart';

class TableInnerGames extends StatefulWidget {
  final String gameCategory;
  const TableInnerGames(this.gameCategory, {Key? key})
      : super(key: key);
  @override
  State<TableInnerGames> createState() =>
      _TableInnerGamesState();
}

class _TableInnerGamesState extends State<TableInnerGames> {
  var allGames = [];
  bool isLoading = true;
  bool isMoreLoading = false;
  int _currentPage = 1;
  final int _itemsPerPage = 9;
  int _totalItems = 0;
  final GlobalKey _topKey = GlobalKey();
  String? _lastCategory;

  @override
  void initState() {
    super.initState();
    fetchGameCategory();
  }

  @override
  void didUpdateWidget(
      covariant TableInnerGames oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gameCategory != oldWidget.gameCategory) {
      fetchGameCategory();
    }
  }

  Future fetchGameCategory() async {
    setState(() {
      if (widget.gameCategory != _lastCategory) {
        allGames.clear();
        _currentPage = 1; // Reset to page 1 for new category
        isLoading = true;
      } else if (_currentPage > 1) {
        isMoreLoading = true;
      } else {
        isLoading = true;
      }
      _lastCategory = widget.gameCategory;
    });
    
    // Only trigger the global centered loading for pagination (page > 1)
    // because the first page already has high-quality shimmer skeletons.
    if (_currentPage > 1) {
      Provider.of<GamesProvider>(context, listen: false).setPageLoading(true);
    }

    GamesProvider provider =
        Provider.of<GamesProvider>(context, listen: false);
    RestApiService restApiService = RestApiService();
    // Check if we need to fetch from API
    bool shouldFetch = true;
    if (provider.turnoverGames.isNotEmpty) {
      if (provider.turnoverGames.length >= _currentPage * _itemsPerPage || 
          (provider.turnoverTotalCount > 0 && provider.turnoverGames.length >= provider.turnoverTotalCount)) {
        shouldFetch = false;
      }
    }

    if (shouldFetch) {
      final ResponseData = widget.gameCategory == 'turnover'
          ? await restApiService
              .getTurnOverGameList(widget.gameCategory, page: _currentPage, limit: _itemsPerPage)
          : await restApiService
              .getGetGameList(widget.gameCategory, page: _currentPage, limit: _itemsPerPage);

      if (ResponseData == "ERROR") {
        // Handle here
        if (kIsWeb) {
          html.window.location.href = '/404.html';
        } else {
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/404');
        }
        // return;
      }
      if (ResponseData == null ||
          ResponseData.trim().isEmpty) {
        // Handle here
        if (kIsWeb) {
          html.window.location.href = '/404.html';
        } else {
          Navigator.of(context, rootNavigator: true)
              .pushNamed('/404');
        }
        // return;
      }

      if (ResponseData.startsWith("<html") ||
          ResponseData.contains("<!DOCTYPE html")) {
        // Handle here
        return;
      }

      // ignore: non_constant_identifier_names
      final ResponseDataJson = await compute(
          json.decode, ResponseData.toString());

      if (ResponseDataJson is List) {
        List<GameModel> gameList = [];
        int parsedTotalCount = 0;
        for (var i = 0; i < ResponseDataJson.length; i++) {
          parsedTotalCount = ResponseDataJson[i]['TotalCount'] ?? parsedTotalCount;
          gameList.add(GameModel(
            category: ResponseDataJson[i]['category'],
            gameCode: ResponseDataJson[i]['game_code'],
            game_id: ResponseDataJson[i]['game_id'],
            name: ResponseDataJson[i]['name'],
            originalName: ResponseDataJson[i]['name'],
            product: ResponseDataJson[i]['product'],
            url_thumb: ResponseDataJson[i]['url_thumb']
                .replaceAll(
                    "thumb.webp", "thumb_3_4_custom.webp"),
            groupname: ResponseDataJson[i]['groupname'],
            sort: ResponseDataJson[i]['sort'],
            gamecategory: ResponseDataJson[i]
                ['gamecategory'],
            statusId: ResponseDataJson[i]['statusId'],
            MinAmount: ResponseDataJson[i]['MinAmount'],
          ));
        }

        // Apply localization and register for future updates
        await provider.localizeGames(gameList);
        provider.registerGames(gameList);

        if (widget.gameCategory == 'turnover') {
          print("Caching turnover games...");
          // ignore: use_build_context_synchronously
          GamesProvider provider =
              Provider.of<GamesProvider>(context,
                  listen: false);
          if (provider.turnoverGames.isEmpty) {
            provider.turnoverGames.addAll(gameList);
          if (parsedTotalCount > 0) {
            provider.turnoverTotalCount = parsedTotalCount;
          }
          }
        }

        setState(() {
          if (parsedTotalCount > 0) {
            _totalItems = parsedTotalCount;
          } else if (gameList.length > _itemsPerPage) {
            _totalItems = gameList.length;
          }
          
          if (_currentPage == 1) {
            allGames = gameList.take(_itemsPerPage).toList();
          } else {
            // Filter out any duplicates and ONLY take the next _itemsPerPage
            final existingIds = allGames.map((e) => e.game_id).toSet();
            final newGames = gameList
                .where((e) => !existingIds.contains(e.game_id))
                .take(_itemsPerPage)
                .toList();
            allGames.addAll(newGames);
          }
          
          isLoading = false;
          isMoreLoading = false;
        });

        // ignore: use_build_context_synchronously
        Provider.of<GamesProvider>(context, listen: false).setPageLoading(false);
        print("Loaded ${allGames.length} games.");
      } else {
        setState(() {
          isLoading = false;
          isMoreLoading = false;
        });
      }
    } else {
      print(
          "Using CACHED turnover games (${provider.turnoverGames.length} found).");
      var gameList = provider.turnoverGames.toList();
      setState(() {
        if (provider.turnoverTotalCount > 0) {
          _totalItems = provider.turnoverTotalCount;
        }
        if (_currentPage == 1) {
           allGames = gameList.take(_itemsPerPage).toList();
        } else {
           allGames = gameList.take(_currentPage * _itemsPerPage).toList();
        }
        isLoading = false;
        isMoreLoading = false;
      });
      print("Loaded CACHED ${allGames.length} games. Total: $_totalItems");
    }
    print("----- fetchGameCategory END -----");
  }

  @override
  Widget build(BuildContext context) {
    final gamesProvider =
        Provider.of<GamesProvider>(context);

    // Show skeleton loader during initial fetch OR during localization transitions
    final bool showSkeleton =
        isLoading && allGames.isEmpty || (gamesProvider.isLocalizing && allGames.isEmpty);

    return SliverMainAxisGroup(
      slivers: [
        if (showSkeleton)
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                childCount: 12,
              ),
            ),
          )
        else if (allGames.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: 200.00,
                height: 24.0,
                child: Text(
                  Provider.of<LanguageProvider>(context, listen: false)
                      .getString("home_screen", "comingsoon"),
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: GlobalConstant.kPrimaryColor),
                ),
              ),
            ),
          )
        else
          SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(key: _topKey, child: const SizedBox(height: 1)),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  key: ValueKey('grid_${widget.gameCategory}'), 
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Throttle animations: Only animate newly added cards
                      final bool shouldAnimate = index >= (_currentPage - 1) * _itemsPerPage;
                
                      return RepaintBoundary(
                        key: ValueKey(allGames[index].game_id),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: shouldAnimate ? (300 + ((index % _itemsPerPage) * 30)) : 0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            if (value == 1.0) return child!;
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: PremiumGameCard(
                            game: allGames[index],
                            index: index,
                          ),
                        ),
                      );
                    },
                    childCount: allGames.length,
                  ),
                ),
              ),
            ],
          ),
        if (((_totalItems > allGames.length) || (_totalItems == 0 && allGames.length > 0 && allGames.length % _itemsPerPage == 0)) && !isLoading)
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
                  elevation: 2,
                ),
                onPressed: isMoreLoading ? null : () {
                   setState(() {
                    _currentPage++;
                  });
                  fetchGameCategory();
                },
                child: isMoreLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      Provider.of<LanguageProvider>(context, listen: false)
                          .getString("home_screen", "load_more"),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class PremiumGameCard extends StatefulWidget {
  final dynamic game;
  final int index;

  const PremiumGameCard({
    Key? key,
    required this.game,
    required this.index,
  }) : super(key: key);

  @override
  State<PremiumGameCard> createState() => _PremiumGameCardState();
}

class _PremiumGameCardState extends State<PremiumGameCard> {
  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onPressed: () async {
        bool Result = await Provider.of<UserAuthProvider>(context, listen: false).isLoggedIn();
        if (Result) {
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.pushNamed(context, GameLaunchCode.routeName, arguments: widget.game.game_id).then((_) {
              Provider.of<UserAuthProvider>(context, listen: false).notify();
            });
          });
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.pushNamed(context, LoginScreen.routeName);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                key: ValueKey('image_${widget.game.game_id}'),
                fit: BoxFit.cover,
                imageUrl: widget.game.displayUrl,
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
                // Optimized memory cache dimensions for mobile grids to reduce decoding overhead
                memCacheWidth: 200,
                memCacheHeight: 266,
                errorWidget: (context, url, error) {
                  return CachedNetworkImage(
                    imageUrl: widget.game.displayFallbackUrl,
                    fit: BoxFit.cover,
                    fadeOutDuration: Duration.zero,
                    fadeInDuration: Duration.zero,
                    memCacheWidth: 200,
                    memCacheHeight: 266,
                  );
                },
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
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
                  alignment: const Alignment(-0.8, 0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 0.85],
                    ),
                  ),
                  child: Consumer<GamesProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        widget.game.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: const Color(0xFFFCEA9B),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.8),
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
