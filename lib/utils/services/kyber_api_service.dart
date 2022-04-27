import 'dart:convert';

import 'package:http/http.dart';
import 'package:kyber_mod_manager/api/kyber/proxy.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';

class KyberApiService {
  static Future<ServerResponse> getServers([int page = 1]) async {
    return get(Uri.parse('$KYBER_API_BASE_URL/servers?page=$page')).then((response) => ServerResponse.fromJson(jsonDecode(response.body)));
  }

  static Future<KyberServer?> searchServer(String name) async {
    List<KyberServer> servers = await KyberApiService.getAllServers();
    Iterable<KyberServer> filtered = servers.where((server) => server.name == name);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  static Future<List<KyberServer>> getAllServers() async {
    ServerResponse server = await getServers();
    List<KyberServer> servers = [];
    await Future.wait(List.generate(server.pageCount, (i) => i + 1).map((e) async {
      ServerResponse server = await getServers(e);
      servers.addAll(server.servers);
    }));
    return servers;
  }

  static Future<dynamic> host(
      {required String name,
      required String proxy,
      required String password,
      required String mode,
      required String map,
      required int maxPlayers,
      required bool autoBalance}) {
    return post(
      Uri.parse('$KYBER_API_BASE_URL/config/host'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'faction': 0,
        'kyberProxy': proxy,
        'name': name,
        'password': password,
        'mode': mode,
        'map': map,
        'maxPlayers': maxPlayers,
        'autoBalanceTeams': autoBalance,
      }),
    ).then((response) => jsonDecode(response.body));
  }

  static Future<KyberServer?> getServer(String id) async {
    return get(Uri.parse('$KYBER_API_BASE_URL/servers/$id')).then((response) {
      if (response.statusCode == 200) {
        return KyberServer.fromJson(jsonDecode(response.body));
      }
      return null;
    });
  }

  static Future<List<KyberProxy>> getProxies() async {
    final resp = await get(Uri.parse('$KYBER_API_BASE_URL/proxies'));
    dynamic data = jsonDecode(resp.body).toList();
    return List<KyberProxy>.from(data.map((proxy) => KyberProxy.fromJson(proxy)));
  }

  static getCurrentConfig() {
    return get(Uri.parse('$KYBER_API_BASE_URL/config')).then((value) => jsonDecode(value.body));
  }

  static Future<dynamic> joinServer(String id, {int faction = 0, String? password = ''}) async {
    return await post(
      Uri.parse('$KYBER_API_BASE_URL/config/play'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'faction': faction,
        'password': password,
      }),
    ).then((value) => jsonDecode(value.body));
  }
}
