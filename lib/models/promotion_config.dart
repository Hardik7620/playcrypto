import 'dart:convert';

PromotionConfig promotionConfigFromJson(String str) => PromotionConfig.fromJson(json.decode(str));

String promotionConfigToJson(PromotionConfig data) => json.encode(data.toJson());

class PromotionConfig {
  bool promotionVideosSection;
  List<PromotionVideo> promotionVideos;
  dynamic specialPromotion;
  bool showScratchCardOffer;
  int winScratchCardAtDeposit;
  int minWithdrawalAmount;
  int maxWithdrawalAmount;
  // Discontinued - showWeatherIssueMessage
  bool showWeatherIssueMessage;
  bool showDepositWithdrawIssueMessage;

  PromotionConfig({
    required this.promotionVideosSection,
    required this.promotionVideos,
    required this.specialPromotion,
    required this.showScratchCardOffer,
    required this.winScratchCardAtDeposit,
    required this.minWithdrawalAmount,
    required this.maxWithdrawalAmount,
    required this.showWeatherIssueMessage,
    required this.showDepositWithdrawIssueMessage,
  });

  factory PromotionConfig.fromJson(Map<String, dynamic> json) => PromotionConfig(
        promotionVideosSection: json["promotionVideosSection"],
        promotionVideos: List<PromotionVideo>.from(
            json["promotionVideos"].map((x) => PromotionVideo.fromJson(x))),
        specialPromotion: json["specialPromotion"],
        showScratchCardOffer: json["showScratchCardOffer"],
        winScratchCardAtDeposit: json["winScratchCardAtDeposit"],
        minWithdrawalAmount: json["minWithdrawalAmount"] ?? 10,
        maxWithdrawalAmount: json["maxWithdrawalAmount"] ?? 50000,
        showWeatherIssueMessage: json["showWeatherIssueMessage"] ?? false,
        showDepositWithdrawIssueMessage: json["showDepositWithdrawIssueMessage"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "promotionVideosSection": promotionVideosSection,
        "promotionVideos": List<dynamic>.from(promotionVideos.map((x) => x.toJson())),
        "specialPromotion": specialPromotion,
        "showScratchCardOffer": showScratchCardOffer,
        "winScratchCardAtDeposit": winScratchCardAtDeposit,
        "minWithdrawalAmount": minWithdrawalAmount,
        "maxWithdrawalAmount": maxWithdrawalAmount,
        "showWeatherIssueMessage": showWeatherIssueMessage,
        "showDepositWithdrawIssueMessage": showDepositWithdrawIssueMessage,
      };
}

class PromotionVideo {
  String banner;
  String videoLink;

  PromotionVideo({
    required this.banner,
    required this.videoLink,
  });

  factory PromotionVideo.fromJson(Map<String, dynamic> json) => PromotionVideo(
        banner: json["banner"],
        videoLink: json["videoLink"],
      );

  Map<String, dynamic> toJson() => {
        "banner": banner,
        "videoLink": videoLink,
      };
}
