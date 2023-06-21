import 'package:fluent_ui/fluent_ui.dart';
import 'package:kyber_mod_manager/utils/helpers/unzip_helper.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';

class NoExecutable extends StatefulWidget {
  const NoExecutable({Key? key}) : super(key: key);

  @override
  State<NoExecutable> createState() => _NoExecutableState();
}

class _NoExecutableState extends State<NoExecutable> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Please install WinRAR or 7-Zip to continue.'),
          const SizedBox(
            height: 16,
          ),
          FilledButton(
            child: const Text('Try again'),
            onPressed: () {
              var executable = UnzipHelper.getExecutable();
              if (executable == null) {
                NotificationService.showNotification(message: 'No executable found.', severity: InfoBarSeverity.error);
                return;
              }

              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
