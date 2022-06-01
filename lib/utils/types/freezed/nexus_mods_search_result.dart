import 'package:freezed_annotation/freezed_annotation.dart';

part 'nexus_mods_search_result.freezed.dart';
part 'nexus_mods_search_result.g.dart';

@freezed
abstract class NexusModsSearchResult with _$NexusModsSearchResult {
  const factory NexusModsSearchResult({
    required List<String> terms,
    required List<dynamic> exclude_authors,
    required List<dynamic> exclude_tags,
    required bool include_adult,
    required int took,
    required int total,
    required List<Result> results,
  }) = _NexusModsSearchResult;

  factory NexusModsSearchResult.fromJson(Map<String, dynamic> json) => _$NexusModsSearchResultFromJson(json);
}

@freezed
abstract class Result with _$Result {
  const factory Result({
    required String name,
    required int downloads,
    required int endorsements,
    required String url,
    required String image,
    required String username,
    required int user_id,
    required String game_name,
    required int game_id,
    required int mod_id,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
