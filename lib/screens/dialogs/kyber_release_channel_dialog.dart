import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';

class KyberReleaseChannelDialog extends StatefulWidget {
  const KyberReleaseChannelDialog({Key? key}) : super(key: key);

  @override
  State<KyberReleaseChannelDialog> createState() => _KyberReleaseChannelDialogState();
}

class _KyberReleaseChannelDialogState extends State<KyberReleaseChannelDialog> {
  bool _loading = false;
  final String prefix = "settings.kyber_release_channel";
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(
      text: box.get('releaseChannel', defaultValue: 'stable'),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 400),
      title: Text(translate("$prefix.title")),
      actions: [
        Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate("cancel")),
        ),
        FilledButton(
          onPressed: _loading
              ? null
              : () async {
                  if (controller.text.isEmpty) {
                    NotificationService.showNotification(
                      message: translate("$prefix.error.no_channel_selected"),
                      severity: InfoBarSeverity.error,
                    );
                    return;
                  }
                  try {
                    setState(() => _loading = true);
                    await box.put('releaseChannel', controller.text);
                    await DllInjector.downloadDll();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  } catch (e) {
                    await box.put('releaseChannel', 'stable');
                    if (e is DioError) {
                      NotificationService.showNotification(
                        message: translate("$prefix.errors.channel_not_found"),
                        severity: InfoBarSeverity.error,
                      );
                    } else {
                      NotificationService.showNotification(
                        message: translate("$prefix.errors.failed_to_download"),
                        severity: InfoBarSeverity.error,
                      );
                    }
                    await DllInjector.downloadDll();
                    Navigator.of(context).pop();
                  }
                },
          child: Text(translate("save")),
        ),
      ],
      content: Center(
        child: Column(
          children: [
            TextBox(
              controller: controller,
              placeholder: 'Release Channel',
            ),
            Expanded(
              child: _loading
                  ? Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            child: const ProgressRing(),
                          ),
                          SizedBox(width: 20),
                          Text(
                            translate("server_browser.join_dialog.buttons.downloading"),
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
