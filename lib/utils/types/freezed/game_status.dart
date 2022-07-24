import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/process_details.dart';

part 'game_status.freezed.dart';

@freezed
class GameStatus with _$GameStatus {
  factory GameStatus({required bool injected, required bool running, DateTime? started, KyberServer? server, ProcessModules? processModules}) = _GameStatus;
}
