import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/gradient_text.dart';

import '../../models/game_model.dart';
import '../../providers/games_provider.dart';
import '../../screens/brand_filter_page.dart';
import '../bounce_tap.dart';

class ProvidersOfGameType extends StatefulWidget {
  final String categoryName;
  final String selectedCategory;
  const ProvidersOfGameType(
      {super.key,
      required this.selectedCategory,
      required this.categoryName});

  @override
  State<ProvidersOfGameType> createState() =>
      _ProvidersOfGameTypeState();
}

class _ProvidersOfGameTypeState
    extends State<ProvidersOfGameType> {
  final List<String> _gameProducts = [];
  bool isLoading = true;
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

  @override
  void initState() {
    super.initState();
    print(widget.selectedCategory);
    getAllProvidersForCategory(widget.selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    // return a sliver grid view of the providers
    return SliverPadding(
      padding: const EdgeInsets.all(10.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: .5,
          crossAxisSpacing: .5,
          childAspectRatio: 16 / 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (isLoading) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                period: const Duration(milliseconds: 1200),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            return BounceTap(
              onPressed: () async {
                // push to brands filter screen
                GamesProvider provider =
                    Provider.of<GamesProvider>(context, listen: false);
                List<GameModel> games = await provider.getAllGames();
                if (mounted) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrandsFilterPage(
                          games: games,
                          providers: List.from(_gameProducts),
                          selectedCategory: widget.selectedCategory,
                          selectedProvider: _gameProducts[index],
                          categoryDisplayName: widget.categoryName,
                        ),
                      ),
                    );
                  });
                }
              },
              child: Card(
                color: Colors.white,
                elevation: 6,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: providerImages.containsKey(_gameProducts[index])
                      ? providerImages[_gameProducts[index]]!
                              .contains('.svg')
                          ? SvgPicture.network(
                              'assets/images/providers/${providerImages[_gameProducts[index]]}'
                                  .res,
                            )
                          : CachedNetworkImage(
                              imageUrl:
                                  'assets/images/providers/${providerImages[_gameProducts[index]]}'
                                      .res,
                              fit: BoxFit.fill,
                            )
                      : GradientText(
                          _gameProducts[index],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF922FC6),
                              GlobalConstant.kTabActiveButtonColor,
                            ],
                            stops: [0.5, 1],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                ),
              ),
            );
          },
          childCount: isLoading ? 12 : _gameProducts.length,
        ),
      ),
    );
  }

  getAllProvidersForCategory(String category) async {
    setState(() {
      isLoading = true;
    });
    GamesProvider provider =
        Provider.of<GamesProvider>(context, listen: false);
    List<GameModel> games = await provider.getAllGames();

    _gameProducts.clear();
    _gameProducts.addAll(games
        .where((element) =>
            element.gamecategory == (category) ||
            element.category == category)
        .map((e) => e.product!)
        .toSet());

    _gameProducts.sort(
        (a, b) => providerImages.containsKey(a) ? 0 : 1);
    if (_gameProducts.remove("Jili Games")) {
      _gameProducts.insert(1, "Jili Games");
    }
    setState(() {
      isLoading = false;
    });
  }
}
