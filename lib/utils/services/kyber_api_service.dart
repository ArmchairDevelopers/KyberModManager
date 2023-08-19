import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:kyber_mod_manager/api/kyber/proxy.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';
import 'package:kyber_mod_manager/constants/maps.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:logging/logging.dart';

class KyberApiService {
  static Future<ServerResponse> getServers([int page = 1]) async {
    return get(Uri.parse('$KYBER_API_BASE_URL/servers?page=$page')).then((response) => ServerResponse.fromJson(jsonDecode(response.body)));
  }

  static Future<bool> hasMissingMapPictures() async {
    if (!Directory('$applicationDocumentsDirectory/maps').existsSync()) {
      return false;
    }

    return maps.map((e) => e["map"].replaceAll("/", "-")).toList().where((map) => File('$applicationDocumentsDirectory/maps/$map.jpg').existsSync()).length == maps.length;
  }

  static Future<void> downloadRequiredMapPictures() async {
    Logger.root.info("Finding missing map thumbnails...");
    var allMaps = maps.map((e) => e["map"].replaceAll("/", "-")).toList();

    if (!Directory('$applicationDocumentsDirectory/maps').existsSync()) {
      Directory('$applicationDocumentsDirectory/maps').createSync();
    }

    var mapsToDownload = allMaps.where((map) => !File('$applicationDocumentsDirectory/maps/$map.jpg').existsSync()).toList();
    Logger.root.info("Downloading ${mapsToDownload.length} missing map thumbnails...");
    await Future.forEach(mapsToDownload, (map) async {
      Logger.root.info("Downloading $map...");
      var resp = await get(Uri.parse("$KYBER_STATIC_URL/images/maps/$map.jpg"));
      await File('$applicationDocumentsDirectory/maps/$map.jpg').writeAsBytes(resp.bodyBytes);
    });
    Logger.root.info("Finished downloading missing map thumbnails!");
  }

  static Future<KyberServer?> searchServer(String name) async {
    List<KyberServer> servers = await KyberApiService.getAllServers();
    Iterable<KyberServer> filtered = servers.where((server) => server.name.trim() == name.trim());
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
      required String description,
      required String mode,
      required String map,
      required int maxPlayers,
      required int faction,
      required bool autoBalance}) {
    return post(
      Uri.parse('$KYBER_API_BASE_URL/config/host'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'faction': faction,
        'kyberProxy': proxy,
        'description': description,
        'name': name,
        'password': password,
        'mode': mode,
        'map': map,
        'maxPlayers': maxPlayers,
        'autoBalanceTeams': autoBalance,
        'displayInBrowser': true,
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
    var proxies = List<KyberProxy>.from(data.map((proxy) => KyberProxy.fromJson(proxy)));
    proxies = await Future.wait(proxies.map((proxy) async {
      final start = DateTime.now();
      DateTime? end;
      await Socket.connect(proxy.ip, 25200, timeout: const Duration(seconds: 1)).then((socket) {
        socket.destroy();
        end = DateTime.now();
      }).catchError((error) {
        Logger.root.severe('Proxy ${proxy.ip} is not reachable');
      });
      proxy.ping = end?.difference(start).inMilliseconds;
      return proxy;
    }))
      ..sort((a, b) => (a.ping ?? 999).compareTo(b.ping ?? 999));
    return proxies;
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
