import 'dart:async';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/proxy.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/server_host/hosting_dialog.dart';
import 'package:kyber_mod_manager/utils/helpers/map_helper.dart';
import 'package:kyber_mod_manager/utils/helpers/system_tasks.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/services/profile_service.dart';
import 'package:kyber_mod_manager/utils/services/rpc_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod.dart';
import 'package:kyber_mod_manager/utils/types/freezed/mod_profile.dart';
import 'package:kyber_mod_manager/utils/types/map.dart';
import 'package:kyber_mod_manager/widgets/custom_tooltip.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ServerHost extends StatefulWidget {
  const ServerHost({Key? key}) : super(key: key);

  @override
  _ServerHostState createState() => _ServerHostState();
}

class _ServerHostState extends State<ServerHost> {
  final prefix = 'host_server';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mapController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();

  late Timer _timer;
  late List<ModProfile> _profiles;

  KyberServer? server;
  List<KyberProxy>? proxies;
  List<String>? frostyProfiles;
  String mode = modes[0].mode;
  String? formattedServerName;
  String? proxy;
  double maxPlayers = 40;
  bool cosmetics = false;
  bool disabled = false;
  bool isHosting = false;
  bool autoBalance = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _mapController.text = '';
    _profiles = List<ModProfile>.from(box.get('profiles') ?? []);
    _timer = Timer.periodic(const Duration(seconds: 5), checkServerStatus);
    cosmetics = box.get('enableCosmetics', defaultValue: false);
    checkServerStatus(null);
    KyberApiService.getProxies().then(
      (proxies) => setState(() {
        this.proxies = proxies;
        proxy = box.get('proxy') ?? proxies.first.ip;
      }),
    );
    FrostyProfileService.getProfiles().then(
      (value) => setState(() {
        String? lastProfile = box.get('lastProfile');
        frostyProfiles = value;
        if (lastProfile != null) {
          if (lastProfile == 'no_mods') {
            _profileController.text = translate('$prefix.forms.mod_profile.no_mods_profile');
          } else {
            _profileController.text = lastProfile;
          }
        } else {
          _profileController.text = frostyProfiles!.first + ' (Frosty Pack)';
        }
      }),
    );
    super.initState();
  }

  @override
  void dispose() {
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    _timer.cancel();
    super.dispose();
  }

  void checkServerStatus(Timer? _timer) async {
    bool running = await SystemTasks.isKyberRunning();
    if (!running && !isHosting) {
      return;
    }
    dynamic config = await KyberApiService.getCurrentConfig();

    if (config['KYBER_MODE'] == 'SERVER' && running && server == null) {
      server = await KyberApiService.searchServer(config['SERVER_OPTIONS']['NAME']);
      if (_hostController.text.isEmpty && server != null) {
        setState(() {
          _hostController.text = server!.name;
          _passwordController.text = config['SERVER_OPTIONS']['PASSWORD'];
          _mapController.text = MapHelper.getMapsForMode(mode).where((m) => m.map == server!.map).first.name;
          mode = server!.mode;
          maxPlayers = server!.maxPlayers + 0.0;
          autoBalance = server!.autoBalanceTeams;
        });
      }
      RPCService.setServerId(server?.id);
      setState(() => isHosting = true);
    } else if (isHosting && (!running || config['KYBER_MODE'] != 'SERVER')) {
      server = null;
      RPCService.setServerId(null);
      setState(() => isHosting = false);
    }
  }

  String getHostname() {
    if (server == null) {
      return _hostController.text;
    }

    String hostname = server!.name;
    int randomNumber = Random().nextInt(3);
    for (int i = 0; i != randomNumber; i++) {
      hostname += " ";
    }
    return server!.name == hostname ? getHostname() : hostname;
  }

  void host([bool update = false]) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => disabled = true);
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
    NotificationService.showNotification(message: translate('$prefix.starting'));
    bool running = await SystemTasks.isKyberRunning();
    if (!update) {
      KyberServer? server = await KyberApiService.searchServer(_hostController.text);
      if (running && server != null) {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
        setState(() => disabled = false);
        showDialog(
          context: context,
          builder: (context) => HostingDialog(kyberServer: server),
        );
        return;
      }
    }

    List<KyberMap> foundMaps = MapHelper.getMapsForMode(mode).where((element) => element.name == _mapController.text).toList();
    if (foundMaps.isEmpty) {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      setState(() => disabled = false);
      NotificationService.showNotification(message: translate('$prefix.forms.map.map_not_found'), color: Colors.red);
      return;
    }

    String formattedServerName = getHostname();
    dynamic data = await KyberApiService.host(
      name: formattedServerName,
      proxy: proxy ?? '',
      password: _passwordController.text,
      mode: mode,
      map: foundMaps.first.map,
      maxPlayers: maxPlayers.toInt(),
      autoBalance: autoBalance,
    );
    if (data['message'] != 'Success, start your game to host this server!') {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      NotificationService.showNotification(message: data['message'], color: Colors.red);
      setState(() => disabled = false);
      return;
    }

    if (update) {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      NotificationService.showNotification(message: translate('$prefix.server_updated'), duration: 10);
      setState(() => disabled = false);
      return;
    }

    List<String> profiles = await FrostyProfileService.getProfiles();
    if (!profiles.contains('KyberModManager')) {
      await FrostyProfileService.createProfile([]);
    }

    Iterable<Mod> cosmeticsMods = Iterable.castFrom(box.get('cosmetics').map((e) => Mod.fromJson(e)).toList());
    if (_profileController.text.endsWith('(Frosty)') && !_profileController.text.contains('KyberModManager')) {
      if (!cosmetics) {
        await FrostyProfileService.loadFrostyPack(_profileController.text.replaceAll(' (Frosty)', ''));
      } else {
        List<Mod> mods = await FrostyProfileService.getModsFromConfigProfile(_profileController.text.replaceAll(' (Frosty)', ''));
        mods.addAll(cosmeticsMods);
        await ProfileService.searchProfile(mods.map((e) => e.toKyberString()).toList());
        await FrostyProfileService.createProfile(mods.map((e) => e.toKyberString()).toList());
      }
    } else if (_profileController.text.endsWith('(Mod Profile)')) {
      ModProfile profile = box.get('profiles').where((p) => p.name == _profileController.text.replaceAll(' (Mod Profile)', '')).first;
      if (cosmetics) {
        profile = profile.copyWith(mods: profile.mods..addAll(cosmeticsMods));
      }
      await FrostyProfileService.createProfile(profile.mods.map((e) => e.toKyberString()).toList());
      await ProfileService.searchProfile(profile.mods.map((e) => e.toKyberString()).toList());
    } else if (!_profileController.text.contains('KyberModManager')) {
      if (cosmetics) {
        await FrostyProfileService.createProfile(cosmeticsMods.map((e) => e.toKyberString()).toList());
      } else {
        await FrostyProfileService.createProfile([]);
      }
    }
    await FrostyService.startFrosty();
    setState(() => disabled = false);
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    showDialog(
      context: context,
      builder: (context) => HostingDialog(
        name: formattedServerName,
        password: _passwordController.text,
        maxPlayers: maxPlayers.toInt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('$prefix.title')),
      ),
      bottomBar: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 10).copyWith(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isHosting)
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: FilledButton(
                  style: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 30, vertical: 8)),
                  ),
                  child: Text(
                    translate('$prefix.buttons.server_info'),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: server == null
                      ? null
                      : () => showDialog(
                            context: context,
                            builder: (context) => HostingDialog(kyberServer: server, name: formattedServerName),
                          ),
                ),
              ),
            FilledButton(
              style: ButtonStyle(
                padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 30, vertical: 8)),
              ),
              child: Text(
                isHosting
                    ? server != null
                        ? translate('$prefix.buttons.update_server')
                        : translate('$prefix.buttons.server_is_starting')
                    : translate('$prefix.buttons.host'),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: server == null && isHosting
                  ? null
                  : !disabled || isHosting && server != null
                      ? () => host(isHosting)
                      : null,
            )
          ],
        ),
      ),
      content: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormBox(
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return translate('$prefix.forms.name.error');
                    }
                    return null;
                  },
                  onChanged: (String? value) => _formKey.currentState?.validate(),
                  controller: _hostController,
                  placeholder: translate('$prefix.forms.name.placeholder'),
                  header: translate('$prefix.forms.name.header'),
                ),
                const SizedBox(height: 8),
                TextFormBox(
                  validator: (String? value) {
                    if (value == null) {
                      return translate('$prefix.forms.password.error');
                    }
                    return null;
                  },
                  controller: _passwordController,
                  placeholder: translate('$prefix.forms.password.placeholder'),
                  header: translate('$prefix.forms.password.header'),
                ),
                const SizedBox(height: 8),
                InfoLabel(
                  label: translate('$prefix.forms.game_mode.header'),
                  child: Combobox<String>(
                    isExpanded: true,
                    items: modes.map((e) => ComboboxItem<String>(value: e.mode, child: Text(e.name))).toList(),
                    value: mode,
                    comboboxColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        mode = value ?? '';
                        _mapController.text = '';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: translate('$prefix.forms.map.header'),
                  child: AutoSuggestBox(
                    controller: _mapController,
                    clearButtonEnabled: true,
                    placeholder: translate('$prefix.forms.map.placeholder'),
                    items: MapHelper.getMapsForMode(mode).map((e) => e.name).toList(),
                    onSelected: (text) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InfoLabel(
                      label: translate('$prefix.forms.mod_profile.header'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: CustomTooltip(message: translate('$prefix.forms.mod_profile.tooltip')),
                    )
                  ],
                ),
                AutoSuggestBox(
                  controller: _profileController,
                  clearButtonEnabled: true,
                  placeholder: translate('$prefix.forms.mod_profile.placeholder'),
                  items: [
                    translate('$prefix.forms.mod_profile.no_mods_profile'),
                    ...frostyProfiles?.map((e) => '$e (Frosty Pack)') ?? [],
                    ..._profiles.map((e) => '${e.name} (Mod Profile)'),
                  ],
                  onSelected: (text) {
                    box.put('lastProfile', text == translate('$prefix.forms.mod_profile.no_mods_profile') ? 'no_mods' : text);
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 21),
                InfoLabel(
                  label: translate('$prefix.forms.proxy.header'),
                  child: Combobox<String>(
                    isExpanded: true,
                    items: proxies?.map((e) {
                          return ComboboxItem<String>(
                            value: e.ip,
                            child: Text(e.name),
                          );
                        }).toList() ??
                        [],
                    value: proxy,
                    comboboxColor: Colors.white,
                    onChanged: (value) {
                      box.put('proxy', value);
                      setState(() => proxy = value ?? '');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      checked: autoBalance,
                      content: Text(translate('$prefix.forms.auto_balance.header')),
                      onChanged: (value) => setState(() => autoBalance = value!),
                    ),
                    CustomTooltip(message: translate('$prefix.forms.auto_balance.tooltip'))
                  ],
                ),
                const SizedBox(height: 21),
                Row(
                  children: [
                    Text(translate('$prefix.forms.max_players.header', args: {'0': maxPlayers.toStringAsFixed(0)})),
                    CustomTooltip(message: translate('$prefix.forms.max_players.tooltip'))
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Slider(
                    max: 64,
                    min: 2,
                    value: maxPlayers,
                    onChanged: (v) => setState(() => maxPlayers = v),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
