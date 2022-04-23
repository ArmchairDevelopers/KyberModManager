import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';

part 'game_status.freezed.dart';

@freezed
class GameStatus with _$GameStatus {
  factory GameStatus({required bool injected, required bool running, DateTime? started, KyberServer? server}) = _GameStatus;
}
