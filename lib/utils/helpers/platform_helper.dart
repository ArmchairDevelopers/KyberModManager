import 'package:kyber_mod_manager/utils/helpers/system_tasks.dart';
import 'package:logging/logging.dart';
import 'package:process_run/process_run.dart';
import 'package:win32_registry/win32_registry.dart';

class PlatformHelper {
  static final Map<String, dynamic> _paths = {
    'origin': {
      'path': r'SOFTWARE\WOW6432Node\Origin',
      'dir': 'OriginPath',
      'exe': 'Origin.exe',
    },
    'ea desktop': {
      'path': r'SOFTWARE\WOW6432Node\Electronic Arts\EA Desktop',
      'dir': 'ClientPath',
      'exe': 'EADesktop.exe',
    },
    'epic games': {
      'path': r'SOFTWARE\WOW6432Node\EpicGames\Unreal Engine',
      'dir': 'INSTALLDIR',
      'exe': 'Launcher\\Portal\\Binaries\\Win32\\EpicGamesLauncher.exe',
    },
  };

  static Future<void> restartPlatform(String platform, String? profile) async {
    dynamic platformData = _paths[platform]!;
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
    runExecutableArguments(dir.contains('.exe') ? dir : '$dir\\$exe', [], environment: {
      'GAME_DATA_DIR': profile ?? '',
    });
    await Future.delayed(const Duration(seconds: 3));
  }
}
