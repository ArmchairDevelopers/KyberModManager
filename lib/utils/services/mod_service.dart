import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/utils/types/mod_info.dart';
import 'package:kyber_mod_manager/utils/types/pack_type.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sentry_flutter/sentry_flutter.dart';

class ModService {
  static final List<String> _kyberCategories = ['gameplay', 'server host'];
  static List<Mod> mods = [];
  static StreamSubscription? _subscription;

  static Future<void> createModPack({
    required PackType packType,
    required String profileName,
    bool cosmetics = false,
    required Function(int copied, int total) onProgress,
    required Function(String content) setContent,
  }) async {
    const String prefix = 'server_browser.join_dialog.joining_states';
    List<Mod> cosmeticMods = List<Mod>.from(box.get('cosmetics'));
    bool enableCosmetics = cosmetics && box.get('enableCosmetics');
    Logger.root.info('Loading mods for $profileName (cosmetics: $enableCosmetics | type: $packType)');

    if (packType == PackType.NO_MODS) {
      if (enableCosmetics) {
        await FrostyProfileService.createProfile(cosmeticMods.map((e) => e.toKyberString()).toList());
      } else {
        await FrostyProfileService.createProfile([]);
      }
    } else if (packType == PackType.MOD_PROFILE) {
      ModProfile profile = List<ModProfile>.from(box.get('profiles')).where((p) => p.name == profileName).first;
      List<Mod> mods = List.from(profile.mods);
      if (enableCosmetics) {
        mods = [...mods, ...cosmeticMods];
      }

      await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
      await ProfileService.searchProfile(mods.map((e) => e.toKyberString()).toList(), onProgress);
    } else if (packType == PackType.FROSTY_PACK) {
      var currentMods = await FrostyProfileService.getModsFromProfile('KyberModManager');
      List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(profileName);
      if (enableCosmetics) {
        mods = [...mods, ...cosmeticMods];
      }

      if (!listEquals(currentMods, mods)) {
        setContent(translate('$prefix.creating'));
        await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
        onProgress(0, 0);
        await FrostyProfileService.loadFrostyPack(profileName.replaceAll(' (Frosty Pack)', ''), onProgress);
      }
    } else if (packType == PackType.COSMETICS) {
      List<Mod> mods = List<Mod>.from(box.get('cosmetics'));
      await ProfileService.searchProfile(mods.map((e) => e.toKyberString()).toList(), onProgress);
      setContent(translate('$prefix.creating'));
      await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
    } else {
      return NotificationService.showNotification(message: translate('host_server.forms.mod_profile.no_profile_found'));
    }
  }

  static Future<List<Mod>> getModsFromModPack(String name) async {
    PackType packType = getPackType(name);
    if (packType == PackType.FROSTY_PACK || packType == PackType.MOD_PROFILE) {
      name = name.replaceAll(' ${packType.name}', '');
    }
    switch (packType) {
      case PackType.NO_MODS:
        return [];
      case PackType.MOD_PROFILE:
        return List<ModProfile>.from(box.get('profiles')).where((p) => p.name == name).first.mods;
      case PackType.FROSTY_PACK:
        return await FrostyProfileService.getModsFromConfigProfile(name);
      case PackType.COSMETICS:
        return List<Mod>.from(box.get('cosmetics'));
      default:
        return [];
    }
  }

  static Mod fromFilename(String filename) {
    for (Mod mod in mods) {
      if (mod.filename == filename) {
        return mod;
      }
    }
    return Mod.fromString('');
  }

  static void deleteMod(Mod mod) {
    Directory dir = Directory(p.join(box.get('frostyPath'), 'Mods', 'starwarsbattlefrontii'));
    File file = File(p.join(dir.path, mod.filename));
    if (file.existsSync()) {
      file.deleteSync();
    }
    mods.remove(mod);
  }

  static Mod convertToMod(String mod) {
    ModInfo info = convertToModInfo(mod);
    return mods.firstWhere((element) => element.name == info.name && element.version == info.version, orElse: () => Mod.fromString(mod));
  }

