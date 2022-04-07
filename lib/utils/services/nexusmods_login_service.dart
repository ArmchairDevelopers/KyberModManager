import 'dart:async';

import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/puppeteer_helper.dart';
import 'package:puppeteer/puppeteer.dart';

class NexusmodsLoginService {
  static const String _mainPage = 'https://www.nexusmods.com/starwarsbattlefront22017';
  static late Page _page;

  static Future<Browser> init({required Function onClose, required Function onCreated, required Function onLoginSuccessful}) async {
    var browser = await PuppeteerHelper.startBrowser(onClose: onClose, headless: false);
    onCreated(browser);
    _page = (await browser.pages).first;
    await PuppeteerHelper.initializePage(_page);
    await _page.goto("https://users.nexusmods.com/auth/sign_in", wait: Until.networkAlmostIdle);
    _page.onFrameNavigated.listen((event) async {
      if (event.url == "https://users.nexusmods.com/account/profile/edit") {
        await Future.delayed(const Duration(milliseconds: 1000));
        await _page.goto(
          'https://users.nexusmods.com/oauth/authorize?client_id=nexus&redirect_uri=https://www.nexusmods.com/oauth/callback&response_type=code&referrer=$_mainPage',
          wait: Until.domContentLoaded,
        );
        await box.put('cookies', (await _page.cookies()).map((e) => e.toJson()).toList());
        await box.put('nexusmods_login', true);
        onLoginSuccessful();
      }
    });
    return browser;
  }
}

enum LoginType {
  NOT_LOGGED_IN,
  LOGGED_IN,
  TWO_FACTOR_AUTH,
}
