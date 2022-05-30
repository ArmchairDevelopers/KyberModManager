import 'package:fluent_ui/fluent_ui.dart';
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
          FilledButton(
            child: const Text('Try again'),
            onPressed: () {
              var path = OriginHelper.getBattlefrontPath();
              if (path.isEmpty) {
                NotificationService.showNotification(message: 'No executable found.', color: Colors.red);
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
