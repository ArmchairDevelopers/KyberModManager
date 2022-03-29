import 'package:kyber_mod_manager/constants/maps.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/utils/types/map.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';

class MapHelper {
  static List<KyberMap> getMapsForMode(String mode) {
    Mode m = modes.firstWhere((element) => element.mode == mode);
    return m.maps.map((e) {
      MapOverride? override = m.mapOverrides?.firstWhere((x) => x.map == e, orElse: () => MapOverride(map: '', name: ''));
      if (override != null && override.name != '') {
        return KyberMap(map: override.map, name: override.name);
      }
      return KyberMap(map: e, name: maps.firstWhere((element) => element['map'] == e)['name']);
    }).toList();
  }
}
