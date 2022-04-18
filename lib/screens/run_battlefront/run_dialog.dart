import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/types/pack_type.dart';

class RunDialog extends StatefulWidget {
  RunDialog({Key? key, required this.profile}) : super(key: key);

  final String profile;

  @override
  State<RunDialog> createState() => _RunDialogState();
}

class _RunDialogState extends State<RunDialog> {
  final String prefix = 'server_browser.join_dialog.joining_states';
  late String selectedProfile;
  String content = "";

  @override
  void initState() {
    selectedProfile = widget.profile;
    startFrosty();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void startFrosty() async {
    await ModService.createModPack(
      packType: getPackType(selectedProfile),
      profileName: selectedProfile.split(' (').first,
      cosmetics: false,
      onProgress: onProgress,
      setContent: (content) => setState(() => this.content = content),
    );
    // if (selectedProfile == translate('host_server.forms.mod_profile.no_mods_profile')) {
    //   await FrostyProfileService.createProfile([]);
    // } else if (selectedProfile.endsWith('(Frosty Pack)')) {
    //   var currentMods = await FrostyProfileService.getModsFromProfile('KyberModManager');
    //   String profile = selectedProfile.replaceAll(' (Frosty Pack)', '');
    //   List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(profile);
    //   if (!listEquals(currentMods, mods)) {
    //     setState(() => content = translate('$prefix.creating'));
    //     await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
    //     onProgress(0, 0);
    //     await FrostyProfileService.loadFrostyPack(profile.replaceAll(' (Frosty Pack)', ''), onProgress);
    //   }
    // } else if (selectedProfile == translate('host_server.forms.cosmetic_mods.header')) {
    //   List<Mod> mods = List<Mod>.from(box.get('cosmetics'));
    //   await ProfileService.searchProfile(mods.map((e) => e.toKyberString()).toList(), onProgress);
    //   setState(() => content = translate('$prefix.creating'));
    //   await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
    // } else {
    //   return NotificationService.showNotification(message: translate('host_server.forms.mod_profile.no_profile_found'));
    // }

    setState(() => content = translate('$prefix.frosty'));
    await FrostyService.startFrosty();
    Navigator.of(context).pop();
  }

  void onProgress(copied, total) => setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(translate('run_battlefront.title')),
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 300,
      ),
      actions: [
        Button(
          child: Text(translate('cancel')),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      content: SizedBox(
        height: 150,
        width: 500,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: ProgressRing(),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(content),
          ],
        ),
      ),
    );
  }
}
