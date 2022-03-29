import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';

class RequiredMods extends StatelessWidget {
  const RequiredMods({Key? key, required this.server}) : super(key: key);

  final KyberServer server;

  @override
  Widget build(BuildContext context) {
    if (server.mods.isEmpty) {
      return Container(
        alignment: Alignment.topCenter,
        child: Text(translate('server_browser.join_dialog.required_mods.none')),
      );
    }

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          children: server.mods.map((mod) {
            final installed = ModService.isInstalled(mod);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Tooltip(
                    message: installed ? translate('installed') : translate('not_installed'),
                    child: Icon(
                      installed ? FluentIcons.check_mark : FluentIcons.error_badge,
                      color: installed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mod, style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
