import 'dart:convert';

FrostyConfig frostyConfigFromJson(String str) => FrostyConfig.fromJson(json.decode(str));

String frostyConfigToJson(FrostyConfig data) => json.encode(data.toJson());

class FrostyConfig {
  FrostyConfig({
    required this.games,
    required this.globalOptions,
  });

  Map<String, Game> games;
  GlobalOptions globalOptions;

  factory FrostyConfig.fromJson(Map<String, dynamic> json) => FrostyConfig(
        games: Map.from(json["Games"]).map((k, v) => MapEntry<String, Game>(k, Game.fromJson(v))),
        globalOptions: GlobalOptions.fromJson(json["GlobalOptions"]),
      );

  Map<String, dynamic> toJson() => {
        "Games": Map.from(games).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "GlobalOptions": globalOptions.toJson(),
      };
}

class Game {
  Game({
    required this.gamePath,
    required this.bookmarkDb,
    required this.options,
    this.packs,
  });

  String gamePath;
  String bookmarkDb;
  Options options;
  Map<String, String>? packs;

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gamePath: json["GamePath"],
        bookmarkDb: json["BookmarkDb"],
        options: Options.fromJson(json["Options"]),
        packs: Map.from(json['Packs']),
      );

  Map<String, dynamic> toJson() => {
        "GamePath": gamePath,
        "BookmarkDb": bookmarkDb,
        "Options": options.toJson(),
        "Packs": packs,
      };
}

class Options {
  Options({
    this.selectedPack,
    this.commandLineArgs,
    this.platform,
    this.platformLaunchingEnabled,
  });

  String? selectedPack;
  String? commandLineArgs;
  String? platform;
  bool? platformLaunchingEnabled;

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        selectedPack: json["SelectedPack"],
        commandLineArgs: json["CommandLineArgs"],
        platform: json["Platform"],
        platformLaunchingEnabled: json["PlatformLaunchingEnabled"],
      );

  Map<String, dynamic> toJson() => {
        "SelectedPack": selectedPack,
        "CommandLineArgs": commandLineArgs,
        "Platform": platform,
        "PlatformLaunchingEnabled": platformLaunchingEnabled,
      };
}

class GlobalOptions {
  GlobalOptions({
    required this.useDefaultProfile,
    required this.defaultProfile,
  });

  bool? useDefaultProfile;
  String? defaultProfile;

  factory GlobalOptions.fromJson(Map<String, dynamic> json) => GlobalOptions(
        useDefaultProfile: json["UseDefaultProfile"],
        defaultProfile: json["DefaultProfile"],
      );

  Map<String, dynamic> toJson() => {
        "UseDefaultProfile": useDefaultProfile,
        "DefaultProfile": defaultProfile,
      };
}
