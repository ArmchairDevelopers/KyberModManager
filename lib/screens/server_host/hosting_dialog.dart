import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';

class HostingDialog extends StatefulWidget {
  const HostingDialog({Key? key, this.name, this.password, this.maxPlayers, this.kyberServer}) : super(key: key);

  final String? name;
  final KyberServer? kyberServer;
  final String? password;
  final int? maxPlayers;

  @override
  _HostingDialogState createState() => _HostingDialogState();
}

class _HostingDialogState extends State<HostingDialog> {
  final String prefix = 'host_server.hosting_dialog';

  int state = 0;
  KyberServer? _server;
  Timer? _timer;
  String? link;

  @override
  void initState() {
    Timer.run(() async {
      if (widget.kyberServer == null) {
        bool isRunning = DllInjector.getBattlefrontPID() != -1;
        if (isRunning) {
          setState(() => state = 1);
          bool s = await checkServer();
          if (!s) {
            _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => checkServer());
          }
          return;
        }
        _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) => checkRunning());
      } else {
        setState(() => state = 2);
        setState(() {
          _server = widget.kyberServer;
          link = 'https://kyber.gg/servers/#id=' + _server!.id.toString();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> checkServer() async {
    bool running = DllInjector.isInjected();
    if (!running) {
      setState(() => state = 0);
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
      state = 2;
    });
    _timer?.cancel();
    return true;
  }

  Future<bool> checkRunning() async {
    bool running = DllInjector.getBattlefrontPID() != -1;
    if (running) {
      DllInjector.inject();
      setState(() => state = 1);
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
    if (state == 2) {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 25,
          width: 25,
          child: ProgressRing(),
        ),
        const SizedBox(width: 16),
        Text(
          translate(state == 0 ? 'server_browser.join_dialog.joining_states.battlefront' : '$prefix.wait_for_server'),
        ),
        if (state == 0) Text(translate('server_browser.join_dialog.joining_states.battlefront_2'))
      ],
    );
  }
}
