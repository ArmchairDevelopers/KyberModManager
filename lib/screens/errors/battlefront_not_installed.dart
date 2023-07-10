import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/origin_helper.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';

class BattlefrontNotFound extends StatefulWidget {
  const BattlefrontNotFound({Key? key}) : super(key: key);

  @override
  State<BattlefrontNotFound> createState() => _BattlefrontNotFoundState();
}

class _BattlefrontNotFoundState extends State<BattlefrontNotFound> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Please install Star Wars: Battlefront II to continue.'),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              FilledButton(
                child: const Text('Select Battlefront 2 path manually.'),
                onPressed: () async {
                  String? dir = await getDirectoryPath();
                  if (dir == null) {
                    return;
                  }
                  Directory path = Directory(dir);
                  if (path.listSync().whereType<File>().where((element) => element.path.endsWith('starwarsbattlefrontii.exe')).isEmpty) {
                    NotificationService.showNotification(message: 'Could not find Battlefront 2 executable.', severity: InfoBarSeverity.error);
                    return;
                  }

                  await box.put('battlefrontPath', dir);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(
                width: 15,
              ),
              Button(
                child: const Text('Try again'),
                onPressed: () {
                  var path = OriginHelper.getBattlefrontPath();
                  if (path.isEmpty) {
                    NotificationService.showNotification(message: 'No executable found.', severity: InfoBarSeverity.error);
                    return;
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
