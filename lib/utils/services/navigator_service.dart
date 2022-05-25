import 'package:fluent_ui/fluent_ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigatorService {
  static Future<void> pushErrorPage(Widget widget) {
    return navigatorKey.currentState!.push(FluentPageRoute(builder: (context) => widget));
  }
}
