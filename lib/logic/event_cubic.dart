import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/discord_event.dart';

class EventCubic extends Cubit<EventCubicState> {
  Timer? _timer;

  EventCubic() : super(EventCubicState(events: [])) {
    _loadEvents();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _loadEvents() async {
    state.events = await ApiService.getEvents();
    emit(state);
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _loadEvents);
  }
}

class EventCubicState {
  EventCubicState({required this.events});

  List<DiscordEvent> events = [];
}
