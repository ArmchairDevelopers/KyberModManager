import 'package:flutter/foundation.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:puppeteer/plugins/stealth.dart';
import 'package:puppeteer/puppeteer.dart';

class PuppeteerHelper {
  static Browser? _browser;
  static const int _height = 1080;
  static const int _width = 1920;

  static Future<Browser> startBrowser({Function? onClose, Function? onBrowserCreated}) async {
    if (_browser != null) {
      await _browser?.close();
      _browser = null;
    }

    _browser = await puppeteer.launch(
      executablePath: kDebugMode ? null : './970485/chrome-win/chrome.exe',
      args: [
        '--window-size=$_width,$_height',
        '--window-position=0,0',
        '--no-sandbox',
        '--disable-infobars',
        '--ignore-certifcate-errors',
        '--ignore-certifcate-errors-spki-list',
        '--lang=en-EN,en',
      ],
      headless: true,
      plugins: [
        StealthPlugin(),
      ],
    );
    if (onBrowserCreated != null) {
      onBrowserCreated(_browser);
    }
    var page = (await _browser!.pages).first;
    _browser!.disconnected.asStream().listen((event) => onClose != null ? onClose() : null);
    if (box.containsKey('cookies') && box.containsKey('nexusmods_login')) {
      await page.setCookies(List<CookieParam>.from(box.get('cookies').map((cookie) => CookieParam.fromJson(Map<String, dynamic>.from(cookie))).toList()));
    }
    return _browser!;
  }

  static Future<void> initializePage(Page page) async {
    String downloadPath = box.get('frostyPath') + '\\Mods\\starwarsbattlefrontii';
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36');
    await page.setViewport(const DeviceViewport(width: _width, height: _height, deviceScaleFactor: 2));
    page.browser.connection.send('Browser.setDownloadBehavior', {
      'behavior': 'allow',
      'downloadPath': downloadPath,
    });
    var t = await page.evaluate("() => document.querySelector('.qc-cmp2-publisher-logo-container')");
    if (t != null) await page.click('button[class\$=" css-47sehv"]');
  }
}
