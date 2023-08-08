import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/utils/helpers/map_helper.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';

class MapRotationModeMaps extends StatefulWidget {
  const MapRotationModeMaps({Key? key, required this.mode, required this.onAdd, required this.onAddAll}) : super(key: key);

  final void Function(String map) onAdd;
  final void Function() onAddAll;
  final Mode mode;

  @override
  State<MapRotationModeMaps> createState() => _MapRotationModeMapsState();
}

class _MapRotationModeMapsState extends State<MapRotationModeMaps> {
  @override
  Widget build(BuildContext context) {
    return Expander(
      header: Text(widget.mode.name),
      trailing: IconButton(
        icon: const Icon(FluentIcons.add),
        onPressed: widget.onAddAll,
      ),
      content: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _ModeMap(mode: widget.mode, map: widget.mode.maps[index], onAdd: widget.onAdd);
        },
        itemCount: widget.mode.maps.length,
      ),
    );
  }
}

class _ModeMap extends StatefulWidget {
  const _ModeMap({Key? key, required this.mode, required this.map, required this.onAdd}) : super(key: key);

  final void Function(String map) onAdd;
  final Mode mode;
  final String map;

  @override
  State<_ModeMap> createState() => _ModeMapState();
}

class _ModeMapState extends State<_ModeMap> {
  late String mapName;

  @override
  void initState() {
    mapName = MapHelper.getMapName(widget.mode, widget.map);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.add, size: 12),
            onPressed: () => widget.onAdd(widget.map),
          ),
          const SizedBox(width: 8),
          Text(mapName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}

