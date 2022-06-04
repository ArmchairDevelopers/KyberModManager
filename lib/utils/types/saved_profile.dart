import 'dart:convert';

import 'package:kyber_mod_manager/utils/types/freezed/frosty_collection.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

SavedProfile savedProfileFromJson(String str) => SavedProfile.fromJson(json.decode(str));

String savedProfileToJson(List<SavedProfile> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SavedProfile {
  SavedProfile({required this.mods, required this.path, required this.id, required this.size, this.lastUsed});

  List<dynamic> mods;
  String path;
  String id;
  DateTime? lastUsed;
  int size;

  @override
  String toString() {
    return 'SavedProfile(mods: $mods, path: $path, id: $id, size: $size, lastUsed: $lastUsed)';
  }

  factory SavedProfile.fromJson(Map<String, dynamic> json) => SavedProfile(
      mods: List<dynamic>.from(json["mods"].map((x) => x['fileNames'] != null ? FrostyCollection.fromJson(x) : Mod.fromJson(x))),
      path: json["path"],
      id: json["id"],
      size: json["size"],
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null);

  Map<String, dynamic> toJson() => {"mods": List<dynamic>.from(mods.map((x) => x.toJson())), "path": path, "id": id, "size": size, "lastUsed": lastUsed?.toString()};
}
