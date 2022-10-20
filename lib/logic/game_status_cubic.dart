import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/process_details.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class GameStatusCubic extends Cubit<GameStatus> {
  GameStatusCubic() : super(GameStatus(injected: false, running: false));

  String? _serverId;
  ISentrySpan? _transaction;
  int interval = 0;

  void emitServerId(String? serverId) {
    _serverId = serverId;
    check();
  }

  void check() async {
    DllInjector.updateBattlefrontPID();
    bool running = DllInjector.battlefrontPID != -1;
    bool injected = running ? DllInjector.isInjected() : false;
    DateTime? started = state.started;
    KyberServer? server = state.server;
    ProcessModules? processModules = running ? DllInjector.processModules() : ProcessModules(modulesLength: 0, modules: []);
    interval++;
    if (interval >= 20 && injected) {
      interval = 0;
      server = await _getServer();
    }
    if (!state.running && running) {
      started = DateTime.now();
      if (state.server == null && injected) {
        server = await _getServer();
      }
    } else if (state.running && !running) {
      started = null;
      server = null;
      _transaction?.finish();
      _transaction = null;
    }

    if (injected && server == null) {
      server = await _getServer();
    }

    if (server != null && injected && _transaction == null) {
      dynamic config = await KyberApiService.getCurrentConfig();
      _transaction = Sentry.startTransaction(config['KYBER_MODE'] != 'CLIENT' ? "hostServer" : "playing", config['KYBER_MODE'] != 'CLIENT' ? "hostServer" : 'playing')
        ..setTag("gameMode", server.mode)
        ..setTag("map", server.map)
        ..setTag("proxy", server.proxy.name)
        ..setTag("maxPlayers", server.maxPlayers.toString());
    }

    emit(GameStatus(
      injected: injected,
      running: running,
      started: started,
      server: server,
      processModules: processModules,
    ));
  }

  Future<KyberServer?> _getServer() async {
    dynamic config = await KyberApiService.getCurrentConfig();
    KyberServer? server;
    if (config['KYBER_MODE'] != 'CLIENT') {
      if (config['SERVER_OPTIONS'] == null) {
        return null;
      }

      if (_serverId == null) {
        server = await KyberApiService.searchServer(config['SERVER_OPTIONS']['NAME']);
        _serverId = server?.id;
      } else {
        server = await KyberApiService.getServer(_serverId ?? '');
      }
    } else {
      if (config['CLIENT_OPTIONS']['SERVER_ID'] == null) {
        _serverId = null;
        return null;
      }
      server = await KyberApiService.getServer(
        config['CLIENT_OPTIONS']['SERVER_ID'],
      );
    }

    return server;
  }
}

// if (navigatorKey.currentContext != null && state.injected) {
//   bool crashed = await BattlefrontOptions.crashed();
//   if (crashed) {
//     showDialog(context: navigatorKey.currentContext!, builder: (_) => const BattlefrontOptionsDialog());
//   }
// }
/* { else if (state.injected && injected) {
  int? t = DllInjector.getKyberErrorWindow();
  if (t != null && t > 0) {
    //  Navigator.of(navigatorKey.currentContext!).push(FluentPageRoute(builder: (context) => Troubleshooting()));
  }
}*/
