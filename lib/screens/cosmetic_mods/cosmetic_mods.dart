import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/constants/mod_categories.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/frosty_profile.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/active_mods.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/export_profile_dialog.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/installed_mods.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';
import 'package:kyber_mod_manager/widgets/custom_tooltip.dart';

class CosmeticMods extends StatefulWidget {
  const CosmeticMods({Key? key}) : super(key: key);

  @override
  _CosmeticModsState createState() => _CosmeticModsState();
}

class _CosmeticModsState extends State<CosmeticMods> {
  final String prefix = 'cosmetic_mods';
  late List<dynamic> activeMods;

  @override
  void initState() {
    activeMods = List<dynamic>.from(box.get('cosmetics'));
    super.initState();
  }

  @override
  void dispose() {
    box.put('cosmetics', activeMods);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
        commandBar: Row(
          children: [
            if (activeMods.isNotEmpty) ...[
              Button(
                child: const ButtonText(
                  text: Text("Export"),
                  icon: Icon(FluentIcons.share),
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ExportProfileDialog(
                    profile: ModProfile(
                      name: 'Cosmetics',
                      mods: activeMods,
                    ),
                    enableCosmetics: false,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
            FilledButton(
              child: ButtonText(
                icon: const Icon(FluentIcons.download),
                text: Text(translate('edit_mod_profile.load_frosty_profile.title')),
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (c) => FrostyProfileSelector(onSelected: (s) {
                  setState(() => activeMods = s.where((element) => !kyber_mod_categories.contains(element.category)).toList());
                }),
              ),
            ),
            CustomTooltip(message: translate('edit_mod_profile.load_frosty_profile.tooltip'))
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height - 109,
          child: Row(
            children: [
              Flexible(
                flex: 6,
                child: InstalledMods(
                  activeMods: activeMods,
                  excludedCategories: kyber_mod_categories,
                  onAdd: (m) => setState(() => activeMods.add(m)),
                ),
              ),
              Flexible(
                flex: 6,
                child: ActiveMods(
                  mods: activeMods,
                  onRemove: (m) => setState(() => activeMods.remove(m)),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final Mod movedMod = activeMods.removeAt(oldIndex);
                      activeMods.insert(newIndex, movedMod);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
