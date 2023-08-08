import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/map_rotation_export_dialog.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/widgets/map_rotation_active_map.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/widgets/map_rotation_mode_maps.dart';

class MapRotationCreator extends StatefulWidget {
  const MapRotationCreator({Key? key}) : super(key: key);

  @override
  State<MapRotationCreator> createState() => _MapRotationCreatorState();
}

class _MapRotationCreatorState extends State<MapRotationCreator> {
  List<MapRotationMap> selectedMaps = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text("Map Rotation Creator"),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.save),
              onPressed: () {
                showDialog(context: context, builder: (_) => MapRotationExportDialog(selectedMaps: selectedMaps));
              },
            ),
          ],
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 79,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildModesList(),
                buildActiveList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildModesList() {
    return Expanded(
      flex: 7,
      child: Column(
        children: [
          InfoLabel(label: "Available Maps"),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return MapRotationModeMaps(
                  mode: modes[index],
                  onAdd: (map) {
                    selectedMaps.add(MapRotationMap(map: map, mode: modes[index].mode));
                    setState(() => null);
                  },
                  onAddAll: () {
                    selectedMaps.addAll(modes[index].maps.map((e) => MapRotationMap(map: e, mode: modes[index].mode)));
                    setState(() => null);
                  },
                );
              },
              shrinkWrap: true,
              itemCount: modes.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActiveList() {
    return Expanded(
      flex: 5,
      child: Column(
        children: [
          InfoLabel(label: "Active Maps"),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  final dynamic map = selectedMaps.removeAt(oldIndex);
                  selectedMaps = selectedMaps..insert(newIndex, map);
                });
              },
              buildDefaultDragHandles: false,
              shrinkWrap: true,
              children: [
                for (final e in selectedMaps)
                  MapRotationActiveMap(
                    map: e,
                    key: Key(e.hashCode.toString()),
                    index: selectedMaps.indexOf(e),
                    onDelete: () => setState(() => selectedMaps.remove(e)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapRotationMap {
  final String map;
  final String mode;

  MapRotationMap({required this.map, required this.mode});
}
