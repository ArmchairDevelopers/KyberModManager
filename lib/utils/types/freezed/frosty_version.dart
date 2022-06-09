import 'package:freezed_annotation/freezed_annotation.dart';

part 'frosty_version.freezed.dart';
part 'frosty_version.g.dart';

@freezed
abstract class FrostyVersion with _$FrostyVersion {
  const factory FrostyVersion({
    required String version,
    required String hash,
  }) = _FrostyVersion;

  factory FrostyVersion.fromJson(Map<String, dynamic> json) => _$FrostyVersionFromJson(json);
}
