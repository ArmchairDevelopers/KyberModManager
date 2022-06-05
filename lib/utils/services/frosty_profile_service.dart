import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_profile.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';

class FrostyProfileService {
  static final Game _battlefront = Game(
    gamePath: OriginHelper.getBattlefrontPath(),
    bookmarkDb: "[Asset Bookmarks]|[Legacy Bookmarks]",
    options: Options(),
    packs: {'Default': '', 'KyberModManager': ''},
  );

  static Future<void> createProfile(List<String> list, [String profile = 'KyberModManager']) async {
    try {
      List mods = list.map((e) => ModService.convertToFrostyMod(e)).toList();
      FrostyConfig config = await FrostyService.getFrostyConfig();
      if (config.games['starwarsbattlefrontii'] == null) {
        return;
      }
      config.globalOptions.defaultProfile = 'starwarsbattlefrontii';
      config.globalOptions.useDefaultProfile = true;
      config.games['starwarsbattlefrontii']?.options.selectedPack = 'KyberModManager';
      config.games['starwarsbattlefrontii']?.packs?[profile] =
          mods.where((element) => element.filename.isNotEmpty).map((e) => '${e.filename.substring(e.filename.lastIndexOf('\\') + 1)}:True').join('|');
      await FrostyService.saveFrostyConfig(config);
    } catch (e) {
      NotificationService.showNotification(message: e.toString(), color: Colors.red);
    }
  }

  static Future<bool> checkConfig(String path) async {
    FrostyConfig config = await FrostyService.getFrostyConfig(path);
    if (config.games['starwarsbattlefrontii'] == null) {
      return false;
    }

    return true;
  }

  static Future<void> loadBattlefront(String configPath) async {
    FrostyConfig config = await FrostyService.getFrostyConfig(configPath);
    if (config.games['starwarsbattlefrontii'] == null) {
      config.games['starwarsbattlefrontii'] = _battlefront;
      config.globalOptions.defaultProfile = 'starwarsbattlefrontii';
      config.globalOptions.useDefaultProfile = true;
    }

    await FrostyService.saveFrostyConfig(config);
  }

  static Future<void> createFrostyConfig() async {
    String path = applicationDocumentsDirectory.replaceAll(r'Roaming\Kyber Mod Manager', r'Local\Frosty');
    if (!Directory(path).existsSync()) {
      Directory(path).createSync(recursive: true);
    }
    File file = File('$path\\manager_config.json');
    if (file.existsSync()) {
      return;
    }
    await file.create();
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    Logger.root.info('Creating Frosty config at "${file.path}"');
    Logger.root.info('Battlefront path: $battlefrontPath');
    FrostyConfig config = FrostyConfig.fromJson({'Games': {}, 'GlobalOptions': Map<String, dynamic>.from({})});
    config.globalOptions.defaultProfile = 'starwarsbattlefrontii';
    config.globalOptions.useDefaultProfile = true;
    config.games['starwarsbattlefrontii'] = _battlefront;
    await FrostyService.saveFrostyConfig(config, file.path);
  }

  static loadFrostyPack(String name, [Function? onProgress]) async {
    Logger.root.info('Loading Frosty pack: $name');
    String bf2path = OriginHelper.getBattlefrontPath();
    List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(name);
    await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
    Directory d = Directory('$bf2path\\ModData\\' + name);
    if (d.existsSync()) {
      var appliedMods = await getModsFromProfile('KyberModManager');
      if (listEquals(mods, appliedMods)) {
        Logger.root.info('Profile $name already loaded');
        return;
      }

      Logger.root.info('Copying profile data for $name');
      await ProfileService.copyProfileData(d, Directory('$bf2path\\ModData\\KyberModManager'), onProgress);
    }
  }

  static Future<List<Mod>> getModsFromConfigProfile(String profile) async {
    FrostyConfig config = await FrostyService.getFrostyConfig();
    if (config.games['starwarsbattlefrontii']?.packs?[profile] == null) {
      return [];
    }
    List<String> modList = config.games['starwarsbattlefrontii']!.packs![profile]!.split('|').map((e) => e.split(':')[0]).toList();
    return modList.map((e) => ModService.fromFilename(e)).toList();
  }

  static Future<List<dynamic>> getModsFromProfile(String profile) async {
    FrostyConfig config = await FrostyService.getFrostyConfig();
    String path = OriginHelper.getBattlefrontPath();
    if (config.games['starwarsbattlefrontii']?.packs![profile] == null) {
      return [];
    }

    File file = File('$path\\ModData\\$profile\\patch\\mods.txt');
    if (!file.existsSync()) {
      return [];
    }

    String content = await file.readAsString();
    return content.split('\n').where((element) => element.contains(':') && element.contains("' '")).map((element) {
      String filename = element.split(':')[0];
      return ModService.getFrostyMod(filename);
    }).toList();
  }

  static List<FrostyProfile> getProfilesWithMods() {
    List<FrostyProfile> profiles = [];
    var config = FrostyService.getFrostyConfig();
    if (config.games['starwarsbattlefrontii'] == null) {
      return [];
    }

    config.games['starwarsbattlefrontii']?.packs?.forEach(
      (key, value) => profiles.add(
        FrostyProfile(
          name: key,
          mods: value.isNotEmpty ? value.split('|').map((element) => element.split(':')[0]).toList().map((e) => ModService.fromFilename(e)).toList() : [],
        ),
      ),
    );

    return profiles;
  }

  static List<String> getProfiles() {
    FrostyConfig config = FrostyService.getFrostyConfig();
    if (config.games['starwarsbattlefrontii'] == null) {
      return [];
    }

    return config.games['starwarsbattlefrontii']?.packs?.keys.toList() ?? [];
  }
}
