import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/event_cubic.dart';
import 'package:kyber_mod_manager/logic/frosty_cubic.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/logic/status_cubit.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/join_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/outdated_frosty_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/update_dialog/update_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/walk_through.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/widgets/nexusmods_login.dart';
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
  const NavigationBar({
    Key? key,
    required this.child,
    required this.shellContext,
    required this.state,
  }) : super(key: key);

  final Widget child;
  final BuildContext? shellContext;
  final GoRouterState state;

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> with ProtocolListener {
  final String prefix = 'navigation_bar';

  bool injectedDll = false;
  int index = -1;

  late List<NavigationPaneItem> originalItems;
  late List<NavigationPaneItem> bottomListItems;

  @override
  void initState() {
    loadPages();
    protocolHandler.addListener(this);
    Jiffy.setLocale(supportedLocales.contains(AppLocale().getLocale().languageCode) ? AppLocale().getLocale().languageCode : 'en');
    ProfileService.generateFiles();
    Timer.run(() async {
      ProfileService.generateFiles();
      if (!box.containsKey('setup')) {
        await openDialog();
      } else if (!box.containsKey('nexusmods_login')) {
        await showDialog(context: context, builder: (_) => const NexusmodsLogin());
      }

      if (await KyberApiService.hasMissingMapPictures()) {
        await KyberApiService.downloadRequiredMapPictures();
      }

      ModInstallerService.initialize();
      DllInjector.downloadDll();
      RPCService.initialize();
      await checkFrostyInstallation();
      checkForUpdates();
      Timer.periodic(const Duration(milliseconds: 250), checkKyberStatus);

      router.addListener(routerListener);
    });
    super.initState();
  }

  void routerListener() async {
    if (router.location.split("/").length > 2) {
      setState(() {
        index = 1;
      });
      await Future.delayed(const Duration(milliseconds: 1));
      setState(() {
        index = -1;
      });
    }
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    router.removeListener(routerListener);
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

      router.goNamed("server_browser");
      KyberServer? server = await KyberApiService.getServer(serverId);
      if (server == null) {
        NotificationService.showNotification(message: "Server not found", severity: InfoBarSeverity.error);
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

  int _calculateSelectedIndex() {
    if (index != -1) {
      return index;
    }

    var location = router.location;
    if (location.contains("?")) {
      location = location.split("?").first;
    }

    if (location.split("/").length > 2) {
      location = location.split("/").getRange(0, location.split("/").length - 1).join("/");
    }

    if (router.location.startsWith("/mod_profiles/profile")) {
      return 3;
    }

    int indexOriginal = originalItems.where((element) => element.key != null).toList().indexWhere((element) => element.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = bottomListItems.where((element) => element.key != null).toList().indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems.where((element) => element.key != null).toList().length + indexFooter;
    } else {
      return indexOriginal;
    }
  }

  void checkForUpdates() async {
    VersionInfo? versionInfo = await AutoUpdater().updateAvailable();
    if (versionInfo != null) {
      await showDialog(context: context, builder: (_) => UpdateDialog(versionInfo: versionInfo));
    }

    bool outdatedFrosty = await BlocProvider.of<FrostyCubic>(context).checkForUpdates();
    if (outdatedFrosty) {
      if (box.get('skipFrostyVersionCheck', defaultValue: false)) {
        await Future.delayed(const Duration(seconds: 2));
        return NotificationService.showNotification(message: 'Your FrostyModManager is outdated!', severity: InfoBarSeverity.warning);
      }
      await showDialog(context: context, builder: (context) => OutdatedFrostyDialog());
    } else {
      if (box.get('skipFrostyVersionCheck', defaultValue: false)) {
        box.put('skipFrostyVersionCheck', false);
      }
    }
  }

  Future<void> checkFrostyInstallation() async {
    bool exists = await FrostyService.checkDirectory();
    if (!exists) {
      await box.delete('setup');
      NotificationService.showNotification(message: 'FrostyModManager not found!', severity: InfoBarSeverity.error);
      await openDialog();
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
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }

    return BlocListener<StatusCubit, ApplicationStatus>(
      listener: (_, state) {
        if (state.initialized) {
          return;
        }

        openDialog().then((value) => BlocProvider.of<StatusCubit>(context).setInitialized(true));
      },
      child: RawKeyboardListener(
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
        child: DropTarget(
          onDragDone: (details) {
            ModInstallerService.handleDrop(details.files.map((e) => e.path).toList());
          },
          child: NavigationView(
            key: const Key('navigation_view'),
            appBar: NavigationAppBar(
              leading: const SizedBox.shrink(),
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
                  ? const SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Spacer(), WindowButtons()],
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
              selected: _calculateSelectedIndex(),
              items: originalItems,
              footerItems: bottomListItems,
              displayMode: PaneDisplayMode.auto,
            ),
            transitionBuilder: (child, animation) => EntrancePageTransition(
              animation: animation,
              startFrom: .015,
              child: child,
            ),
            paneBodyBuilder: (item, child) {
              final name = item?.key is ValueKey ? (item!.key as ValueKey).value : null;
              return FocusTraversalGroup(
                key: ValueKey('body$name'),
                child: widget.child,
              );
            },
          ),
        ),
      ),
    );
  }

  void _goto(String path) {
    if (router.location != "/$path") {
      router.goNamed(path);
    }
  }

  void loadPages() {
    originalItems = [
      PaneItemHeader(header: const Text('Kyber')),
      PaneItem(
        key: const ValueKey('/server_browser'),
        mouseCursor: MouseCursor.defer,
        body: const SizedBox.shrink(),
        icon: const Icon(FluentIcons.server),
        title: Text(translate('$prefix.items.server_browser')),
        onTap: () => _goto('server_browser'),
      ),
      PaneItem(
        key: const ValueKey('/server_host'),
        mouseCursor: MouseCursor.defer,
        body: const SizedBox.shrink(),
        icon: const Icon(FluentIcons.package),
        title: Text(translate('$prefix.items.host')),
        onTap: () => _goto('server_host'),
      ),
      PaneItem(
        key: const ValueKey('/events'),
        mouseCursor: MouseCursor.defer,
        body: const SizedBox.shrink(),
        infoBadge: BlocBuilder<EventCubic, EventCubicState>(
          bloc: BlocProvider.of<EventCubic>(context),
          builder: (context, state) {
            if (state.events.isEmpty) {
              return const SizedBox();
            }

            return InfoBadge(
              source: Text(state.events.length.toString()),
            );
          },
        ),
        icon: const Icon(FluentIcons.event),
        title: Text(translate('$prefix.items.events')),
        onTap: () => _goto('events'),
      ),
      PaneItem(
        key: const ValueKey('/map_rotation_creator'),
        icon: const Icon(FluentIcons.edit_create),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.map_rotation_creator')),
        onTap: () => _goto('map_rotation_creator'),
      ),
      PaneItemSeparator(),
      PaneItemHeader(header: Text(translate('navigation_bar.items.mod_profiles'))),
      PaneItem(
        key: const ValueKey('/mod_profiles'),
        icon: const Icon(FluentIcons.list),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.mod_profiles')),
        onTap: () => _goto('mod_profiles'),
      ),
      PaneItem(
        key: const ValueKey('/saved_profiles'),
        icon: const Icon(FluentIcons.save_all),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.saved_profiles')),
        onTap: () => _goto('saved_profiles'),
      ),
      PaneItemSeparator(),
      PaneItemHeader(header: Text(translate('mods'))),
      PaneItem(
        key: const ValueKey('/cosmetic_mods'),
        icon: const Icon(FluentIcons.custom_list),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.cosmetic_mods')),
        onTap: () => _goto('cosmetic_mods'),
      ),
      PaneItem(
        key: const ValueKey('/installed_mods'),
        icon: const Icon(FluentIcons.installation),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.installed_mods')),
        onTap: () => _goto('installed_mods'),
      ),
      PaneItemSeparator(),
      PaneItemHeader(header: const Text('Battlefront 2')),
      PaneItem(
        key: const ValueKey('/run_bf2'),
        icon: const Icon(FluentIcons.processing_run),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.run_bf2')),
        onTap: () => _goto('run_bf2'),
      ),
    ];
    bottomListItems = [
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
        key: const ValueKey('/feedback'),
        icon: const Icon(FluentIcons.feedback),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.feedback')),
        onTap: () => _goto('feedback'),
      ),
      PaneItem(
        key: const ValueKey('/settings'),
        icon: const Icon(FluentIcons.settings),
        body: const SizedBox.shrink(),
        title: Text(translate('$prefix.items.settings')),
        onTap: () => _goto('settings'),
      ),
    ];
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

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
