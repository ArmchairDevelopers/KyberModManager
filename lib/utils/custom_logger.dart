import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CustomLogger {
  static late File _logFile;

  static void initialize() {
    _logFile = File('$applicationDocumentsDirectory/log.txt');
    _createLogFile();
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(
      (record) {
        String message = '[${DateTime.now().toString().split('.').first}] ${record.level.name}: ${record.message}';
        _logToFile(message);
        print(message);
      },
    );
    FlutterError.onError = (details) {
      Logger.root.severe('Uncaught exception: ${details.exception}\n${details.stack}');
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };
  }

  static String getLogs() {
    return _logFile.readAsStringSync();
  }

  static void _logToFile(String message) {
    _logFile.writeAsString('$message\n', mode: FileMode.append);
  }

  static void _createLogFile() {
    if (!_logFile.existsSync()) {
      _logFile.createSync();
    }
  }
}
