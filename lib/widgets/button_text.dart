import 'package:fluent_ui/fluent_ui.dart';

class ButtonText extends StatelessWidget {
  const ButtonText({Key? key, required this.text, required this.icon}) : super(key: key);

  final Icon icon;
  final Text text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        text,
      ],
    );
  }
}
