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

        style: InfoBarThemeData.standard(FluentTheme.of(context).copyWith(resources: ResourceDictionary.dark(systemFillColorAttentionBackground: FluentTheme.of(context).resources.solidBackgroundFillColorBase))),
        severity: severity ?? InfoBarSeverity.info,
      );
    });
  }
}
