import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';
import 'package:version/version.dart';

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

  static Future<FrostyVersion> getFrostyVersion() async {
    List<FrostyVersion> hashes = await ApiService.versionHashes();
    var content = await File('${box.get('frostyPath')}\\FrostyModManager.exe').readAsBytes();
    var digest = sha256.convert(content.toList()).toString();
    return hashes.firstWhere((element) => element.hash == digest, orElse: () => const FrostyVersion(version: '', hash: ''));
  }

  static Future<bool> isOutdated() async {
    List<FrostyVersion> hashes = await ApiService.versionHashes();
    File file = File('${box.get('frostyPath')}\\FrostyModManager.exe');
    var content = await file.readAsBytes();
    if (content.isEmpty) {
      return false;
    }

    var digest = sha256.convert(content.toList()).toString();
    var version = hashes.firstWhere((element) => element.hash == digest, orElse: () => const FrostyVersion(version: '', hash: ''));
    if (version.version == '') {
      return false;
    }

    return true;

    return Version.parse(version.version.replaceAll('v', '')) == Version.parse('1.0.6-beta4');
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
    String? filePath = path ?? getFrostyConfigPath();
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
