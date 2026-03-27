class AmountBonus {
  String? depositAmountId;
  String? levelId;
  double? amount;
  double? bonusPercentage;
  double? wagering;
  int? sorting;

  AmountBonus({
    this.depositAmountId,
    this.levelId,
    this.amount,
    this.bonusPercentage,
    this.wagering,
    this.sorting,
  });

  factory AmountBonus.fromJson(Map<String, dynamic> json) => AmountBonus(
    depositAmountId: json['DepositAmountId']?.toString(),
    levelId: json['LevelId']?.toString(),
    amount: (json['Amount'] ?? 0).toDouble(),
    bonusPercentage: (json['BonusPercentage'] ?? 0).toDouble(),
    wagering: (json['Wagering'] ?? 0).toDouble(),
    sorting: json['Sorting'],
  );
}
