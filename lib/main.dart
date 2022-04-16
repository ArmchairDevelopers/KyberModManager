import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/rpc_service.dart';
import 'package:kyber_mod_manager/utils/translation/translate_preferences.dart';
import 'package:kyber_mod_manager/utils/translation/translation_delegate.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/navigation_bar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:system_info2/system_info2.dart';
import 'package:system_theme/system_theme.dart';

final bool _isNewWindows = SysInfo.operatingSystemName.contains('Windows 11');
Box box = Hive.box('data');
String applicationDocumentsDirectory = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    if (_isNewWindows) {
      await Window.initialize();
      await Window.setEffect(
        effect: WindowEffect.mica,
        dark: true,
      );
    }
    await SentryFlutter.init(
      (options) {
        options.autoSessionTrackingInterval = const Duration(minutes: 1);
        options.dsn = 'https://1d0ce9262dcb416e8404c51e396297e4@o1117951.ingest.sentry.io/6233409';
        options.tracesSampleRate = 1.0;
        options.release = "kyber-mod-manager@1.0.3";
      },
    );
    applicationDocumentsDirectory = (await getApplicationSupportDirectory()).path;
    CustomLogger.initialise();
    await SystemTheme.accentColor.load();
    await loadHive();
    var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en', 'de', 'pl', 'ru'],
      preferences: TranslatePreferences(),
    );
    runApp(LocalizedApp(delegate, const App()));
  }, (exception, stackTrace) async {
    Logger.root.severe('Uncaught exception: $exception\n$stackTrace');
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}

Future<void> loadHive() async {
  await Hive.initFlutter(applicationDocumentsDirectory);
  Hive.registerAdapter(ModProfileAdapter(), override: true);
  Hive.registerAdapter(ModAdapter(), override: true);
  box = await Hive.openBox('data').catchError((e) {
    Logger.root.severe('Error while opening box: $e');
    exit(1);
  });
  if (box.isEmpty) {
    box.put('cosmetics', []);
    box.put('discordRPC', true);
    box.put('saveProfiles', true);
    box.put('enableCosmetics', false);
  }
  if (!box.containsKey('discordRPC')) {
    box.put('discordRPC', true);
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    ModService.loadMods(context);
    ModService.watchDirectory();
    RPCService.initialize();
    FlutterError.onError = (details) {
      Logger.root.severe('Uncaught exception: ${details.exception}\n${details.stack}');
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };
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
        child = BlocProvider(create: (_) => WidgetCubit(), child: child);
        if (!_isNewWindows) {
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
