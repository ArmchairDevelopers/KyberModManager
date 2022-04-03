import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/translation/translate_preferences.dart';
import 'package:kyber_mod_manager/utils/translation/translation_delegate.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/navigation_bar.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:system_theme/system_theme.dart';

Box box = Hive.box('data');
String applicationDocumentsDirectory = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(
    (record) => print('${DateFormat('HH:mm:ss').format(DateTime.now())} ${record.level.name}: ${record.message}'),
  );
  runZonedGuarded(() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://1d0ce9262dcb416e8404c51e396297e4@o1117951.ingest.sentry.io/6233409';
        options.tracesSampleRate = 1.0;
      },
    );
    applicationDocumentsDirectory = (await getApplicationSupportDirectory()).path;
    await SystemTheme.accentInstance.load();
    await loadHive();
    ProfileService.generateFiles();
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
    box.put('saveProfiles', true);
    box.put('enableCosmetics', false);
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Brightness brightness = box.get('brightness', defaultValue: false) ? Brightness.dark : Brightness.light;

  @override
  void initState() {
    ModService.loadMods(context);
    ModService.watchDirectory();
    SystemTheme.darkMode.then((value) {
      setState(() => brightness = value ? Brightness.dark : Brightness.light);
      box.put('brightness', value);
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
      theme: ThemeData(
        accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
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
        return botToastBuilder(context, child);
      },
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      home: const NavigationBar(),
    );
  }
}
