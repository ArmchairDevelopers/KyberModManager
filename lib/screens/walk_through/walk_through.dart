import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/frosty_selector.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/path_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/system_tray_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_installer_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/github_asset.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class WalkThrough extends StatefulWidget {
  const WalkThrough({Key? key}) : super(key: key);

  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  final String prefix = 'walk_through';
  late List<GitHubAsset> frostyVersions;
  late GitHubAsset selectedFrostyVersion;
  Directory? _directory;
  bool firstInstall = false;
  bool installed = false;
  bool disabled = true;
  bool downloading = false;
  int total = 0;
  int current = 0;
  int index = 0;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((value) => setState(() => _directory = Directory(join(value.path, 'FrostyModManager'))));
    PathHelper.getFrostyVersions().then((value) {
      setState(() {
        frostyVersions = value.take(10).toList();
        selectedFrostyVersion = frostyVersions.first;
      });
    });
    DllInjector.checkForUpdates().then(
      (value) => setState(() {
        index++;
        disabled = false;
      }),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget getWidgetByIndex() {
    switch (index) {
      case 0:
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: disabled
                ? [
                    Text(
                      translate('$prefix.dependencies.downloading'),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const ProgressBar(),
                  ]
                : [Text(translate('$prefix.dependencies.finished'))],
          ),
        );
      case 1:
        return const FrostySelector();
      case 2:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 18),
            text: translate('$prefix.bugs_notice'),
          ),
        );
      case 3:
      case 5:
        if (downloading) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                "Downloading Frosty " + selectedFrostyVersion.version,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: SizedBox(
                  width: 700,
                  child: ProgressBar(value: (current / total) * 100),
                ),
              ),
              const SizedBox(height: 5),
              Text(formatBytes(current, 1) + ' / ' + formatBytes(selectedFrostyVersion.size, 1), style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Text('Path: ' + (_directory?.path ?? ''), style: const TextStyle(fontSize: 14)),
              Text('Version: ' + selectedFrostyVersion.version, style: const TextStyle(fontSize: 14)),
            ],
          );
        }

        if (index == 5) {
          return Container(
            alignment: Alignment.center,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              const ProgressRing(),
              const SizedBox(width: 10),
              Text(
                firstInstall ? "Please close Frosty after it initialised." : 'Please click on "Scan for games" once Frosty started.',
                style: const TextStyle(fontSize: 18),
              ),
            ]),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: 'Frosty Version',
              child: Combobox(
                isExpanded: true,
                items: frostyVersions
                    .map(
                      (e) => ComboboxItem(
                        child: Text(e.version),
                        value: e,
                      ),
                    )
                    .toList(),
                value: selectedFrostyVersion,
                onChanged: (GitHubAsset? value) => setState(() => selectedFrostyVersion = value ?? frostyVersions.first),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextBox(
                    header: 'Destination Folder',
                    enabled: false,
                    controller: TextEditingController(text: _directory?.path ?? ''),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Button(
              child: const Text('Change Folder'),
              onPressed: () async {
                String? path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select Folder');
                if (path == null) {
                  return;
                }

                setState(() => _directory = Directory(join(path, 'FrostyModManager')));
              },
            ),
          ],
        );
      default:
        return const Text('unknown');
    }
  }

  void onPressed() async {
    if (index == 1) {
      String? selectedDirectory;
      if (installed) {
        selectedDirectory = _directory!.path;
      } else {
        selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: true, dialogTitle: 'Select Frosty Path');
      }
      if (selectedDirectory != null) {
        box.put('frostyPath', selectedDirectory);
        String? configPath = await FrostyService.getFrostyConfigPath();
        if (configPath == null) {
          return;
        }
        box.put('frostyConfigPath', configPath);
        String? valid = await PathHelper.isValidFrostyDir(selectedDirectory);
        if (valid != null) {
          NotificationService.showNotification(
            message: translate('$prefix.select_frosty_path.error_messages.$valid'),
            color: Colors.red,
          );
          await box.delete('frostyPath');
          await box.delete('frostyConfigPath');
          return;
        }
        setState(() {
          index++;
          disabled = true;
        });
        Future.delayed(const Duration(seconds: 4), () => setState(() => disabled = false));
      }
    } else if (index == 3) {
      setState(() {
        downloading = true;
        disabled = true;
      });
      await PathHelper.downloadFrosty(
        _directory!,
        selectedFrostyVersion,
        (p0, p1) => setState(() {
          current = p0;
          total = p1;
        }),
      );

      setState(() {
        downloading = false;
        installed = true;
        index = 5;
      });

      box.put('frostyPath', _directory!.path);
      String? configPath = await FrostyService.getFrostyConfigPath();
      box.put('frostyConfigPath', configPath);
      FrostyConfig config = await FrostyService.getFrostyConfig();
      setState(() {
        firstInstall = config.games.keys.contains('starwarsbattlefrontii');
      });
      await FrostyService.startFrosty(launch: false, frostyPath: _directory!.path);

      setState(() {
        downloading = false;
        installed = true;
        index = 1;
        disabled = false;
      });
      onPressed();
    } else {
      if (index != 2) {
        setState(() {
          disabled = true;
          index++;
        });
        Future.delayed(const Duration(seconds: 4), () => setState(() => disabled = false));
      } else {
        await box.put('setup', true);
        await ModService.loadMods(context);
        ModInstallerService.initialise();
        SystemTrayHelper.setProfiles();
        ModService.watchDirectory();
        Navigator.of(context).pop();
        showDialog(context: context, builder: (context) => const NexusmodsLogin());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 700),
      title: Text(index == 3 ? 'Frosty Download' : translate('$prefix.title')),
      actions: [
        Button(
          child: index == 3 ? const Text('Cancel') : Text(translate('server_browser.prev_page')),
          onPressed: index == 0 || disabled
              ? null
              : () {
                  if (index == 3) {
                    PathHelper.cancelDownload();
                  }
                  setState(() => index == 3 ? index = 1 : index);
                },
        ),
        if (index == 1)
          Button(
            child: const Text("Download Frosty"),
            onPressed: index == 0 || disabled ? null : () => setState(() => index = 3),
          ),
        FilledButton(
          child: Text(
            index == 1
                ? translate('$prefix.select_frosty_path.button')
                : index == 3
                    ? 'Download'
                    : translate('continue'),
          ),
          onPressed: disabled ? null : onPressed,
        ),
      ],
      content: SizedBox(
        height: 400,
        child: getWidgetByIndex(),
      ),
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }
}
