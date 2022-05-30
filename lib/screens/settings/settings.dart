import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/settings/platform_selector.dart';
import 'package:kyber_mod_manager/screens/update_dialog/update_dialog.dart';
import 'package:kyber_mod_manager/screens/walk_through/walk_through.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/app_locale.dart';
import 'package:kyber_mod_manager/utils/auto_updater.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/storage_helper.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/rpc_service.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';
import 'package:kyber_mod_manager/widgets/custom_button.dart';
import 'package:system_theme/system_theme.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final String prefix = 'settings';
  bool disabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
        commandBar: Row(
          children: [
            Button(
              child: ButtonText(
                icon: const Icon(FluentIcons.export),
                text: Text(translate('$prefix.export_log_file')),
              ),
              onPressed: () async {
                String? path = await FilePicker.platform.saveFile(
                  type: FileType.custom,
                  allowedExtensions: ['txt'],
                  fileName: 'log.txt',
                  dialogTitle: translate('$prefix.export_log_file'),
                  lockParentWindow: true,
                );
                if (path == null) {
                  return;
                }

                String content = CustomLogger.getLogs();
                File(path).writeAsStringSync(content);
              },
            ),
            const SizedBox(width: 10),
            Button(
              onPressed: () async {
                var version = await AutoUpdater().updateAvailable();
                if (version == null) {
                  NotificationService.showNotification(message: translate('$prefix.check_for_updates.no_updates_available'));
                  return;
                }
                showDialog(context: context, builder: (c) => UpdateDialog(versionInfo: version));
              },
              child: ButtonText(
                icon: const Icon(FluentIcons.refresh),
                text: Text(translate('$prefix.check_for_updates.title')),
              ),
            ),
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        children: [
          Card(
            child: ListTile(
              title: Text(translate('$prefix.language.title')),
              subtitle: Text(translate('$prefix.language.subtitle')),
              leading: const Icon(FluentIcons.locale_language),
              trailing: SizedBox(
                width: 250,
                child: Combobox<dynamic>(
                  onChanged: (dynamic value) async {
                    changeLocale(context, value);
                    await box.put('locale', value);
                    Jiffy.locale(AppLocale().getLocale().languageCode);
                    var cubit = BlocProvider.of<WidgetCubit>(context);
                    cubit.toIndex(7);
                    cubit.toIndex(8);
                  },
                  isExpanded: true,
                  value: LocalizedApp.of(context).delegate.currentLocale.languageCode,
                  items: LocalizedApp.of(context).delegate.supportedLocales.map((e) {
                    return ComboboxItem<dynamic>(
                      value: e.languageCode,
                      child: SizedBox(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/flags/${e.languageCode}.svg',
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(translate('languages.' + e.languageCode)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(translate('$prefix.nexus_mods.title')),
              subtitle: Text(translate('$prefix.nexus_mods.subtitle')),
              leading: const Icon(FluentIcons.download),
              trailing: CustomFilledButton(
                child: ButtonText(
                  text: Text(translate(box.get('nexusmods_login', defaultValue: false) ? '$prefix.nexus_mods.logout' : 'Login')),
                  icon: Icon(box.get('nexusmods_login', defaultValue: false) ? FluentIcons.user_remove : FluentIcons.user_sync),
                ),
                color: box.get('nexusmods_login', defaultValue: false) ? Colors.red : SystemTheme.accentColor.accent,
                onPressed: () async {
                  if (box.get('nexusmods_login', defaultValue: false)) {
                    var s = Directory('$applicationDocumentsDirectory\\puppeteer');
                    if (s.existsSync()) {
                      s.deleteSync(recursive: true);
                    }
                    await box.put('nexusmods_login', false);
                    await box.delete('cookies');
                  } else {
                    await showDialog(context: context, builder: (c) => const NexusmodsLogin());
                  }
                  setState(() => null);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(translate('$prefix.discord_activity.title')),
                ],
              ),
              subtitle: Text(translate('$prefix.discord_activity.subtitle')),
              leading: const Icon(FluentIcons.activity_feed),
              trailing: ToggleSwitch(
                checked: box.get('discordRPC', defaultValue: true),
                onChanged: (enabled) async {
                  await box.put('discordRPC', enabled);
                  if (enabled) {
                    RPCService.start();
                  } else {
                    RPCService.dispose();
                  }
                  setState(() => null);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(translate('$prefix.saved_profiles.title')),
                  Tooltip(
                    child: const Icon(
                      FluentIcons.status_circle_question_mark,
                      size: 22,
                    ),
                    style: const TooltipThemeData(
                      padding: EdgeInsets.all(8),
                    ),
                    message: translate('saved_profiles.tooltip'),
                  )
                ],
              ),
              subtitle: Text(translate('$prefix.saved_profiles.subtitle')),
              leading: const Icon(FluentIcons.save),
              trailing: ToggleSwitch(
                checked: box.get('saveProfiles', defaultValue: true),
                onChanged: (enabled) async {
                  await box.put('saveProfiles', enabled);
                  setState(() => null);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(translate('$prefix.frosty_profile.title')),
                  Tooltip(
                    child: const Icon(
                      FluentIcons.status_circle_question_mark,
                      size: 22,
                    ),
                    style: const TooltipThemeData(
                      padding: EdgeInsets.all(8),
                    ),
                    message: translate('$prefix.frosty_profile.tooltip'),
                  )
                ],
              ),
              subtitle: Text(translate('$prefix.frosty_profile.subtitle')),
              leading: const Icon(FluentIcons.game),
              trailing: ToggleSwitch(
                checked: PlatformHelper.isProfileActive(),
                onChanged: !disabled
                    ? (value) async {
                        String path;
                        setState(() => disabled = true);
                        if (value) {
                          String? result = await showDialog(
                            context: context,
                            builder: (b) => const PlatformSelector(),
                          );
                          if (result == null) {
                            return setState(() {
                              disabled = false;
                            });
                          }
                          path = await PlatformHelper.activateProfile('KyberModManager');
                          await box.put('platform', result);
                          if (result.contains('epic')) {
                            await Future.wait([
                              PlatformHelper.restartPlatform(result, path),
                              PlatformHelper.restartPlatform('origin', path),
                            ]);
                          } else {
                            await PlatformHelper.restartPlatform(result, path);
                          }
                        } else {
                          path = await PlatformHelper.activateProfile(box.get('previousProfile') ?? '', previous: true);
                          await PlatformHelper.restartPlatform(box.get('platform', defaultValue: 'origin'), path);
                          await box.put('previousProfile', null);
                        }
                        await box.put('frostyProfile', value);
                        setState(() => disabled = false);
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(translate('$prefix.change_frosty_directory.title')),
              subtitle: Text(translate('$prefix.change_frosty_directory.subtitle')),
              leading: const Icon(FluentIcons.folder),
              trailing: FilledButton(
                child: ButtonText(
                  text: Text(translate('$prefix.change_frosty_directory.change')),
                  icon: const Icon(FluentIcons.move_to_folder),
                ),
                onPressed: () => showDialog(
                  builder: (_) => const WalkThrough(
                    changeFrostyPath: true,
                  ),
                  context: context,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(translate('$prefix.reset.title')),
              subtitle: Text(translate('$prefix.reset.subtitle')),
              leading: const Icon(FluentIcons.reset),
              trailing: CustomFilledButton(
                child: ButtonText(
                  text: Text(translate('$prefix.reset.title')),
                  icon: const Icon(FluentIcons.reset),
                ),
                color: Colors.red,
                onPressed: () => box.deleteFromDisk().then((value) async {
                  await StorageHelper.initialiseHive();
                  var s = Directory('$applicationDocumentsDirectory\\puppeteer');
                  if (s.existsSync()) {
                    s.deleteSync(recursive: true);
                  }
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              'V1.0.6',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
