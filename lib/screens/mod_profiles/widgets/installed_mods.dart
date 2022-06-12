import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/mod_category.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';

class InstalledMods extends StatefulWidget {
  const InstalledMods({Key? key, required this.activeMods, required this.onAdd, this.excludedCategories, this.kyber = false}) : super(key: key);

  final List<dynamic> activeMods;
  final bool kyber;
  final List<String>? excludedCategories;
  final Function(dynamic) onAdd;

  @override
  _InstalledModsState createState() => _InstalledModsState();
}

class _InstalledModsState extends State<InstalledMods> {
  String search = '';

  bool filterMods(String value) => widget.activeMods.where((element1) => value == element1.filename).isEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          translate('edit_mod_profile.installed_mods'),
          style: TextStyle(color: Colors.white.withOpacity(.7)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          child: TextBox(
            onChanged: (String? value) => setState(() => search = value ?? ''),
            placeholder: translate('search'),
          ),
        ),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => InstalledModCategory(
                activeMods: widget.activeMods,
                onAdd: widget.onAdd,
                index: index,
                kyberCategories: widget.kyber,
                search: search,
                excludedCategories: widget.excludedCategories,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: ModService.getModsByCategory(widget.kyber).length,
            ),
          ),
        ),
      ],
    );
  }
}
