import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/mod_info.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

class ModService {
  static final List<String> _kyberCategories = ['gameplay', 'server host'];
  static List<Mod> mods = [];

  static Mod fromFilename(String filename) {
    for (Mod mod in mods) {
      if (mod.filename == filename) {
        return mod;
      }
    }
    return Mod.fromString('');
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

    DateTime cooldown = DateTime.now();
    Logger.root.info('Watching directory for changes');
    dir.watch(events: FileSystemEvent.all).listen((event) {
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
      NotificationService.showNotification(message: translate('mods_loaded', args: {'count': list!.length.toString()}));
    }
    if (list == null) {
      return mods = [];
    }
    return mods = List<Mod>.from(list);
  }

  static _loadMods(List<dynamic> data) async {
    List<Mod> loadedMods = [];
    await Future.forEach(List<String>.from(data[0]).where((element) => element.endsWith('.fbmod')), (String element) async {
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
    });
    Isolate.exit(data[1], loadedMods);
  }
}
