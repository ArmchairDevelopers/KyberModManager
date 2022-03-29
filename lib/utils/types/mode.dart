List<Mode> modesFromJson(dynamic data) => List<Mode>.from(data.map((x) => Mode.fromJson(x)));

class Mode {
  Mode({
    required this.mode,
    required this.name,
    required this.maps,
    this.mapOverrides,
  });

  String mode;
  String name;
  List<String> maps;
  List<MapOverride>? mapOverrides;

  factory Mode.fromJson(Map<String, dynamic> json) => Mode(
        mode: json["mode"],
        name: json["name"],
        maps: List<String>.from(json["maps"].map((x) => x)),
        mapOverrides: json["mapOverrides"] == null ? null : List<MapOverride>.from(json["mapOverrides"].map((x) => MapOverride.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mode": mode,
        "name": name,
        "maps": List<dynamic>.from(maps.map((x) => x)),
        "mapOverrides": mapOverrides == null ? null : List<dynamic>.from(mapOverrides?.map((x) => x.toJson()) ?? []),
      };
}

class MapOverride {
  MapOverride({
    required this.map,
    required this.name,
  });

  String map;
  String name;

  factory MapOverride.fromJson(Map<String, dynamic> json) => MapOverride(
        map: json["map"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "map": map,
        "name": name,
      };
}
