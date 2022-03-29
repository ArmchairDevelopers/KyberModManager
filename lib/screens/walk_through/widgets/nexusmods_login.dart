import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/nexusmods_login_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
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

  bool disabled = false;
  bool loadedSite = false;
  bool twoFactor = false;

  @override
  void initState() {
    NexusmodsLoginService.init(() => mounted ? Navigator.of(context).pop() : null, (v) => _browser = v).then(
      (value) => setState(() {
        loadedSite = true;
        _browser = value;
      }),
    );
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
    _browser?.close();
    super.dispose();
  }

  void login() async {
    setState(() => disabled = true);
    if (!twoFactor) {
      var s = await NexusmodsLoginService.login(emailController.text, passwordController.text);
      if (s == LoginType.NOT_LOGGED_IN) {
        setState(() => disabled = false);
        NotificationService.showNotification(message: translate('$prefix.notifications.invalid_credentials'), color: Colors.red);
        return;
      } else if (s == LoginType.TWO_FACTOR_AUTH) {
        emailController.text = '';
        setState(() {
          disabled = false;
          twoFactor = true;
        });
        return;
      }
    } else {
      var s = await NexusmodsLoginService.validateTwoFactor(emailController.text);
      if (!s) {
        setState(() => disabled = false);
        NotificationService.showNotification(message: translate('$prefix.notifications.invalid_code'), color: Colors.red);
        return;
      }
    }
    NotificationService.showNotification(message: translate('$prefix.notifications.login_success'));
    await box.put('nexusmods_login', true);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 700),
      title: Text(translate('$prefix.title')),
      actions: [
        Button(
          child: Text(translate('$prefix.buttons.skip')),
          onPressed: () {
            box.put('nexusmods_login', false);
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          child: Text(loadedSite ? translate('login') : translate('$prefix.buttons.loading')),
          onPressed: disabled || !loadedSite ? null : login,
        ),
      ],
      content: SizedBox(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text('Nexusmods Login', style: TextStyle(fontSize: 16)),
            // const SizedBox(height: 20),
            ...buildContent(),
            const SizedBox(height: 16),
            Text(translate('$prefix.text_1'), style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(translate('$prefix.text_2')),
          ],
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    if (twoFactor) {
      return [
        TextBox(
          onSubmitted: (String s) => FocusScope.of(context).requestFocus(passwordFocusNode),
          controller: emailController,
          autofocus: true,
          header: translate('$prefix.two_factor.header'),
          placeholder: '123 456',
        ),
        const SizedBox(height: 16),
        Text(translate('$prefix.two_factor.description'), style: const TextStyle(fontSize: 16)),
      ];
    }

    return [
      TextBox(
        onSubmitted: (String s) => FocusScope.of(context).requestFocus(passwordFocusNode),
        controller: emailController,
        autofocus: true,
        header: translate('$prefix.login.email'),
        placeholder: 'example@gmail.com',
      ),
      const SizedBox(height: 16),
      TextBox(
        focusNode: passwordFocusNode,
        controller: passwordController,
        onSubmitted: (s) => login(),
        header: translate('$prefix.login.password'),
        obscureText: true,
        placeholder: '1234',
      ),
    ];
  }
}
