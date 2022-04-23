import 'dart:async';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/constants/maps.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/logic/game_status_cubic.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';
import 'package:logging/logging.dart';

class RPCService {
  static late GameStatus _gameStatus;

  static final DiscordRPC rpc = DiscordRPC(
    applicationId: '931094111694520350',
  );
  static bool _running = false;
  static Timer? _timer;
  static Timer? _applicationTimer;

  static void initialize(BuildContext context) {
    DiscordRPC.initialize();
    RPCService.start();
    _gameStatus = BlocProvider.of<GameStatusCubic>(context).state;
    BlocProvider.of<GameStatusCubic>(context).stream.forEach((element) {
      RPCService._gameStatus = element;
      checkStatus();
    });
  }

  static void dispose() {
    if (!_running) {
      return;
    }

    Logger.root.info('Disposing rpc-service');

    rpc.clearPresence();
    _running = false;
    _applicationTimer?.cancel();
    _timer?.cancel();
    _timer = null;
  }

  static void start() {
    if (box.containsKey('discordRPC') && !box.get('discordRPC') || !box.containsKey('discordRPC') || _running) {
      return;
    }
    rpc.start(autoRegister: true);
    _running = true;
    // _applicationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    //   bool isRunning = DllInjector.isInjected();
    //   if (isRunning && _started == null) {
    //     checkStatus();
    //   } else if (!isRunning && _started != null) {
    //     _started = null;
    //     _serverId = null;
    //     rpc.clearPresence();
    //   }
    // });
    _timer = Timer.periodic(const Duration(seconds: 5), (x) => checkStatus());
    Logger.root.info('Started rpc-service');
  }

  static void checkStatus() async {
    bool isRunning = DllInjector.isInjected();
    if (!box.get('discordRPC')) {
      return dispose();
    }

    if (isRunning && _gameStatus.started != null) {
      dynamic config = await KyberApiService.getCurrentConfig();
      try {
        // KyberServer? server;
        // if (config['KYBER_MODE'] != 'CLIENT') {
        //   if (_serverId == null) {
        //     server = await KyberApiService.searchServer(config['SERVER_OPTIONS']['NAME']);
        //     _serverId = server?.id;
        //   } else {
        //     server = await KyberApiService.getServer(_serverId ?? '');
        //   }
        // } else {
        //   if (config['CLIENT_OPTIONS']['SERVER_ID'] == null) {
        //     _serverId = null;
        //     return;
        //   }
        //   server = await KyberApiService.getServer(
        //     config['CLIENT_OPTIONS']['SERVER_ID'],
        //   );
        // }

        if (_gameStatus.server == null) {
          print('Server is null');
          return;
        }

        dynamic map = maps.where((element) => element['map'] == _gameStatus.server?.map).first;
        Mode mode = modes.where((element) => element.mode == _gameStatus.server?.mode).first;

        if (!_running) {
          return;
        }

        rpc.updatePresence(DiscordPresence(
          details: _gameStatus.server!.name,
          state:
              '${config['KYBER_MODE'] == 'CLIENT' ? 'Playing' : 'Hosting'} ${mode.name} on ${map['name']} (${_gameStatus.server!.users}/${_gameStatus.server!.maxPlayers})',
          startTimeStamp: _gameStatus.started?.millisecondsSinceEpoch,
          largeImageText: 'SW: Battlefront II',
          largeImageKey: 'bf2',
          smallImageText: map['name'],
          smallImageKey: 'test',
        ));
      } catch (e) {
        return;
      }
    } else {
      rpc.clearPresence();
    }
  }
}
