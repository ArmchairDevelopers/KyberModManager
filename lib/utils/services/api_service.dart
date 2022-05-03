import 'dart:convert';

import 'package:http/http.dart';
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';

class ApiService {
  static Future<bool> isAvailable(String name) async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/mods/check?query=$name'),
        headers: {'Accept': 'application/json'},
      );
      return response.statusCode == 200 && json.decode(response.body)['found'];
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> supportedFrostyVersions() async {
    try {
      final response = await get(
        Uri.parse('$BACKEND_API_BASE_URL/frosty/versions'),
      );
      print('$BACKEND_API_BASE_URL/frosty/versions');
      return List<String>.from(json.decode(response.body));
    } catch (e) {
      print(e);
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
    final resp = await get(Uri.parse('$BACKEND_API_BASE_URL/mods/download?query=$modName'));
    if (resp.statusCode == 200) {
      return DownloadInfo.fromJson(json.decode(resp.body));
    }
    return null;
  }
}

class _DownloadLinksResponse {
  List<String> links;
  List<String> unavailable;

  _DownloadLinksResponse(this.links, this.unavailable);
}
