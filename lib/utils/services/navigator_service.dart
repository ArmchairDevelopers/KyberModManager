import 'package:fluent_ui/fluent_ui.dart';

class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void pushErrorPage(Widget widget) {
    navigatorKey.currentState!.push(FluentPageRoute(builder: (context) => widget));
  }
}
