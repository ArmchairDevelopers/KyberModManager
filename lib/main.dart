import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/logic/event_cubic.dart';
import 'package:kyber_mod_manager/logic/frosty_cubic.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/screens/cosmetic_mods/cosmetic_mods.dart';
import 'package:kyber_mod_manager/screens/discord_events/discord_events.dart';
import 'package:kyber_mod_manager/screens/feedback.dart' as fb;
import 'package:kyber_mod_manager/screens/installed_mods.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/map_rotation_creator.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/edit_profile.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/mod_profiles.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_battlefront.dart';
import 'package:kyber_mod_manager/screens/saved_profiles.dart';
import 'package:kyber_mod_manager/screens/server_browser/server_browser.dart';
import 'package:kyber_mod_manager/screens/server_host/server_host.dart';
import 'package:kyber_mod_manager/screens/settings/settings.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/storage_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/window_helper.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/translation/translate_preferences.dart';
import 'package:kyber_mod_manager/utils/translation/translation_delegate.dart';
import 'package:kyber_mod_manager/widgets/navigation_bar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

final bool micaSupported = SysInfo.operatingSystemName.contains('Windows 11');
final supportedLocales = ['en', 'de', 'pl', 'ru'];
const String protocol = "kmm";
bool dynamicEnvEnabled = true;
Box box = Hive.box('data');
String applicationDocumentsDirectory = '';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    var started = DateTime.now();
    await SentryFlutter.init(
      (options) {
        options.autoSessionTrackingInterval = const Duration(minutes: 1);
        options.dsn = 'https://1d0ce9262dcb416e8404c51e396297e4@o1117951.ingest.sentry.io/6233409';
        options.tracesSampleRate = 1.0;
        options.attachThreads = true;
        options.release = "kyber-mod-manager@1.0.11";
      },
    );
    applicationDocumentsDirectory = (await getApplicationSupportDirectory()).path;
    CustomLogger.initialize();
    await StorageHelper.initializeHive();
    await WindowHelper.initializeWindow();
    await SystemTheme.accentColor.load();
    await protocolHandler.register(protocol);
    var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: supportedLocales,
      preferences: TranslatePreferences(),
    );
    runApp(LocalizedApp(delegate, const App()));
    Logger.root.info('Started in ${DateTime.now().difference(started).inMilliseconds}ms');
  }, (exception, stackTrace) async {
    Logger.root.severe('$exception\n$stackTrace');
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    Timer.run(() async {
      ModService.watchDirectory();
      PuppeteerHelper.checkFiles();
      await ModService.loadMods(context);
      if (box.containsKey('setup')) {
        ProfileService.migrateSavedProfiles();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    final localizationDelegate = LocalizedApp.of(context).delegate;

    return FluentApp.router(
      title: 'Kyber Mod Manager',
      color: SystemTheme.accentColor.accent.toAccentColor(),
      theme: ThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        cardColor: micaSupported ? Colors.white.withOpacity(.025) : null,
        brightness: Brightness.dark,
      ),
      localizationsDelegates: [
        TranslationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      builder: (context, child) {
        child = MultiBlocProvider(
          providers: [
            BlocProvider<WidgetCubit>(
              create: (BuildContext context) => WidgetCubit(),
            ),
            BlocProvider<GameStatusCubic>(
              create: (BuildContext context) => GameStatusCubic(),
            ),
            BlocProvider<EventCubic>(
              create: (BuildContext context) => EventCubic(),
            ),
            BlocProvider<FrostyCubic>(
              create: (BuildContext context) => FrostyCubic(),
            ),
          ],
          child: child ?? const SizedBox(height: 0),
        );

        if (!micaSupported) {
          return botToastBuilder(context, child);
        }

        return Directionality(
          textDirection: TextDirection.ltr,
          child: NavigationPaneTheme(
            data: const NavigationPaneThemeData(
              backgroundColor: Colors.transparent,
            ),
            child: botToastBuilder(context, child),
          ),
        );
      },
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

final shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  observers: [
    SentryNavigatorObserver(),
  ],
  navigatorKey: navigatorKey,
  initialLocation: "/server_browser",
  errorBuilder: (context, state) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Page Not Found',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(state.error?.toString() ?? 'page not found'),
            const SizedBox(height: 16),
            Button(
              onPressed: () => context.go('/'),
              child: const Text(
                'Go to home page',
              ),
            ),
          ],
        ),
      ),
    );
  },
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return NavigationBar(
          shellContext: shellNavigatorKey.currentContext,
          state: state,
          child: child,
        );
      },
      observers: [
        SentryNavigatorObserver(),
      ],
      routes: [
        GoRoute(path: "/", redirect: (context, state) => "/server_browser"),
        GoRoute(
          path: '/server_browser',
          name: 'server_browser',
          builder: (context, state) => const ServerBrowser(),
        ),
        GoRoute(
          path: '/server_host',
          name: 'server_host',
          builder: (context, state) => const ServerHost(),
        ),
        GoRoute(
          path: '/events',
          name: 'events',
          builder: (context, state) => const DiscordEvents(),
        ),
        GoRoute(
          path: '/map_rotation_creator',
          name: 'map_rotation_creator',
          builder: (context, state) => const MapRotationCreator(),
        ),
        GoRoute(
          path: '/mod_profiles',
          name: 'mod_profiles',
          builder: (context, state) => const ModProfiles(),
          routes: [
            GoRoute(
              parentNavigatorKey: shellNavigatorKey,
              path: 'profile',
              name: 'profile',
              builder: (context, state) => EditProfile(
                profile: state.queryParameters['profile'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/saved_profiles',
          name: 'saved_profiles',
          builder: (context, state) => const SavedProfiles(),
        ),
        GoRoute(
          path: '/cosmetic_mods',
          name: 'cosmetic_mods',
          builder: (context, state) => const CosmeticMods(),
        ),
        GoRoute(
          path: '/installed_mods',
          name: 'installed_mods',
          builder: (context, state) => const InstalledMods(),
        ),
        GoRoute(
          path: '/run_bf2',
          name: 'run_bf2',
          builder: (context, state) => const RunBattlefront(),
        ),
        GoRoute(
          path: '/feedback',
          name: 'feedback',
          builder: (context, state) => const fb.Feedback(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const Settings(),
        ),
      ],
    ),
  ],
);
