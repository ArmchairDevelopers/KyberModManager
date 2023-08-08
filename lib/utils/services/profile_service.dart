import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dynamic_env/dynamic_env.dart';
import 'package:flutter/foundation.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/errors/missing_permissions.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:kyber_mod_manager/utils/types/saved_profile.dart';
import 'package:logging/logging.dart';
import 'package:system_info2/system_info2.dart';
import 'package:uuid/uuid.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ProfileService {
  static final File _profileFile = File('${OriginHelper.getBattlefrontPath()}\\ModData\\SavedProfiles\\profiles.json');

  static Future<String?> searchProfile(List<String> mods, [Function? onProgress, bool search = false]) async {
    if (!box.get('saveProfiles', defaultValue: true)) {
      return null;
    }

    String battlefrontPath = OriginHelper.getBattlefrontPath();
    FrostyConfig config = FrostyService.getFrostyConfig();
    Directory dir = Directory('$battlefrontPath\\ModData\\KyberModManager');
    List<dynamic> convertedMods = mods.map((mod) => ModService.convertToFrostyMod(mod)).toList();
    List<dynamic> current = await FrostyProfileService.getModsFromProfile('KyberModManager');

    if (listEquals(current, convertedMods)) {
      Logger.root.info('Profile is already up to date');
      return null;
    }

    List<SavedProfile> profiles = getSavedProfiles();
    if (profiles.where((element) => equalModlist(element.mods, convertedMods)).isEmpty) {
      await enableProfile(getProfilePath('KyberModManager'));
      if (current.isEmpty || profiles.where((element) => equalModlist(element.mods, current)).isNotEmpty) {
        return null;
      }
      await _saveProfile(dir, current, onProgress);
      return null;
    }

    if (current.isNotEmpty && profiles.where((element) => equalModlist(current, element.mods)).isEmpty) {
      await _saveProfile(dir, current, onProgress);
    }

    if (search) {
      return null;
    }

    SavedProfile profile = profiles.firstWhere((element) => equalModlist(element.mods, convertedMods));
    profile.lastUsed = DateTime.now();
    _editProfile(profile);
    if (dynamicEnvEnabled) {
      enableProfile(profile.path);
    } else {
      await copyProfileData(Directory(profile.path), dir, onProgress, true);
    }

    if (!dynamicEnvEnabled) {
      config.games['starwarsbattlefrontii']?.packs?['KyberModManager'] =
          profile.mods.where((element) => element.filename.isNotEmpty).map((element) => '${element.filename}:True').join('|');
      await FrostyService.saveFrostyConfig(config);

      File file = File('${dir.path}\\patch\\mods.txt');
      if (file.existsSync()) {
        String content = await file.readAsString();
        String newContent = '';
        content.split('\n').where((element) => element.contains(':') && element.contains("' '")).map((element) {
          String filename = element.split(':')[0];
          String line = element.trim().replaceAll(RegExp(r'(\n){3,}'), "");
          var mod = ModService.getFrostyMod(filename);
          if (line.endsWith("'${mod.category}'")) {
            newContent += "$line ''\n";
          } else {
            newContent += '$line\n';
          }
        }).toList();
        if (newContent != content) {
          await file.writeAsString(newContent);
        }
        await FrostyProfileService.convertModsFile("KyberModManager");
      }
    }

    Logger.root.info('Found profile ${profile.id}');
    return profile.path;
  }

  static String getProfilePath(String name, {bool isSavedProfile = false}) {
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    return '$battlefrontPath\\ModData\\${isSavedProfile ? 'SavedProfiles\\$name' : name}';
  }

  static Future<void> enableProfile(String path) async {
    if (dynamicEnvEnabled) {
      await DynamicEnv().setEnv(pid, "GAME_DATA_DIR", path);
      return;
    }

    await PlatformHelper.activateProfile(path, isPath: true);

    if (PlatformHelper.isInstalled(Platform.EA_Desktop) && !await PlatformHelper.isPlatformRunning(Platform.Origin)) {
      if (!(await PlatformHelper.isPlatformRunning(Platform.EA_Desktop))) {
        await PlatformHelper.restartPlatform('EA Desktop');
      }

      int pid = await DllInjector.getPid(PlatformHelper.platforms[Platform.EA_Desktop]['exe'].toString().toLowerCase());
      await DynamicEnv().setEnv(pid, 'GAME_DATA_DIR', path);
      return;
    } else {
      if (!(await PlatformHelper.isPlatformRunning(Platform.Origin))) {
        await PlatformHelper.restartPlatform('origin');
      }

      int pid = await DllInjector.getPid(PlatformHelper.platforms[Platform.Origin]['exe'].toString().toLowerCase());
      await DynamicEnv().setEnv(pid, 'GAME_DATA_DIR', path);
    }
  }

  static bool equalModlist(List<dynamic> a, List<dynamic> b) {
    return listEquals(List<String>.from(a.map((e) => e.toKyberString())), List<String>.from(b.map((e) => e.toKyberString())));
  }

  static containsMod(List<Mod> mods, Mod mod) => mods.where((element) => element.filename == mod.filename).isNotEmpty;

  static Future<void> _saveProfile(Directory dir, List<dynamic> mods, [Function? onProgress]) async {
    String id = const Uuid().v4();
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    String profilePath = '$battlefrontPath\\ModData\\SavedProfiles\\$id';
    await copyProfileData(dir, Directory(profilePath), onProgress);
    int size = await getProfileSize(id);
    SavedProfile savedProfile = SavedProfile(id: id, path: profilePath, mods: mods, size: size);
    saveProfile(savedProfile);
    Logger.root.info('Saved profile ${savedProfile.id}');
  }

  static Future<void> deleteProfile(String id) async {
    List<SavedProfile> profiles = getSavedProfiles();
    SavedProfile profile = profiles.firstWhere((element) => element.id == id);
    Directory dir = Directory(profile.path);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    profiles = profiles.where((element) => element.id != id).toList();
    _saveProfiles(profiles);
  }

  static void generateFiles() {
    try {
      String path = OriginHelper.getBattlefrontPath();
      if (path.isEmpty) {
        return;
      }

      if (!_profileFile.existsSync()) {
        _profileFile.createSync(recursive: true);
        _profileFile.writeAsStringSync('[]');
      }
    } catch (e) {
      NavigatorService.pushErrorPage(const MissingPermissions());
    }
  }

  static Future<int> getProfileSize(String name) async {
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    int size = 0;
    Directory dir = Directory('$battlefrontPath\\ModData\\SavedProfiles\\$name');
    if (!dir.existsSync()) {
      return 0;
    }
    dir.listSync(recursive: true).forEach((element) async {
      if (element is File) {
        size += element.lengthSync();
      }
    });
    return size;
  }

  static Future<void> copyProfileData(Directory from, Directory to, [Function? onProgress, bool symlink = false]) async {
    List<File> files = await _getAllFiles(from);
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);

    if (to.path.contains('ModData\\KyberModManager') && files.where((element) => element.path.endsWith('layout.toc')).isNotEmpty) {
      File file = files.firstWhere((element) => element.path.endsWith('layout.toc'));
      File backupFile = File(file.path.replaceAll('layout.toc', 'layout_backup.toc'));
      if (!backupFile.existsSync()) {
        await file.copy(backupFile.path);
      } else {
        files.removeWhere((element) => element.path.endsWith('layout_backup.toc'));
        await backupFile.copy(file.path);
      }
    }

    if (symlink) {
      for (File file in files) {
        if (onProgress != null) {
          onProgress(files.indexOf(file), files.length - 1);
        }
        WindowsTaskbar.setProgress(files.indexOf(file), files.length - 1);
        String dirPath = '${to.path}/${file.parent.path.substring(from.path.length)}';
        Directory dir = Directory(dirPath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        String path = '${to.path}${file.path.substring(from.path.length)}';
        if (File(path).existsSync()) {
          if (await FileSystemEntity.isLink(path)) {
            await Link(path).delete();
          } else {
            await File(path).delete();
          }
        }

        try {
          await Link(path).create(file.path, recursive: true);
        } catch (e) {
          await copyProfileData(from, to, onProgress, false);
          break;
        }
      }
    } else {
      DateTime started = DateTime.now();
      ReceivePort receivePort = ReceivePort();

      int totalSize = files.fold(0, (a, b) => a + b.lengthSync());
      int maxChunkSize = totalSize ~/ SysInfo.cores.length;

      List<List<File>> chunks = [[]];
      files.forEach((file) {
        if (chunks.isEmpty || (chunks.last.fold(0, (dynamic a, dynamic b) => a + b.lengthSync())) < maxChunkSize) {
          chunks.last.add(file);
        } else {
          chunks.add([file]);
        }
      });

      StreamSubscription? subscription;
      if (onProgress != null) {
        int i = 0;
        subscription = receivePort.listen((message) {
          i++;
          onProgress(i, files.length);
        });
      }

      await Future.wait(chunks.map((e) async {
        Map map = {
          'chunk': List<File>.from(e),
          'files': files,
          'from': from,
          'to': to,
          'sendPort': receivePort.sendPort,
        };

        await compute(ProfileService.moveFiles, map);
      }));
      subscription?.cancel();
      DateTime ended = DateTime.now();
      Logger.root.info('Copying profile data took ${ended.difference(started).inMilliseconds}ms');
    }
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }

  static Future<void> moveFiles(Map map) async {
    dynamic files = map['files'];
    dynamic from = map['from'];
    dynamic to = map['to'];
    await Future.wait(List<File>.from(map['chunk']).map((file) async {
      String dirPath = '${to.path}/${file.parent.path.substring(from.path.length)}';
      Directory dir = Directory(dirPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      String path = '${to.path}${file.path.substring(from.path.length)}';
      await file.copy(path);

      (map['sendPort'] as SendPort).send([files.indexOf(file), files.length - 1]);
    }));
  }

  static bool _isSymlink(String path) {
    return File(path).resolveSymbolicLinksSync() != path;
  }

  static Future<List<File>> _getAllFiles(Directory dir) async {
    List<FileSystemEntity> files = await dir.list(recursive: true).toList();
    return List<File>.from(files.where((element) => element is File && !_isSymlink(element.path)).toList());
  }

  static void _saveProfiles(List<SavedProfile> profiles) {
    if (!_profileFile.existsSync()) {
      _profileFile.createSync();
      _profileFile.writeAsStringSync('[]');
    }
    const encoder = JsonEncoder.withIndent('  ');
    _profileFile.writeAsStringSync(encoder.convert(profiles.map((e) => e.toJson()).toList()));
  }

  static void _editProfile(SavedProfile profile) {
    const encoder = JsonEncoder.withIndent('  ');
    List<dynamic> profiles = jsonDecode(_profileFile.readAsStringSync());
    profiles.removeWhere((element) => element['id'] == profile.id);
    profiles.add(profile.toJson());
    _profileFile.writeAsStringSync(encoder.convert(profiles));
  }

  static void saveProfile(SavedProfile profile) {
    if (!_profileFile.existsSync()) {
      _profileFile.createSync();
      _profileFile.writeAsStringSync('[]');
    }
    const encoder = JsonEncoder.withIndent('  ');
    List<SavedProfile> profiles = getSavedProfiles()..add(profile);
    _profileFile.writeAsStringSync(encoder.convert(profiles.map((e) => e.toJson()).toList()));
  }

  static Future<List<SavedProfile>> getSavedProfilesAsync() async {
    if (!await _profileFile.exists()) {
      await _profileFile.create();
      _profileFile.writeAsStringSync('[]');
      return [];
    }
    List<SavedProfile> profiles =
        await _profileFile.readAsString().then((value) => List<SavedProfile>.from(jsonDecode(value).map((element) => SavedProfile.fromJson(element)).toList()));
    List<SavedProfile> profilesToRemove = profiles.where((element) => !Directory(element.path).existsSync()).toList();
    profiles.removeWhere((element) => !Directory(element.path).existsSync());
    for (SavedProfile profile in profilesToRemove) {
      deleteProfile(profile.id);
    }
    return profiles;
  }

  static List<SavedProfile> getSavedProfiles() {
    if (!_profileFile.existsSync()) {
      _profileFile.createSync(recursive: true);
      _profileFile.writeAsStringSync('[]');
      return [];
    }
    return List<SavedProfile>.from(jsonDecode(_profileFile.readAsStringSync()).map((element) => SavedProfile.fromJson(element)).toList());
  }

  static void migrateSavedProfiles() {
    if (box.containsKey('savedProfilesMigrated')) {
      return;
    }

    var profiles = getSavedProfiles();
    if (profiles.every((element) => element.mods[0].author != null)) {
      Logger.root.info('Saved profiles already migrated');
      return;
    }

    profiles = profiles.map((e) {
      e.mods = e.mods.map((e) => ModService.fromFilename(e.filename)).toList();
      return e;
    }).toList();
    box.put('savedProfilesMigrated', true);
    _saveProfiles(profiles);
  }
}
