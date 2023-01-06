import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:http/http.dart';
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/types/freezed/discord_event.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';

class ApiService {
  static Future<bool> isAvailable(String name) async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/mods?q=$name'),
        headers: {'Accept': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getLatestFrostyVersion() async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/frosty/latest'),
      );
      return response.statusCode == 200 ? jsonDecode(response.body)['version'] : '';
    } catch (e) {
      return '';
    }
  }

  static Future<List<FrostyVersion>> versionHashes() async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/frosty/hashes'),
        headers: {'Accept': 'application/json'},
      );
      return (json.decode(response.body) as List<dynamic>).map((e) {
        e['plugins'] = [];
        return FrostyVersion.fromJson(e);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> supportedFrostyVersions() async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/frosty/versions'),
      );
      return List<String>.from(json.decode(response.body));
    } catch (e) {
      return [];
    }
  }

  static Future<_DownloadLinksResponse> getDownloadLinks(List<String> mods) async {
    List<String> links = [];
    List<String> unavailableMods = [];
    await Future.wait(mods.map((e) async {
      var info = await getDownloadInfo(e);
      if (info?.fileUrl == null) {
        unavailableMods.add(e);
        return;
      }
      links.add(info!.fileUrl + '?tab=files&file_id=' + info.fileId);
    }));
    return _DownloadLinksResponse(links, unavailableMods);
  }

  static Future<DownloadInfo?> getDownloadInfo(String modName) async {
    final resp = await get(Uri.parse('$BACKEND_API_BASE_URL/mods?q=$modName'));
    if (resp.statusCode == 200) {
      return DownloadInfo.fromJson(json.decode(resp.body));
    }
    return null;
  }

  static HiveCacheStore get cacheStore => HiveCacheStore(
    applicationDocumentsDirectory,
    hiveBoxName: 'cache',
  );

  static Dio dio({Duration? maxCacheStale, CachePolicy? cachePolicy}) {
    var cacheOptions = CacheOptions(
      store: cacheStore,
      maxStale: maxCacheStale,
      policy: cachePolicy ?? CachePolicy.request,
      priority: CachePriority.high,
    );

    return Dio()..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }
}

class _DownloadLinksResponse {
  List<String> links;
  List<String> unavailable;

  _DownloadLinksResponse(this.links, this.unavailable);
}
