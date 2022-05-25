import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

class UnzipHelper {
  static Future<void> unrar(File file, Directory to) async {
    String? exe = getExecutable();
    if (exe == null) {
      throw Exception('Not executable found');
    }
    if (exe.endsWith('7z.exe')) {
      await Process.run(exe, ['e', file.path, '-y'], workingDirectory: to.path);
    } else {
      await Process.run(exe, ['e', '-ibck', file.path, '*.*', to.path]);
    }
  }

  static String? getExecutable() {
    final key = Registry.openPath(RegistryHive.localMachine, path: r'SOFTWARE');
    if (key.subkeyNames.contains('WinRAR')) {
      return Registry.openPath(RegistryHive.localMachine, path: r'SOFTWARE\WinRAR').getValueAsString('exe64');
    } else if (key.subkeyNames.contains('7-Zip')) {
      return '${Registry.openPath(RegistryHive.localMachine, path: r'SOFTWARE\7-Zip').getValueAsString('Path64')!}\\7z.exe';
    }
    return null;
  }
}
