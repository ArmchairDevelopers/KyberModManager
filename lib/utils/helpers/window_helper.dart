import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  static const Size _minimumSize = Size(900, 600);
  static const Size _size = Size(1400, 700);
  static WindowBrightness _windowBrightness = WindowBrightness.system;

  static Stream<WindowBrightness> get windowBrightnessStream => _streamController!.stream;
  static StreamController<WindowBrightness>? _streamController;
  static WindowBrightness get windowBrightness => _windowBrightness;
  static void set windowBrightness(WindowBrightness value) {
    _windowBrightness = value;
    _streamController?.add(value);
  }

  static Future<void> changeWindowEffect(bool enabled) async {
    if (enabled) {
      await Window.setEffect(effect: WindowEffect.mica, dark: true);
      await windowManager.setBackgroundColor(Colors.transparent);
    } else {
      await Window.setEffect(effect: WindowEffect.disabled, dark: true);
      await windowManager.setBackgroundColor(FluentThemeData.dark().navigationPaneTheme.backgroundColor!);
    }
  }

  static Future<void> changeEffect(bool dark) async {
    await windowManager.setBackgroundColor(Colors.transparent);

    if (micaSupported) {
      await Window.setEffect(effect: WindowEffect.mica, dark: dark);
    }
  }

  static Future<void> initializeWindow() async {
    Logger.root.info('Initializing window');
    _windowBrightness = WindowBrightness.values[box.get('brightness', defaultValue: 2)];
    _streamController = StreamController.broadcast();
    await Window.initialize();

    if (!micaSupported) {
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
        await windowManager.setSize(_size);
        await windowManager.setMinimumSize(_minimumSize);
        await windowManager.center();
        await windowManager.show();
        await windowManager.setSkipTaskbar(false);
      });
    } else {
      windowManager.waitUntilReadyToShow().then((_) async {
        bool enabled = !box.containsKey('micaEnabled') || box.get('micaEnabled');
        await windowManager.setTitleBarStyle(TitleBarStyle.normal, windowButtonVisibility: false);
        await windowManager.setSize(_size);
        await windowManager.setMinimumSize(_minimumSize);
        await windowManager.center();
        await windowManager.show();
        await windowManager.setBackgroundColor(enabled ? Colors.transparent : (windowBrightness.isDark ? FluentThemeData.dark() : FluentThemeData.light()).navigationPaneTheme.backgroundColor!);

        if (enabled) {
          await Window.setEffect(effect: WindowEffect.mica, dark: _windowBrightness.isDark);
        }
      });
    }
  }
}

enum WindowBrightness {
  light,
  dark,
  system,
}

extension WindowBrightnessExtension on WindowBrightness {
  bool get isDark {
    switch (this) {
      case WindowBrightness.light:
        return false;
      case WindowBrightness.dark:
        return true;
      case WindowBrightness.system:
        return SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
    }
  }
}