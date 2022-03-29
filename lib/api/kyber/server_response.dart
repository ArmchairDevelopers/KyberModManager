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

class KyberServer {
  KyberServer({
    required this.id,
    required this.name,
    required this.map,
    required this.mode,
    required this.mods,
    required this.users,
    required this.host,
    required this.maxPlayers,
    required this.autoBalanceTeams,
    required this.startedAt,
    required this.startedAtPretty,
    required this.requiresPassword,
    required this.region,
    required this.proxy,
  });

  late final String id;
  late final String name;
  late final String map;
  late final String mode;
  late List<String> mods;
  late final int users;
  late final String host;
  late final int maxPlayers;
  late final bool autoBalanceTeams;
  late final int startedAt;
  late final String startedAtPretty;
  late final bool requiresPassword;
  late final String region;
  late final Proxy proxy;

  KyberServer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    map = json['map'];
    mode = json['mode'];
    mods = List.castFrom<dynamic, String>(json['mods']);
    users = json['users'];
    host = json['host'];
    maxPlayers = json['maxPlayers'];
    autoBalanceTeams = json['autoBalanceTeams'];
    startedAt = json['startedAt'];
    startedAtPretty = json['startedAtPretty'];
    requiresPassword = json['requiresPassword'];
    region = json['region'];
    proxy = Proxy.fromJson(json['proxy']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['map'] = map;
    _data['mode'] = mode;
    _data['mods'] = mods;
    _data['users'] = users;
    _data['host'] = host;
    _data['maxPlayers'] = maxPlayers;
    _data['autoBalanceTeams'] = autoBalanceTeams;
    _data['startedAt'] = startedAt;
    _data['startedAtPretty'] = startedAtPretty;
    _data['requiresPassword'] = requiresPassword;
    _data['region'] = region;
    _data['proxy'] = proxy.toJson();
    return _data;
  }
}

class Proxy {
  Proxy({
    required this.flag,
    required this.name,
  });

  late final String flag;
  late final String name;

  Proxy.fromJson(Map<String, dynamic> json) {
    flag = json['flag'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['flag'] = flag;
    _data['name'] = name;
    return _data;
  }
}
