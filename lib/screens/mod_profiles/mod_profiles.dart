import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/logic/widget_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/edit_profile.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/export_profile_dialog.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';
import 'package:kyber_mod_manager/widgets/custom_button.dart';

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
    setState(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('mod_profiles.title')),
        commandBar: FilledButton(
          child: ButtonText(
            text: Text(translate('mod_profiles.create_profile')),
            icon: const Icon(FluentIcons.add),
          ),
          onPressed: () {
            BlocProvider.of<WidgetCubit>(context).navigate(2, const EditProfile());
          },
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        onPressed: () => BlocProvider.of<WidgetCubit>(context).navigate(2, EditProfile(profile: e)),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        child: const ButtonText(
                          text: Text("Export"),
                          icon: Icon(FluentIcons.share),
                        ),
                        onPressed: () => showDialog(context: context, builder: (_) => ExportProfileDialog(profile: e)),
                      ),
                      const SizedBox(width: 8),
                      CustomFilledButton(
                        color: Colors.red,
                        child: ButtonText(text: Text(translate('delete')), icon: const Icon(FluentIcons.delete)),
                        onPressed: () => deleteProfile(e),
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
