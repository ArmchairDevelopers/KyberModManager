import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_asset.freezed.dart';
part 'github_asset.g.dart';

@freezed
abstract class GitHubAsset with _$GitHubAsset {
  const factory GitHubAsset({
    required String url,
    required int id,
    required String node_id,
    required String name,
    required dynamic label,
    required String content_type,
    required String state,
    required int size,
    required int download_count,
    required DateTime created_at,
    required DateTime updated_at,
    required String version,
    required String browser_download_url,
  }) = _GitHubAsset;

  factory GitHubAsset.fromJson(Map<String, dynamic> json) => _$GitHubAssetFromJson(json);
}
