import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/pack_type.dart';
import 'package:logging/logging.dart';

class RunDialog extends StatefulWidget {
  const RunDialog({Key? key, required this.profile}) : super(key: key);

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
    final String profile = selectedProfile.split(' (').first;
    final PackType packType = getPackType(selectedProfile);
    List<dynamic> mods = await ModService.createModPack(
      context,
      packType: packType,
      profileName: profile,
      cosmetics: false,
      onProgress: onProgress,
      setContent: (content) => setState(() => this.content = content),
    );
    if (!mounted) return;

    bool startFrosty = (!dynamicEnvEnabled);
    if (dynamicEnvEnabled) {
      if (packType == PackType.FROSTY_PACK) {
        List<dynamic> appliedMods = await FrostyProfileService.getModsFromProfile(profile);
        if (!ProfileService.equalModlist(mods, appliedMods)) {
          Logger.root.info('Mod list is not equal, applying mods');
          startFrosty = true;
        }
      } else if (packType == PackType.MOD_PROFILE || packType == PackType.COSMETICS) {
        String currentPath = PlatformHelper.getProfile();
        List<dynamic> activeMods = await FrostyProfileService.getModsFromProfile(currentPath, isPath: true);
        if (!ProfileService.equalModlist(activeMods, mods) && ProfileService.getSavedProfiles().where((element) => ProfileService.equalModlist(element.mods, mods)).isEmpty) {
          Logger.root.info("No profile found, starting Frosty");
          startFrosty = true;
        }
      } else if (packType == PackType.NO_MODS) {
        Logger.root.info("No mods, starting Frosty");
        startFrosty = true;
      }
    }

    if (startFrosty) {
      setState(() => content = translate('$prefix.frosty'));
      await FrostyService.startFrosty();
    } else {
      PlatformHelper.startBattlefront();
    }

    if (!mounted) return;
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
