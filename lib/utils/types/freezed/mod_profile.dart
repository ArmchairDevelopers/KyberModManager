import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

part 'mod_profile.freezed.dart';

part 'mod_profile.g.dart';

@HiveType(typeId: 1)
@freezed
class ModProfile with _$ModProfile {
  factory ModProfile({
    @HiveField(0) required String name,
    @HiveField(1) required List<Mod> mods,
    @HiveField(2) String? description,
  }) = _ModProfile;

  factory ModProfile.fromJson(Map<String, dynamic> json) => _$ModProfileFromJson(json);
}
