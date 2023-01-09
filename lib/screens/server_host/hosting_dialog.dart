import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/helpers/platform_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/pack_type.dart';
import 'package:logging/logging.dart';

class HostingDialog extends StatefulWidget {
  const HostingDialog({Key? key, this.name, this.password, this.maxPlayers, this.kyberServer, this.selectedProfile}) : super(key: key);

  final String? name;
  final String? selectedProfile;
  final KyberServer? kyberServer;
  final String? password;
  final int? maxPlayers;

  @override
  _HostingDialogState createState() => _HostingDialogState();
}

class _HostingDialogState extends State<HostingDialog> {
  final String prefix = 'host_server.hosting_dialog';
  final String dialog_prefix = 'server_browser.join_dialog';

  int state = 0;
  late StreamSubscription _streamSubscription;
  KyberServer? _server;
  Timer? _timer;
  String? content;
  String? link;

  @override
  void initState() {
    Timer.run(() async {
      _streamSubscription = BlocProvider.of<GameStatusCubic>(context).stream.listen((GameStatus element) {
        if (element.running && !element.injected) {
          DllInjector.inject();
        }

        if (element.injected && state < 2) {
          if (element.server != null) {
            setServer(element.server!);
          } else {
            setState(() => state = 2);
          }
          return;
        } else if (!element.running && state > 1) {
          _timer?.cancel();
          setState(() => state = 1);
          return;
        }

        if (element.server != null) {
          setServer(element.server!);
        }
      });

      if (widget.kyberServer != null) {
        setServer(widget.kyberServer!);
        return;
      }

      await createProfile();
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void setServer(KyberServer server) => setState(() {
        state = 3;
        _server = server;
        link = 'https://kyber.gg/servers/#id=${server.id}';
      });

  Future<void> createProfile() async {
    String? selectedProfile = widget.selectedProfile;
    if (selectedProfile == null) {
      return;
    }

    setState(() => content = translate('$dialog_prefix.joining_states.creating'));
    final PackType packType = getPackType(widget.selectedProfile!);
    final String profile = selectedProfile.split(' (').first;
    List<dynamic> mods = await ModService.createModPack(
      context,
      packType: packType,
      profileName: profile,
      cosmetics: true,
      onProgress: onCopied,
      setContent: (content) => setState(() => this.content = content),
    ).catchError((error) {
      NotificationService.showNotification(message: error.toString(), color: Colors.red);
    });
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
      setState(() => content = translate('$dialog_prefix.joining_states.frosty'));
      await FrostyService.startFrosty();
      if (dynamicEnvEnabled) {
        BlocProvider.of<GameStatusCubic>(context).setProfile(ProfileService.getProfilePath("KyberModManager"));
      }
    } else {
      PlatformHelper.startBattlefront();
    }

    if (!mounted) return;

    setState(() => state = 1);
  }

  void onCopied(copied, total) => setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500, minHeight: 200),
      title: Text(translate('$prefix.title')),
      actions: [
        Button(
          child: Text(translate('close')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: SizedBox(
        height: 150,
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    if (state == 3) {
      return Column(
        children: [
          TextFormBox(
            header: translate('$prefix.server_link'),
            readOnly: true,
            controller: TextEditingController(text: link!),
          ),
          const SizedBox(height: 10),
          Button(
            child: Text(translate('copy_link')),
            onPressed: () => Clipboard.setData(
              ClipboardData(text: link!),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: ProgressRing(),
            ),
            const SizedBox(width: 15),
            Text(
              state == 0 ? content ?? 'none' : translate(state == 1 ? 'server_browser.join_dialog.joining_states.battlefront' : '$prefix.wait_for_server'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (state == 1) Text(translate('server_browser.join_dialog.joining_states.battlefront_2')),
      ],
    );
  }
}
