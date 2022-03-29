import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

part 'frosty_profile.freezed.dart';

part 'frosty_profile.g.dart';

@freezed
class FrostyProfile with _$FrostyProfile {
  factory FrostyProfile({required String name, required List<Mod> mods}) = _FrostyProfile;

  factory FrostyProfile.fromJson(Map<String, dynamic> json) => _$FrostyProfileFromJson(json);
}
