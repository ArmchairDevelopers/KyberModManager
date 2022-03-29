import 'dart:convert';
import 'dart:io';

import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:path_provider/path_provider.dart';

class FrostyService {
  static Future<bool> startFrosty() async {
    String path = box.get('frostyPath');
    var r = await Process.run(
      '$path/FrostyModManager.exe',
      ['-launch', 'KyberModManager'],
      workingDirectory: path,
      includeParentEnvironment: true,
    );
    return true;
  }

  static Future<FrostyConfig> getFrostyConfig() async {
    String? filePath = await getFrostyConfigPath();
    if (filePath == null) {
      return FrostyConfig.fromJson({});
    }
    File file = File(filePath);
    FrostyConfig config = FrostyConfig.fromJson(
      jsonDecode(await file.readAsString()),
    );
    return config;
  }

  static Future<void> saveFrostyConfig(FrostyConfig config) async {
    String? filePath = await getFrostyConfigPath();
    if (filePath == null) {
      return;
    }
    File file = File(filePath);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(config.toJson()));
  }

  static Future<String?> getFrostyConfigPath() async {
    if (box.containsKey('frostyConfigPath')) {
      return box.get('frostyConfigPath');
    }

    Directory tmp = await getTemporaryDirectory();

    File v5path = File('${tmp.path.replaceAll('Temp', 'Frosty')}\\manager_config.json');
    File v4path = File('${box.get('frostyPath')}\\config.json');

    if (await v5path.exists()) {
      return v5path.path;
    } else if (await v4path.exists()) {
      return v4path.path;
    }

    return null;
  }
}
