import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';

class FrostyService {
  static Future<ProcessResult> startFrosty({bool launch = true, String? frostyPath}) async {
    String path = frostyPath ?? box.get('frostyPath');
    var r = await Process.run(
      '$path/FrostyModManager.exe',
      launch ? ['-launch', 'KyberModManager'] : [],
      workingDirectory: path,
      includeParentEnvironment: true,
      runInShell: true,
    ).catchError((error, stackTrace) {
      NotificationService.showNotification(message: error.toString(), color: Colors.red);
    });

    return r;
  }

  static FrostyConfig getFrostyConfig([String? path]) {
    String? filePath = path ?? getFrostyConfigPath();
    if (filePath == null) {
      return FrostyConfig.fromJson({'Games': [], 'GlobalOptions': Map<String, dynamic>.from({})});
    }
    File file = File(filePath);
    FrostyConfig config = FrostyConfig.fromJson(
      jsonDecode(file.readAsStringSync()),
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

  static String? getFrostyConfigPath() {
    if (box.containsKey('frostyConfigPath')) {
      return box.get('frostyConfigPath');
    }

    File v5path = File('${Platform.environment['LOCALAPPDATA']}\\Frosty\\manager_config.json');
    File v4path = File('${box.get('frostyPath')}\\config.json');
    Logger.root.info('Checking for Frosty configs at "${v5path.path}" and "${v4path.path}"');

    if (v5path.existsSync()) {
      return v5path.path;
    } else if (v4path.existsSync()) {
      return v4path.path;
    }

    Logger.root.severe('No Frosty config found');

    return null;
  }
}
