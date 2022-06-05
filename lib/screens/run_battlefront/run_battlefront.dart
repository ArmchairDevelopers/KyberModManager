import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_dialog.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_profile.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/widgets/unordered_list.dart';

class RunBattlefront extends StatefulWidget {
  const RunBattlefront({Key? key}) : super(key: key);

  @override
  _RunBattlefrontState createState() => _RunBattlefrontState();
}

class _RunBattlefrontState extends State<RunBattlefront> {
  final String prefix = 'run_battlefront';
  final TextEditingController _controller = TextEditingController();

  bool disabled = false;

  List<FrostyProfile>? frostyProfiles;
  List<String>? profiles;

  @override
  void initState() {
    loadProfiles();
    super.initState();
  }

  void loadProfiles() {
    var loadedProfiles = FrostyProfileService.getProfilesWithMods();
    String? lastProfile = box.get('runBf2lastProfile');
    frostyProfiles = loadedProfiles;
    profiles = [
      translate('host_server.forms.mod_profile.no_mods_profile'),
      translate('host_server.forms.cosmetic_mods.header'),
      ...frostyProfiles?.where((e) => !e.name.toLowerCase().startsWith("kybermodmanager")).map((e) => '${e.name} (Frosty Pack)') ?? [],
    ];
    if (lastProfile != null) {
      if (lastProfile == 'no_mods') {
        _controller.text = translate('host_server.forms.mod_profile.no_mods_profile');
      } else if (lastProfile == 'cosmetic_mods') {
        _controller.text = translate('host_server.forms.cosmetic_mods.header');
      } else {
        _controller.text = lastProfile;
      }
    }
  }

  List<String> getMods() {
    if (_controller.text == translate('host_server.forms.mod_profile.no_mods_profile') || _controller.text.isEmpty) {
      return [];
    }

    if (_controller.text == translate('host_server.forms.cosmetic_mods.header')) {
      return List<Mod>.from(box.get('cosmetics')).map((e) => e.name).toList();
    }

    if (_controller.text.endsWith('(Frosty Pack)')) {
      return frostyProfiles?.firstWhere((profile) => profile.name == _controller.text.replaceAll(' (Frosty Pack)', '')).mods.map((e) => e.name).toList() ?? [];
    }

    return [];
  }

  void launchFrosty() async {
    setState(() => disabled = true);
    if (_controller.text.isEmpty || !profiles!.contains(_controller.text)) {
      NotificationService.showNotification(message: translate('$prefix.notifications.no_profile_selected'), color: Colors.red);
      return;
    }

    if (DllInjector.getBattlefrontPID() != -1) {
      NotificationService.showNotification(message: translate('$prefix.notifications.battlefront_already_running'), color: Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => RunDialog(
        profile: _controller.text,
      ),
    );
  }

  void showMods() {
    final List<String> mods = getMods();

    showDialog(
      context: context,
      builder: (x) {
        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 350),
          title: Text(translate('active_mods')),
          content: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: UnorderedList(mods),
            ),
          ),
          actions: [
            Button(child: Text(translate('close')), onPressed: () => Navigator.pop(x)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('run_battlefront.title')),
      ),
      content: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoLabel(
              label: translate('host_server.forms.mod_profile.header'),
              child: AutoSuggestBox(
                controller: _controller,
                clearButtonEnabled: true,
                placeholder: translate('host_server.forms.mod_profile.placeholder'),
                items: profiles ?? [],
                onSelected: (text) {
                  if (text == translate('host_server.forms.mod_profile.no_mods_profile')) {
                    text = 'no_mods';
                  } else if (text == translate('host_server.forms.cosmetic_mods.header')) {
                    text = 'cosmetic_mods';
                  }
                  box.put('runBf2lastProfile', text);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  style: ButtonStyle(
                    padding: ButtonState.all(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                    ),
                  ),
                  onPressed: _controller.text.isNotEmpty && profiles!.contains(_controller.text) ? () => showMods() : null,
                  child: Text(translate('server_browser.join_dialog.buttons.view_mods')),
                ),
                FilledButton(
                  style: ButtonStyle(
                    padding: ButtonState.all(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                    ),
                  ),
                  onPressed: () => launchFrosty(),
                  child: Text(translate('start')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
