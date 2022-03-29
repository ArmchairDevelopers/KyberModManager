import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

class InstalledMods extends StatefulWidget {
  const InstalledMods({Key? key, required this.onLoaded}) : super(key: key);

  final VoidCallback onLoaded;

  @override
  _InstalledModsState createState() => _InstalledModsState();
}

class _InstalledModsState extends State<InstalledMods> {
  bool loaded = false;

  @override
  void initState() {
    ModService.loadMods().then((value) {
      setState(() => loaded = true);
      widget.onLoaded();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: ModService.mods.length,
        itemBuilder: (context, index) {
          final Mod mod = ModService.mods[index];

          return ListTile(
            title: Text(mod.name),
            subtitle: Text(' - ${mod.version}'),
          );
        },
      );
    }

    return const Center(
      child: ProgressRing(),
    );
  }
}
