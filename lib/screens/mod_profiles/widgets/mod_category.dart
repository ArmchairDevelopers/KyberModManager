import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_collection.dart';

class InstalledModCategory extends StatefulWidget {
  const InstalledModCategory(
      {Key? key,
      required this.index,
      required this.onAdd,
      required this.kyberCategories,
      required this.search,
      required this.excludedCategories,
      required this.activeMods})
      : super(key: key);

  final int index;
  final bool kyberCategories;
  final List activeMods;
  final String search;
  final Function onAdd;
  final List? excludedCategories;

  @override
  State<InstalledModCategory> createState() => _InstalledModCategoryState();
}

class _InstalledModCategoryState extends State<InstalledModCategory> {
  late List<dynamic> mods;
  late String category;
  bool show = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InstalledModCategory oldWidget) {
    loadData();
    setState(() => null);
    super.didUpdateWidget(oldWidget);
  }

  void loadData() {
    final modsByCategory = ModService.getModsByCategory(widget.kyberCategories);
    category = modsByCategory.keys.toList()[widget.index];
    mods = modsByCategory.values.toList()[widget.index]..sort((a, b) => a.name.compareTo(b.name));
    mods = mods.where((element) => filterMods(element.filename) && (widget.search.isEmpty || element.name.toLowerCase().contains(widget.search.toLowerCase()))).toList();
    show = mods.isNotEmpty && !(widget.excludedCategories != null && widget.excludedCategories!.contains(category));
  }

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox(
        height: 0,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10).copyWith(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListView(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            children: mods.map((dynamic mod) {
              return ListTile(
                title: Text(
                  '${mod.name} (${mod.version})${mod is FrostyCollection ? ' (Frosty Collection)' : ''}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                leading: IconButton(
                  icon: const Icon(FluentIcons.add),
                  onPressed: () => setState(() => widget.onAdd(mod)),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  bool filterMods(String value) => widget.activeMods.where((element1) => value == element1.filename).isEmpty;
}
