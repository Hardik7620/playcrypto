class GameModel {
  String? category;

  String? gameCode;
  int? game_id;
  String? name;
  String? originalName;

  String? product;
  String? url_thumb;
  String? groupname;
  int? sort;
  String? gamecategory;
  int? statusId;
  double? MinAmount;
  double? MaxAmount;

  GameModel({
    this.category,
    this.gameCode,
    this.game_id,
    this.name,
    this.originalName,
    this.product,
    this.url_thumb,
    this.groupname,
    this.sort,
    this.gamecategory,
    this.statusId,
    this.MinAmount,
    this.MaxAmount,
  });

  String get displayUrl {
    return url_thumb ?? '';
  }

  String get displayFallbackUrl {
    return displayUrl.replaceAll(
        "thumb_3_4_custom", "thumb");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModel &&
          runtimeType == other.runtimeType &&
          game_id == other.game_id;

  @override
  int get hashCode => game_id.hashCode;
}
