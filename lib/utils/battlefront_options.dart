import 'dart:io';

import 'package:path_provider/path_provider.dart';

class BattlefrontOptions {
  static Future<BattlefrontProfileOptions?> getOptions() async {
    String config = await BattlefrontOptions._getConfig();

    if (config.isEmpty) {
      return null;
    }

    return BattlefrontProfileOptions(
      enableDx12: config.contains('GstRender.EnableDx12 1'),
      fullscreenEnabled: config.contains('GstRender.FullscreenEnabled 1'),
    );
  }

  static Future<bool> crashed() async {
    Directory docs = await getApplicationDocumentsDirectory();
    if (!Directory('${docs.path}\\STAR WARS Battlefront II\\CrashDumps').existsSync()) {
      return false;
    }

    List<File> files = Directory('${docs.path}\\STAR WARS Battlefront II\\CrashDumps').listSync().whereType<File>().toList();
    if (files.isEmpty) {
      return false;
    }

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    File lastCrash = files.first;
    if (lastCrash.lastModifiedSync().difference(DateTime.now()).inMinutes < 2) {
      return false;
    }

    return true;
  }

  static Future<void> setConfig() async {
    String config = await _getConfig();
    String configPath = await _getConfigPath();
    var values = [
      ['GstRender.EnableDx12 1', 'GstRender.EnableDx12 0'],
      ['GstRender.FullscreenEnabled 1', 'GstRender.FullscreenEnabled 0'],
      ['GstRender.FullscreenMode 0', 'GstRender.FullscreenMode 1'],
      ['GstRender.FullscreenMode 0', 'GstRender.FullscreenMode 1'],
    ];
    values.forEach((value) => config.replaceAll(value[0], value[1]));
    await File(configPath).writeAsString(config);
  }

  static Future<String> _getConfig() async {
    String configPath = await _getConfigPath();
    return File(configPath).readAsString();
  }

  static Future<String> _getConfigPath() async {
    Directory docs = await getApplicationDocumentsDirectory();
    if (!Directory('${docs.path}/STAR WARS Battlefront II').existsSync()) {
      return '';
    }

    return '${docs.path}\\STAR WARS Battlefront II\\settings\\ProfileOptions_profile';
  }
}

class BattlefrontProfileOptions {
  bool enableDx12;
  bool fullscreenEnabled;

  BattlefrontProfileOptions({required this.enableDx12, required this.fullscreenEnabled});
}
