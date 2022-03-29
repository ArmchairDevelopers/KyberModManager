import 'package:auto_update/auto_update.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
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

  Future<VersionInfo?> getLatestVersion() {
    return Dio().get('https://api.github.com/repos/7reax/kyber-mod-manager/releases/latest').then((response) {
      VersionInfo? versionInfo;
      response.data['assets'].forEach((asset) {
        if (asset['name'].toString().endsWith('.exe')) {
          versionInfo = VersionInfo(
            Version.parse(response.data['tag_name']),
            asset['browser_download_url'],
            response.data['body'],
          );
        }
      });
      return versionInfo;
    }).catchError((error) {
      return null;
    });
  }
}

class VersionInfo {
  final Version version;
  final String assetUrl;
  final String body;

  VersionInfo(this.version, this.assetUrl, this.body);
}
