import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/active_mods.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/installed_mods.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

class CosmeticMods extends StatefulWidget {
  const CosmeticMods({Key? key}) : super(key: key);

  @override
  _CosmeticModsState createState() => _CosmeticModsState();
}

class _CosmeticModsState extends State<CosmeticMods> {
  final String prefix = 'cosmetic_mods';
  late List<Mod> activeMods;

  @override
  void initState() {
    activeMods = List<Mod>.from(box.get('cosmetics').map((json) => Mod.fromJson(json)).toList());
    super.initState();
  }

  @override
  void dispose() {
    box.put('cosmetics', activeMods.map((mod) => mod.toJson()).toList());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height - 71,
          child: Row(
            children: [
              Flexible(
                flex: 6,
                child: InstalledMods(
                  activeMods: activeMods,
                  excludedCategories: const ['Gameplay'],
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
