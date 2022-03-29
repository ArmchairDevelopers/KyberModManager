import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/settings/platform_selector.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/widgets/custom_button.dart';
import 'package:kyber_mod_manager/widgets/icon_button.dart';
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
      ),
      content: ListView(
        children: [
          ListTile(
            title: Text(translate('$prefix.language.title')),
            subtitle: Text(translate('$prefix.language.subtitle')),
            leading: const Icon(FluentIcons.locale_language),
            trailing: SizedBox(
              width: 250,
              child: Combobox<dynamic>(
                onChanged: (dynamic value) {
                  changeLocale(context, value);
                  box.put('locale', value);
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
          ListTile(
            title: Text(translate('$prefix.nexus_mods.title')),
            subtitle: Text(translate('$prefix.nexus_mods.subtitle')),
            leading: const Icon(FluentIcons.download),
            trailing: CustomFilledButton(
              child: CustomIconButton(
                text: translate(box.get('nexusmods_login', defaultValue: false) ? '$prefix.nexus_mods.logout' : 'Login'),
                icon: box.get('nexusmods_login', defaultValue: false) ? FluentIcons.user_remove : FluentIcons.user_sync,
              ),
              color: box.get('nexusmods_login', defaultValue: false) ? Colors.red : SystemTheme.accentInstance.accent,
              onPressed: () async {
                if (box.get('nexusmods_login', defaultValue: false)) {
                  await box.put('nexusmods_login', false);
                  await box.delete('cookies');
                } else {
                  await showDialog(context: context, builder: (c) => const NexusmodsLogin());
                }
                setState(() => null);
              },
            ),
          ),
          ListTile(
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
          ListTile(
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
              checked: ProfileService.isProfileActive(),
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
                        path = await ProfileService.activateProfile('KyberModManager');
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
                        path = await ProfileService.activateProfile(box.get('previousProfile') ?? '', previous: true);
                        await PlatformHelper.restartPlatform(box.get('platform', defaultValue: 'origin'), path);
                        await box.put('previousProfile', null);
                      }
                      await box.put('frostyProfile', value);
                      setState(() => disabled = false);
                    }
                  : null,
            ),
          ),
          ListTile(
            title: Text(translate('$prefix.reset.title')),
            subtitle: Text(translate('$prefix.reset.subtitle')),
            leading: const Icon(FluentIcons.reset),
            trailing: CustomFilledButton(
              child: CustomIconButton(
                text: translate('$prefix.reset.title'),
                icon: FluentIcons.reset,
              ),
              color: Colors.red,
              onPressed: () => box.deleteFromDisk().then((value) async {
                await loadHive();
                var s = Directory('$applicationDocumentsDirectory\\chromium');
                if (s.existsSync()) {
                  s.deleteSync(recursive: true);
                }
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }),
            ),
          )
        ],
      ),
    );
  }
}
