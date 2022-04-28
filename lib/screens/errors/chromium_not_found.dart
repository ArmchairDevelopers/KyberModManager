import 'package:fluent_ui/fluent_ui.dart';

class ChromiumNotFound extends StatelessWidget {
  const ChromiumNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Chromium was not found. To fix this, you need to reinstall Kyber Mod Manager.'),
    );
  }
}
