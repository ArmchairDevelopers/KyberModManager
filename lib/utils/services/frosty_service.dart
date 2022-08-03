import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/errors/missing_permissions.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';
import 'package:version/version.dart';

class FrostyService {
  static Future<ProcessResult> startFrosty({bool launch = true, String? frostyPath, String? profile}) async {
    String path = frostyPath ?? box.get('frostyPath');
    var r = await Process.run(
      '$path/FrostyModManager.exe',
      launch ? ['-launch', profile ?? 'KyberModManager'] : [],
      workingDirectory: path,
      includeParentEnvironment: true,
      runInShell: true,
    ).catchError((error, stackTrace) {
      NotificationService.showNotification(message: error.toString(), color: Colors.red);
    });
    if (r.stderr.toString().isNotEmpty && !r.stderr.toString().contains('Qt')) {
      NavigatorService.pushErrorPage(const MissingPermissions());
    }

    return r;
  }

  static Future<bool> checkDirectory() async {
    if (!box.containsKey('frostyPath')) {
      return true;
    }

    Directory dir = Directory(box.get('frostyPath'));
    File file = File('${dir.path}\\FrostyModManager.exe');
    if (!dir.existsSync()) {
      return false;
    }

    return file.existsSync();
  }

  static Future<FrostyVersion> getFrostyVersion() async {
    List<FrostyVersion> hashes = await ApiService.versionHashes();
    var content = await File('${box.get('frostyPath')}\\FrostyModManager.exe').readAsBytes();
    var digest = sha256.convert(content.toList()).toString();
    return hashes.firstWhere((element) => element.hash == digest, orElse: () => const FrostyVersion(version: '', hash: ''));
  }

  static Future<bool> isOutdated() async {
    if (!box.containsKey('frostyPath')) {
      return false;
    }

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

    return Version.parse(version.version.replaceAll('v', '')) < Version.parse(await ApiService.getLatestFrostyVersion());
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
