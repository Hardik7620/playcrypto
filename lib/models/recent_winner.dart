import 'dart:convert';

class RecentWinner {
  String name;
  String timeAgo;
  String price;

  RecentWinner({
    required this.name,
    required this.timeAgo,
    required this.price,
  });

  RecentWinner copyWith({
    String? name,
    String? timeAgo,
    String? price,
  }) =>
      RecentWinner(
        name: name ?? this.name,
        timeAgo: timeAgo ?? this.timeAgo,
        price: price ?? this.price,
      );

  factory RecentWinner.fromRawJson(String str) => RecentWinner.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecentWinner.fromJson(Map<String, dynamic> json) => RecentWinner(
        name: json["Name"],
        timeAgo: json["TimeAgo"].toString(),
        price: json["Price"],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "TimeAgo": timeAgo,
        "Price": price,
      };
}
