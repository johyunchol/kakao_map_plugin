part of '../../kakao_map_plugin.dart';

class CategorySearchService extends BaseService<CategorySearchResponse> {
  static final CategorySearchService _instance =
      CategorySearchService._internal();

  factory CategorySearchService() => _instance;

  CategorySearchService._internal() : super();

  static void categorySearchCallback(String message) {
    final resultData = jsonDecode(message);
    _instance._completer.complete(CategorySearchResponse.fromJson(resultData));
  }

  static Future<CategorySearchResponse> categorySearchResult() =>
      _instance.completer.future;
}
