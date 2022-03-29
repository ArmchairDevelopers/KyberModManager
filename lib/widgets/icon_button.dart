import 'package:fluent_ui/fluent_ui.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({Key? key, required this.text, required this.icon}) : super(key: key);
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
