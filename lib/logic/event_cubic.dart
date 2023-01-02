import 'package:dynamic_env/dynamic_env.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/utils/dll_injector.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/discord_event.dart';
import 'package:kyber_mod_manager/utils/types/freezed/game_status.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/process_details.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class EventCubic extends Cubit<EventCubicState> {
  EventCubic() : super(EventCubicState(events: [])) {
    // load events on startup
    _loadEvents();
  }

  // load events on startup
  void _loadEvents() async {
    state.events = await ApiService.getEvents();
    emit(state);
  }
}

class EventCubicState {
  EventCubicState({required this.events});

  List<DiscordEvent> events = [];
}