import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/cosmetic_mods/cosmetic_mods.dart';
import 'package:kyber_mod_manager/screens/feedback.dart' as feedback;
import 'package:kyber_mod_manager/screens/installed_mods.dart';
import 'package:kyber_mod_manager/screens/missing_permissions.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/mod_profiles.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_battlefront.dart';
import 'package:kyber_mod_manager/screens/saved_profiles.dart';
import 'package:kyber_mod_manager/screens/server_browser/server_browser.dart';
import 'package:kyber_mod_manager/screens/server_host/server_host.dart';
import 'package:kyber_mod_manager/screens/settings/settings.dart';
import 'package:kyber_mod_manager/screens/update_dialog/update_dialog.dart';
import 'package:kyber_mod_manager/screens/walk_through/walk_through.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/app_locale.dart';
import 'package:kyber_mod_manager/utils/auto_updater.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/mod_installer_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:window_manager/window_manager.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key, this.widget, this.index}) : super(key: key);
  final Widget? widget;
  final int? index;

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  final String prefix = 'navigation_bar';

  bool injectedDll = false;
  int index = 0;
  int fakeIndex = 0;

  Future<void> openDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const WalkThrough(),
    );
    if (!box.containsKey('setup')) {
      openDialog();
    }
  }

  @override
  void initState() {
    Jiffy.locale(AppLocale().getLocale().languageCode);
    Timer.run(() {
      try {
        ProfileService.generateFiles();
      } catch (e) {
        Navigator.of(context).pushAndRemoveUntil(FluentPageRoute(builder: (context) => MissingPermissions()), (route) => false);
        return;
      }
    });
    if (!box.containsKey('setup')) {
      Timer.run(() => openDialog());
    } else if (!box.containsKey('nexusmods_login')) {
      Timer.run(() => showDialog(context: context, builder: (context) => const NexusmodsLogin()));
    } else {
      ModInstallerService.initialise();
      DllInjector.checkForUpdates();
      AutoUpdater().updateAvailable().then((value) {
        if (value == null) {
          return;
        }
        showDialog(context: context, builder: (context) => UpdateDialog(versionInfo: value));
      });
    }
    checkKyberStatus(null);
    Timer.periodic(const Duration(seconds: 3), checkKyberStatus);
    super.initState();
  }

  void checkKyberStatus(Timer? timer) {
    if (!mounted) {
      timer?.cancel();
      return;
    }
    bool injected = DllInjector.isInjected();
    if (injected == injectedDll) {
      return;
    }
    setState(() => injectedDll = injected);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetCubit, dynamic>(listener: (context, state) {
      bool isFake = state.runtimeType != int && state.containsKey(state.keys.first);
      setState(() {
        index = !isFake ? state : 9;
        fakeIndex = !isFake ? state : state.keys.toList().first;
      });
    }, builder: (context, widget) {
      return NavigationView(
        appBar: NavigationAppBar(
          height: 30,
          title: () {
            return DragToMoveArea(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text('Kyber Mod Manager'),
              ),
            );
          }(),
          actions: SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [Spacer(), WindowButtons()],
            ),
          ),
        ),
        pane: NavigationPane(
          selected: fakeIndex,
          items: [
            // PaneItem(
            //   icon: const Icon(FluentIcons.power_shell),
            //   tileColor: ButtonState.resolveWith((states) {
            //     var theme = FluentTheme.of(context);
            //     if (injectedDll) {
            //       return theme.accentColor.lighter;
            //     } else if (states.isPressing) {
            //       return theme.accentColor.darker;
            //     } else if (states.isHovering) {
            //       return theme.accentColor.dark;
            //     }
            //     return theme.accentColor;
            //   }),
            //   title: Text(
            //     translate('$prefix.kyber.' + (injectedDll ? 'running' : 'not_running')),
            //   ),
            // ),
            // PaneItemSeparator(),
            PaneItemHeader(header: const Text('Kyber')),
            PaneItem(
              mouseCursor: MouseCursor.defer,
              icon: const Icon(FluentIcons.server),
              title: Text(translate('$prefix.items.server_browser')),
            ),
            PaneItem(
              mouseCursor: MouseCursor.defer,
              icon: const Icon(FluentIcons.package),
              title: Text(translate('$prefix.items.host')),
            ),
            PaneItemSeparator(),
            PaneItemHeader(header: Text(translate('mods'))),
            PaneItem(
              icon: const Icon(FluentIcons.list),
              title: Text(translate('$prefix.items.mod_profiles')),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.installation),
              title: const Text('Installed mods'),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.custom_list),
              title: Text(translate('$prefix.items.cosmetic_mods')),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.save_all),
              title: Text(translate('$prefix.items.saved_profiles')),
            ),
            PaneItemSeparator(),
            PaneItemHeader(header: const Text('Battlefront 2')),
            PaneItem(
              icon: const Icon(FluentIcons.processing_run),
              title: Text(translate('$prefix.items.run_bf2')),
            ),
          ],
          footerItems: [
            PaneItemSeparator(),
            PaneItem(
              icon: const Icon(FluentIcons.feedback),
              title: Text(translate('$prefix.items.feedback')),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(translate('$prefix.items.settings')),
            ),
          ],
          onChanged: (i) async {
            // if (i == 0) {
            //   if (injectedDll) {
            //     return;
            //   }
            //   var result = DllInjector.getBattlefrontPID();
            //   if (result == -1) {
            //     NotificationService.showNotification(message: translate('$prefix.battlefront_not_running'), color: Colors.red);
            //     return;
            //   }
            //   DllInjector.inject();
            //   return;
            // }
            setState(() {
              index = i;
              fakeIndex = i;
            });
          },
          displayMode: PaneDisplayMode.auto,
        ),
        content: NavigationBody(
          index: index,
          transitionBuilder: (child, animation) => EntrancePageTransition(
            child: child,
            animation: animation,
            startFrom: .02,
          ),
          children: [
            // const SizedBox(),
            const ServerBrowser(),
            const ServerHost(),
            const ModProfiles(),
            const InstalledMods(),
            const CosmeticMods(),
            const SavedProfiles(),
            const RunBattlefront(),
            const feedback.Feedback(),
            const Settings(),
            widget.runtimeType != int ? widget.values.first : const SizedBox(height: 0),
          ],
        ),
      );
    });
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
