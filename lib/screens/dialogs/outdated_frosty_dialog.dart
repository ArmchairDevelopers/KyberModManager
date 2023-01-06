import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/logic/frosty_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/path_helper.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';
import 'package:logging/logging.dart';

class OutdatedFrostyDialog extends StatefulWidget {
  OutdatedFrostyDialog({Key? key}) : super(key: key);

  @override
  State<OutdatedFrostyDialog> createState() => _OutdatedFrostyDialogState();
}

class _OutdatedFrostyDialogState extends State<OutdatedFrostyDialog> {
  int index = 0;
  int total = 0;
  int current = 0;
  int totalFiles = 0;
  int currentFile = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (index != 0) {
      box.put('skipFrostyVersionCheck', false);
    }
    super.dispose();
  }

  void initDownload() async {
    if (index == 3) {
      return Navigator.of(context).pop();
    }

    setState(() => index = 1);
    String path = box.get('frostyPath');
    if (!Directory('$path/Backups').existsSync()) {
      Directory('$path/Backups').createSync(recursive: true);
    }

    Logger.root.info('Generating backup of FrostyModManager...');
    ReceivePort port = ReceivePort();
    var x = port.listen((message) {
      setState(() {
        currentFile = message[0];
        totalFiles = message[1];
      });
    });
    await compute(_createZip, [path, BlocProvider.of<FrostyCubic>(context).state.currentVersion!, box.get('frostyConfigPath', defaultValue: ''), port.sendPort]);
    x.cancel();
    Logger.root.info('Generated backup.');
    Logger.root.info('Starting download...');
    setState(() => index = 2);
    await PathHelper.downloadFrosty(
      Directory(path),
      BlocProvider.of<FrostyCubic>(context).state.latestVersion!,
      (current, total) => setState(() {
        this.current = current;
        this.total = total;
      }),
    );
    await BlocProvider.of<FrostyCubic>(context).checkForUpdates();
    setState(() => index = 3);
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 400),
      title: const Text("Outdated Frosty"),
      actions: [
        Button(
          onPressed: index == 1
              ? null
              : () {
                  if (index == 3) {
                    return Navigator.of(context).pop();
                  }
                  if (index > 1) {
                    PathHelper.cancelDownload();
                  }

                  box.put('skipFrostyVersionCheck', true);
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: index != 0 && index != 3 ? null : () => initDownload(),
          child: Text(index == 3
              ? 'Finish'
              : index == 0
                  ? 'Update Frosty'
                  : 'Updating...'),
        ),
      ],
      content: IndexedStack(
        index: index,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'You currently have FrostyModManager version '),
                  TextSpan(text: BlocProvider.of<FrostyCubic>(context).state.currentVersion?.version, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' installed. The latest version is '),
                  TextSpan(text: "${BlocProvider.of<FrostyCubic>(context).state.latestVersion?.version}.", style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                style: const TextStyle(fontSize: 16),
              ),
              const Text(
                '\nIf you click on update, KMM will make a backup of your FrostyModManager installation and overwrite your current Frosty installation.\n\nThe backup will be saved in your FrostyModManager directory.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                  width: 25,
                  child: ProgressRing(),
                ),
                const SizedBox(width: 15),
                Text(
                  'Generating backup...  (${currentFile.toString()}/${totalFiles.toString()})',
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                "Downloading Frosty ${BlocProvider.of<FrostyCubic>(context).state.latestVersion?.version}",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: SizedBox(
                  width: 700,
                  child: ProgressBar(value: index != 2 ? 0 : (current / total) * 100),
                ),
              ),
              const SizedBox(height: 5),
              Text('${formatBytes(current, 1)} / ${formatBytes(BlocProvider.of<FrostyCubic>(context).state.latestVersion?.size ?? 0, 1)}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Text('Version: ${BlocProvider.of<FrostyCubic>(context).state.latestVersion?.version}', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const Center(
            child: Text(
              'Frosty Mod Manager has been updated!',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
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

void _createZip(List<dynamic> args) async {
  var encoder = ZipFileEncoder();
  String path = args[0];
  FrostyVersion installedVersion = args[1];
  String backupPath = '$path/Backups/${installedVersion.version}.zip';
  if (File(backupPath).existsSync()) {
    return;
  }

  encoder.create('$path/Backups/${installedVersion.version}.zip');
  int i = 0;
  List<FileSystemEntity> files = Directory(path).listSync();
  files = files.where((entity) => !entity.path.endsWith('Mods') && !entity.path.endsWith('Backups') && !entity.path.endsWith('Caches')).toList();
  (args[3] as SendPort).send([i, files.length]);
  for (FileSystemEntity entity in files) {
    Logger.root.info('Found: ${entity.path}');
    if (entity is File) {
      encoder.addFile(entity);
    } else if (entity is Directory) {
      encoder.addDirectory(entity);
    }
    i++;
    (args[3] as SendPort).send([i, files.length]);
  }
  String configPath = args[2];
  if (configPath.isNotEmpty) {
    File configFile = File(configPath);
    encoder.addFile(configFile, configFile.uri.pathSegments.last);
  }
  encoder.close();
}
