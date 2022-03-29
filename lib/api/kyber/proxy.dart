class KyberProxy {
  KyberProxy({
    required this.ip,
    required this.name,
    required this.flag,
    this.ping,
  });

  String ip;
  String name;
  String flag;
  int? ping;

  factory KyberProxy.fromJson(Map<String, dynamic> json) => KyberProxy(ip: json["ip"], name: json["name"], flag: json["flag"], ping: json["ping"]);

  Map<String, dynamic> toJson() => {"ip": ip, "name": name, "flag": flag, "ping": ping};
}
