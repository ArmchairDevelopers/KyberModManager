import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

class InstalledMods extends StatefulWidget {
  const InstalledMods({Key? key, required this.activeMods, required this.onAdd, this.excludedCategories}) : super(key: key);

  final List<Mod> activeMods;
  final List<String>? excludedCategories;
  final Function(Mod) onAdd;

  @override
  _InstalledModsState createState() => _InstalledModsState();
}

class _InstalledModsState extends State<InstalledMods> {
  String search = '';

  bool filterMods(String value) => widget.activeMods.where((element1) => value == element1.filename).isEmpty;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14);

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
          child: Builder(
            builder: (ctx) {
              List<Widget> children = [];
              ModService.getModsByCategory(true).forEach((key, value) {
                if (widget.excludedCategories != null && widget.excludedCategories!.contains(key)) return;
                value.sort((a, b) => a.name.compareTo(b.name));
                if (value.where((element) => filterMods(element.filename)).isNotEmpty && (search.isEmpty || value.where((element) => element.name.toLowerCase().contains(search.toLowerCase())).isNotEmpty)) {
                  children.add(const SizedBox(height: 25));
                  children.add(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ));
                }
                children.add(ListView(
                  padding: const EdgeInsets.all(0),
                  shrinkWrap: true,
                  children: value.where((element) => filterMods(element.filename) && (search.isEmpty || element.name.toLowerCase().contains(search.toLowerCase()))).map((Mod mod) {
                    return ListTile(
                      title: Text(
                        mod.name,
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: IconButton(
                        icon: const Icon(FluentIcons.add),
                        onPressed: () => setState(() => widget.onAdd(mod)),
                      ),
                    );
                  }).toList(),
                ));
              });
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              );
            },
          ),
          flex: 5,
        ),
      ],
    );
  }
}
