import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';

class GameStatusCubic extends Cubit<GameStatus> {
  GameStatusCubic() : super(GameStatus(injected: false, running: false));

  DateTime? _started;

  void check() {
    bool running = DllInjector.getBattlefrontPID() != -1;
    bool injected = DllInjector.isInjected();
    if (!state.running && running) {
      _started = DateTime.now();
    } else if (state.running && !running) {
      _started = null;
    }

    emit(GameStatus(injected: injected, running: running, started: _started));
  }
}