  static ModInfo convertToModInfo(String name) {
    String modName = name.substring(0, name.lastIndexOf(' ('));
    String version = name.substring(name.lastIndexOf('(') + 1, name.length - 1);
    return ModInfo(name: modName, version: version);
  }

  static bool isInstalled(String name) {
    String modName = name.substring(0, name.lastIndexOf(' ('));
    String version = name.substring(name.lastIndexOf('(') + 1, name.length - 1);
    return mods.any((mod) => mod.name == modName && mod.version == version);
  }

  static Map<String, List<Mod>> getModsByCategory([bool kyberCategories = false]) {
    Map<String, List<Mod>> categories = {};
    for (Mod mod in mods) {
      if (kyberCategories && !_kyberCategories.contains(mod.category.toLowerCase())) continue;
      if (categories.containsKey(mod.category)) {
        categories[mod.category]?.add(mod);
      } else {
        categories[mod.category] = [mod];
      }
    }
    return categories;
  }

  static void watchDirectory() {
    FrostyService.getFrostyConfigPath();
    if (!box.containsKey('frostyPath')) {
      return;
    }

    Directory dir = Directory(p.join(box.get('frostyPath'), 'Mods', 'starwarsbattlefrontii'));
    if (!dir.existsSync()) {
      return;
    }

    if (_subscription != null) {
      _subscription?.cancel();
    }

    DateTime cooldown = DateTime.now();
    Logger.root.info('Watching directory for changes');
    _subscription = dir.watch(events: FileSystemEvent.all).listen((event) {
      cooldown = DateTime.now();
      Future.delayed(const Duration(seconds: 2), () {
        if (DateTime.now().difference(cooldown).inSeconds != 2) {
          return;
        }
        loadMods();
      });
    });
  }

  static Future<List> loadMods([BuildContext? context]) async {
    FrostyService.getFrostyConfigPath();
    if (!box.containsKey('frostyPath')) {
      return [];
    }

    Directory dir = Directory(p.join(box.get('frostyPath'), 'Mods', 'starwarsbattlefrontii'));
    if (!dir.existsSync()) {
      box.delete('frostyPath');
      box.delete('setup');
      return [];
    }

    final List<FileSystemEntity> entities = await dir.list().toList();
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
      _loadMods,
      [
        entities.map((e) => e.path),
        receivePort.sendPort,
      ],
      paused: true,
    );
    isolate.addOnExitListener(receivePort.sendPort);
    isolate.resume(isolate.pauseCapability!);
    List<dynamic>? list = await receivePort.first;
    if (context != null) {
      NotificationService.showNotification(message: translate('mods_loaded', args: {'count': list?.length.toString() ?? 0}));
    }
    if (list == null) {
      return mods = [];
    }
    return mods = List<Mod>.from(list);
  }

  static Future<Mod> getDataFromFile(File file) async {
    List<int> data = [];
    await file.openRead(0, 1500).toList().then((value) => value.forEach((element) => element.forEach((element1) => data.add(element1))));
    return Mod.fromString(
      file.path,
      utf8.decode(
        data.getRange(50, data.length).toList(),
        allowMalformed: true,
      ),
    );
  }

  static _loadMods(List<dynamic> data) async {
    List<Mod> loadedMods = [];
    await Future.forEach(List<String>.from(data[0]).where((element) => element.endsWith('.fbmod')), (String element) async {
      try {
        File file = File(element);
        if (!file.existsSync()) {
          return;
        }
        List<int> data = [];
        await file.openRead(0, 1500).toList().then((value) => value.forEach((element) => element.forEach((element1) => data.add(element1))));
        loadedMods.add(Mod.fromString(
          element,
          utf8.decode(
            data.getRange(50, data.length).toList(),
            allowMalformed: true,
          ),
        ));
      } catch (e) {
        Sentry.captureException(e);
        Logger.root.info('Error loading mod: $e');
      }
    });
    Isolate.exit(data[1], loadedMods);
  }
}
