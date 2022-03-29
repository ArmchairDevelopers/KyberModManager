import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';

const String _prefix = 'server_browser.join_dialog.team_selector';

class TeamSelector extends StatelessWidget {
  const TeamSelector({Key? key, required this.server, required this.value, required this.onChange}) : super(key: key);

  final String value;
  final KyberServer server;
  final Function(String? preferredTeam) onChange;

  @override
  Widget build(BuildContext context) {
    if (server.autoBalanceTeams) {
      return Center(
        child: Text(
          translate('$_prefix.auto_balancing'),
        ),
      );
    }

    return SizedBox(
      child: Column(
        children: [
          Text(translate('$_prefix.select_team')),
          const SizedBox(height: 8),
          Combobox<String>(
            isExpanded: true,
            items: [
              ComboboxItem<String>(
                value: '0',
                child: Text(translate('$_prefix.light_side')),
              ),
              ComboboxItem<String>(
                value: '1',
                child: Text(translate('$_prefix.dark_side')),
              ),
            ],
            value: value,
            onChanged: (value) => onChange(value),
          )
        ],
      ),
    );
  }
}
