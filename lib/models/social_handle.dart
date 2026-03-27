class SocialHandle {
  String name;
  String icon;
  String link;

  SocialHandle({required this.name, required this.icon, required this.link});

  factory SocialHandle.fromJson(Map<String, dynamic> json) => SocialHandle(
        name: json["name"],
        icon: json["icon"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "icon": icon,
        "link": link,
      };
}
