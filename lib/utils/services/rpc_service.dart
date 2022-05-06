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
  static StreamSubscription? _subscription;

  static void initialize(BuildContext context) {
    if (_subscription != null) {
      _subscription!.cancel();
    }

    DiscordRPC.initialize();
    RPCService.start();
    _gameStatus = BlocProvider.of<GameStatusCubic>(context).state;
    _subscription = BlocProvider.of<GameStatusCubic>(context).stream.listen((element) {
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
    _subscription?.cancel();
    _running = false;
  }

  static void start() {
    if (box.containsKey('discordRPC') && !box.get('discordRPC') || !box.containsKey('discordRPC') || _running) {
      return;
    }
    rpc.start(autoRegister: true);
    _running = true;
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
        if (_gameStatus.server == null) {
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
