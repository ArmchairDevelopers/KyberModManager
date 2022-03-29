import 'dart:io';

import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';

class PathHelper {
  static Future<String?> isValidFrostyDir(String path) async {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return 'invalid_dir';
    }

    List<FileSystemEntity> entities = directory.listSync().toList();
    if (entities.where((element) => element.path.endsWith('FrostyModManager.exe')).isEmpty) {
      return 'invalid_dir';
    }

    Directory dataDir = Directory('$path/Mods/starwarsbattlefrontii');
    if (!dataDir.existsSync()) {
      return 'bf2_not_found';
    }

    FrostyConfig config = await FrostyService.getFrostyConfig();
    if (!config.games.keys.contains('starwarsbattlefrontii')) {
      return 'bf2_not_found';
    }

    return null;
  }
}
