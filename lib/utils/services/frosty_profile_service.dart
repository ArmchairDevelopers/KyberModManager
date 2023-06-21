import 'dart:convert';
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
      FrostyConfig config = FrostyService.getFrostyConfig();
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
      NotificationService.showNotification(message: e.toString(), severity: InfoBarSeverity.error);
      Logger.root.severe(e.toString());
    }
  }

  static bool checkConfig(String path) {
    FrostyConfig config = FrostyService.getFrostyConfig(path);
    if (config.games['starwarsbattlefrontii'] == null) {
      return false;
    }

    return true;
  }

  static Future<void> loadBattlefront(String configPath) async {
    FrostyConfig config = FrostyService.getFrostyConfig(configPath);
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
    FrostyConfig config = FrostyConfig.fromJson(
      {'Games': {}, 'GlobalOptions': Map<String, dynamic>.from({})},
    );
    config.globalOptions.defaultProfile = 'starwarsbattlefrontii';
    config.globalOptions.useDefaultProfile = true;
    config.games['starwarsbattlefrontii'] = _battlefront;
    await FrostyService.saveFrostyConfig(config, file.path);
  }

  static loadFrostyPack(String name, [Function? onProgress]) async {
    Logger.root.info('Loading Frosty pack: $name');
    String bf2path = OriginHelper.getBattlefrontPath();
    List<dynamic> mods = FrostyProfileService.getModsFromConfigProfile(name);
    await FrostyProfileService.createProfile(
      List<String>.from(mods.map((e) => e.toKyberString()).toList()),
    );
    Directory d = Directory('$bf2path\\ModData\\$name');
    if (d.existsSync()) {
      var appliedMods = await getModsFromProfile('KyberModManager');
      if (listEquals(mods, appliedMods)) {
        Logger.root.info('Profile $name already loaded');
        return;
      }

      Logger.root.info('Copying profile data for $name');
      await ProfileService.copyProfileData(d, Directory('$bf2path\\ModData\\KyberModManager'), onProgress, true);
    }
  }

  static List<dynamic> getModsFromConfigProfile(String profile) {
    FrostyConfig config = FrostyService.getFrostyConfig();
    if (config.games['starwarsbattlefrontii']?.packs?[profile] == null) {
      return [];
    }
    List<String> modList = config.games['starwarsbattlefrontii']!.packs![profile]!.split('|').map((e) => e.split(':')[0]).toList();
    return modList.map((e) => ModService.fromFilename(e)).toList();
  }

  static Future<void> convertModsFile(String profile) async {
    String path = OriginHelper.getBattlefrontPath();
    File oldFile = File('$path\\ModData\\$profile\\patch\\mods.txt');
    File file = File('$path\\ModData\\$profile\\patch\\mods.json');
    if (oldFile.existsSync() && !file.existsSync()) {
      Logger.root.info("Converting old mods.txt to mods.json");
      var mods = oldFile.readAsStringSync().split('\n').where((element) => element.contains(':') && element.contains("' '")).map((element) {
        String filename = element.split(':')[0];
        return ModService.getFrostyMod(filename);
      }).toList();
      await file.writeAsString(jsonEncode(
        mods.map(
          (e) => ({'name': e.name, 'version': e.version, 'category': e.category, 'file_name': e.filename}),
        ),
      ));
    }
  }

  static Future<List<dynamic>> getModsFromProfile(String profile, {bool isPath = false}) async {
    FrostyConfig config = FrostyService.getFrostyConfig();
    String path = OriginHelper.getBattlefrontPath();
    if (!isPath && config.games['starwarsbattlefrontii']?.packs![profile] == null) {
      return [];
    }

    String basePath = !isPath ? '$path\\ModData\\$profile' : profile;
    File oldFile = File('$basePath\\patch\\mods.txt');
    File file = File('$basePath\\patch\\mods.json');

    if (oldFile.existsSync() && !file.existsSync()) {
      Logger.root.info("Converting old mods.txt to mods.json");
      var mods = oldFile.readAsStringSync().split('\n').where((element) => element.contains(':') && element.contains("' '")).map((element) {
        String filename = element.split(':')[0];
        return ModService.getFrostyMod(filename);
      }).toList();
      await file.writeAsString(jsonEncode(
        mods.map(
          (e) => ({'name': e.name, 'version': e.version, 'category': e.category, 'file_name': e.filename}),
        ),
      ));
      return mods;
    } else if (oldFile.existsSync() || !file.existsSync()) {
      return [];
    }

    String content = await file.readAsString();
    List<dynamic> mods = await jsonDecode(content);

    return mods.map((e) => ModService.getFrostyMod(e['file_name'])).toList();
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
          mods: value.isNotEmpty ? value.split('|').map((element) => element.split(':')[0]).toList().map((e) => ModService.getFrostyMod(e)).toList() : [],
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
