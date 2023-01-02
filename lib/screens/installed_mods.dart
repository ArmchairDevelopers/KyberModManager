import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/widgets/button_text.dart';
import 'package:kyber_mod_manager/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InstalledMods extends StatefulWidget {
  const InstalledMods({Key? key}) : super(key: key);

  @override
  _InstalledModsState createState() => _InstalledModsState();
}

class _InstalledModsState extends State<InstalledMods> {
  final String prefix = 'installed_mods';
  List<dynamic> _installedMods = [];
  bool loaded = false;
  final TextEditingController _searchController = TextEditingController();
  String search = '';

  @override
  void initState() {
    Timer.run(() => loadMods());
    super.initState();
  }

  void loadMods() async {
    if (!loaded) {
      await Future.delayed(const Duration(milliseconds: 200));
      loaded = true;
    }
    if (mounted) {
      setState(() => _installedMods = [...ModService.mods, ...ModService.collections].where((element) => element.toString().toLowerCase().contains(search.toLowerCase())).toList()
        ..sort((dynamic a, dynamic b) => a.name.compareTo(b.name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = FluentTheme.of(context).typography.body?.copyWith(
          fontSize: 12,
          color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
        );

    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.folder_search),
              label: Text(translate('$prefix.open_directory')),
              onPressed: () => launchUrlString('file://${box.get('frostyPath')}\\Mods\\starwarsbattlefrontii'),
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextBox(
              autofocus: true,
              onChanged: (String? value) {
                setState(() => search = value ?? '');
                loadMods();
              },
              controller: _searchController,
              suffix: search.isEmpty ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  FluentIcons.search,
                  color: FluentTheme.of(context).typography.body?.color?.withOpacity(.5),
                ),
              ) : IconButton(
                icon: const Icon(FluentIcons.cancel),
                onPressed: () {
                  _searchController.clear();
                  setState(() => search = '');
                  loadMods();
                },
              ),
              placeholder: translate('search'),
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: _installedMods.length,
                      itemBuilder: (BuildContext context, int index) {
                        final mod = _installedMods[index];
                        return Card(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mod.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(mod.author, style: style),
                                        Container(
                                          width: 1,
                                          height: 12,
                                          color: Colors.white,
                                          margin: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        Text(mod.category, style: style),
                                        Container(
                                          width: 1,
                                          height: 12,
                                          color: Colors.white,
                                          margin: const EdgeInsets.symmetric(horizontal: 5),
                                        ),
                                        Text(mod.version, style: style),
                                      ],
                                    ),
                                  ],
                                ),
                                DropDownButton(
                                  title: const Icon(FluentIcons.more),
                                  closeAfterClick: true,
                                  leading: const SizedBox(
                                    height: 30,
                                  ),
                                  trailing: const SizedBox(),
                                  buttonStyle: ButtonStyle(
                                    border: ButtonState.all(BorderSide.none),
                                    backgroundColor: ButtonState.resolveWith((states) => states.isNone ? Colors.transparent : null),
                                  ),
                                  items: [
                                    MenuFlyoutItem(
                                      text: Text(translate('delete')),
                                      onPressed: () {
                                        ModService.deleteMod(mod);
                                        loadMods();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (!loaded)
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.4,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: const ProgressRing(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
