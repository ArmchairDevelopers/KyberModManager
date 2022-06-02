import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/saved_profile.dart';
import 'package:kyber_mod_manager/widgets/custom_tooltip.dart';
import 'package:kyber_mod_manager/widgets/unordered_list.dart';

class SavedProfiles extends StatefulWidget {
  const SavedProfiles({Key? key}) : super(key: key);

  @override
  State<SavedProfiles> createState() => _SavedProfilesState();
}

class _SavedProfilesState extends State<SavedProfiles> {
  final String prefix = 'saved_profiles';
  List<SavedProfile>? _savedProfiles;
  bool disabled = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    loadProfiles();
    super.initState();
  }

  void deleteProfile(String id) async {
    setState(() => disabled = true);
    await ProfileService.deleteProfile(id);
    setState(() => disabled = false);
    loadProfiles();
  }

  void loadProfiles() {
    ProfileService.getSavedProfilesAsync().then((value) {
      value.sort((a, b) {
        if (a.lastUsed == null) {
          return 1;
        }
        if (b.lastUsed == null) {
          return -1;
        }

        return b.lastUsed!.compareTo(a.lastUsed!);
      });
      setState(() => _savedProfiles = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          children: [
            Text(translate('$prefix.title')),
            CustomTooltip(message: translate('$prefix.tooltip')),
          ],
        ),
      ),
      content: buildContent(),
    );
  }

  Widget buildContent() {
    final color = FluentTheme.of(context).typography.body!.color!;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: material.DataTable(
          dataRowHeight: 80,
          columns: [
            material.DataColumn(
              label: SizedBox(
                child: Text(
                  'IDs',
                  style: TextStyle(
                    color: color.withOpacity(.5),
                  ),
                ),
              ),
            ),
            material.DataColumn(
              label: SizedBox(
                child: Text(
                  translate('mods'),
                  style: TextStyle(
                    color: color.withOpacity(.5),
                  ),
                ),
              ),
            ),
            material.DataColumn(
              label: SizedBox(
                child: Text(
                  translate('last_used'),
                  style: TextStyle(
                    color: color.withOpacity(.5),
                  ),
                ),
              ),
            ),
            material.DataColumn(
              label: SizedBox(
                child: Text(
                  translate('size'),
                  style: TextStyle(
                    color: color.withOpacity(.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const material.DataColumn(
              label: Text(''),
            ),
          ],
          rows: _savedProfiles?.map((e) {
                return material.DataRow(cells: [
                  material.DataCell(
                    Text(e.id),
                  ),
                  material.DataCell(
                    Text(
                      e.mods.length.toString(),
                    ),
                  ),
                  material.DataCell(
                    Text(
                      e.lastUsed != null
                          ? DateFormat.yMMMMEEEEd(
                              Locale.fromSubtags(languageCode: box.get('locale', defaultValue: Platform.localeName.split('_').first)).languageCode,
                            ).format(e.lastUsed!)
                          : '-',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  material.DataCell(
                    Text(
                      formatBytes(e.size, 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  material.DataCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (x) {
                                return ContentDialog(
                                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 350),
                                  title: Text(translate('active_mods')),
                                  content: SizedBox(
                                    height: 200,
                                    child: SingleChildScrollView(
                                      child: UnorderedList(e.mods.map((e) => e.toKyberString()).toList()),
                                    ),
                                  ),
                                  actions: [
                                    Button(child: Text(translate('close')), onPressed: () => Navigator.pop(x)),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(translate('server_browser.join_dialog.buttons.view_mods')),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: disabled ? null : () => deleteProfile(e.id),
                          child: Text(translate('delete')),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList() ??
              [],
        ),
      ),
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
