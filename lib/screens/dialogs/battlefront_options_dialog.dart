import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/battlefront_options.dart';

class BattlefrontOptionsDialog extends StatefulWidget {
  const BattlefrontOptionsDialog({Key? key}) : super(key: key);

  @override
  State<BattlefrontOptionsDialog> createState() => _BattlefrontOptionsDialogState();
}

class _BattlefrontOptionsDialogState extends State<BattlefrontOptionsDialog> {
  BattlefrontProfileOptions? options;

  @override
  void initState() {
    BattlefrontOptions.getOptions().then((value) => setState(() => options = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 400),
      title: const Text("Battlefront Settings"),
      actions: [
        Button(
          onPressed: () {
            box.put('skipOptionsCheck', true);
            Navigator.of(context).pop();
          },
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () async {
            await BattlefrontOptions.setConfig();
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('BF2 Settings'),
        ),
      ],
      content: Center(
        child: Column(
          children: [
            const Text('text'),
            const SizedBox(
              height: 20,
            ),
            if (options?.enableDx12 ?? false)
              const Text(
                'dx12',
              ),
            if (options?.fullscreenEnabled ?? false)
              const Text(
                'fullscreen',
                style: TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }
}
