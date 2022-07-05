import 'package:freezed_annotation/freezed_annotation.dart';

part 'frosty_profile.freezed.dart';
part 'frosty_profile.g.dart';

@freezed
class FrostyProfile with _$FrostyProfile {
  factory FrostyProfile({required String name, required List<dynamic> mods}) = _FrostyProfile;

  factory FrostyProfile.fromJson(Map<String, dynamic> json) => _$FrostyProfileFromJson(json);
}
