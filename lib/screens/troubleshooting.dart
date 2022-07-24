import 'package:fluent_ui/fluent_ui.dart';

class Troubleshooting extends StatefulWidget {
  Troubleshooting({Key? key}) : super(key: key);

  @override
  State<Troubleshooting> createState() => _TroubleshootingState();
}

class _TroubleshootingState extends State<Troubleshooting> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Troubleshooting'),
      ),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Expander(
            header: const Text('Kyber related errors'),
            initiallyExpanded: true,
            content: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                Expander(
                  header: const Text('Requires mods, but client did not send any.'),
                  content: const Text('This is the content'),
                ),
                Expander(
                  header: const Text("Kyber won't inject properly and BF2 just loads into the main menu."),
                  content: const Text('This is the content'),
                ),
              ],
            ),
          ),
          Expander(
            header: const Text('Frosty related errors'),
            initiallyExpanded: true,
            content: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                Expander(
                  header: const Text('123123123123'),
                  content: const Text('This is the content'),
                ),
                Expander(
                  header: const Text("Kyber won't inject properly and BF2 just loads into the main menu."),
                  content: const Text('This is the content'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
