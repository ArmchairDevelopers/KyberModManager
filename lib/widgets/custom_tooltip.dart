import 'package:fluent_ui/fluent_ui.dart';

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      style: const TooltipThemeData(
        padding: EdgeInsets.all(8),
      ),
      message: message,
      child: const Icon(
        FluentIcons.status_circle_question_mark,
        size: 22,
      ),
    );
  }
}
