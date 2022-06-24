import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/nexusmods_login_service.dart';
import 'package:puppeteer/puppeteer.dart' as puppeteer;

class NexusmodsLogin extends StatefulWidget {
  const NexusmodsLogin({Key? key}) : super(key: key);

  @override
  _NexusmodsLoginState createState() => _NexusmodsLoginState();
}

class _NexusmodsLoginState extends State<NexusmodsLogin> {
  final String prefix = 'nexus_mods_login';
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  puppeteer.Browser? _browser;

  bool browserOpen = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
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
                  NexusmodsLoginService.init(
                    onClose: () => mounted ? Navigator.of(context).pop() : null,
                    onCreated: (v) => _browser = v,
                    onLoginSuccessful: () => _browser?.close(),
                  ).then(
                    (value) => setState(() => _browser = value),
                  );
                },
          child: Text(translate(!browserOpen ? 'continue' : '$prefix.buttons.waiting')),
        ),
      ],
      content: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: browserOpen
              ? [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                            width: 30,
                            child: ProgressRing(),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            translate('$prefix.waiting_for_login'),
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
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
