import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/errors/missing_permissions.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:logging/logging.dart';
import 'package:version/version.dart';
import 'package:window_manager/window_manager.dart';

class FrostyService {
  static FrostyConfig? _config;

  static Future<ProcessResult> startFrosty({bool launch = true, String? frostyPath, String? profile}) async {
    String path = frostyPath ?? box.get('frostyPath');
    File crashlogFile = File("$path/crashlog.txt");
    if (await crashlogFile.exists()) {
      await crashlogFile.delete();
    }

    var c = CancelableOperation.fromFuture(Process.run(
      '$path/FrostyModManager.exe',
      launch ? ['-launch', dynamicEnvEnabled ? (profile ?? 'KyberModManager') : 'KyberModManager'] : [],
      workingDirectory: path,
      includeParentEnvironment: true,
      runInShell: true,
    ).catchError((error, stackTrace) {
      NotificationService.showNotification(message: error.toString(), severity: InfoBarSeverity.error);
    }));

    var directoryChangeStream = Directory(path).watch(events: FileSystemEvent.create).listen((event) async {
      if (event.path.endsWith("crashlog.txt")) {
        await c.cancel();

        var pid = await DllInjector.getPid("frostymodmanager.exe");
        Process.killPid(pid);
        await WindowManager.instance.setAlwaysOnTop(true);
        await WindowManager.instance.focus();
        await WindowManager.instance.setAlwaysOnTop(false);

        print("Frosty crashed");
      }
    });

    if (c.isCanceled) {
      throw Exception("Frosty crashed");
    }

    var value = await c.value;
    directoryChangeStream.cancel();
    if (value.stderr.toString().isNotEmpty && !value.stderr.toString().contains('Qt')) {
      NavigatorService.pushErrorPage(const MissingPermissions());
    }

    return value;
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

    File file = File('${box.get('frostyPath')}\\FrostyModManager.exe');
    var content = await file.readAsBytes();
    if (content.isEmpty) {
      return false;
    }

    List<FrostyVersion> hashes = await ApiService.versionHashes();
    var digest = sha256.convert(content.toList()).toString();
    var version = hashes.firstWhere((element) => element.hash == digest, orElse: () => const FrostyVersion(version: '', hash: ''));
    if (version.version == '') {
      return false;
    }

    String correctedVersion = _parseFrostyVersion(version.version);

    String latestVersion = await ApiService.getLatestFrostyVersion();
    String correctedLatestVersion = _parseFrostyVersion(latestVersion);

    return Version.parse(correctedVersion) < Version.parse(correctedLatestVersion);
  }

  static String _parseFrostyVersion(String rawVersion) {
    if (rawVersion.toLowerCase().startsWith("v")) {
      rawVersion = rawVersion.substring(1);
    }

    late String formattedVersion;
    List<String> preRelease = [""];

    if (rawVersion.split(".").length - 1 == 2) {
      formattedVersion = rawVersion.contains("-") ? rawVersion.substring(0, rawVersion.lastIndexOf("-")) : rawVersion;
    } else {
      formattedVersion = rawVersion.substring(0, rawVersion.lastIndexOf(".")) + rawVersion.substring(rawVersion.lastIndexOf(".") + 1);
      if (formattedVersion.contains("-")) {
        formattedVersion = formattedVersion.substring(0, formattedVersion.lastIndexOf("-"));
      }
    }

    if (rawVersion.contains("-")) {
      String preReleaseString = rawVersion.substring(rawVersion.lastIndexOf("-") + 1);
      if (preReleaseString.toLowerCase().contains("alpha")) {
        preRelease.add("alpha");
      } else {
        preRelease.add("beta");
      }

      int preReleaseVersion = int.tryParse(preReleaseString.substring(preReleaseString.lastIndexOf(".") + 1)) ?? 0;
      preRelease.add((preReleaseVersion * (preReleaseString.toLowerCase().contains("alpha") ? 1 : 2)).toString());
    }

    return formattedVersion;
  }

  static FrostyConfig getFrostyConfig([String? path, bool force = false]) {
    String? filePath = path ?? getFrostyConfigPath();
    if (filePath == null) {
      return FrostyConfig.fromJson({'Games': [], 'GlobalOptions': Map<String, dynamic>.from({})});
    }

    if (_config != null && !force) {
      return _config!;
    }

    File file = File(filePath);
    FrostyConfig config = FrostyConfig.fromJson(
      jsonDecode(file.readAsStringSync()),
    );
    _config = config;
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
