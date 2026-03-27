import 'dart:convert';

class RolloverDetails {
  double totalBalanceRollover;
  double pendingBalanceRollover;
  double normalBalanceRollover;
  double sportsBalanceRollover;
  double liveBalanceRollover;
  double slotsBalanceRollover;
  double crashGameBalanceRollover;
  double tableGameBalanceRollover;
  double fishingBalanceRollover;
  String withdrawalStatus;
  String message;

  RolloverDetails({
    required this.totalBalanceRollover,
    required this.pendingBalanceRollover,
    required this.normalBalanceRollover,
    required this.sportsBalanceRollover,
    required this.liveBalanceRollover,
    required this.slotsBalanceRollover,
    required this.crashGameBalanceRollover,
    required this.tableGameBalanceRollover,
    required this.fishingBalanceRollover,
    required this.withdrawalStatus,
    required this.message,
  });

  factory RolloverDetails.fromRawJson(String str) => RolloverDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RolloverDetails.fromJson(Map<String, dynamic> json) => RolloverDetails(
        totalBalanceRollover: json["TotalBalanceRollover"],
        // pendingBalanceRollover: json["CompletedBalanceRollover"], /// changed due to API response
        pendingBalanceRollover: json["CompletedRolloverAmount"],
        normalBalanceRollover: json["NormalBalanceRollover"],
        sportsBalanceRollover: json["SportsBalanceRollover"],
        liveBalanceRollover: json["LiveBalanceRollover"],
        slotsBalanceRollover: json["SlotsBalanceRollover"],
        crashGameBalanceRollover: json["CrashGameBalanceRollover"],
        tableGameBalanceRollover: json["TableGameBalanceRollover"],
        fishingBalanceRollover: json["FishingBalanceRollover"],
        withdrawalStatus: json["WithdrawalStatus"],
        message: json["Message"],
      );

  Map<String, dynamic> toJson() => {
        "TotalBalanceRollover": totalBalanceRollover,
        "CompletedBalanceRollover": pendingBalanceRollover,
        "NormalBalanceRollover": normalBalanceRollover,
        "SportsBalanceRollover": sportsBalanceRollover,
        "LiveBalanceRollover": liveBalanceRollover,
        "SlotsBalanceRollover": slotsBalanceRollover,
        "CrashGameBalanceRollover": crashGameBalanceRollover,
        "TableGameBalanceRollover": tableGameBalanceRollover,
        "FishingBalanceRollover": fishingBalanceRollover,
        "WithdrawalStatus": withdrawalStatus,
        "Message": message,
      };
}
