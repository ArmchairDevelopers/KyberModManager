import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_profile.dart';

class FrostyProfileSelector extends StatefulWidget {
  const FrostyProfileSelector({Key? key, this.onSelected}) : super(key: key);

  final Function(List<dynamic> mods)? onSelected;

  @override
  _FrostyProfileSelectorState createState() => _FrostyProfileSelectorState();
}

class _FrostyProfileSelectorState extends State<FrostyProfileSelector> {
  late List<FrostyProfile> profiles;
  String? value;

  @override
  void initState() {
    profiles = FrostyProfileService.getProfilesWithMods();
    value = profiles.first.name;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: Text(translate('select_frosty_profile.title')),
      actions: [
        Button(
          child: Text(translate('close')),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: Text(translate('load')),
          onPressed: () {
            if (widget.onSelected != null) {
              widget.onSelected!(profiles.firstWhere((p) => p.name == value).mods);
            }
            Navigator.of(context).pop(profiles.firstWhere((p) => p.name == value));
          },
        ),
      ],
      content: InfoLabel(
        label: translate('select_frosty_profile.label'),
        child: ComboBox<String>(
          value: value,
          onChanged: (v) => setState(() => value = v),
          isExpanded: true,
          items: profiles.map((e) {
            return ComboBoxItem(
              value: e.name,
              child: Text(e.name),
            );
          }).toList(),
        ),
      ),
    );
  }
}
