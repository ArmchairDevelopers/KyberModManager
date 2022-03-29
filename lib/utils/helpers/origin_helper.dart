import 'package:logging/logging.dart';
import 'package:win32_registry/win32_registry.dart';

class OriginHelper {
  static String getBattlefrontPath() {
    try {
      final ea = Registry.openPath(RegistryHive.localMachine, path: r'SOFTWARE\EA Games\STAR WARS Battlefront II');
      String path = ea.getValueAsString('Install Dir') ?? '';
      return path.substring(0, path.length - 1);
    } catch (e) {
      Logger.root.severe('Could not find Battlefront path');
      return '';
    }
  }
}
