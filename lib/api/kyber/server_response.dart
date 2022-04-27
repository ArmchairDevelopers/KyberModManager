import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';

class ServerResponse {
  ServerResponse({
    required this.page,
    required this.pageCount,
    required this.serverCount,
    required this.servers,
  });

  late final int page;
  late final int pageCount;
  late final int serverCount;
  late final List<KyberServer> servers;

  ServerResponse.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageCount = json['pageCount'];
    serverCount = json['serverCount'];
    servers = List.from(json['servers']).map((e) => KyberServer.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['page'] = page;
    _data['pageCount'] = pageCount;
    _data['serverCount'] = serverCount;
    _data['servers'] = servers.map((e) => e.toJson()).toList();
    return _data;
  }
}
