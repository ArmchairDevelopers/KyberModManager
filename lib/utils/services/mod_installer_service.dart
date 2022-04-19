import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/unzip_helper.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:logging/logging.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ModInstallerService {
  static final _allowedExtensions = ['zip', 'rar', '7z', 'fbmod'];
  static late Directory _installDir;
  static late StreamSubscription<List<String>> _subscription;

  static void initialise() {
    if (!box.containsKey('frostyPath')) {
      return;
    }

    _installDir = Directory(box.get('frostyPath') + '\\Mods\\starwarsbattlefrontii\\');
    _subscription = dropEventStream.listen(_handleDrop);
  }

  static void dispose() {
    _subscription.cancel();
  }

  static void _handleDrop(List<String> paths) async {
    await Future.forEach(paths.where((path) => _allowedExtensions.contains(path.split('.').last)), (String path) async {
      String extension = path.split('.').last;
      File file = File(path);

      if (extension == 'fbmod') {
        String basename = file.path.split('\\').last;
        await File(_installDir.path + '\\' + basename).writeAsBytes(file.readAsBytesSync());
        Logger.root.info('Installed mod: $basename');
        NotificationService.showNotification(message: 'Installed mod: $basename');
      } else if (extension == 'zip') {
        final inputStream = InputFileStream(file.path);
        final archive = ZipDecoder().decodeBuffer(inputStream, verify: false);

        WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
        for (var file in archive.files) {
          WindowsTaskbar.setProgress(archive.files.indexOf(file), archive.files.length - 1);
          final outputStream = OutputFileStream(_installDir.path + file.name);
          file.writeContent(outputStream);
          outputStream.close();
        }
        await archive.clear();
        Logger.root.info('Installed mod: ${file.path.split('\\').last}');
        NotificationService.showNotification(message: 'Installed mod: ${file.path.split('\\').last}');
      } else {
        await UnzipHelper.unrar(file, _installDir).catchError((error) {
          NotificationService.showNotification(message: error.toString(), color: Colors.red);
          Logger.root.severe('Could not unrar ${file.path}. $error');
        });
        Logger.root.info('Installed mod: ${file.path.split('\\').last}');
        NotificationService.showNotification(message: 'Installed mod: ${file.path.split('\\').last}');
      }
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    });
  }
}
