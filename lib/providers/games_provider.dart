import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:playcrypto365/models/game_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/rest_api_service.dart';

class GamesProvider with ChangeNotifier {
  final List<GameModel> _games = [];
  List<GameModel> get games => _games;
  final Map<String, List<GameModel>> _gamesByCategory = {};
  final Set<GameModel> turnoverGames = {};
  int turnoverTotalCount = 0;
  final Set<GameModel> _allObservedGames = {};

  bool _isPageLoading = false;
  bool get isPageLoading => _isPageLoading;

  void setPageLoading(bool value) {
    if (_isPageLoading == value) return;
    _isPageLoading = value;
    notifyListeners();
  }

  bool _isLocalizing = false;
  bool get isLocalizing => _isLocalizing;

  void registerGames(List<GameModel> games) {
    _allObservedGames.addAll(games);
  }

  Future<void> localizeGames(
      [List<GameModel>? specificList]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode =
          prefs.getString('language_code') ?? 'en';

      _isLocalizing = true;
      notifyListeners();

      // Determine which games to process
      List<GameModel> allToLocalize = [];
      if (specificList != null) {
        allToLocalize = specificList;
      } else {
        // Collect all unique games from all caches and observed list
        Set<GameModel> uniqueGames = {};
        uniqueGames.addAll(_games);
        uniqueGames.addAll(_allObservedGames);
        _gamesByCategory.values
            .forEach((list) => uniqueGames.addAll(list));
        uniqueGames.addAll(turnoverGames);
        allToLocalize = uniqueGames.toList();
      }

      // Skip if no games to localize
      if (allToLocalize.isEmpty) {
        _isLocalizing = false;
        notifyListeners();
        return;
      }

      for (var game in allToLocalize) {
        // HEAL: If originalName is null (stale object), fallback to product
        if (game.originalName == null) {
          game.originalName = game.name ?? game.product;
        }

        if (game.originalName != null) {
          game.name = game.originalName;
        }
      }

      RestApiService restApiService = RestApiService();
      final localizedNamesResponse = await restApiService
          .getGameNameByLanguage(langCode);

      final dynamic decodedResponse = await compute(
          json.decode, localizedNamesResponse);

      List<dynamic> localizedData = [];
      if (decodedResponse is List) {
        localizedData = decodedResponse;
      } else if (decodedResponse is Map) {
        if (decodedResponse.containsKey('data') &&
            decodedResponse['data'] is List) {
          localizedData = decodedResponse['data'];
        } else {
          // Unexpected map structure
        }
      }

      if (localizedData.isEmpty) {
        // No translations available
      } else {
        // Create maps for both ID and Code for maximum resilience
        final Map<String, String> idMap = {};
        final Map<String, String> codeMap = {};

        for (var item in localizedData) {
          String id = item['gameid']?.toString() ?? '';
          String code = item['gamecode']?.toString() ?? '';
          String name = item['name']?.toString() ?? '';

          if (id.isNotEmpty) idMap[id] = name;
          if (code.isNotEmpty) codeMap[code] = name;
        }

        for (var game in allToLocalize) {
          String? localizedName;

          // Try ID first
          if (game.game_id != null &&
              idMap.containsKey(game.game_id.toString())) {
            localizedName = idMap[game.game_id.toString()];
          }
          // Then try Code
          else if (game.gameCode != null &&
              codeMap.containsKey(game.gameCode)) {
            localizedName = codeMap[game.gameCode];
          }

          if (localizedName != null) {
            game.name = localizedName;
            // HEAL: If we are in English mode, this is the canonical English name.
            // Update originalName to heal any previously polluted caches.
            if (langCode == 'en') {
              game.originalName = localizedName;
            }
          }
        }
      }
      notifyListeners();
      _isLocalizing = false;
      notifyListeners();
    } catch (e) {
      _isLocalizing = false;
      notifyListeners();
      log("Error localizing games: ${e.toString()}");
    }
  }

  String? getGameNameByCodeOrId(String codeOrId) {
    if (codeOrId.isEmpty) return null;

    // Check main games list
    for (var game in _games) {
      if (game.gameCode == codeOrId ||
          game.game_id.toString() == codeOrId) {
        return game.name;
      }
    }
    // Check category lists
    for (var list in _gamesByCategory.values) {
      for (var game in list) {
        if (game.gameCode == codeOrId ||
            game.game_id.toString() == codeOrId) {
          return game.name;
        }
      }
    }
    // Check turnover games
    for (var game in turnoverGames) {
      if (game.gameCode == codeOrId ||
          game.game_id.toString() == codeOrId) {
        return game.name;
      }
    }
    return null;
  }

  Future<void> reLocalizeAll() async {
    // Standardize key here just in case
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null &&
        prefs.getString('Locale') != null) {
      await prefs.setString(
          'language_code', prefs.getString('Locale')!);
    }
    await localizeGames(); // Trigger full cache localization
  }

  Future<List<GameModel>> getAllGames() async {
    if (_games.isNotEmpty) return _games;
    try {
      RestApiService restApiService = RestApiService();

      final responseData =
          await restApiService.getGameAllGameList();
      final responseDataJson = await compute(
          json.decode, responseData.toString());

      if (responseDataJson != null) {
        List<GameModel> gameList = [];
        for (var i = 0; i < responseDataJson.length; i++) {
          try {
            // Robust name extraction
            String? extractedName = responseDataJson[i]
                        ['name']
                    ?.toString() ??
                responseDataJson[i]['game_name']
                    ?.toString() ??
                responseDataJson[i]['product']?.toString();

            gameList.add(GameModel(
              category: responseDataJson[i]['category'],
              gameCode: responseDataJson[i]['game_code'],
              game_id: int.tryParse(responseDataJson[i]
                              ['game_id']
                          ?.toString() ??
                      '') ??
                  int.tryParse(responseDataJson[i]['gameid']
                          ?.toString() ??
                      ''),
              name: extractedName,
              originalName: extractedName,
              product: responseDataJson[i]['product'],
              url_thumb:
                  (responseDataJson[i]['url_thumb'] ?? '')
                      .toString()
                      .replaceAll("thumb.webp",
                          "thumb_3_4_custom.webp"),
              groupname: responseDataJson[i]['groupname'],
              sort: responseDataJson[i]['sort'],
              gamecategory: responseDataJson[i]
                  ['gamecategory'],
              statusId: responseDataJson[i]['statusId'],
              MinAmount: responseDataJson[i]['MinAmount'],
              MaxAmount: responseDataJson[i]['MaxAmount'],
            ));
          } catch (e) {
            log(e.toString());
          }
        }

        await localizeGames(gameList);

        _games.addAll(gameList);
        return _games;
      }
    } catch (e) {
      log("Error in getAllGames: $e");
    }
    return [];
  }

  Future getGamesByCategory(String category) async {
    if ((_gamesByCategory[category] ?? []).isNotEmpty)
      return _gamesByCategory[category]!;
    try {
      RestApiService restApiService = RestApiService();
      final responseData = await restApiService
          .getGameSubCategoryList(category);
      final responseDataJson =
          json.decode(responseData.toString());
      if (responseDataJson != null) {
        List<GameModel> gameList = [];
        for (var i = 0; i < responseDataJson.length; i++) {
          // Robust name extraction
          String? extractedName = responseDataJson[i]
                      ['name']
                  ?.toString() ??
              responseDataJson[i]['game_name']
                  ?.toString() ??
              responseDataJson[i]['product']?.toString();

          gameList.add(GameModel(
            category: responseDataJson[i]['category'],
            gameCode: responseDataJson[i]['game_code'],
            game_id: int.tryParse(responseDataJson[i]
                            ['game_id']
                        ?.toString() ??
                    '') ??
                int.tryParse(responseDataJson[i]['gameid']
                        ?.toString() ??
                    ''),
            name: extractedName,
            originalName: extractedName,
            product: responseDataJson[i]['product'],
            url_thumb: responseDataJson[i]['url_thumb'],
            groupname: responseDataJson[i]['groupname'],
            sort: responseDataJson[i]['sort'],
            gamecategory: responseDataJson[i]
                ['gamecategory'],
            statusId: responseDataJson[i]['statusId'],
            MinAmount: responseDataJson[i]['MinAmount'],
            MaxAmount: responseDataJson[i]['MaxAmount'],
          ));
        }
        await localizeGames(gameList);
        _gamesByCategory.putIfAbsent(category, () => []);
        _gamesByCategory[category]!.addAll(gameList);
        return _gamesByCategory[category];
      }
    } catch (e) {
      log("Error in getGamesByCategory: $e");
    }
    return [];
  }

  void clearCache() {
    _games.clear();
    _gamesByCategory.clear();
    turnoverGames.clear();
    notifyListeners();
  }
}
