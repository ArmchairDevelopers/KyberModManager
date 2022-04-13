import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/screens/feedback.dart' as feedback;
import 'package:kyber_mod_manager/screens/mod_profiles/mod_profiles.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_battlefront.dart';
import 'package:kyber_mod_manager/screens/saved_profiles.dart';
import 'package:kyber_mod_manager/screens/server_browser/server_browser.dart';
import 'package:kyber_mod_manager/screens/server_host/server_host.dart';
import 'package:kyber_mod_manager/screens/settings/settings.dart';

final routes = {
  '/server-browser': (context) => const ServerBrowser(),
  '/host-server': (context) => const ServerHost(),
  '/mod-profiles': (context) => const ModProfiles(),
  '/saved-profiles': (context) => const SavedProfiles(),
  '/run-battlefront': (context) => const RunBattlefront(),
  '/feedback': (context) => const feedback.Feedback(),
  '/settings': (context) => const Settings(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final route = routes[settings.name];
  if (route != null) {
    return FluentPageRoute(builder: (context) => route(settings.arguments));
  }
  return FluentPageRoute(builder: (context) => const Text('error'));
}
