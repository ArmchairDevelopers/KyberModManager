import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
class InstalledModDialog extends StatefulWidget {
  const InstalledModDialog({Key? key, required this.mod}) : super(key: key);

  final dynamic mod;

  @override
  State<InstalledModDialog> createState() => _InstalledModDialogState();
}

class _InstalledModDialogState extends State<InstalledModDialog> {
  Uint8List? image;

  @override
  void initState() {
    //ModService.getModCover(widget.mod.filename).then((value) => setState(() => image = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.mod.name),
      constraints: const BoxConstraints(maxWidth: 700),
      content: ListTile(
        leading: SizedBox(
          height: 60,
          width: 60,
          child: image != null && image!.isNotEmpty
              ? Image.memory(image!)
              : const Icon(FluentIcons.blocked, size: 50),
        ),
        title: Text(widget.mod.name),
        subtitle: Text(widget.mod.description ?? ''),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(translate('close')),
        ),
      ],
    );
  }
}
