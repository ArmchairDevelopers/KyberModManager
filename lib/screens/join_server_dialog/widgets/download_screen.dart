import 'dart:async';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/screens/errors/no_executable.dart';
import 'package:kyber_mod_manager/screens/join_server_dialog/join_dialog.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/helpers/unzip_helper.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/download_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
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
  Timer? downloadSpeedTimer;
  bool done = false;
  bool unsupportedMods = false;
  int loadingState = 0;
  double progress = 0;
  int speed = 0;
  int received = 0;
  int total = 0;

  @override
  void initState() {
    mods = widget.server.mods.where((element) => !ModService.isInstalled(element)).map((e) => ModService.convertToModInfo(e)).toList();
    Logger.root.info('Downloading mods for ${widget.server.name}');
    Timer.run(() => init());
    super.initState();
  }

  @override
  void dispose() {
    try {
      close();
    } catch (_e) {
      Logger.root.severe(_e.toString());
    }
    super.dispose();
  }

  void close() {
    downloadService.close();
    downloadSpeedTimer?.cancel();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }

  void init() async {
    String? unrarExecutable = UnzipHelper.getExecutable();
    if (unrarExecutable == null) {
      await NavigatorService.pushErrorPage(const NoExecutable());
    }
    startDownloads();
  }

  void onDownloadsFinished() {
    if (!mounted) {
      return;
    }
    Logger.root.info('Downloads complete');
    downloadSpeedTimer?.cancel();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    if (!unsupportedMods) {
      widget.onDownloadComplete();
    } else {
      widget.onUnsupportedMods();
    }
    setState(() => done = true);
  }

  void startDownloads() async {
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
    await Future.wait(mods.map((e) async {
      bool available = await ApiService.isAvailable(e.toString());
      if (!available) {
        unsupportedModList.add(e.name);
        unsupportedMods = true;
        mods = mods.where((element) => element.toString() != e.toString()).toList();
      }
    }));

    if (mods.isEmpty) {
      setState(() {
        done = true;
        unsupportedMods = true;
      });
      onDownloadsFinished();
      return;
    }

    setState(() {
      currentMod = mods.first;
      loadingState = 1;
    });
    await downloadService.init();
    setState(() {
      currentMod = mods.first;
      loadingState = 2;
    });
    int lastChunk = 0;
    int lastTotal = 0;
    downloadService.onReceiveProgress().listen((event) {
      setState(() {
        received = int.parse(event.received);
        total = int.parse(event.total);
        progress = received / total * 100;
      });
      lastTotal = (received - lastChunk);
      WindowsTaskbar.setProgress(received, total);
    });

    downloadSpeedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (loadingState != 3) {
        setState(() => speed = 0);
        return;
      }
      lastChunk += lastTotal;
      setState(() => speed = lastTotal);
    });
    await downloadService
        .startDownload(
      onWebsiteOpened: () {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
        setState(() => loadingState = 3);
      },
      context: context,
      onClose: () => Navigator.of(context).pop(),
      onFileInfo: (i) => setState(() => downloadInfo = i),
      onExtracting: () => setState(() {
        loadingState = 4;
        speed = 0;
      }),
      mods: mods.map((e) => e.toString()).toList(),
      onNextMod: (String s) {
        setState(() {
          total = 0;
          progress = 0;
          received = 0;
          speed = 0;
          currentMod = mods.firstWhere((element) => s == element.toString());
          loadingState = 2;
        });
      },
    )
        .catchError((e) async {
      if (e.toString() == 'LoginError') {
        Navigator.of(context).pop();
        close();
        NotificationService.showNotification(message: 'Login expired. Please login again!', color: Colors.red);
        await showDialog(context: context, builder: (c) => const NexusmodsLogin());
        showDialog(context: navigatorKey.currentContext!, builder: (context) => ServerDialog(server: widget.server));
      }
    });
    onDownloadsFinished();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingState < 2 && !done) {
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
            translate(loadingState == 1 ? '$prefix.loading_states.0' : '$prefix.loading_states.checking_mods'),
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
            child: ProgressBar(value: progress >= 0 && progress <= 100 ? progress : 0),
          ),
        ),
        const SizedBox(height: 5),
        Text('${formatBytes(received, 1)} / ${formatBytes(total, 1)} (${formatBytes(speed, 1)}/s)', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        Text(translate('$prefix.file', args: {'0': downloadInfo?.fileName ?? '-'})),
        if (loadingState == 2 || loadingState == 4)
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
                  translate('$prefix.loading_states.${(loadingState - 1).toString()}'),
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
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
