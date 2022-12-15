import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/cosmetic_mods/cosmetic_mods.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/join_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/outdated_frosty_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/update_dialog/update_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/walk_through.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/screens/feedback.dart' as feedback;
import 'package:kyber_mod_manager/screens/installed_mods.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/mod_profiles.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_battlefront.dart';
import 'package:kyber_mod_manager/screens/saved_profiles.dart';
import 'package:kyber_mod_manager/screens/server_browser/server_browser.dart';
import 'package:kyber_mod_manager/screens/server_host/server_host.dart';
import 'package:kyber_mod_manager/screens/settings/settings.dart';
import 'package:kyber_mod_manager/utils/app_locale.dart';
import 'package:kyber_mod_manager/utils/auto_updater.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/window_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_installer_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/services/rpc_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:logging/logging.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key, this.widget, this.index}) : super(key: key);
  final Widget? widget;
  final int? index;

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> with ProtocolListener {
  final String prefix = 'navigation_bar';

  bool injectedDll = false;
  int index = 0;
  int fakeIndex = 0;

  @override
  void initState() {
    protocolHandler.addListener(this);
    Jiffy.locale(supportedLocales.contains(AppLocale().getLocale().languageCode) ? AppLocale().getLocale().languageCode : 'en');
    Timer.run(() async {
      ProfileService.generateFiles();
      if (!box.containsKey('setup')) {
        await openDialog();
      } else if (!box.containsKey('nexusmods_login')) {
        await showDialog(context: context, builder: (_) => const NexusmodsLogin());
      }

      ModInstallerService.initialize();
      DllInjector.downloadDll();
      RPCService.initialize();
      Timer.periodic(const Duration(milliseconds: 500), checkKyberStatus);

      bool exists = await FrostyService.checkDirectory();
      if (!exists) {
        await box.delete('setup');
        NotificationService.showNotification(message: 'FrostyModManager not found!', color: Colors.red);
        await openDialog();
      }

      VersionInfo? versionInfo = await AutoUpdater().updateAvailable();
      if (versionInfo != null) {
        await showDialog(context: context, builder: (_) => UpdateDialog(versionInfo: versionInfo));
      }

      bool outdatedFrosty = await FrostyService.isOutdated();
      if (outdatedFrosty) {
        if (box.get('skipFrostyVersionCheck', defaultValue: false)) {
          await Future.delayed(const Duration(seconds: 2));
          return NotificationService.showNotification(message: 'Your FrostyModManager is outdated!', color: Colors.orange);
        }
        await showDialog(context: context, builder: (context) => OutdatedFrostyDialog());
      } else {
        if (box.get('skipFrostyVersionCheck', defaultValue: false)) {
          box.put('skipFrostyVersionCheck', false);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    super.dispose();
  }

  @override
  void onProtocolUrlReceived(String url) async {
    if (!box.containsKey("setup") || !mounted) {
      Logger.root.severe("Received protocol url but setup is not complete");
      return;
    }

    if (url.startsWith("kmm://join_server")) {
      String? serverId = url.split("?").last;
      if (serverId.isEmpty) {
        Logger.root.severe("Received protocol url but server_id is null");
        return;
      }

      if (index != 0) {
        setState(() => index = 0);
      }
      KyberServer? server = await KyberApiService.getServer(serverId);
      if (server == null) {
        NotificationService.showNotification(message: "Server not found", color: Colors.red);
        Logger.root.severe("Received protocol url but server is null");
        return;
      }

      showDialog(
        context: context,
        builder: (context) => ServerDialog(
          server: server,
          join: true,
        ),
      );
    }
  }

  Future<void> openDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const WalkThrough(),
    );
    if (!box.containsKey('setup')) {
      return openDialog();
    }
  }

  void checkKyberStatus(Timer? timer) => box.containsKey('setup') && mounted ? BlocProvider.of<GameStatusCubic>(context).check() : timer?.cancel();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetCubit, dynamic>(listener: (context, state) {
      bool isFake = state.runtimeType != int && state.containsKey(state.keys.first);
      setState(() {
        index = !isFake ? state : 9;
        fakeIndex = !isFake ? state : state.keys.toList().first;
      });
    }, builder: (context, widget) {
      return RawKeyboardListener(
        autofocus: true,
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent && event.isAltPressed && event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyC && micaSupported) {
            if (!box.containsKey('micaEnabled') || box.get('micaEnabled')) {
              box.put('micaEnabled', false);
              WindowHelper.changeWindowEffect(false);
            } else {
              box.put('micaEnabled', true);
              WindowHelper.changeWindowEffect(true);
            }
          }
        },
        focusNode: FocusNode(),
        child: NavigationView(
          appBar: NavigationAppBar(
            leading: const SizedBox(),
            height: micaSupported ? 0 : 30,
            title: !micaSupported
                ? () {
                    return DragToMoveArea(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('Kyber Mod Manager'),
                      ),
                    );
                  }()
                : null,
            actions: !micaSupported
                ? SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [Spacer(), WindowButtons()],
                    ),
                  )
                : null,
          ),
          pane: NavigationPane(
            header: !micaSupported
                ? null
                : const SizedBox(
                    height: 0,
                  ),
            selected: fakeIndex,
            items: [
              PaneItemHeader(header: const Text('Kyber')),
              PaneItem(
                mouseCursor: MouseCursor.defer,
                body: const ServerBrowser(),
                icon: const Icon(FluentIcons.server),
                title: Text(translate('$prefix.items.server_browser')),
              ),
              PaneItem(
                mouseCursor: MouseCursor.defer,
                body: const ServerHost(),
                icon: const Icon(FluentIcons.package),
                title: Text(translate('$prefix.items.host')),
              ),
              PaneItemSeparator(),
              PaneItemHeader(header: Text(translate('navigation_bar.items.mod_profiles'))),
              PaneItem(
                icon: const Icon(FluentIcons.list),
                body: const ModProfiles(),
                title: Text(translate('$prefix.items.mod_profiles')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.save_all),
                body: const SavedProfiles(),
                title: Text(translate('$prefix.items.saved_profiles')),
              ),
              PaneItemSeparator(),
              PaneItemHeader(header: Text(translate('mods'))),
              PaneItem(
                icon: const Icon(FluentIcons.custom_list),
                body: const CosmeticMods(),
                title: Text(translate('$prefix.items.cosmetic_mods')),
              ),
              // PaneItem(
              //   icon: const Icon(FluentIcons.view_dashboard),
              //   title: const Text('Mod Browser'),
              // ),
              PaneItem(
                icon: const Icon(FluentIcons.installation),
                body: const InstalledMods(),
                title: Text(translate('$prefix.items.installed_mods')),
              ),
              PaneItemSeparator(),
              PaneItemHeader(header: const Text('Battlefront 2')),
              PaneItem(
                icon: const Icon(FluentIcons.processing_run),
                body: const RunBattlefront(),
                title: Text(translate('$prefix.items.run_bf2')),
              ),
            ],
            footerItems: [
              PaneItemSeparator(),
              // PaneItem(
              //   icon: const Icon(FluentIcons.linked_database),
              //   title: const Text('Statistics'),
              // ),
              // PaneItem(
              //   icon: const Icon(FluentIcons.help),
              //   title: const Text('Troubleshooting'),
              // ),
              PaneItem(
                icon: const Icon(FluentIcons.feedback),
                body: const feedback.Feedback(),
                title: Text(translate('$prefix.items.feedback')),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.settings),
                body: const Settings(),
                title: Text(translate('$prefix.items.settings')),
              ),
            ],
            onChanged: (i) async {
              setState(() {
                index = i;
                fakeIndex = i;
              });
            },
            displayMode: PaneDisplayMode.auto,
          ),
          transitionBuilder: (child, animation) => EntrancePageTransition(
            animation: animation,
            startFrom: .015,
            child: child,
          ),
          paneBodyBuilder: (selectedPaneItemBody) {
            return DropTarget(
              onDragDone: (details) {
                ModInstallerService.handleDrop(details.files.map((e) => e.path).toList());
              },
              // TODO: fix animation for sub-pages
              child: fakeIndex != index ? widget.values.first : selectedPaneItemBody,
            );
          },
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
