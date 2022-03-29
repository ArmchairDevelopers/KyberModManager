import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'mod.freezed.dart';

part 'mod.g.dart';

@HiveType(typeId: 2)
@freezed
class Mod with _$Mod {
  const Mod._();

  String toKyberString() {
    return '$name ($version)';
  }

  factory Mod({
    @HiveField(0) required String name,
    @HiveField(1) required String filename,
    @HiveField(2) required String category,
    @HiveField(3) required String version,
  }) = _Mod;

  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);

  factory Mod.fromString(String filename, [String? data]) {
    List<String> formatted = data != null ? Uri.encodeComponent(data).split('%00') : ['', '', '', ''];
    return Mod(
      name: Uri.decodeComponent(formatted[0]),
      filename: filename.split('\\').last,
      category: Uri.decodeComponent(formatted[2]),
      version: Uri.decodeComponent(formatted[3]),
    );
  }
}
