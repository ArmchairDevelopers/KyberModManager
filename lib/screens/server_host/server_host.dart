import 'dart:async';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/proxy.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/screens/server_host/hosting_dialog.dart';
import 'package:kyber_mod_manager/utils/helpers/map_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_profile_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/services/mod_service.dart';
import 'package:kyber_mod_manager/utils/services/notification_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
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

  late List<ModProfile> _profiles;

  StreamSubscription? _subscription;
  KyberServer? server;
  List<KyberProxy>? proxies;
  late List<String> profiles;
  String mode = modes[0].mode;
  String? formattedServerName;
  String? proxy;
  int maxPlayers = 40;
  int faction = 0;
  bool warning = false;
  bool disabled = false;
  bool cosmetics = false;
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
    cosmetics = box.get('enableCosmetics', defaultValue: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      GameStatus status = BlocProvider.of<GameStatusCubic>(context).state;
      checkServerStatus(status);
      _subscription = BlocProvider.of<GameStatusCubic>(context).stream.listen((status) => checkServerStatus(status));
      KyberApiService.getProxies().then(
        (proxies) => mounted
            ? setState(() {
                this.proxies = proxies;
                proxy = box.get('proxy') ?? proxies.first.ip;
              })
            : null,
      );
    });
    loadProfiles();
    super.initState();
  }

  void loadProfiles() {
    var profiles = FrostyProfileService.getProfiles();
    String noMods = translate('$prefix.forms.mod_profile.no_mods_profile');
    String? lastProfile = box.get('lastProfile');
    this.profiles = [
      translate('$prefix.forms.mod_profile.no_mods_profile'),
      ...profiles.where((e) => e != 'KyberModManager').map((e) => '$e (Frosty Pack)'),
      ..._profiles.map((e) => '${e.name} (Mod Profile)'),
    ];

    if (lastProfile != null) {
      if (lastProfile == 'no_mods') {
        _profileController.text = noMods;
        return;
      }
      _profileController.text = lastProfile;
      checkWarnings();
      return;
    }

    if (profiles.isEmpty) {
      _profileController.text = noMods;
      return;
    }

    setState(() => _profileController.text = '${profiles.first} (Frosty Pack)');
    checkWarnings();
  }

  void checkWarnings() async {
    var mods = ModService.getModsFromModPack(_profileController.text);
    if (mods.length > 20 || mods.where((element) => element.name.contains('BF2022')).isNotEmpty) {
      setState(() => warning = true);
      return;
    } else if (warning == true) {
      setState(() => warning = false);
    }
  }

  @override
  void dispose() {
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    _subscription?.cancel();
    super.dispose();
  }

  void checkServerStatus(GameStatus status) async {
    var config = await KyberApiService.getCurrentConfig();
    if (status.injected && config['KYBER_MODE'] == 'SERVER') {
      if (status.server != null) {
        setState(() {
          _hostController.text = status.server!.name;
          _passwordController.text = config?['SERVER_OPTIONS']?['PASSWORD'] ?? '';
          _mapController.text = MapHelper.getMapsForMode(mode).where((m) => m.map == status.server!.map).first.name;
          server = status.server;
          mode = status.server!.mode;
          maxPlayers = status.server!.maxPlayers;
          autoBalance = status.server!.autoBalanceTeams;
        });
      }
      setState(() => isHosting = true);
    } else if (isHosting && (!status.injected || config['KYBER_MODE'] != 'SERVER')) {
      setState(() {
        isHosting = false;
        server = null;
      });
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
    bool running = BlocProvider.of<GameStatusCubic>(context).state.injected;
    if (!update) {
      NotificationService.showNotification(message: translate('$prefix.starting'));
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
      NotificationService.showNotification(message: translate('$prefix.forms.map.map_not_found'), severity: InfoBarSeverity.error);
      return;
    }

    String formattedServerName = getHostname();
    dynamic data = await KyberApiService.host(
      name: formattedServerName,
      proxy: proxy ?? '',
      password: _passwordController.text,
      mode: mode,
      faction: faction,
      map: foundMaps.first.map,
      maxPlayers: maxPlayers,
      autoBalance: autoBalance,
    );
    if (data['message'] != 'Success, start your game to host this server!') {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      NotificationService.showNotification(message: data['message'], severity: InfoBarSeverity.error);
      setState(() => disabled = false);
      return;
    }

    if (update) {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      NotificationService.showNotification(message: translate('$prefix.server_updated'));
      setState(() => disabled = false);
      return;
    }

    List<String> profiles = FrostyProfileService.getProfiles();
    if (!profiles.contains('KyberModManager')) {
      await FrostyProfileService.createProfile([]);
    }

    if (!mounted) return;
    setState(() => disabled = false);
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
    showDialog(
      context: context,
      builder: (context) => HostingDialog(
        selectedProfile: _profileController.text,
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
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            if (isHosting)
              CommandBarButton(
                onPressed: server == null
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (context) => HostingDialog(kyberServer: server, name: formattedServerName),
                        ),
                icon: const Icon(FluentIcons.info),
                label: Text(
                  translate('$prefix.buttons.server_info'),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            CommandBarButton(
              onPressed: server == null && isHosting
                  ? null
                  : !disabled || isHosting && server != null
                      ? () => host(isHosting)
                      : null,
              icon: Icon(
                isHosting ? FluentIcons.refresh : FluentIcons.play,
                color: Colors.white,
              ),
              label: Text(
                isHosting
                    ? server != null
                        ? translate('$prefix.buttons.update_server')
                        : translate('$prefix.buttons.server_is_starting')
                    : translate('$prefix.buttons.host'),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
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
                    controller: _hostController,
                    placeholder: translate('$prefix.forms.name.placeholder'),
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: translate('$prefix.forms.password.header'),
                  child: TextFormBox(
                    validator: (String? value) {
                      if (value == null) {
                        return translate('$prefix.forms.password.error');
                      }
                      return null;
                    },
                    controller: _passwordController,
                    placeholder: translate('$prefix.forms.password.placeholder'),
                    //header: translate('$prefix.forms.password.header'),
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: translate('$prefix.forms.game_mode.header'),
                  child: ComboBox<String>(
                    isExpanded: true,
                    items: modes.map((e) => ComboBoxItem<String>(value: e.mode, child: Text(e.name))).toList(),
                    value: mode,
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
                  child: AutoSuggestBox.form(
                    controller: _mapController,
                    clearButtonEnabled: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty || MapHelper.getMapsForMode(mode).where((element) => element.name == value).isEmpty) {
                        return translate('$prefix.forms.map.map_not_found');
                      }
                      return null;
                    },
                    placeholder: translate('$prefix.forms.map.placeholder'),
                    items: MapHelper.getMapsForMode(mode).map((e) => AutoSuggestBoxItem(value: e.name, label: e.name)).toList(),
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
                AutoSuggestBox.form(
                  controller: _profileController,
                  placeholder: translate('$prefix.forms.mod_profile.placeholder'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty || !profiles.contains(value)) {
                      return translate('$prefix.forms.mod_profile.no_profile_found');
                    }
                    return null;
                  },
                  onChanged: (String? value, TextChangedReason _) => value != null && value.isNotEmpty && _formKey.currentState!.validate(),
                  items: profiles.map((e) => AutoSuggestBoxItem(value: e, label: e)).toList(),
                  onSelected: (text) {
                    box.put('lastProfile', text.value == translate('$prefix.forms.mod_profile.no_mods_profile') ? 'no_mods' : text.value);
                    Timer.run(() => checkWarnings());
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'Server Host Faction',
                  child: ComboBox<int>(
                    isExpanded: true,
                    items: [0, 1].map((e) {
                      return ComboBoxItem<int>(
                        value: e,
                        child: Text(translate("server_browser.join_dialog.team_selector.${e == 0 ? 'light_side' : 'dark_side'}")),
                      );
                    }).toList(),
                    value: faction,
                    onChanged: autoBalance
                        ? null
                        : (value) {
                            setState(() => faction = value ?? 0);
                          },
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: translate('$prefix.forms.proxy.header'),
                  child: ComboBox<String>(
                    isExpanded: true,
                    items: proxies?.map((e) {
                          return ComboBoxItem<String>(
                            value: e.ip,
                            child: Text('${e.name} (${e.ping} ms)'),
                          );
                        }).toList() ??
                        [const ComboBoxItem(value: null, child: Text(""))],
                    value: proxy,
                    onChanged: proxies == null
                        ? null
                        : (value) {
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
                      onChanged: (value) {
                        if (value! == true) {
                          faction = 0;
                        }

                        setState(() => autoBalance = value!);
                      },
                    ),
                    CustomTooltip(message: translate('$prefix.forms.auto_balance.tooltip'))
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      checked: cosmetics,
                      content: Text(translate('$prefix.forms.cosmetic_mods.header')),
                      onChanged: (value) {
                        setState(() => cosmetics = value!);
                        box.put('enableCosmetics', value);
                      },
                    ),
                    if (warning) ...[
                      Tooltip(
                        message: 'Cosmetic mods might cause crashes with your selected gameplay mods',
                        child: Icon(FluentIcons.warning, color: Colors.yellow),
                      ),
                      const SizedBox(width: 4),
                    ],
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
                    value: maxPlayers + 0.0,
                    onChanged: (v) => setState(() => maxPlayers = int.parse(v.toString().split('.').first)),
                  ),
                ),
                const SizedBox(height: 21),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
