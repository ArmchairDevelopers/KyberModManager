import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:kyber_mod_manager/utils/services/download_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:puppeteer/puppeteer.dart' hide Key;

class ModBrowser extends StatefulWidget {
  const ModBrowser({Key? key}) : super(key: key);

  @override
  State<ModBrowser> createState() => _ModBrowserState();
}

class _ModBrowserState extends State<ModBrowser> {
  Browser? browser;
  StreamSubscription<FileSystemEvent>? fileStream;
  bool browserOpen = false;
  bool disabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    closeBrowser(true);
    super.dispose();
  }

  void closeBrowser([dispose = false]) async {
    if (!mounted) return;
    browser?.close();
    fileStream?.cancel();
    if (dispose) return;
    setState(() {
      browserOpen = false;
      disabled = false;
    });
  }

  void openBrowser() async {
    setState(() => disabled = true);
    browser = await PuppeteerHelper.startBrowser(headless: false, asApp: false, onClose: () => closeBrowser());
    var page = (await browser!.pages).first;
    // await page.goto('https://www.nexusmods.com/starwarsbattlefront22017/', wait: Until.networkIdle);
    await PuppeteerHelper.initializePage(page);

    final String path = '${box.get('frostyPath')}\\mods\\starwarsbattlefrontii\\';
    fileStream = Directory(path).watch().listen((event) async {
      if (event.type != 2 || (!event.path.endsWith('.zip') && !event.path.endsWith('.rar'))) {
        return;
      }

      Logger.root.info('Installing ${basename(event.path)}');
      await compute(DownloadService.unpackFile, [path, basename(event.path)]);
      Logger.root.info('Installed');
      ModService.loadMods();
    });

    setState(() {
      browserOpen = true;
      disabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Mod Browser'),
      ),
      content: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: browserOpen
            ? FilledButton(
                onPressed: disabled ? null : () => closeBrowser(),
                child: const Text('Close Browser'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('This page opens a browser for Nexusmods.com. All mods you download will be installed automatically.'),
                  const SizedBox(
                    height: 20,
                  ),
                  FilledButton(
                    onPressed: disabled ? null : () => openBrowser(),
                    child: const Text('Open Browser'),
                  ),
                ],
              ),
      ),
    );
  }
}
