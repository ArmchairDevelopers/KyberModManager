import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

part 'frosty_collection.freezed.dart';

part 'frosty_collection.g.dart';

abstract class FrostyMod {
  String get name;

  String get version;

  String get filename;
}

@freezed
class FrostyCollection with _$FrostyCollection {
  const FrostyCollection._();

  String toKyberString() {
    return '$name ($version)';
  }

  @Implements<FrostyMod>()
  const factory FrostyCollection({
    required String link,
    required String title,
    required String version,
    required String description,
    required String category,
    required String name,
    required String filename,
    required List<String> fileNames,
    required List<String> modVersions,
    List<Mod>? mods,
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
