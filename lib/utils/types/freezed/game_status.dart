import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_status.freezed.dart';

@freezed
class GameStatus with _$GameStatus {
  factory GameStatus({required bool injected, required bool running, DateTime? started}) = _GameStatus;
}
