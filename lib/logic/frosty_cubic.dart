import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kyber_mod_manager/utils/helpers/path_helper.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_cubic_state.dart';

class FrostyCubic extends Cubit<FrostyCubicState> {
  Timer? _timer;

  FrostyCubic() : super(FrostyCubicState(isOutdated: false)) {
    _load();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _load() async {
    var isOutdated = await FrostyService.isOutdated();
    var currentVersion = await FrostyService.getFrostyVersion();
    var latestVersion = (await PathHelper.getFrostyVersions()).first;
    emit(state.copyWith(isOutdated: isOutdated, latestVersion: latestVersion, currentVersion: currentVersion));
    Timer.periodic(const Duration(minutes: 5), (_) => _load);
  }

  Future<bool> checkForUpdates() async {
    var isOutdated = await FrostyService.isOutdated();
    var currentVersion = await FrostyService.getFrostyVersion();
    var latestVersion = (await PathHelper.getFrostyVersions()).first;
    emit(state.copyWith(isOutdated: isOutdated, latestVersion: latestVersion, currentVersion: currentVersion));
    return state.isOutdated;
  }
}
