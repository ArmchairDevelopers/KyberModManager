import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/storage_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/window_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/translation/translate_preferences.dart';
import 'package:kyber_mod_manager/utils/translation/translation_delegate.dart';
import 'package:kyber_mod_manager/widgets/navigation_bar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

final bool micaSupported = SysInfo.operatingSystemName.contains('Windows 11');
final supportedLocales = ['en', 'de', 'pl', 'ru'];
Box box = Hive.box('data');
String applicationDocumentsDirectory = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runZonedGuarded(() async {
    var started = DateTime.now();
    await SentryFlutter.init(
      (options) {
        options.autoSessionTrackingInterval = const Duration(minutes: 1);
        options.dsn = 'https://1d0ce9262dcb416e8404c51e396297e4@o1117951.ingest.sentry.io/6233409';
        options.tracesSampleRate = 1.0;
        options.release = "kyber-mod-manager@1.0.7";
      },
    );
    applicationDocumentsDirectory = (await getApplicationSupportDirectory()).path;
    CustomLogger.initialise();
    await StorageHelper.initialiseHive();
    await WindowHelper.initialiseWindow();
    await SystemTheme.accentColor.load();
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
    Timer.run(() {
      ModService.watchDirectory();
      PuppeteerHelper.checkFiles();
      ModService.loadMods(context).then((value) {
        if (box.containsKey('setup')) {
          ProfileService.migrateSavedProfiles();
        }
      });
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
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return FluentApp(
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
      navigatorKey: navigatorKey,
      builder: (context, child) {
        child = MultiBlocProvider(
          providers: [
            BlocProvider<WidgetCubit>(
              create: (BuildContext context) => WidgetCubit(),
            ),
            BlocProvider<GameStatusCubic>(
              create: (BuildContext context) => GameStatusCubic(),
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
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      home: const NavigationBar(),
    );
  }
}
