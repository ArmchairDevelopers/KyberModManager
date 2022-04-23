import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:kyber_mod_manager/utils/auto_updater.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({Key? key, required this.versionInfo}) : super(key: key);

  final VersionInfo versionInfo;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool installing = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Update available!'),
      constraints: const BoxConstraints(
        maxWidth: 800,
      ),
      actions: [
        Button(child: const Text('Ignore'), onPressed: installing ? null : () => Navigator.pop(context)),
        FilledButton(
          child: const Text('Install'),
          onPressed: !installing
              ? () {
                  setState(() => installing = true);
                  AutoUpdater().update();
                }
              : null,
        ),
      ],
      content: SizedBox(
        height: 400,
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${widget.versionInfo.version} is available.',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Changelog:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MarkdownBody(data: widget.versionInfo.body),
            ],
          ),
        ),
      ),
    );
  }
}
