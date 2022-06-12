import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/services/frosty_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/github_asset.dart';
import 'package:kyber_mod_manager/utils/types/frosty_config.dart';

class PathHelper {
  static CancelToken? _cancelToken;

  static Future<List<GitHubAsset>> getFrostyVersions() async {
    var response = await ApiService.dio(cachePolicy: CachePolicy.forceCache, maxCacheStale: const Duration(hours: 3))
        .get('https://api.github.com/repos/CadeEvs/FrostyToolsuite/releases');
    List<GitHubAsset> releases = [];
    response.data.forEach((release) {
      releases.add(GitHubAsset.fromJson({...release['assets'].where((asset) => asset['name'] == 'FrostyModManager.zip').first, 'version': release['tag_name']}));
    });
    return releases;
  }

  static void cancelDownload() => _cancelToken?.cancel();

  static Future<void> downloadFrosty(Directory path, GitHubAsset gitHubAsset, Function(int, int) onProgress) async {
    onProgress(0, gitHubAsset.size);
    _cancelToken = CancelToken();
    await Dio().download(
      gitHubAsset.browser_download_url,
      '${path.path}.zip',
      cancelToken: _cancelToken,
      onReceiveProgress: (received, total) => onProgress(received, total),
    );
    await Future.delayed(const Duration(seconds: 1));
    final inputStream = InputFileStream('${path.path}.zip');
    final archive = ZipDecoder().decodeBuffer(inputStream, verify: false);
    for (var file in archive.files) {
      String filepath = '${path.path}/${file.name}';
      if (!file.isFile) {
        continue;
      }

      if (!File(filepath).existsSync()) {
        File(filepath).createSync(recursive: true);
      }
      final outputStream = OutputFileStream(filepath);
      file.writeContent(outputStream);
      outputStream.close();
    }
    archive.clear();
  }

  static String? isValidFrostyDir(String path) {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return 'invalid_dir';
    }

    List<FileSystemEntity> entities = directory.listSync().toList();
    if (entities.where((element) => element.path.endsWith('FrostyModManager.exe')).isEmpty) {
      return 'invalid_dir';
    }

    Directory dataDir = Directory('$path/Mods/starwarsbattlefrontii');
    if (!dataDir.existsSync()) {
      return 'bf2_not_found';
    }

    FrostyConfig config = FrostyService.getFrostyConfig();
    if (!config.games.keys.contains('starwarsbattlefrontii')) {
      return 'bf2_not_found';
    }

    return null;
  }
}
