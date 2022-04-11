import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';

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
  KyberServer? _server;
  Timer? _timer;
  String? content;
  String? link;

  @override
  void initState() {
    Timer.run(() async {
      if (widget.kyberServer != null) {
        setState(() {
          state = 3;
          _server = widget.kyberServer;
          link = 'https://kyber.gg/servers/#id=' + _server!.id.toString();
        });
        return;
      }

      bool isRunning = DllInjector.getBattlefrontPID() != -1;
      if (isRunning) {
        setState(() => state = 1);
        bool s = await checkServer();
        if (!s) {
          _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => checkServer());
        }
        return;
      }

      await createProfile();
      _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) => checkRunning());
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> createProfile() async {
    List<Mod> cosmeticMods = List<Mod>.from(box.get('cosmetics'));
    bool cosmetics = box.get('enableCosmetics', defaultValue: false);
    print(cosmetics);
    String? selectedProfile = widget.selectedProfile;
    if (selectedProfile == null) {
      return;
    }

    setState(() => content = translate('$dialog_prefix.joining_states.creating'));
    if (selectedProfile.endsWith('(Frosty Pack)') && !selectedProfile.contains('KyberModManager')) {
      if (!cosmetics) {
        await FrostyProfileService.loadFrostyPack(selectedProfile.replaceAll(' (Frosty Pack)', ''), onCopied);
      } else {
        List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(selectedProfile.replaceAll(' (Frosty Pack)', ''))
          ..addAll(cosmeticMods);
        await ProfileService.searchProfile(mods.map((e) => e.toKyberString()).toList(), onCopied);
        await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
      }
    } else if (selectedProfile.endsWith('(Mod Profile)')) {
      ModProfile profile = box.get('profiles').where((p) => p.name == selectedProfile.replaceAll(' (Mod Profile)', '')).first;
      if (cosmetics) {
        profile = profile.copyWith(mods: profile.mods..addAll(cosmeticMods));
      }
      await FrostyProfileService.createProfile(profile.mods.map((e) => e.toKyberString()).toList());
      await ProfileService.searchProfile(profile.mods.map((e) => e.toKyberString()).toList(), onCopied);
    } else if (selectedProfile == translate('host_server.forms.mod_profile.no_mods_profile')) {
      if (cosmetics) {
        await FrostyProfileService.createProfile(cosmeticMods.map((e) => e.toKyberString()).toList());
      } else {
        await FrostyProfileService.createProfile([]);
      }
    } else {
      return NotificationService.showNotification(message: translate('host_server.forms.mod_profile.no_profile_found'), color: Colors.red);
    }
    setState(() => content = translate('$dialog_prefix.joining_states.frosty'));
    await FrostyService.startFrosty();
    setState(() => state = 1);
  }

  void onCopied(copied, total) => setState(() => content = translate('run_battlefront.copying_profile', args: {'copied': copied, 'total': total}));

  Future<bool> checkServer() async {
    bool running = DllInjector.isInjected();
    if (!running) {
      setState(() => state = 1);
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 5), checkRunning);
      return false;
    }

    KyberServer? server = await KyberApiService.searchServer(widget.name ?? '');
    if (server == null) {
      return false;
    }

    setState(() {
      _server = server;
      link = 'https://kyber.gg/servers#id=' + _server!.id;
      state = 3;
    });
    _timer?.cancel();
    return true;
  }

  Future<bool> checkRunning() async {
    bool running = DllInjector.getBattlefrontPID() != -1;
    if (running) {
      DllInjector.inject();
      setState(() => state = 2);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => checkServer());
      return false;
    }
    return true;
  }

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
          FilledButton(
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
