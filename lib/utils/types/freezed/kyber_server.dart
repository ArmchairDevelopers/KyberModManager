import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyber_server.freezed.dart';
part 'kyber_server.g.dart';

@freezed
abstract class KyberServer with _$KyberServer {
  const factory KyberServer({
    required String id,
    required String name,
    required String description,
    required String map,
    required String mode,
    required List<KyberServerMod> mods,
    required int users,
    required String host,
    required int maxPlayers,
    required bool autoBalanceTeams,
    required int startedAt,
    required String startedAtPretty,
    required bool requiresPassword,
    bool? official,
    required String region,
    required Proxy proxy,
  }) = _KyberServer;

  factory KyberServer.fromJson(Map<String, dynamic> json) => _$KyberServerFromJson(json);
}

@freezed
class KyberServerMod with _$KyberServerMod {
  const factory KyberServerMod({
    required String name,
    required String link,
  }) = _KyberServerMod;

  factory KyberServerMod.fromJson(Map<String, dynamic> json) => _$KyberServerModFromJson(json);
}

@freezed
abstract class Proxy with _$Proxy {
  const factory Proxy({
    required String ip,
    required String name,
    required String flag,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, dynamic> json) => _$ProxyFromJson(json);
}
