import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  static const Size _minimumSize = Size(900, 600);
  static const Size _size = Size(1400, 700);

  static Future<void> changeWindowEffect(bool enabled) async {
    if (enabled) {
      await Window.setEffect(effect: WindowEffect.mica, dark: true);
      await windowManager.setBackgroundColor(Colors.transparent);
    } else {
      await Window.setEffect(effect: WindowEffect.disabled, dark: true);
      await windowManager.setBackgroundColor(FluentThemeData.dark().navigationPaneTheme.backgroundColor!);
    }
  }

  static Future<void> initializeWindow() async {
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
        await windowManager.setBackgroundColor(enabled ? Colors.transparent : FluentThemeData.dark().navigationPaneTheme.backgroundColor!);

        if (enabled) {
          await Window.setEffect(effect: WindowEffect.mica, dark: true);
        }
      });
    }
  }
}
