import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart' show Colors, BuildContext;
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/unzip_helper.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:logging/logging.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DownloadService {
  late Browser _browser;
  late Page _page;
  late BuildContext context;
  late String _downloadFolder;
  bool _done = false;
  bool _initializedPage = false;
  Timer? _timer;
  StreamController<_DownloadInfo>? _progressController;
  StreamSubscription? _progressSubscription;

  Future<void> init() async {
    _downloadFolder = box.get('frostyPath') + '\\Mods\\starwarsbattlefrontii\\';
    _browser = await PuppeteerHelper.startBrowser(
      onClose: () {
        if (!_done) {
          _timer?.cancel();
          _progressController?.close();
          _progressSubscription?.cancel();
        }
      },
    );
    _page = (await _browser.pages).first;
    _progressController = StreamController<_DownloadInfo>.broadcast();
  }

  Stream<_DownloadInfo> onReceiveProgress() => _progressController!.stream;

  void close() {
    if (!_done) {
      _progressController?.close();
      _progressSubscription?.cancel();
    }
    _browser
        .close()
        .then((value) => Directory(_downloadFolder).listSync().where((element) => element.path.endsWith('.crdownload')).forEach((element) => element.deleteSync()));
  }

  Future<void> startDownload({
    required List<String> mods,
    required Function onWebsiteOpened,
    required Function onFileInfo,
    required Function onExtracting,
    required Function onNextMod,
    required Function onClose,
    required BuildContext context,
  }) async {
    this.context = context;
    await Future.forEach(mods, (String element) async {
      if (mods.indexOf(element) != 0) {
        onNextMod(element);
      }
      if (ModService.isInstalled(element)) {
        Logger.root.info('$element is already installed');
        return;
      }
      DownloadInfo? info = await ApiService.getDownloadInfo(element);
      if (info == null) {
        Logger.root.severe('Could not find download info for $element');
        return;
      }
      onFileInfo(info);
      String filename = await _download(info.fileUrl + '?tab=files&file_id=' + info.fileId, info, onClose, onWebsiteOpened);
      onExtracting();
      await _unpackFile(filename);
    });
    _done = true;
    await _browser.close();
  }

  Future<String> _download(String url, DownloadInfo info, Function onClose, Function? onDone) async {
    await _page.goto(url, wait: Until.networkAlmostIdle);
    if (!_initializedPage) {
      await PuppeteerHelper.initializePage(_page);
      _initializedPage = true;
    }
    bool isPremium = await _page.evaluate(r'''document.querySelectorAll('#startDownloadButton').length > 0''');
    await _page.click(isPremium ? 'button[id\$="startDownloadButton"]' : 'button[id\$="slowDownloadButton"]').onError((error, stackTrace) async {
      await _page
          .screenshot(fullPage: true)
          .then((value) => File('$applicationDocumentsDirectory\\${DateTime.now().toString().replaceAll(':', '-')}.png').writeAsBytesSync(value));
      NotificationService.showNotification(message: 'Download button not found! Please try again!', color: Colors.red);
      close();
      onClose();
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    });
    String filename = await _page.evaluate(r'''document.querySelectorAll('.page-layout .header')[0].innerHTML.split('<')[0]''');
    String name = filename.substring(0, filename.lastIndexOf('.'));
    String extension = filename.split('.').last;
    final Completer<String> downloadCompleter = Completer<String>();
    final Completer<String> fileCompleter = Completer<String>();
    _progressSubscription = Directory(_downloadFolder)
        .watch(events: FileSystemEvent.modify)
        .firstWhere((element) => element.path.contains(name) && element.path.endsWith(extension))
        .asStream()
        .listen((element) async => fileCompleter.complete(filename));
    _progressSubscription = _page.onResponse.firstWhere((element) => element.url.contains(extension)).asStream().listen((value) {
      downloadCompleter.complete(value.headers['content-length']);
    });
    String size = await downloadCompleter.future;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      File file = File('$_downloadFolder$filename.crdownload');
      if (file.existsSync() && !_progressController!.isClosed) {
        _progressController?.add(_DownloadInfo(size, file.lengthSync().toString()));
      }
    });
    if (onDone != null) {
      onDone();
    }
    await fileCompleter.future;
    _progressController?.add(_DownloadInfo(size, size));
    _timer?.cancel();
    return filename;
  }

  Future<void> _unpackFile(String filename) async {
    if (!filename.endsWith('.rar')) {
      final inputStream = InputFileStream('$_downloadFolder$filename');
      final archive = ZipDecoder().decodeBuffer(inputStream, verify: false);
      for (var file in archive.files) {
        final outputStream = OutputFileStream(_downloadFolder + file.name);
        file.writeContent(outputStream);
        outputStream.close();
      }
      archive.clear();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      await UnzipHelper.unrar(File('$_downloadFolder$filename'), Directory(_downloadFolder)).catchError((error) {
        NotificationService.showNotification(message: error.toString(), color: Colors.red);
        Logger.root.severe('Could not unrar $filename. $error');
      });
    }
    await File('$_downloadFolder\\$filename').delete();
    await ModService.loadMods();
  }
}

class _DownloadInfo {
  final String total;
  final String received;

  _DownloadInfo(this.total, this.received);
}
