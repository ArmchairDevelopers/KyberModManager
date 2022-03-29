import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:puppeteer/puppeteer.dart';

class NexusmodsLoginService {
  static const String _mainPage = 'https://www.nexusmods.com/starwarsbattlefront22017';
  static late Page _page;

  static Future<Browser> init(Function onClose, Function onCreated) async {
    var browser = await PuppeteerHelper.startBrowser(onClose: onClose);
    onCreated(browser);
    _page = (await browser.pages).first;
    await _page.goto(_mainPage, wait: Until.networkAlmostIdle);
    await PuppeteerHelper.initializePage(_page);
    await _page.click('a[id\$="login"]');
    await _page.waitForNavigation(wait: Until.networkIdle);
    await _page
        .waitForFunction('document.getElementsByClassName("max-width-520").length > 0', polling: Polling.interval(const Duration(milliseconds: 500)))
        .catchError(
      (e) {
        if (e is TimeoutException) {
          browser.close();
          NotificationService.showNotification(message: 'Failed to load NexusMods login page.', color: ui.Colors.red);
          onClose();
          throw Exception('Nexusmods login page timed out');
        }
      },
    );
    return browser;
  }

  static Future<bool> validateTwoFactor(String code) async {
    await _page.type('input[id\$="otp_attempt"]', code);
    await _page.keyboard.press(Key.enter);
    await _page.waitForNavigation(wait: Until.domContentLoaded);
    return _checkUrl();
  }

  static Future<LoginType> login(String email, String password) async {
    await _page.type('input[id\$="user_login"]', email, delay: const Duration(milliseconds: 10));
    await _page.type('input[id\$="password"]', password, delay: const Duration(milliseconds: 10));
    await _page.keyboard.press(Key.enter);
    await _page.waitForNavigation(wait: Until.domContentLoaded);
    var success = await _checkUrl();
    if (!success) {
      return LoginType.NOT_LOGGED_IN;
    }
    var twoFactor = await _page.evaluate("document.querySelector('.btn-primary')?.dataset?.disableWith == 'Verify'");
    if (twoFactor) {
      return LoginType.TWO_FACTOR_AUTH;
    }
    await box.put('cookies', (await _page.cookies()).map((e) => e.toJson()).toList());
    return LoginType.LOGGED_IN;
  }

  static Future<bool> _checkUrl() async {
    if (_page.url!.contains('https://users.nexusmods.com/account/profile/edit')) {
      await _page.goto(
        'https://users.nexusmods.com/oauth/authorize?client_id=nexus&redirect_uri=https://www.nexusmods.com/oauth/callback&response_type=code&referrer=$_mainPage',
        wait: Until.domContentLoaded,
      );
    }
    return _page.url!.contains(_mainPage);
  }
}

enum LoginType {
  NOT_LOGGED_IN,
  LOGGED_IN,
  TWO_FACTOR_AUTH,
}
