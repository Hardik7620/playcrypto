class ApiToggles {
  /// Set to true to load games from LOCAL asset file (assets/allgames_list.json)
  static const bool useLocalGameList = false;

  /// Set to true to load games from the OLD remote API (allgames_v2old.json)
  /// If both are false, it uses the default remote API (allgames_v2.json)
  static const bool useOldV2GameList = false;
}
