import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/download_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/mod_info.dart';
import 'package:logging/logging.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key, required this.server, required this.onDownloadComplete, required this.onUnsupportedMods}) : super(key: key);

  final KyberServer server;
  final Function onDownloadComplete;
  final Function onUnsupportedMods;

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final String prefix = 'server_browser.join_dialog.download_page';
  final DownloadService downloadService = DownloadService();
  late List<ModInfo> mods;
  List<String> unsupportedModList = [];
  DownloadInfo? downloadInfo;
  ModInfo? currentMod;
  bool done = false;
  bool unsupportedMods = false;
  int loadingState = 0;
  double progress = 0;
  int received = 0;
  int total = 0;

  @override
  void initState() {
    mods = widget.server.mods.where((element) => !ModService.isInstalled(element)).map((e) => ModService.convertToModInfo(e)).toList();
    startDownloads();
    Logger.root.info('Downloading mods for ${widget.server.name}');
    super.initState();
  }

  void onDownloadsFinished() {
    Logger.root.info('Downloads complete');
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    if (!unsupportedMods) {
      widget.onDownloadComplete();
    } else {
      widget.onUnsupportedMods();
    }
    setState(() => done = true);
  }

  @override
  void dispose() {
    try {
      downloadService.close();
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    } catch (_e) {
      print(_e);
    }
    super.dispose();
  }

  void startDownloads() async {
    await Future.wait(mods.map((e) async {
      bool available = await ApiService.isAvailable(e.toString());
      if (!available) {
        unsupportedModList.add(e.name);
        unsupportedMods = true;
        mods = mods.where((element) => element.toString() != e.toString()).toList();
      }
    }));

    if (mods.isEmpty) {
      onDownloadsFinished();
      setState(() => loadingState = 2);
      return;
    }

    await downloadService.init();
    setState(() {
      currentMod = mods.first;
      loadingState = 1;
    });
    downloadService.onReceiveProgress().listen((event) {
      setState(() {
        received = int.parse(event.received);
        total = int.parse(event.total);
        progress = received / total * 100;
      });
    });
    await downloadService.startDownload(
      onWebsiteOpened: () {
        setState(() => loadingState = 2);
      },
      context: context,
      onClose: () => Navigator.of(context).pop(),
      onFileInfo: (i) => setState(() => downloadInfo = i),
      onExtracting: () => setState(() => loadingState = 3),
      mods: mods.map((e) => e.toString()).toList(),
      onNextMod: (String s) {
        setState(() {
          total = 0;
          progress = 0;
          received = 0;
          currentMod = mods.firstWhere((element) => s == element.toString());
          loadingState = 1;
        });
      },
    );
    onDownloadsFinished();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingState == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: ProgressRing(),
          ),
          const SizedBox(width: 15),
          Text(
            translate('$prefix.loading_states.0'),
            style: const TextStyle(fontSize: 15),
          ),
        ],
      );
    }
    if (unsupportedMods && done || mods.isEmpty) {
      return Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text(translate('$prefix.unsupported_mods_1')),
            Text(translate('$prefix.unsupported_mods_2')),
            Text(translate('$prefix.unsupported_mods_3')),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: unsupportedModList.map((e) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Tooltip(
                        message: translate('not_installed'),
                        child: Icon(
                          FluentIcons.error_badge,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e, style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
                      )
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('$prefix.downloading', args: {'0': currentMod.toString(), '1': progress.toStringAsFixed(0)}),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: SizedBox(
            width: 500,
            child: ProgressBar(value: progress),
          ),
        ),
        const SizedBox(height: 5),
        Text(formatBytes(received, 1) + ' / ' + formatBytes(total, 1), style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        Text(translate('$prefix.file', args: {'0': downloadInfo?.fileName ?? '-'})),
        if (loadingState == 1 || loadingState == 3)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: ProgressRing(),
                ),
                const SizedBox(width: 15),
                Text(
                  translate('$prefix.loading_states.${loadingState.toString()}'),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          )
      ],
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }
}
