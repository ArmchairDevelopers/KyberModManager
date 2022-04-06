import 'package:fluent_ui/fluent_ui.dart';

class MissingPermissions extends StatefulWidget {
  MissingPermissions({Key? key}) : super(key: key);

  @override
  State<MissingPermissions> createState() => _MissingPermissionsState();
}

class _MissingPermissionsState extends State<MissingPermissions> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Missing permissions. Please start Kyber Mod Manager as admin.'),
    );
  }
}