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
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              translate('feedback.description'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
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
    );
  }
}
