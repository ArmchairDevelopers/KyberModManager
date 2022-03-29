import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/frosty_selector.dart';
import 'package:kyber_mod_manager/screens/walk_through/widgets/nexusmods_login.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/path_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';

class WalkThrough extends StatefulWidget {
  const WalkThrough({Key? key}) : super(key: key);

  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  final String prefix = 'walk_through';
  int index = 0;
  bool disabled = true;

  @override
  void initState() {
    DllInjector.checkForUpdates().then(
      (value) => setState(() {
        index++;
        disabled = false;
      }),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget getWidgetByIndex() {
    switch (index) {
      case 0:
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: disabled
                ? [
                    Text(
                      translate('$prefix.dependencies.downloading'),
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const ProgressBar(),
                  ]
                : [Text(translate('$prefix.dependencies.finished'))],
          ),
        );
      case 1:
        return const FrostySelector();
      case 2:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 18),
            text: translate('$prefix.bugs_notice'),
          ),
        );
      default:
        return const Text('unknown');
    }
  }

  void onPressed() async {
    if (index == 1) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: true, dialogTitle: 'Select Frosty Path');
      if (selectedDirectory != null) {
        box.put('frostyPath', selectedDirectory);
        String? configPath = await FrostyService.getFrostyConfigPath();
        if (configPath == null) {
          return;
        }
        box.put('frostyConfigPath', configPath);
        String? valid = await PathHelper.isValidFrostyDir(selectedDirectory);
        if (valid != null) {
          NotificationService.showNotification(
            message: '$prefix.select_frosty_path.error_messages.$valid',
            color: Colors.red,
          );
          await box.delete('frostyPath');
          await box.delete('frostyConfigPath');
          return;
        }
        setState(() {
          index++;
          disabled = true;
        });
        Future.delayed(const Duration(seconds: 4), () => setState(() => disabled = false));
      }
    } else {
      if (index != 2) {
        setState(() {
          disabled = true;
          index++;
        });
        Future.delayed(const Duration(seconds: 4), () => setState(() => disabled = false));
      } else {
        await box.put('setup', true);
        await ModService.loadMods(context);
        Navigator.of(context).pop();
        showDialog(context: context, builder: (context) => const NexusmodsLogin());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      backgroundDismiss: false,
      constraints: const BoxConstraints(maxWidth: 700),
      title: Text(translate('$prefix.title')),
      actions: [
        Button(
          child: Text(translate('server_browser.prev_page')),
          onPressed: index == 0 || disabled ? null : () => setState(() => index),
        ),
        FilledButton(
          child: Text(index == 1 ? translate('$prefix.select_frosty_path.button') : translate('continue')),
          onPressed: disabled ? null : onPressed,
        ),
      ],
      content: SizedBox(
        height: 400,
        child: getWidgetByIndex(),
      ),
    );
  }
}
