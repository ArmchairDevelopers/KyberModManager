import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/frosty_cubic.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/dialogs/kyber_release_channel_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/outdated_frosty_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/update_dialog/update_dialog.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/walk_through.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/screens/settings/widgets/platform_selector.dart';
import 'package:kyber_mod_manager/screens/settings/widgets/settings_card.dart';
import 'package:kyber_mod_manager/utils/app_locale.dart';
import 'package:kyber_mod_manager/utils/auto_updater.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/storage_helper.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/rpc_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_cubic_state.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';

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
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              onPressed: () async {
                var version = await AutoUpdater().updateAvailable();
                if (version == null) {
                  NotificationService.showNotification(message: translate('$prefix.check_for_updates.no_updates_available'));
                  return;
                }
                showDialog(context: context, builder: (c) => UpdateDialog(versionInfo: version));
              },
              icon: const Icon(FluentIcons.refresh),
              label: Text(translate('$prefix.check_for_updates.title')),
            ),
            const CommandBarSeparator(),
            CommandBarButton(
              icon: const Icon(FluentIcons.export),
              label: Text(translate('$prefix.export_log_file')),
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
            )
          ],
          secondaryItems: [
            CommandBarButton(
              icon: Icon(!box.get("enableDynamicEnv") ? FluentIcons.unlock : FluentIcons.lock),
              label: Text(box.get("enableDynamicEnv") ? "Disable Env Injection" : "Enable Env Injection"),
              onPressed: () async {
                await box.put("enableDynamicEnv", !box.get("enableDynamicEnv"));
                dynamicEnvEnabled = box.get("enableDynamicEnv");
                Navigator.of(context).pop();
                setState(() => null);
              },
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.empty_recycle_bin),
              label: const Text("Clear cache"),
              onPressed: () async {
                ApiService.cacheStore.clean();
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        children: [
          InfoLabel(label: translate('General')),
          SettingsCard(
            icon: FluentIcons.locale_language,
            title: Text(translate('$prefix.language.title')),
            subtitle: Text(translate('$prefix.language.subtitle')),
            child: SizedBox(
              width: 250,
              child: ComboBox<dynamic>(
                onChanged: (dynamic value) async {
                  changeLocale(context, value);
                  await box.put('locale', value);
                  Jiffy.setLocale(AppLocale().getLocale().languageCode);
                  var cubit = BlocProvider.of<WidgetCubit>(context);
                  cubit.toIndex(8);
                  cubit.toIndex(9);
                },
                isExpanded: true,
                value: LocalizedApp.of(context).delegate.currentLocale.languageCode,
                items: LocalizedApp.of(context).delegate.supportedLocales.map((e) {
                  return ComboBoxItem<dynamic>(
                    value: e.languageCode,
                    child: SizedBox(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/flags/${e.languageCode}.svg',
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(translate('languages.${e.languageCode}')),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SettingsCard(
            icon: FluentIcons.activity_feed,
            title: Text(translate('$prefix.discord_activity.title')),
            subtitle: Text(translate('$prefix.discord_activity.subtitle')),
            child: ToggleSwitch(
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
          SettingsCard(
            icon: FluentIcons.download,
            title: Text(translate('$prefix.nexus_mods.title')),
            subtitle: Text(translate('$prefix.nexus_mods.subtitle')),
            child: Button(
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
              child: ButtonText(
                text: Text(translate(box.get('nexusmods_login', defaultValue: false) ? '$prefix.nexus_mods.logout' : 'Login')),
                icon: Icon(box.get('nexusmods_login', defaultValue: false) ? FluentIcons.user_remove : FluentIcons.user_sync),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InfoLabel(label: translate('Frosty')),
          BlocBuilder<FrostyCubic, FrostyCubicState>(
            bloc: BlocProvider.of<FrostyCubic>(context),
            builder: (context, state) {
              return InfoBar(
                title: Text(translate("$prefix.frosty_updater.titles.${state.isOutdated ? 'new_version_available' : 'up_to_date'}")),
                content: Text(state.isOutdated
                    ? translate("$prefix.frosty_updater.contents.new_version_available", args: {"version": state.latestVersion?.version})
                    : translate("$prefix.frosty_updater.contents.up_to_date", args: {"version": state.currentVersion?.version})),
                severity: state.isOutdated ? InfoBarSeverity.warning : InfoBarSeverity.success,
                isLong: true,
                action: Button(
                  child: ButtonText(
                    text: state.isOutdated ? Text(translate("$prefix.frosty_updater.buttons.install_update")) : Text(translate("$prefix.frosty_updater.buttons.check_for_updates")),
                    icon: Icon(state.isOutdated ? FluentIcons.installation : FluentIcons.refresh),
                  ),
                  onPressed: () async {
                    var outdated = await BlocProvider.of<FrostyCubic>(context).checkForUpdates();
                    if (!outdated) {
                      return;
                    }
                    await Future.delayed(const Duration(milliseconds: 500));
                    showDialog(context: context, builder: (c) => OutdatedFrostyDialog());
                  },
                ),
              );
            },
          ),
          SettingsCard(
            icon: FluentIcons.game,
            title: Row(
              children: [
                Text(translate('$prefix.frosty_profile.title')),
                Tooltip(
                  style: const TooltipThemeData(
                    padding: EdgeInsets.all(8),
                  ),
                  message: translate('$prefix.frosty_profile.tooltip'),
                  child: const Icon(
                    FluentIcons.status_circle_question_mark,
                    size: 22,
                  ),
                )
              ],
            ),
            subtitle: Text(translate('$prefix.frosty_profile.subtitle')),
            child: ToggleSwitch(
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
                      if (!mounted) return;

                      setState(() => disabled = false);
                    }
                  : null,
            ),
          ),
          SettingsCard(
            icon: FluentIcons.settings,
            title: Row(
              children: [
                Text(translate('$prefix.saved_profiles.title')),
                Tooltip(
                  style: const TooltipThemeData(
                    padding: EdgeInsets.all(8),
                  ),
                  message: translate('saved_profiles.tooltip'),
                  child: const Icon(
                    FluentIcons.status_circle_question_mark,
                    size: 22,
                  ),
                )
              ],
            ),
            subtitle: Text(translate('$prefix.saved_profiles.subtitle')),
            child: ToggleSwitch(
              checked: box.get('saveProfiles', defaultValue: true),
              onChanged: (enabled) async {
                await box.put('saveProfiles', enabled);
                setState(() => null);
              },
            ),
          ),
          SettingsCard(
            icon: FluentIcons.folder,
            title: Text(translate('$prefix.change_frosty_directory.title')),
            subtitle: Text(translate('$prefix.change_frosty_directory.subtitle')),
            child: Button(
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
          const SizedBox(height: 20),
          InfoLabel(label: translate('Kyber')),
          SettingsCard(
            icon: FluentIcons.release_gate,
            title: Text(translate("$prefix.kyber_release_channel.title")),
            subtitle: Text(translate("$prefix.kyber_release_channel.description")),
            child: Button(
              child: ButtonText(
                text: Text(translate("$prefix.kyber_release_channel.button")),
                icon: const Icon(FluentIcons.edit),
              ),
              onPressed: () => showDialog(
                builder: (_) => const KyberReleaseChannelDialog(),
                context: context,
              ),
            ),
          ),
          const SizedBox(height: 20),
          InfoLabel(label: translate('Other')),
          SettingsCard(
            icon: FluentIcons.reset,
            title: Text(translate('$prefix.reset.title')),
            subtitle: Text(translate('$prefix.reset.subtitle')),
            child: FilledButton(
              onPressed: () => box.deleteFromDisk().then((value) async {
                await StorageHelper.initializeHive();
                var s = Directory('$applicationDocumentsDirectory\\puppeteer');
                if (s.existsSync()) {
                  s.deleteSync(recursive: true);
                }
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }),
              child: ButtonText(
                text: Text(translate('$prefix.reset.title')),
                icon: const Icon(FluentIcons.reset),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Text(
              'V1.0.9',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
