import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:kyber_mod_manager/api/backend/download_info.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';
import 'package:kyber_mod_manager/main.dart';

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

  static Future<DownloadInfo?> getDownloadInfo(String modName) async {
    final resp = await get(Uri.parse('$BACKEND_API_BASE_URL/mods/download?query=$modName'));
    if (resp.statusCode == 200) {
      return DownloadInfo.fromJson(json.decode(resp.body));
    }
    return null;
  }
}
