import 'package:auto_update/auto_update.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/github_asset.dart';
import 'package:logging/logging.dart';
import 'package:version/version.dart';

class AutoUpdater {
  Future<VersionInfo?> updateAvailable() async {
    List<dynamic>? packageInfo = await const MethodChannel('auto_update').invokeListMethod("getProductAndVersion");
    Version currentVersion = Version.parse(packageInfo![1]);
    VersionInfo? latestVersion = await getLatestVersion();
    if (latestVersion == null || latestVersion.version <= currentVersion) {
      Logger.root.info("No updates available");
      return null;
    }
    return latestVersion;
  }

  Future<void> update() async {
    VersionInfo? available = await updateAvailable();
    if (available == null) {
      return;
    }

    await AutoUpdate.downloadAndUpdate(available.assetUrl);
  }

  Future<VersionInfo?> getLatestVersion() async {
    var response =
        await ApiService.dio(cachePolicy: CachePolicy.forceCache, maxCacheStale: const Duration(hours: 1)).get('https://api.github.com/repos/7reax/kyber-mod-manager/releases');
    List<GitHubAsset> releases = [];
    response.data.forEach((release) {
      releases
          .add(GitHubAsset.fromJson({...release['assets'].where((asset) => asset['name'].toString().endsWith('.exe')).first, 'version': release['tag_name'], 'id': release['id']}));
    });
    var version = box.get('beta') ? releases.first : releases.firstWhere((element) => !Version.parse(element.version).isPreRelease);
    var versionInfo = await Dio().get('https://api.github.com/repos/7reax/kyber-mod-manager/releases/${version.id}');
    return VersionInfo(Version.parse(version.version), version.browser_download_url, versionInfo.data['body']);
  }
}

class VersionInfo {
  final Version version;
  final String assetUrl;
  final String body;

  VersionInfo(this.version, this.assetUrl, this.body);
}
