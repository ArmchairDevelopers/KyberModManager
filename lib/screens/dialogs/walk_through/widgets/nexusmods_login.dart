import 'dart:async';
import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:puppeteer/puppeteer.dart' as puppeteer;
import 'package:webview_windows/webview_windows.dart';

class NexusmodsLogin extends StatefulWidget {
  const NexusmodsLogin({Key? key}) : super(key: key);

  @override
  _NexusmodsLoginState createState() => _NexusmodsLoginState();
}

class _NexusmodsLoginState extends State<NexusmodsLogin> {
  final WebviewController _controller = WebviewController();
  final String _mainPage = 'https://www.nexusmods.com/starwarsbattlefront22017';
  final String prefix = 'nexus_mods_login';
  late StreamSubscription _subscription;

  puppeteer.Browser? _browser;

  bool browserOpen = false;
  bool showOverlay = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    if (!box.containsKey('nexusmods_login')) {
      box.put('nexusmods_login', false);
    }
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    await _controller.initialize();

    _subscription = _controller.url.listen((url) async {
      if (url == "https://users.nexusmods.com/account/profile/edit") {
        setState(() => showOverlay = true);
        await _controller.loadUrl(
            'https://users.nexusmods.com/oauth/authorize?client_id=nexus&redirect_uri=https://www.nexusmods.com/oauth/callback&response_type=code&referrer=$_mainPage');
        _browser?.close();
        if (!mounted) return;
        await Future.delayed(const Duration(seconds: 3));
        List<puppeteer.CookieParam> cookies = [];
        for (var cookie in jsonDecode(await _controller.getCookies())['cookies']) {
          cookies.add(puppeteer.CookieParam.fromJson(cookie));
        }

        await box.put('cookies', cookies.map((e) => e.toJson()).toList());
        await box.put('nexusmods_login', true);
        if (!mounted) return;
        Navigator.of(context).pop();
      } else if (!url.contains('nexusmods') ||! url.startsWith("https://users.nexusmods.com") &&! showOverlay) {
        _controller.loadUrl('https://users.nexusmods.com/auth/sign_in');
      }
    });

    await _controller.clearCache();
    await _controller.clearCookies();
    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl('https://users.nexusmods.com/auth/sign_in');

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxWidth: browserOpen ? 1000 : 600, maxHeight: browserOpen ? 857 : 400),
      title: Text(translate('$prefix.title')),
      actions: [
        Button(
          child: Text(translate('$prefix.buttons.skip')),
          onPressed: () {
            box.put('nexusmods_login', false);
            if (_browser != null) {
              _browser!.close();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        FilledButton(
          onPressed: browserOpen
              ? null
              : () async {
                  setState(() => browserOpen = true);
                },
          child: Text(translate(!browserOpen ? 'continue' : '$prefix.buttons.waiting')),
        ),
      ],
      content: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: browserOpen
              ? [
                  Expanded(
                    child: Stack(
                      children: [
                        Webview(
                          _controller,
                        ),
                        if (showOverlay)
                          Positioned.fill(
                            child: Container(
                              color: FluentTheme.of(context).micaBackgroundColor.withOpacity(.9),
                              alignment: Alignment.center,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: ProgressRing(),
                                    ),
                                    SizedBox(width: 15),
                                    Text(
                                      'Waiting for NexusMods...',
                                      style: TextStyle(fontSize: 19),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]
              : [
                  Text(
                    translate('$prefix.text_0'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(translate('$prefix.text_2'), style: const TextStyle(fontSize: 14)),
                ],
        ),
      ),
    );
  }
}
