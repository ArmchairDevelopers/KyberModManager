import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/widgets/frosty_selector.dart';
import 'package:kyber_mod_manager/screens/dialogs/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/screens/errors/battlefront_not_installed.dart';
import 'package:kyber_mod_manager/utils/custom_logger.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/path_helper.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_installer_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/github_asset.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/cmd_run.dart';

class WalkThrough extends StatefulWidget {
  const WalkThrough({Key? key, this.changeFrostyPath = false}) : super(key: key);

  final bool changeFrostyPath;

  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  final String prefix = 'walk_through';
  late List<GitHubAsset> frostyVersions;
  List<String>? supportedFrostyVersions;
  late GitHubAsset selectedFrostyVersion;
  Directory? _directory;
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
    ApiService.supportedFrostyVersions().then((value) => setState(() => supportedFrostyVersions = value));
    if (widget.changeFrostyPath == true) {
      index = 1;
      disabled = false;
    } else {
      DllInjector.checkForUpdates().then(
        (value) => setState(() {
          index++;
          disabled = false;
        }),
      );
    }
    String path = OriginHelper.getBattlefrontPath();
    if (path.isEmpty) {
      NavigatorService.pushErrorPage(const BattlefrontNotFound());
    }
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
        return FrostySelector(
          supportedVersions: supportedFrostyVersions ?? ['loading...'],
        );
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
                "Downloading Frosty ${selectedFrostyVersion.version}",
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
              Text('${formatBytes(current, 1)} / ${formatBytes(selectedFrostyVersion.size, 1)}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Text('Path: ${_directory?.path ?? ''}', style: const TextStyle(fontSize: 14)),
              Text('Version: ${selectedFrostyVersion.version}', style: const TextStyle(fontSize: 14)),
            ],
          );
        }

        if (index == 5) {
          return Container(
            alignment: Alignment.center,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: const [
              SizedBox(
                height: 20,
                width: 20,
                child: ProgressRing(),
              ),
              SizedBox(width: 20),
              Text(
                "Please close Frosty after it loaded into the menu",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
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
                        value: e,
                        child: Text(
                          e.version +
                              (supportedFrostyVersions != null
                                  ? supportedFrostyVersions!.contains(e.version)
                                      ? ' (Supported)'
                                      : ' (Not Supported)'
                                  : ' (-)'),
                        ),
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
        String? configPath = FrostyService.getFrostyConfigPath();
        if (configPath == null) {
          Logger.root.severe('No config found.');
          NotificationService.showNotification(message: 'No config found.', color: Colors.red);
          return;
        }
        box.put('frostyConfigPath', configPath);
        String? valid = PathHelper.isValidFrostyDir(selectedDirectory);
        if (valid != null) {
          NotificationService.showNotification(
            message: translate('$prefix.select_frosty_path.error_messages.$valid'),
            color: Colors.red,
          );
          await box.delete('frostyPath');
          await box.delete('frostyConfigPath');
          return;
        }
        if (widget.changeFrostyPath) {
          setState(() {
            disabled = true;
            index = 2;
          });
          onPressed();
          return;
        }
        setState(() {
          index++;
          disabled = true;
        });
        Future.delayed(const Duration(seconds: 4), () => setState(() => disabled = false));
      } else {
        Logger.root.severe('Failed to select Frosty directory');
        NotificationService.showNotification(message: 'Failed to select Frosty path', color: Colors.red);
      }
    } else if (index == 3) {
      setState(() {
        downloading = true;
        disabled = true;
      });
      await PathHelper.downloadFrosty(
        _directory!,
        selectedFrostyVersion,
        (current, total) => setState(() {
          this.current = current;
          this.total = total;
        }),
      );

      setState(() {
        downloading = false;
        installed = true;
        index = 5;
      });

      box.put('frostyPath', _directory!.path);
      String? configPath = FrostyService.getFrostyConfigPath();
      var config;
      if (configPath != null && File(configPath).existsSync()) {
        bool validConfig = FrostyProfileService.checkConfig(configPath);
        if (!validConfig) {
          await FrostyProfileService.loadBattlefront(configPath);
        }

        box.put('frostyConfigPath', configPath);
        config = FrostyService.getFrostyConfig();
      } else {
        await FrostyProfileService.createFrostyConfig();
      }

      String? valid = PathHelper.isValidFrostyDir(_directory!.path);
      if (valid == null) {
        setState(() {
          downloading = false;
          installed = true;
          index = 1;
          disabled = false;
        });
        onPressed();
      }

      final Completer<Process> processCompleter = Completer<Process>();
      runExecutableArguments(
        '${_directory!.path}\\FrostyModManager.exe',
        [],
        workingDirectory: _directory!.path,
        onProcess: (e) => processCompleter.complete(e),
      );
      Process process = await processCompleter.future;
      await Directory(_directory!.path).watch(recursive: true).firstWhere((FileSystemEvent event) {
        return event.path.endsWith('FrostyModManager\\Mods\\starwarsbattlefrontii');
      });
      await Future.delayed(const Duration(milliseconds: 200));
      process.kill();

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
        ModInstallerService.initialize();
        ModService.watchDirectory();
        Navigator.of(context).pop();
        if (!widget.changeFrostyPath && !box.containsKey('cookies')) {
          showDialog(context: context, builder: (context) => const NexusmodsLogin());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 700),
      title: Row(children: [
        Expanded(child: Text(index == 3 ? 'Frosty Download' : translate('$prefix.title'))),
        DropDownButton(
          leading: Text(translate('server_browser.join_dialog.options.title')),
          items: [
            MenuFlyoutItem(
              text: Text(translate('settings.export_log_file')),
              leading: const Icon(FluentIcons.paste),
              onPressed: () async {
                String? path = await FilePicker.platform.saveFile(
                  type: FileType.custom,
                  allowedExtensions: ['txt'],
                  fileName: 'log.txt',
                  dialogTitle: translate('settings.export_log_file'),
                  lockParentWindow: true,
                );
                if (path == null) {
                  return;
                }

                String content = CustomLogger.getLogs();
                File(path).writeAsStringSync(content);
              },
            ),
          ],
        )
      ]),
      actions: [
        Button(
          onPressed: (index < 2 || disabled) && !widget.changeFrostyPath || downloading && index != 0
              ? null
              : () {
                  if (index == 0) {
                    return onPressed();
                  }
                  if (widget.changeFrostyPath && index != 3) {
                    return Navigator.of(context).pop();
                  }
                  if (index == 3) {
                    PathHelper.cancelDownload();
                  }
                  setState(() => index == 3 ? index = 1 : index--);
                },
          child: index == 0
              ? const Text('Skip')
              : widget.changeFrostyPath && index != 3
                  ? Text(translate('close'))
                  : index == 3
                      ? const Text('Cancel')
                      : Text(translate('server_browser.prev_page')),
        ),
        if (index == 1)
          Button(
            onPressed: index == 0 || disabled ? null : () => setState(() => index = 3),
            child: const Text("Download Frosty"),
          ),
        FilledButton(
          onPressed: disabled ? null : onPressed,
          child: Text(
            index == 1
                ? translate('$prefix.select_frosty_path.button')
                : index == 3
                    ? 'Download'
                    : translate('continue'),
          ),
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
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
