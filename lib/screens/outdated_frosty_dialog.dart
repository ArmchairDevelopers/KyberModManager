import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';

class OutdatedFrostyDialog extends StatefulWidget {
  OutdatedFrostyDialog({Key? key}) : super(key: key);

  @override
  State<OutdatedFrostyDialog> createState() => _OutdatedFrostyDialogState();
}

class _OutdatedFrostyDialogState extends State<OutdatedFrostyDialog> {
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text("Outdated Frosty"),
      actions: [
        Button(
          onPressed: () {
            box.put('skipFrostyVersionCheck', true);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // TODO: update frosty
          },
          child: const Text('Update Frosty'),
        ),
      ],
      content: const Text(''),
    );
  }
}
