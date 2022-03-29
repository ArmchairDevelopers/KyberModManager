class KyberMap {
  KyberMap({
    required this.map,
    required this.name,
  });

  String map;
  String name;

  factory KyberMap.fromJson(Map<String, dynamic> json) => KyberMap(
        map: json["map"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "map": map,
        "name": name,
      };
}
