part of '../../kakao_map_plugin.dart';

class KeywordSearchService extends BaseService<KeywordSearchResponse> {
  static final KeywordSearchService _instance =
      KeywordSearchService._internal();

  factory KeywordSearchService() {
    return _instance;
  }

  KeywordSearchService._internal() : super();

  static void keywordSearchCallback(String message) {
    final resultData = jsonDecode(message);
    _instance._completer.complete(KeywordSearchResponse.fromJson(resultData));
  }

  static Future<KeywordSearchResponse> keywordSearchResult() {
    return _instance.completer.future;
  }
}
