import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class FrostyService {
  static Future<bool> startFrosty({bool launch = true, String? frostyPath}) async {
    String path = frostyPath ?? box.get('frostyPath');
    await Process.run(
      '$path/FrostyModManager.exe',
      launch ? ['-launch', 'KyberModManager'] : [],
      workingDirectory: path,
      includeParentEnvironment: true,
    ).catchError((error, stackTrace) {
      NotificationService.showNotification(message: error.toString(), color: Colors.red);
    });
    return true;
  }

  static Future<FrostyConfig> getFrostyConfig() async {
    String? filePath = await getFrostyConfigPath();
    if (filePath == null) {
      return FrostyConfig.fromJson({'Games': [], 'GlobalOptions': Map<String, dynamic>.from({})});
    }
    File file = File(filePath);
    FrostyConfig config = FrostyConfig.fromJson(
      jsonDecode(await file.readAsString()),
    );
    return config;
  }

  static Future<void> saveFrostyConfig(FrostyConfig config, [String? path]) async {
    String? filePath = path ?? await getFrostyConfigPath();
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
    Logger.root.info('Checking for Frosty configs at "${v5path.path}" and "${v4path.path}"');

    if (await v5path.exists()) {
      return v5path.path;
    } else if (await v4path.exists()) {
      return v4path.path;
    }

    Logger.root.severe('No Frosty config found');

    return null;
  }
}
