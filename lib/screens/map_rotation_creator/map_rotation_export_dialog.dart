import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/screens/map_rotation_creator/map_rotation_creator.dart';

class MapRotationExportDialog extends StatefulWidget {
  const MapRotationExportDialog({Key? key, required this.selectedMaps}) : super(key: key);

  final List<MapRotationMap> selectedMaps;

  @override
  State<MapRotationExportDialog> createState() => _MapRotationExportDialogState();
}

class _MapRotationExportDialogState extends State<MapRotationExportDialog> {
  bool shuffle = false;

  String generateMapRotationString() {
    String mapRotationString = "";
    for (MapRotationMap map in widget.selectedMaps) {
      mapRotationString += "${map.map} ${map.mode}\n";
    }

    return mapRotationString;
  }

  void export() async {
    String mapRotationString = generateMapRotationString();
    final destination = await getSaveLocation(
      suggestedName: "map_rotation.txt",
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Text',
          extensions: ['txt'],
        ),
      ],
    );
    await File(destination!.path).writeAsString(mapRotationString);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Export Map Rotation"),
      actions: [
        Button(
          child: Text(translate('close')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Button(
          child: const Text("Copy to Clipboard"),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: generateMapRotationString()));
            Navigator.of(context).pop();
          },
        ),
        FilledButton(onPressed: export, child: Text(translate("Export"))),
      ],
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 325),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            checked: shuffle,
            onChanged: (value) => setState(() => shuffle = value ?? false),
            content: const Text("Shuffle"),
          ),
        ],
      ),
    );
  }
}
