import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/constants/mod_categories.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/frosty_profile.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/active_mods.dart';
import 'package:kyber_mod_manager/screens/mod_profiles/widgets/installed_mods.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, this.profile}) : super(key: key);

  final String? profile;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final String prefix = 'edit_mod_profile';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ModProfile _profile;

  @override
  void initState() {
    try {
      if (widget.profile!.isNotEmpty) {
        _profile = List<ModProfile>.from(box.get('profiles', defaultValue: [])).where((x) => x.name == widget.profile).first;
      } else {
        _profile = ModProfile(name: '', mods: []);
      }
    } catch (e) {
      _profile = ModProfile(name: '', mods: []);
    }
    _nameController.text = _profile.name;
    _descriptionController.text = _profile.description ?? '';
    super.initState();
  }

  @override
  dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      List<ModProfile> profiles = List<ModProfile>.from(box.get('profiles') ?? []);
      profiles.removeWhere((profile) => profile.name == _profile.name);
      profiles.add(_profile.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
      ));
      await box.put('profiles', profiles);
      router.pop();
    }
  }

  filterMods(String value) => _profile.mods.where((element1) => value == element1.filename).isEmpty;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
        leading: Padding(
          padding: const EdgeInsets.only(right: 15, left: 15),
          child: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () => router.pop(),
          ),
        ),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.download),
              label: Text(translate('$prefix.load_frosty_profile.title')),
              onPressed: () => showDialog(
                context: context,
                builder: (c) => FrostyProfileSelector(onSelected: (s) {
                  setState(() => _profile = _profile.copyWith(mods: s.where((element) => kyber_mod_categories.contains(element.category)).toList()));
                }),
              ),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.save),
              label: Text(
                translate('save'),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              onPressed: () => save(),
            ),
          ],
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 79,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoLabel(
                    label: translate('$prefix.forms.name.header'),
                    child: TextFormBox(
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return translate('$prefix.forms.name.error');
                        }
                        return null;
                      },
                      onChanged: (String? value) => _formKey.currentState?.validate(),
                      placeholder: translate('$prefix.forms.name.placeholder'),
                      controller: _nameController,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InfoLabel(
                    label: translate('$prefix.forms.description.header'),
                    child: TextFormBox(
                      controller: _descriptionController,
                      placeholder: translate('$prefix.forms.description.placeholder'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translate('$prefix.forms.mods.header'),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: InstalledMods(
                            kyber: true,
                            activeMods: _profile.mods,
                            onAdd: (mod) => setState(() => _profile = _profile.copyWith(mods: _profile.mods + [mod])),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: ActiveMods(
                            mods: _profile.mods,
                            onRemove: (mod) => setState(() => _profile = _profile.copyWith(mods: [..._profile.mods]..remove(mod))),
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }

                                var mods = [..._profile.mods];
                                final dynamic mod = mods.removeAt(oldIndex);
                                _profile = _profile.copyWith(mods: mods..insert(newIndex, mod));
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
