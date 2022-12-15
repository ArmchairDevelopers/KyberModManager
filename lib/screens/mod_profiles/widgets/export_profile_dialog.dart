import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';

class ExportProfileDialog extends StatefulWidget {
  const ExportProfileDialog({Key? key, required this.profile, this.enableCosmetics = true}) : super(key: key);

  final ModProfile profile;
  final bool enableCosmetics;

  @override
  _ExportProfileDialogState createState() => _ExportProfileDialogState();
}

class _ExportProfileDialogState extends State<ExportProfileDialog> {
  final TextEditingController _controller = TextEditingController();
  final String prefix = "export_profile_dialog";
  String selectedType = "Frosty Pack";
  bool cosmetics = false;

  @override
  void initState() {
    _controller.text = widget.profile.name;
    super.initState();
  }

  void export() {
    if (selectedType == "Frosty Pack") {
      List<dynamic> cosmeticMods = List<dynamic>.from(box.get('cosmetics'));
      FrostyProfileService.createProfile([
        ...widget.profile.mods.map((e) => e.toKyberString()).toList(),
        if (cosmetics) ...cosmeticMods.map((e) => e.toKyberString()).toList(),
      ], _controller.text);
      Navigator.of(context).pop();
    } else {
      // TODO: Export to json
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(translate('$prefix.title')),
      actions: [
        Button(
          child: Text(translate('close')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(onPressed: export, child: Text(translate('$prefix.export'))),
      ],
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 325),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: translate('$prefix.export_type'),
            child: ComboBox(
              value: 'Frosty Pack',
              isExpanded: true,
              onChanged: (String? e) => setState(() => selectedType = e ?? 'Frosty Pack'),
              items: [
                'Frosty Pack' /*, 'File'*/
              ].map((e) => ComboBoxItem(value: e, child: Text(e))).toList(),
            ),
          ),
          const SizedBox(height: 15),
          TextBox(
            controller: _controller,
            header: translate('$prefix.export_type'),
          ),
          if (widget.enableCosmetics) ...[
            const SizedBox(height: 15),
            Checkbox(
              checked: cosmetics,
              onChanged: (value) => setState(() => cosmetics = value ?? false),
              content: Text(translate('$prefix.include_cosmetics')),
            ),
          ],
        ],
      ),
    );
  }
}
