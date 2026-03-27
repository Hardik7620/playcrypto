import 'dart:convert';

class VIPConfigurations {
  int templateId;
  String templateName;
  String? features;
  List<VIPLevel> vipLevels;
  VipProgress? progress;
  VipBonusDetails? bonusDetails;

  VIPConfigurations({
    required this.templateId,
    required this.templateName,
    required this.features,
    required this.vipLevels,
    this.progress,
    this.bonusDetails,
  });

  VIPConfigurations copyWith({
    int? templateId,
    String? templateName,
    String? features,
    List<VIPLevel>? vipLevels,
    VipProgress? progress,
    VipBonusDetails? bonusDetails,
  }) =>
      VIPConfigurations(
        templateId: templateId ?? this.templateId,
        templateName: templateName ?? this.templateName,
        features: features ?? this.features,
        vipLevels: vipLevels ?? this.vipLevels,
        progress: progress ?? this.progress,
        bonusDetails: bonusDetails ?? this.bonusDetails,
      );

  factory VIPConfigurations.fromRawJson(String str) =>
      VIPConfigurations.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VIPConfigurations.fromJson(
          Map<String, dynamic> json) =>
      VIPConfigurations(
        templateId: json["TemplateId"],
        templateName: json["TemplateName"],
        features: json["Features"],
        vipLevels: List<VIPLevel>.from(json["VIPLevels"]
            .map((x) => VIPLevel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "TemplateId": templateId,
        "TemplateName": templateName,
        "Features": features,
        "VIPLevels": List<dynamic>.from(
            vipLevels.map((x) => x.toJson())),
      };
}

class VIPLevel {
  int levelId;
  String levelName;
  int levelNumber;
  double depositAmtCriteria;
  double betAmtCriteria;
  double betTurnoverWegring;
  double dailyReward;
  double weeklyReward;
  double monthlyReward;
  double upgradeReward;
  int dayFreq;
  int weekFreq;
  int monthFreq;
  double dailyDepositAmount;
  double weeklyDepositAmount;
  double monthlyDepositAmount;

  VIPLevel({
    required this.levelId,
    required this.levelName,
    required this.levelNumber,
    required this.depositAmtCriteria,
    required this.betAmtCriteria,
    required this.betTurnoverWegring,
    required this.dailyReward,
    required this.weeklyReward,
    required this.monthlyReward,
    required this.upgradeReward,
    required this.dayFreq,
    required this.weekFreq,
    required this.monthFreq,
    required this.dailyDepositAmount,
    required this.weeklyDepositAmount,
    required this.monthlyDepositAmount,
  });

  VIPLevel copyWith({
    int? levelId,
    String? levelName,
    int? levelNumber,
    double? depositAmtCriteria,
    double? betAmtCriteria,
    double? betTurnoverWegring,
    double? dailyReward,
    double? weeklyReward,
    double? monthlyReward,
    double? upgradeReward,
    int? dayFreq,
    int? weekFreq,
    int? monthFreq,
    double? dailyDepositAmount,
    double? weeklyDepositAmount,
    double? monthlyDepositAmount,
  }) =>
      VIPLevel(
        levelId: levelId ?? this.levelId,
        levelName: levelName ?? this.levelName,
        levelNumber: levelNumber ?? this.levelNumber,
        depositAmtCriteria:
            depositAmtCriteria ?? this.depositAmtCriteria,
        betAmtCriteria:
            betAmtCriteria ?? this.betAmtCriteria,
        betTurnoverWegring:
            betTurnoverWegring ?? this.betTurnoverWegring,
        dailyReward: dailyReward ?? this.dailyReward,
        weeklyReward: weeklyReward ?? this.weeklyReward,
        monthlyReward: monthlyReward ?? this.monthlyReward,
        upgradeReward: upgradeReward ?? this.upgradeReward,
        dayFreq: dayFreq ?? this.dayFreq,
        weekFreq: weekFreq ?? this.weekFreq,
        monthFreq: monthFreq ?? this.monthFreq,
        dailyDepositAmount:
            dailyDepositAmount ?? this.dailyDepositAmount,
        weeklyDepositAmount:
            weeklyDepositAmount ?? this.weeklyDepositAmount,
        monthlyDepositAmount: monthlyDepositAmount ??
            this.monthlyDepositAmount,
      );

  factory VIPLevel.fromRawJson(String str) =>
      VIPLevel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
//// was getting double parsing error so changed the parsing to check for int and double ///
  factory VIPLevel.fromJson(Map<String, dynamic> json) =>
      VIPLevel(
        levelId: json["LevelId"] is int
            ? json["LevelId"]
            : int.tryParse(json["LevelId"].toString()) ?? 0,
        levelName: json["LevelName"] ?? '',
        levelNumber: json["LevelNumber"] is int
            ? json["LevelNumber"]
            : int.tryParse(
                    json["LevelNumber"].toString()) ??
                0,
        depositAmtCriteria: (json["DepositAmtCriteria"]
                is double)
            ? json["DepositAmtCriteria"]
            : (json["DepositAmtCriteria"] is int)
                ? (json["DepositAmtCriteria"] as int)
                    .toDouble()
                : double.tryParse(json["DepositAmtCriteria"]
                        .toString()) ??
                    0.0,
        betAmtCriteria: (json["BetAmtCriteria"] is double)
            ? json["BetAmtCriteria"]
            : (json["BetAmtCriteria"] is int)
                ? (json["BetAmtCriteria"] as int).toDouble()
                : double.tryParse(json["BetAmtCriteria"]
                        .toString()) ??
                    0.0,
        betTurnoverWegring: (json["BetTurnoverWegring"]
                is double)
            ? json["BetTurnoverWegring"]
            : (json["BetTurnoverWegring"] is int)
                ? (json["BetTurnoverWegring"] as int)
                    .toDouble()
                : double.tryParse(json["BetTurnoverWegring"]
                        .toString()) ??
                    0.0,
        dailyReward: (json["DailyReward"] is double)
            ? json["DailyReward"]
            : (json["DailyReward"] is int)
                ? (json["DailyReward"] as int).toDouble()
                : double.tryParse(
                        json["DailyReward"].toString()) ??
                    0.0,
        weeklyReward: (json["WeeklyReward"] is double)
            ? json["WeeklyReward"]
            : (json["WeeklyReward"] is int)
                ? (json["WeeklyReward"] as int).toDouble()
                : double.tryParse(
                        json["WeeklyReward"].toString()) ??
                    0.0,
        monthlyReward: (json["MonthlyReward"] is double)
            ? json["MonthlyReward"]
            : (json["MonthlyReward"] is int)
                ? (json["MonthlyReward"] as int).toDouble()
                : double.tryParse(
                        json["MonthlyReward"].toString()) ??
                    0.0,
        upgradeReward: (json["UpgradeReward"] is double)
            ? json["UpgradeReward"]
            : (json["UpgradeReward"] is int)
                ? (json["UpgradeReward"] as int).toDouble()
                : double.tryParse(
                        json["UpgradeReward"].toString()) ??
                    0.0,
        dayFreq: (json["DayFreq"] is int)
            ? json["DayFreq"]
            : int.tryParse(
                    json["DayFreq"]?.toString() ?? '') ??
                0,
        weekFreq: (json["WeekFreq"] is int)
            ? json["WeekFreq"]
            : int.tryParse(
                    json["WeekFreq"]?.toString() ?? '') ??
                0,
        monthFreq: (json["MonthFreq"] is int)
            ? json["MonthFreq"]
            : int.tryParse(
                    json["MonthFreq"]?.toString() ?? '') ??
                0,
        dailyDepositAmount: (json["DailyDepositAmount"]
                is double)
            ? json["DailyDepositAmount"]
            : (json["DailyDepositAmount"] is int)
                ? (json["DailyDepositAmount"] as int)
                    .toDouble()
                : double.tryParse(json["DailyDepositAmount"]
                            ?.toString() ??
                        '') ??
                    0.0,
        weeklyDepositAmount:
            (json["WeeklyDepositAmount"] is double)
                ? json["WeeklyDepositAmount"]
                : (json["WeeklyDepositAmount"] is int)
                    ? (json["WeeklyDepositAmount"] as int)
                        .toDouble()
                    : double.tryParse(
                            json["WeeklyDepositAmount"]
                                    ?.toString() ??
                                '') ??
                        0.0,
        monthlyDepositAmount:
            (json["MonthlyDepositAmount"] is double)
                ? json["MonthlyDepositAmount"]
                : (json["MonthlyDepositAmount"] is int)
                    ? (json["MonthlyDepositAmount"] as int)
                        .toDouble()
                    : double.tryParse(
                            json["MonthlyDepositAmount"]
                                    ?.toString() ??
                                '') ??
                        0.0,
      );

  Map<String, dynamic> toJson() => {
        "LevelId": levelId,
        "LevelName": levelName,
        "LevelNumber": levelNumber,
        "DepositAmtCriteria": depositAmtCriteria,
        "BetAmtCriteria": betAmtCriteria,
        "BetTurnoverWegring": betTurnoverWegring,
        "DailyReward": dailyReward,
        "WeeklyReward": weeklyReward,
        "MonthlyReward": monthlyReward,
        "UpgradeReward": upgradeReward,
        "DayFreq": dayFreq,
        "WeekFreq": weekFreq,
        "MonthFreq": monthFreq,
        "DailyDepositAmount": dailyDepositAmount,
        "WeeklyDepositAmount": weeklyDepositAmount,
        "MonthlyDepositAmount": monthlyDepositAmount,
      };
}

class VipProgress {
  int vipLevelId;
  double currentTurnover;
  double currentDeposit;
  dynamic levelAchievedDate;

  VipProgress({
    required this.vipLevelId,
    required this.currentTurnover,
    required this.currentDeposit,
    required this.levelAchievedDate,
  });

  VipProgress copyWith({
    int? vipLevelId,
    double? currentTurnover,
    double? currentDeposit,
    String? levelAchievedDate,
  }) =>
      VipProgress(
        vipLevelId: vipLevelId ?? this.vipLevelId,
        currentTurnover:
            currentTurnover ?? this.currentTurnover,
        currentDeposit:
            currentDeposit ?? this.currentDeposit,
        levelAchievedDate:
            levelAchievedDate ?? this.levelAchievedDate,
      );

  factory VipProgress.fromRawJson(String str) =>
      VipProgress.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VipProgress.fromJson(Map<String, dynamic> json) {
    return VipProgress(
      vipLevelId: json["VIPLevelId"],
      currentTurnover: json["CurrentTurnover"],
      currentDeposit: json["CurrentDeposit"],
      levelAchievedDate: json["LevelAchievedDate"],
    );
  }

  Map<String, dynamic> toJson() => {
        "VIPLevelId": vipLevelId,
        "CurrentTurnover": currentTurnover,
        "CurrentDeposit": currentDeposit,
        "LevelAchievedDate": levelAchievedDate,
      };
}

class VipBonusDetails {
  final bool eligibleForDailyBonus,
      eligibleForWeeklyBonus,
      eligibleForMonthlyBonus;
  final double totalBonusClaimed;
  final int dayStreak;

  const VipBonusDetails(
      {required this.eligibleForDailyBonus,
      required this.eligibleForWeeklyBonus,
      required this.eligibleForMonthlyBonus,
      required this.totalBonusClaimed,
      required this.dayStreak});

  bool get isEligible =>
      eligibleForDailyBonus ||
      eligibleForWeeklyBonus ||
      eligibleForMonthlyBonus;
}
