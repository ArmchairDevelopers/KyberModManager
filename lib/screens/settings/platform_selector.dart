import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';

class PlatformSelector extends StatefulWidget {
  const PlatformSelector({Key? key}) : super(key: key);

  @override
  _PlatformSelectorState createState() => _PlatformSelectorState();
}

class _PlatformSelectorState extends State<PlatformSelector> {
  final String prefix = 'settings.platform_selector';
  String platform = 'origin';

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: true,
      title: Text(translate('$prefix.title')),
      constraints: const BoxConstraints(maxWidth: 500),
      actions: [
        Button(
          child: Text(translate('close')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          child: Text(translate('$prefix.enable')),
          onPressed: () {
            Navigator.of(context).pop(platform.toLowerCase());
          },
        ),
      ],
      content: InfoLabel(
        label: translate('$prefix.subtitle'),
        child: Combobox<String>(
          value: platform,
          onChanged: (v) => setState(() => platform = v ?? 'Origin'),
          isExpanded: true,
          items: ['Origin', 'EA Desktop', 'Epic Games'].map((e) {
            return ComboboxItem(
              child: Text(e),
              value: e.toLowerCase(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
