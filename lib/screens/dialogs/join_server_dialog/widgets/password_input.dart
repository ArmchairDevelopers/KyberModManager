import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({Key? key, required this.onChanged, required this.checkPassword, required this.focusNode}) : super(key: key);

  final Function(String) onChanged;
  final Function(String) checkPassword;
  final FocusNode focusNode;

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.addListener(() => widget.onChanged(controller.text));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
      label: translate("enter_password"),
      child: TextBox(
        controller: controller,
        autofocus: true,
        placeholder: translate('password'),
        focusNode: widget.focusNode,
        onSubmitted: widget.checkPassword,
      ),
    );
  }
}
