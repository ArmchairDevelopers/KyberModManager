import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/widgets/download_screen.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/widgets/password_input.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/widgets/required_mods.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/widgets/team_selector.dart';
import 'package:kyber_mod_manager/screens/errors/missing_permissions.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/edit_profile.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/frosty_profile.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_profile.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/unordered_list.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ServerDialog extends StatefulWidget {
  const ServerDialog({Key? key, required this.server}) : super(key: key);

  final KyberServer server;

  @override
  _ServerDialogState createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  final String prefix = 'server_browser.join_dialog';
  bool profileEnabled = PlatformHelper.isProfileActive();

  FocusNode passwordFocusNode = FocusNode();
  Timer? timer;
  String preferredTeam = '0';
  String password = '';
  String? profile;
  String? content;
  bool downloading = false;
  bool cosmetics = false;
  bool disabled = false;
  bool failedInjection = false;
  bool unsupportedMods = false;
  bool modsInstalled = false;
  bool loading = false;
  int startingState = 0;
  int state = 0;

  late KyberServer server;
  late bool correctPassword;

  @override
  void initState() {
    server = widget.server;
    modsInstalled = server.mods.every((element) => ModService.isInstalled(element));
    correctPassword = !(server.requiresPassword);
    cosmetics = server.mods.length < 10 ? box.get('enableCosmetics', defaultValue: false) : false;
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    super.dispose();
  }

  void onButtonPressed() async {
    if (unsupportedMods) {
      return Navigator.pop(context);
    }

    if (!correctPassword) {
      passwordFocusNode.requestFocus();
      if (password.isEmpty) {
        return;
      }
      dynamic resp = await KyberApiService.joinServer(server.id, faction: 0, password: password).catchError((e) => null);
      if (resp['message'] != "Success, start your game to join this server!") {
        NotificationService.showNotification(message: resp['message'], color: Colors.red);
        return;
      }
      setState(() => correctPassword = true);
      return;
    }
    if (modsInstalled) {
      if (DllInjector.battlefrontPID != -1) {
        NotificationService.showNotification(message: translate('run_battlefront.notifications.battlefront_already_running'), color: Colors.red);
        return;
      }
      setState(() {
        state = 0;
        disabled = true;
        loading = true;
      });
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      List<String> mods = [];
      if (profile == null) {
        mods = List.from(server.mods);
        List<Mod> cosmeticMods = List<Mod>.from(box.get('cosmetics'));
        if (cosmetics) {
          mods.addAll(cosmeticMods.map((e) => e.toKyberString()).toList());
        }

        await ProfileService.enableProfile(ProfileService.getProfilePath("KyberModManager"));
        await ProfileService.searchProfile(mods, (copied, total) {
          setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));
        }).catchError((e) {
          NotificationService.showNotification(message: e.toString(), color: Colors.red);
        });
      } else {
        final String path = OriginHelper.getBattlefrontPath();
        await ProfileService.searchProfile([' ()'], (copied, total) {
          setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));
        }, false);

        await ProfileService.copyProfileData(Directory('$path\\ModData\\$profile'), Directory('$path\\ModData\\KyberModManager'), (copied, total) {
          setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));
        });
        await ProfileService.enableProfile(ProfileService.getProfilePath(profile!));
      }

      if (!mounted) return;
      setState(() {
        startingState = 1;
        content = null;
      });
      dynamic resp = await KyberApiService.joinServer(server.id, faction: int.parse(preferredTeam), password: password);
      if (resp['message'] != "Success, start your game to join this server!") {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
        NotificationService.showNotification(message: resp['message'], color: Colors.red);
        setState(() {
          disabled = false;
          loading = false;
        });
        return;
      }
      setState(() => startingState = 2);
      if (profile == null) {
        await FrostyProfileService.createProfile(mods);
      }

      if (!mounted) return;
      setState(() => startingState = 3);

      var appliedMods = await FrostyProfileService.getModsFromProfile(profile ?? 'KyberModManager');
      var serverMods =
          profile != null ? server.mods.map((mod) => ModService.convertToFrostyMod(mod)).toList() : mods.map((e) => ModService.convertToFrostyMod(e)).toList();
      if (!listEquals(profile == null ? appliedMods : appliedMods.where((element) => element.category.toString().toLowerCase() == "gameplay").toList(), serverMods)) {
        Logger.root.info("Applying Frosty mods...");
        await FrostyService.startFrosty(profile: profile).catchError((error) {
          NotificationService.showNotification(message: error, color: Colors.red);
          NavigatorService.pushErrorPage(const MissingPermissions());
        });
      } else {
        try {
          Logger.root.info("Mods are already applied.");
          PlatformHelper.startBattlefront();
        } catch (e) {
          NotificationService.showNotification(message: e.toString());
        }
      }

      if (!mounted) return;
      setState(() => startingState = 4);
      startTimer();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    } else if (!downloading) {
      if (!box.get('nexusmods_login', defaultValue: false)) {
        var links = await ApiService.getDownloadLinks(server.mods);
        if (links.unavailable.isNotEmpty) {
          NotificationService.showNotification(message: translate('$prefix.required_mods.not_in_database'), color: Colors.red);
          await Future.delayed(const Duration(seconds: 1));
        }
        links.links.toSet().toList().forEach((element) => launchUrlString(element));
        return;
      }
      setState(() {
        state = 0;
        downloading = true;
        disabled = true;
      });
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (DllInjector.isInjected()) {
        timer.cancel();
        checkInjection();
        return;
      }

      DllInjector.inject();
    });
  }

  void checkInjection([x = false]) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (DllInjector.battlefrontPID == -1) {
      return startTimer();
    }

    if (DllInjector.battlefrontPID != -1 && !DllInjector.isInjected()) {
      if (!x) {
        return checkInjection(true);
      }

      NotificationService.showNotification(message: translate('$prefix.failed_injection.notification'), color: Colors.red);
      Process.killPid(DllInjector.battlefrontPID);
      setState(() {
        failedInjection = true;
        loading = false;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context1) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600, minHeight: 400, maxHeight: 400),
      title: Row(children: [
        Expanded(
          child: AutoSizeText(
            server.name,
            maxLines: 1,
          ),
        ),
        DropDownButton(
          leading: Text(translate('$prefix.options.title')),
          items: [
            if (modsInstalled)
              MenuFlyoutItem(
                text: Text(translate('$prefix.options.import_mods')),
                leading: const Icon(FluentIcons.copy),
                onPressed: () {
                  Navigator.of(context).pop();
                  BlocProvider.of<WidgetCubit>(context).navigate(
                    2,
                    EditProfile(
                      profile: ModProfile(name: '', description: '', mods: server.mods.map((e) => ModService.convertToFrostyMod(e)).toList()),
                    ),
                  );
                },
              ),
            MenuFlyoutItem(
              text: Text(translate('copy_link')),
              leading: const Icon(FluentIcons.paste),
              onPressed: () => Clipboard.setData(ClipboardData(text: 'https://kyber.gg/servers/#id=${server.id}')),
            ),
          ],
        )
      ]),
      actions: [
        Button(
          child: Text(downloading ? translate('cancel') : translate('close')),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Button(
          onPressed: downloading || unsupportedMods ? null : () => setState(() => state = state == 1 ? 0 : 1),
          child: Text(state == 1 ? translate('back') : translate('$prefix.buttons.view_mods')),
        ),
        if (correctPassword && !unsupportedMods && modsInstalled)
          SplitButtonBar(
            buttons: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: FilledButton(
                    onPressed: disabled ? null : onButtonPressed,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        translate(
                          correctPassword && !unsupportedMods
                              ? modsInstalled
                                  ? 'join'
                                  : downloading
                                      ? '$prefix.buttons.downloading'
                                      : !box.get('nexusmods_login', defaultValue: false)
                                          ? '$prefix.buttons.open_mods'
                                          : '$prefix.buttons.download'
                              : 'continue',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: DropDownButton(
                  disabled: disabled,
                  items: [
                    MenuFlyoutItem(
                      text: const Text('Manually select profile'),
                      leading: const Icon(FluentIcons.copy),
                      onPressed: !disabled
                          ? () => Timer.run(() async {
                                FrostyProfile? profile = await showDialog<FrostyProfile?>(
                                  context: navigatorKey.currentContext!,
                                  builder: (c) => FrostyProfileSelector(
                                    onSelected: (s) {
                                      setState(() => null);
                                    },
                                  ),
                                );
                                if (profile == null) return;
                                List<dynamic> mods = profile.mods.where((e) => e.category.toLowerCase() == "gameplay").toList();
                                if (!listEquals(mods, server.mods.map((mod) => ModService.convertToFrostyMod(mod)).toList())) {
                                  NotificationService.showNotification(
                                    message: 'Please select a Frosty pack that contains the server mods in the correct order!',
                                    color: Colors.red,
                                  );
                                  return;
                                }
                                this.profile = profile.name;
                                onButtonPressed();
                              })
                          : null,
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   icon: const SizedBox(
              //     height: 22,
              //     child: const Icon(FluentIcons.chevron_down, size: 10.0),
              //   ),
              //   onPressed: () {},
              // ),
            ],
          ),
        if (!(correctPassword && !unsupportedMods && modsInstalled))
          FilledButton(
            onPressed: disabled ? null : onButtonPressed,
            child: Text(
              translate(
                correctPassword && !unsupportedMods
                    ? modsInstalled
                        ? 'join'
                        : downloading
                            ? '$prefix.buttons.downloading'
                            : !box.get('nexusmods_login', defaultValue: false)
                                ? '$prefix.buttons.open_mods'
                                : '$prefix.buttons.download'
                    : 'continue',
              ),
            ),
          ),
      ],
      content: SizedBox(
        height: 250,
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    if (downloading || unsupportedMods) {
      return DownloadScreen(
        server: server,
        onUnsupportedMods: () => setState(() {
          disabled = false;
          downloading = false;
          unsupportedMods = true;
        }),
        onDownloadComplete: () {
          setState(() {
            downloading = false;
            modsInstalled = true;
            disabled = false;
          });
        },
      );
    }

    if (state == 1) {
      return RequiredMods(
        server: server,
      );
    }

    if (failedInjection) {
      return Column(
        children: [
          Text(
            translate('$prefix.failed_injection.title'),
            style: const TextStyle(fontSize: 17),
          ),
          Text(
            translate('$prefix.failed_injection.text'),
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 10),
          SizedBox(
            child: UnorderedList(
              [
                translate('$prefix.failed_injection.text_1'),
                translate('$prefix.failed_injection.text_2'),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          )
        ],
      );
    }

    if (!correctPassword) {
      return PasswordInput(
        onChanged: (value) => password = value,
        focusNode: passwordFocusNode,
        checkPassword: (String value) {
          password = value;
          onButtonPressed();
        },
      );
    }

    if (loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: ProgressRing(),
              ),
              const SizedBox(width: 15),
              Text(
                content != null ? content! : translate('$prefix.joining_states.${startingText()}'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (startingState == 4) Text(translate('$prefix.joining_states.battlefront_2')),
        ],
      );
    }

    return Column(
      children: [
        if (!profileEnabled)
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: InfoBar(
              title: Text(translate('$prefix.frosty_profile_disabled')),
              content: const Text(
                  "Frosty Profile enables use of the mods for the platform of your choice. If you do not use it, you can experience problems with mods not loading."),
              isLong: true,
              action: Button(
                child: const Text('Open Settings'),
                onPressed: () {
                  BlocProvider.of<WidgetCubit>(context).toIndex(0);
                  BlocProvider.of<WidgetCubit>(context).toIndex(9);
                  Navigator.of(context).pop();
                },
              ),
              onClose: () => setState(() => profileEnabled = true),
              severity: InfoBarSeverity.warning,
            ),
          ),
        TeamSelector(
          server: server,
          value: preferredTeam,
          onChange: (team) => setState(() => preferredTeam = team ?? ''),
        ),
        ...requiredMods(),
        if (modsInstalled)
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Checkbox(
                checked: cosmetics,
                onChanged: (value) {
                  box.put('enableCosmetics', value);
                  setState(() => cosmetics = value!);
                },
                content: Text(translate('$prefix.cosmetic_mods.apply_cosmetic_mods')),
              ),
            ),
          )
      ],
    );
  }

  String startingText() {
    switch (startingState) {
      case 0:
        return 'searching';
      case 1:
        return 'joining';
      case 2:
        return 'creating';
      case 3:
        return 'frosty';
      case 4:
        return 'battlefront';
      default:
        return 'error';
    }
  }

  List<Widget> requiredMods() {
    if (modsInstalled) {
      return [];
    }

    return [
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.info),
          const SizedBox(width: 5),
          Text(
            translate('$prefix.required_mods.required_mods'),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      Text(
        translate('$prefix.required_mods.click_on_download'),
        style: const TextStyle(fontSize: 14),
      ),
    ];
  }
}
