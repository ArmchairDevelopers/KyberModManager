import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';

class NotificationService {
  static void showNotification({required String message, Color? color, int duration = 3}) {
    BotToast.showCustomNotification(
      duration: Duration(seconds: duration),
      toastBuilder: (cancelFunc) {
        return Container(
          margin: const EdgeInsets.all(8).copyWith(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color ?? SystemTheme.accentColor.accent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            message,
            style: TextStyle(color: color?.basedOnLuminance()),
          ),
        );
      },
    );
  }
}
