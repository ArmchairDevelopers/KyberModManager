import 'dart:convert';

import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

SavedProfile savedProfileFromJson(String str) => SavedProfile.fromJson(json.decode(str));

String savedProfileToJson(List<SavedProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavedProfile {
  SavedProfile({required this.mods, required this.path, required this.id, required this.size});

  List<Mod> mods;
  String path;
  String id;
  int size;

  @override
  String toString() {
    return 'SavedProfile(mods: $mods, path: $path, id: $id, size: $size)';
  }

  factory SavedProfile.fromJson(Map<String, dynamic> json) =>
      SavedProfile(mods: List<Mod>.from(json["mods"].map((x) => Mod.fromJson(x))), path: json["path"], id: json["id"], size: json["size"]);

  Map<String, dynamic> toJson() => {"mods": List<dynamic>.from(mods.map((x) => x.toJson())), "path": path, "id": id, "size": size};
}
