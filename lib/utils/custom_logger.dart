import 'dart:io';

import 'package:intl/intl.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:logging/logging.dart';

class CustomLogger {
  static late File _logFile;

  static void initialise() {
    _logFile = File('$applicationDocumentsDirectory/log.txt');
    _createLogFile();
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(
      (record) {
        String message = '${DateFormat('HH:mm:ss').format(DateTime.now())} ${record.level.name}: ${record.message}';
        _logToFile(message);
        print(message);
      },
    );
  }

  static String getLogs() {
    return _logFile.readAsStringSync();
  }

  static void _logToFile(String message) {
    _logFile.writeAsStringSync('$message\n', mode: FileMode.append);
  }

  static void _createLogFile() {
    if (!_logFile.existsSync()) {
      _logFile.createSync();
    }
  }
}
