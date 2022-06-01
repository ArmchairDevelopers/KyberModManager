import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:kyber_mod_manager/utils/services/api_service.dart';
import 'package:kyber_mod_manager/utils/types/freezed/nexus_mods_search_result.dart';

class NexusModsApiService {
  static const String _baseUrl = 'https://www.nexusmods.com/starwarsbattlefront22017/mods/';

  static Future<NexusModsSearchResult> search(String query) async {
    var res = await ApiService.dio().get('https://search.nexusmods.com/mods?terms=ioi&game_id=2229&blocked_tags=&blocked_authors=&include_adult=0');
    return NexusModsSearchResult.fromJson(res.data);
  }

  static Future<String?> generateDownloadUrl(String url, String version) async {
    if (!url.startsWith(_baseUrl) || url.replaceAll(url, _baseUrl).isEmpty) {
      return null;
    }

    var res = await ApiService.dio().get('$url?tab=files');
    var doc = parse(res.data);
    List<Element> element = doc.getElementsByClassName('file-expander-header').where((element) {
      return element.attributes['data-version'].toString().toLowerCase() == version.toLowerCase().replaceAll('v', '');
    }).toList();
    if (element.length != 1) {
      return null;
    }

    return '$url?tab=files&file_id=${element.first.attributes['data-id']}';
  }
}
