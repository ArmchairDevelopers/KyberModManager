import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/export_profile_dialog.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';

class ModProfiles extends StatefulWidget {
  const ModProfiles({Key? key}) : super(key: key);

  @override
  _ModProfilesState createState() => _ModProfilesState();
}

class _ModProfilesState extends State<ModProfiles> {
  late List<ModProfile> profiles;

  @override
  void initState() {
    profiles = List<ModProfile>.from(box.get('profiles', defaultValue: []))..sort((a, b) => a.name.compareTo(b.name));
    super.initState();
  }

  deleteProfile(ModProfile profile) async {
    profiles.removeWhere((p) => p.name == profile.name);
    await box.put('profiles', profiles);
    if (box.get('lastProfile', defaultValue: '') == profile.name) {
      box.put('lastProfile', '');
    }
    setState(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('mod_profiles.title')),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: Text(translate('mod_profiles.create_profile')),
              onPressed: () async {
                Router.neglect(context, () {
                  context.goNamed('profile');
                });
              },
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: profiles
              .map(
                (e) => ListTile(
                  title: Text(
                    e.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    e.description != null && e.description!.isNotEmpty ? e.description! : '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  trailing: Row(
                    children: [
                      Button(
                        child: ButtonText(
                          text: Text(translate('edit')),
                          icon: const Icon(FluentIcons.edit),
                        ),
                        onPressed: () {
                          router.goNamed("profile", queryParameters: {"profile": e.name});
                        },
                      ),
                      const SizedBox(width: 8),
                      DropDownButton(
                        title: const Icon(FluentIcons.more),
                        closeAfterClick: true,
                        leading: const SizedBox(
                          height: 20,
                        ),
                        trailing: const SizedBox(),
                        items: [
                          MenuFlyoutItem(
                            text: Text("Export"),
                            onPressed: () => showDialog(context: context, builder: (_) => ExportProfileDialog(profile: e)),
                          ),
                          MenuFlyoutItem(
                            text: Text(translate('delete')),
                            onPressed: () => deleteProfile(e),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
