import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/map_rotation_creator.dart';
import 'package:kyber_mod_manager/utils/helpers/map_helper.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';

class MapRotationActiveMap extends StatefulWidget {
  const MapRotationActiveMap({Key? key, required this.map, required this.index, required this.onDelete}) : super(key: key);

  final MapRotationMap map;
  final int index;
  final void Function() onDelete;

  @override
  State<MapRotationActiveMap> createState() => _MapRotationActiveMapState();
}

class _MapRotationActiveMapState extends State<MapRotationActiveMap> {
  late String mapName;
  late Mode mode;

  @override
  void initState() {
    mapName = MapHelper.getMapName(modes.firstWhere((element) => element.mode == widget.map.mode), widget.map.map);
    mode = modes.firstWhere((element) => element.mode == widget.map.mode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.index,
      key: Key(widget.map.hashCode.toString()),
      child: Card(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: FluentTheme(
            data: FluentTheme.of(context),
            child: IconButton(icon: const Icon(FluentIcons.delete), onPressed: widget.onDelete),
          ),
          title: Text(
            mapName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            mode.name,
          ),
          trailing: ReorderableDragStartListener(
            index: widget.index,
            key: Key(widget.map.hashCode.toString()),
            child: FluentTheme(
              data: FluentTheme.of(context),
              child: IconButton(
                icon: const Icon(FluentIcons.drag_object),
                onPressed: () => null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
