class SpinResult {
  String id;
  String title;
  String description;
  String amount;
  String status;
  String? category;

  SpinResult({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.status,
    this.category,
  });

  SpinResult copyWith({
    String? id,
    String? title,
    String? description,
    String? amount,
    String? status,
    String? category,
  }) =>
      SpinResult(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        category: category ?? this.category,
      );

  factory SpinResult.fromJson(Map<String, dynamic> json) => SpinResult(
        id: json["Id"].toString(),
        title: json["Title"].toString(),
        description: json["Description"].toString(),
        amount: json["Amount"].toString(),
        status: json["Status"].toString(),
        category: json["Category"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Title": title,
        "Description": description,
        "Amount": amount,
        "Status": status,
        "Category": category,
      };
}
