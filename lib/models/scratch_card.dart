class ScratchCard {
  int id;
  String description;
  String amount;
  String status;
  DateTime createdDate;

  ScratchCard({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdDate,
  });

  ScratchCard copyWith({
    int? id,
    String? description,
    String? amount,
    String? status,
    DateTime? createdDate,
  }) =>
      ScratchCard(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        createdDate: createdDate ?? this.createdDate,
      );

  factory ScratchCard.fromJson(Map<String, dynamic> json) => ScratchCard(
        id: json["Id"],
        description: json["Description"],
        amount: json["Amount"].toString(),
        status: json["Status"],
        createdDate: DateTime.parse(json["CreatedDate"]).add(const Duration(minutes: 30)),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Description": description,
        "Amount": amount,
        "Status": status,
        "CreatedDate": createdDate.toIso8601String(),
      };
}
