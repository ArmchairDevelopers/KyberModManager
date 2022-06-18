import 'package:fluent_ui/fluent_ui.dart';

class SymlinksDialog extends StatefulWidget {
  SymlinksDialog({Key? key}) : super(key: key);

  @override
  State<SymlinksDialog> createState() => _SymlinksDialogState();
}

class _SymlinksDialogState extends State<SymlinksDialog> {
  bool _disabled = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () => mounted ? setState(() => _disabled = false) : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: true,
      constraints: const BoxConstraints(maxWidth: 600, minHeight: 400, maxHeight: 400),
      title: const Text("Symlinks"),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _disabled ? null : () => Navigator.of(context).pop(true),
          child: const Text('Activate'),
        )
      ],
      content: SizedBox(
        height: 250,
        child: Container(
          alignment: Alignment.center,
          child: const Text.rich(
            TextSpan(
              text: 'If you enable this feature, you must',
              style: TextStyle(fontSize: 17),
              children: <TextSpan>[
                TextSpan(text: ' always ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: 'start KMM as '),
                TextSpan(text: 'admin.', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: '\nOtherwise the saved profile generation will not work'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
