import 'package:fluent_ui/fluent_ui.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard(
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.child})
      : super(key: key);

  final IconData icon;
  final Widget title;
  final Widget subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(fontSize: 17),
                    child: title,
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(fontSize: 13),
                    child: subtitle,
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
