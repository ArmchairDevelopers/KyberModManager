import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/errors/chromium_not_found.dart';
import 'package:kyber_mod_manager/utils/services/navigator_service.dart';
import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';

class PuppeteerHelper {
  static const String _chromiumPath = './970485/chrome-win/chrome.exe';
  static Browser? _browser;

  static void checkFiles() {
    if (kDebugMode) {
      return;
    }

    var file = File(_chromiumPath);
    if (!file.existsSync()) {
      NavigatorService.pushErrorPage(const ChromiumNotFound());
      throw Exception('Chromium not found');
    }
  }

  static Future<Browser> startBrowser({Function? onClose, Function? onBrowserCreated, bool headless = true, bool asApp = true}) async {
    if (_browser != null) {
      await _browser?.close().catchError((e) => null);
      _browser = null;
    }

    _browser = await puppeteer.launch(
      executablePath: kDebugMode ? null : _chromiumPath,
      defaultViewport: null,
      args: [
        '--ignore-certifcate-errors',
        '--ignore-certifcate-errors-spki-list',
        '--lang=en-EN,en',
        '--start-maximized',
        '--suppress-message-center-popups',
        asApp ? '--app=https://nexusmods.com/starwarsbattlefront22017/' : '',
      ],
      ignoreDefaultArgs: ['--enable-automation'],
      headless: headless,
      plugins: [
        StealthPlugin(),
      ],
    );
    if (onBrowserCreated != null) {
      onBrowserCreated(_browser);
    }
    var page = (await _browser!.pages).first;
    _browser!.disconnected.asStream().listen((event) {
      onClose != null ? onClose() : null;
      _browser = null;
    });

    if (box.containsKey('cookies') && box.containsKey('nexusmods_login')) {
      await page.setCookies(List<CookieParam>.from(box.get('cookies').map((cookie) => CookieParam.fromJson(Map<String, dynamic>.from(cookie))).toList()));
    }
    return _browser!;
  }

  static Future<void> initializePage(Page page) async {
    String downloadPath = box.get('frostyPath') + '\\Mods\\starwarsbattlefrontii';
    page.browser.connection.send('Browser.setDownloadBehavior', {
      'behavior': 'allow',
      'downloadPath': downloadPath,
    });
    var t = await page.evaluate("() => document.querySelector('.qc-cmp2-publisher-logo-container')");
    if (t != null) await page.click('button[class\$=" css-47sehv"]');
  }
}
