import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

part 'frosty_collection.freezed.dart';
part 'frosty_collection.g.dart';

abstract class FrostyMod {
  String get name;

  String get version;

  String get filename;

  String? get description;
}

@HiveType(typeId: 6)
@freezed
class FrostyCollection with _$FrostyCollection {
  const FrostyCollection._();

  String toKyberString() {
    return '$name ($version)';
  }

  @Implements<FrostyMod>()
  const factory FrostyCollection({
    @HiveField(0) required String link,
    @HiveField(1) required String title,
    @HiveField(2) required String version,
    @HiveField(3) required String description,
    @HiveField(4) required String category,
    @HiveField(5) required String name,
    @HiveField(6) required String filename,
    @HiveField(7) required List<String> fileNames,
    @HiveField(8) required List<String> modVersions,
    @HiveField(9) required String author,
    @HiveField(10) List<Mod>? mods,
  }) = _FrostyCollection;

  @Implements<FrostyMod>()
  factory FrostyCollection.fromFile(String filename, dynamic json) {
    return FrostyCollection(
      link: json['link'],
      title: json['title'],
      version: json['version'],
      description: json['description'],
      category: json['category'],
      fileNames: List<String>.from(json['mods']),
      filename: filename.split(r'\').last,
      name: json['title'],
      author: json['author'],
      modVersions: List<String>.from(json['modVersions']),
      mods: List<Mod>.from(
        json['mods'].map(
          (fileName) => ModService.mods.firstWhere(
            (element) => element.filename.endsWith(fileName),
            orElse: () => Mod.fromString(''),
          ),
        ),
      ),
    );
  }

  @Implements<FrostyMod>()
  factory FrostyCollection.fromJson(Map<String, dynamic> json) => _$FrostyCollectionFromJson(json);
}
