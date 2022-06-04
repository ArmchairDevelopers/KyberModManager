import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_collection.dart';

part 'mod.freezed.dart';

part 'mod.g.dart';

@HiveType(typeId: 2)
@freezed
class Mod with _$Mod {
  const Mod._();

  String toKyberString() {
    return '$name ($version)';
  }

  @Implements<FrostyMod>()
  factory Mod({
    @HiveField(0) required String name,
    @HiveField(1) required String filename,
    @HiveField(2) required String category,
    @HiveField(3) required String version,
    @HiveField(4) String? author,
  }) = _Mod;

  @Implements<FrostyMod>()
  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);

  @Implements<FrostyMod>()
  factory Mod.fromString(String filename, [String? data]) {
    List<String> formatted = data != null ? Uri.encodeComponent(data).split('%00') : ['Invalid', 'Unknown', 'Unknown', 'Unknown'];
    return Mod(
      name: Uri.decodeComponent(formatted[0]),
      author: Uri.decodeComponent(formatted[1]),
      filename: filename.split('\\').last,
      category: Uri.decodeComponent(formatted[2]),
      version: Uri.decodeComponent(formatted[3]),
    );
  }
}
