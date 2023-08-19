import 'package:fluent_ui/fluent_ui.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({Key? key, required this.child, this.color, required this.onPressed, this.disabled = false}) : super(key: key);
  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: disabled ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: color != null
            ? ButtonState.resolveWith((states) {
                var accentColor = color!.toAccentColor();
                if (states.isDisabled) {
                  return FluentTheme.of(context).inactiveColor;
                } else if (states.isPressing) {
                  return accentColor.darker;
                } else if (states.isHovering) {
                  return accentColor.dark;
                }
                return color;
              })
            : null,
      ),
      child: child,
    );
  }
}
