import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';

class ActiveMods extends StatelessWidget {
  const ActiveMods({Key? key, required this.mods, required this.onReorder, required this.onRemove}) : super(key: key);

  final List<Mod> mods;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(Mod mod) onRemove;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14);

    return Column(
      children: [
        Text(
          translate('edit_mod_profile.active_mods'),
          style: TextStyle(color: Colors.white.withOpacity(.7)),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) => onReorder(oldIndex, newIndex),
            buildDefaultDragHandles: false,
            header: mods.isEmpty
                ? Container(
                    key: const Key("empty"),
                    child: Center(
                      child: Text(
                        translate('edit_mod_profile.forms.mods.no_mods_selected'),
                        style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : null,
            children: List<Widget>.of(mods.map((e) {
              return ReorderableDragStartListener(
                index: mods.indexWhere((element) => element.filename == e.filename),
                key: Key(e.filename),
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(FluentIcons.delete),
                    onPressed: () => onRemove(e),
                  ),
                  title: Text(
                    e.name,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: ReorderableDragStartListener(
                    index: mods.indexOf(e),
                    key: Key(e.filename),
                    child: IconButton(
                      icon: const Icon(FluentIcons.drag_object),
                      onPressed: () => null,
                    ),
                  ),
                ),
              );
            }).toList()),
          ),
        )
      ],
    );
  }
}
