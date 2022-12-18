import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/system_tasks.dart';
import 'package:logging/logging.dart';
import 'package:process_run/process_run.dart';
import 'package:win32_registry/win32_registry.dart';

class PlatformHelper {
  static final Map<Platform, dynamic> platforms = {
    Platform.Origin: {
      'path': r'SOFTWARE\WOW6432Node\Origin',
      'dir': 'OriginPath',
      'exe': 'Origin.exe',
    },
    Platform.EA_Desktop: {
      'path': r'SOFTWARE\WOW6432Node\Electronic Arts\EA Desktop',
      'dir': 'ClientPath',
      'exe': 'EADesktop.exe',
    },
    Platform.Epic_Games: {
      'path': r'SOFTWARE\WOW6432Node\EpicGames\Unreal Engine',
      'dir': 'INSTALLDIR',
      'exe': 'Launcher\\Portal\\Binaries\\Win32\\EpicGamesLauncher.exe',
    },
  };

  static void startBattlefront() {
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    String dataDir = '$battlefrontPath\\ModData\\KyberModData';
    runExecutableArguments('$battlefrontPath\\starwarsbattlefrontii.exe', ['-datapath "$dataDir"']);
  }

  static bool isInstalled(Platform platform) {
    try {
      final key = Registry.openPath(RegistryHive.localMachine, path: platforms[platform]['path']).close();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPlatformRunning(Platform platform) async {
    List<Task> tasks = await SystemTasks.tasks();
    return tasks.where((task) => task.pname.toLowerCase().contains(platforms[platform]['exe'].toString().split('\\').last.toLowerCase())).toList().isNotEmpty;
  }

  static Future<void> restartPlatform(String platform, [String? profile]) async {
    dynamic platformData = platforms[_platformFromString(platform)]!;
    final key = Registry.openPath(RegistryHive.localMachine, path: platformData['path']);
    List<Task> tasks = await SystemTasks.tasks();
    List<Task> oTasks = tasks.where((task) => task.pname.toLowerCase().contains(platformData['exe'].toString().split('\\').last.toLowerCase())).toList();
    Logger.root.info('Found ${oTasks.length} processes');
    for (var task in oTasks) {
      Logger.root.info('Killing ${task.pname}');
      await task.killLikes();
    }
    Logger.root.info('Starting platform...');
    String dir = key.getValueAsString(platformData['dir'])!;
    String? exe = platformData['exe'];
    runExecutableArguments(
      dir.contains('.exe') ? dir : '$dir\\$exe',
      [],
      environment: {
        'GAME_DATA_DIR': profile ?? '',
      },
      runInShell: true,
    );
    key.close();
    await Future.delayed(const Duration(seconds: 3));
  }

  static bool isProfileActive() {
    final key = Registry.openPath(RegistryHive.currentUser, path: 'Environment');
    String? value = key.getValueAsString('GAME_DATA_DIR');
    key.close();
    return value != null && value.endsWith('KyberModManager');
  }

  static String getProfile() {
    final key = Registry.openPath(RegistryHive.currentUser, path: 'Environment');
    String? value = key.getValueAsString('GAME_DATA_DIR');
    key.close();
    return value ?? '';
  }

  static Future<String> activateProfile(String profile, {bool previous = false, bool isPath = false}) async {
    final key = Registry.openPath(RegistryHive.currentUser, path: 'Environment', desiredAccessRights: AccessRights.allAccess);
    String battlefrontPath = OriginHelper.getBattlefrontPath();
    String profilePath = '$battlefrontPath\\ModData\\$profile';
    RegistryValue path = RegistryValue(
      'GAME_DATA_DIR',
      RegistryValueType.string,
      previous || isPath ? profile : '$battlefrontPath\\ModData\\$profile',
    );
    Logger.root.info('Activating profile $profile');
    if (key.getValue('GAME_DATA_DIR') != null && !previous) {
      await box.put('previousProfile', key.getValueAsString('GAME_DATA_DIR'));
      Logger.root.info('Saved previous profile (${key.getValueAsString('GAME_DATA_DIR')})');
    }
    if (profile.isNotEmpty) {
      key.createValue(path);
    } else {
      key.deleteValue('GAME_DATA_DIR');
    }
    key.close();
    return previous ? profile : profilePath;
  }

  static Platform _platformFromString(String platform) {
    return Platform.values.firstWhere((p) => p.toString().split('.').last.toLowerCase() == platform.toLowerCase().replaceAll(' ', '_'));
  }
}

enum Platform {
  Origin,
  EA_Desktop,
  Epic_Games,
}
