import 'package:flutter_translate/flutter_translate.dart';

enum PackType {
  NO_MODS,
  FROSTY_PACK,
  MOD_PROFILE,
  COSMETICS,
}

PackType getPackType(String packType) {
  if (packType.contains('Frosty Pack')) {
    return PackType.FROSTY_PACK;
  } else if (packType.contains('Mod Profile')) {
    return PackType.MOD_PROFILE;
  } else if (packType.endsWith('Cosmetics')) {
    return PackType.COSMETICS;
  } else if (packType.endsWith(translate('host_server.forms.mod_profile.no_mods_profile'))) {
    return PackType.NO_MODS;
  }
  throw Exception('Invalid pack type: $packType');
}

extension PackTypeExtesion on PackType {
  String get name {
    switch (this) {
      case PackType.FROSTY_PACK:
        return '(Frosty Pack)';
      case PackType.MOD_PROFILE:
        return '(Mod Profile)';
      case PackType.COSMETICS:
        return 'Cosmetics';
      case PackType.NO_MODS:
        return translate('host_server.forms.mod_profile.no_mods_profile');
    }
  }
}
