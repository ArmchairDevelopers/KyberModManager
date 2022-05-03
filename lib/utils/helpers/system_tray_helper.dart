import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_dialog.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayHelper {
  static late SystemTray systemTray;
  static late BuildContext _context;
  static final _defaultMenu = [
    MenuItem(label: translate('exit'), onClicked: () => exit(0)),
  ];

  static void init(BuildContext context) {
    _context = context;
    systemTray = SystemTray();
    return;
    systemTray = SystemTray();
    systemTray.initSystemTray(title: 'Kyber Mod Manager', iconPath: './assets/app_icon.ico');
    systemTray.setContextMenu(_defaultMenu);
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == "rightMouseDown" || eventName == "leftMouseDown") {
        systemTray.popUpContextMenu();
      }
    });
    if (box.containsKey('setup') && box.get('setup')) {
      setProfiles();
    }
  }

  static void setProfiles() async {
    List<String> profiles = await FrostyProfileService.getProfiles();
    var items = [
      SubMenu(
        label: 'Start BF2',
        children: [
          ...['host_server.forms.mod_profile.no_mods_profile', 'host_server.forms.cosmetic_mods.header']
              .map((e) => MenuItem(label: translate(e), onClicked: () => _onProfileSelected(translate(e))))
              .toList(),
          ...profiles.map((profile) => MenuItem(label: profile, onClicked: () => _onProfileSelected(profile + ' (Frosty Pack)'))).toList(),
        ],
      ),
      MenuSeparator(),
      MenuItem(label: 'Mod directory', onClicked: () => launchUrlString('file://${box.get('frostyPath')}\\Mods\\starwarsbattlefrontii')),
      ..._defaultMenu,
    ];
    systemTray.setContextMenu(items);
  }

  static void _onProfileSelected(String profile) {
    windowManager.focus();
    BlocProvider.of<WidgetCubit>(_context).toIndex(6);
    showDialog(
      context: _context,
      builder: (context) => RunDialog(
        profile: profile,
      ),
    );
  }
}
