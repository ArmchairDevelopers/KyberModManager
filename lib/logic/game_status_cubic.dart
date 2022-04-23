import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';

class GameStatusCubic extends Cubit<GameStatus> {
  GameStatusCubic() : super(GameStatus(injected: false, running: false));

  String? _serverId;

  void emitServerId(String? serverId) {
    _serverId = serverId;
    check();
  }

  void check() async {
    bool running = DllInjector.getBattlefrontPID() != -1;
    bool injected = DllInjector.isInjected();
    DateTime? started = state.started;
    KyberServer? server = state.server;
    if (!state.running && running) {
      started = DateTime.now();
      if (state.server == null) {
        server = await _getServer();
      }
    } else if (state.running && !running) {
      started = null;
      server = null;
    }

    emit(GameStatus(injected: injected, running: running, started: started, server: server));
  }

  Future<KyberServer?> _getServer() async {
    dynamic config = await KyberApiService.getCurrentConfig();
    KyberServer? server;
    if (config['KYBER_MODE'] != 'CLIENT') {
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
