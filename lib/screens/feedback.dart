import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Feedback extends StatefulWidget {
  const Feedback({Key? key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('feedback.title')),
      ),
      content: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Kyber Mod Manager: ',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://discord.gg/t2YBaHqbkb'),
                        color: const Color.fromRGBO(88, 101, 242, 1),
                        child: const Text(
                          'Discord',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://github.com/7reax/kyber-mod-manager'),
                        color: Colors.grey,
                        child: const Text(
                          'GitHub',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Frosty Mod Manager: ',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://discord.gg/DSW2cU6Ywq'),
                        color: const Color.fromRGBO(88, 101, 242, 1),
                        child: const Text(
                          'Discord',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://github.com/CadeEvs/FrostyToolsuite'),
                        color: Colors.grey,
                        child: const Text(
                          'GitHub',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Kyber: ',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://discord.gg/kyber'),
                        color: const Color.fromRGBO(88, 101, 242, 1),
                        child: const Text(
                          'Discord',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://twitter.com/KyberServers'),
                        color: const Color.fromRGBO(29, 161, 242, 1),
                        child: const Text(
                          'Twitter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://github.com/BattleDash/Kyber'),
                        color: Colors.grey,
                        child: const Text(
                          'GitHub',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomFilledButton(
                        onPressed: () => launchUrlString('https://patreon.com/KyberServers'),
                        color: const Color.fromRGBO(249, 104, 84, 1),
                        child: const Text(
                          'Patreon',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
