import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';

class NotificationService {
  static void showNotification({String? title, required String message, InfoBarSeverity? severity}) {
    displayInfoBar(shellNavigatorKey.currentContext!, builder: (context, close) {
      return InfoBar(
        title: Text(title ?? message),
        content: title == null ? null : Text(message),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
        style: InfoBarThemeData(
          decoration: (severity) {
            if (severity == InfoBarSeverity.info) return const BoxDecoration(color: Color(0xFF202020));
            return null;
          },
        ),
        severity: severity ?? InfoBarSeverity.info,
      );
    });
  }
}
