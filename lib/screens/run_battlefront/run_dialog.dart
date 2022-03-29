import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';

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
    if (selectedProfile == translate('host_server.forms.mod_profile.no_mods_profile')) {
      await FrostyProfileService.createProfile([]);
    } else if (selectedProfile.endsWith('(Frosty Pack)')) {
      var currentMods = await FrostyProfileService.getModsFromProfile('KyberModManager');
      String profile = selectedProfile.replaceAll(' (Frosty Pack)', '');
      List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(profile);
      if (!listEquals(currentMods, mods)) {
        setState(() => content = translate('$prefix.creating'));
        await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
        onProgress(0, 0);
        await FrostyProfileService.loadFrostyPack(profile.replaceAll(' (Frosty Pack)', ''), onProgress);
      }
    } else {
      ModProfile profile = box.get('profiles').where((p) => selectedProfile.replaceAll(' (Mod Profile)', '') == p.name).first;
      setState(() => content = translate('$prefix.searching'));
      await ProfileService.searchProfile(profile.mods.map((e) => e.toKyberString()).toList(), onProgress);
      setState(() => content = translate('$prefix.creating'));
      await FrostyProfileService.createProfile(profile.mods.map((e) => e.toKyberString()).toList());
    }

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
