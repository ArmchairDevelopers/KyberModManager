import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/run_battlefront/run_dialog.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_profile.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
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
      return List<String>.from(
        frostyProfiles?.firstWhere((profile) => profile.name == _controller.text.replaceAll(' (Frosty Pack)', '')).mods.map((e) => e.name).toList() ?? [],
      );
    }

    return [];
  }

  void launchFrosty() async {
    setState(() => disabled = true);
    if (_controller.text.isEmpty || !profiles!.contains(_controller.text)) {
      NotificationService.showNotification(message: translate('$prefix.notifications.no_profile_selected'), severity: InfoBarSeverity.error);
      return;
    }

    if (DllInjector.battlefrontPID != -1) {
      NotificationService.showNotification(message: translate('$prefix.notifications.battlefront_already_running'), severity: InfoBarSeverity.error);
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
        commandBar: BlocBuilder<GameStatusCubic, GameStatus>(
          bloc: context.read<GameStatusCubic>(),
          builder: (context, state) {
            return CommandBar(mainAxisAlignment: MainAxisAlignment.end, primaryItems: [
              CommandBarButton(
                onPressed: _controller.text.isNotEmpty && profiles!.contains(_controller.text) ? () => showMods() : null,
                icon: const Icon(FluentIcons.view_list),
                label: Text(translate('server_browser.join_dialog.buttons.view_mods')),
              ),
              CommandBarButton(
                onPressed: state.running ? null : () => launchFrosty(),
                icon: const Icon(FluentIcons.play),
                label: Text(translate('start')),
              ),
            ]);
          },
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            InfoLabel(
              label: translate('host_server.forms.mod_profile.header'),
              child: AutoSuggestBox(
                controller: _controller,
                clearButtonEnabled: true,
                placeholder: translate('host_server.forms.mod_profile.placeholder'),
                items: profiles?.map((e) => AutoSuggestBoxItem(value: e, label: e)).toList() ?? [],
                onSelected: (AutoSuggestBoxItem item) {
                  String value = item.value;
                  if (item.value == translate('host_server.forms.mod_profile.no_mods_profile')) {
                    value = 'no_mods';
                  } else if (item.value == translate('host_server.forms.cosmetic_mods.header')) {
                    value = 'cosmetic_mods';
                  }
                  box.put('runBf2lastProfile', value);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
