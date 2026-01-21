import 'dart:convert';

import 'package:kakao_map_plugin/src/protocol/category_search_response.dart';
import 'package:kakao_map_plugin/src/service/base_service.dart';

/// 카테고리로 장소를 검색하는 서비스입니다.
///
/// 카카오 로컬 API의 카테고리 검색 기능을 제공합니다.
/// 지정한 카테고리의 장소를 특정 영역 내에서 검색할 수 있습니다.
/// 싱글톤 패턴으로 구현되어 있으며, [Completer] 기반의 비동기 처리를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final response = await controller.categorySearch(
///   CategorySearchRequest(
///     categoryGroupCode: 'FD6', // 음식점 카테고리
///     x: '127.06283102249932',
///     y: '37.514322572335935',
///     radius: 1000,
///   ),
/// );
/// ```
class CategorySearchService extends BaseService<CategorySearchResponse> {
  static final CategorySearchService _instance =
      CategorySearchService._internal();

  /// [CategorySearchService]의 싱글톤 인스턴스를 반환합니다.
  factory CategorySearchService() => _instance;

  /// private 생성자로 싱글톤 패턴을 구현합니다.
  CategorySearchService._internal() : super();

  /// 네이티브 플랫폼에서 카테고리 검색 결과를 받아 처리하는 콜백입니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달한 JSON 문자열입니다.
  /// 이 메서드는 네이티브 코드에서 직접 호출됩니다.
  static void categorySearchCallback(String message) {
    final resultData = jsonDecode(message);
    _instance.completer.complete(CategorySearchResponse.fromJson(resultData));
  }

  /// 카테고리 검색 결과를 비동기로 반환합니다.
  ///
  /// 네이티브 플랫폼에서 검색이 완료되면 [CategorySearchResponse]를 반환합니다.
  /// 이 Future는 [categorySearchCallback]이 호출될 때 완료됩니다.
  static Future<CategorySearchResponse> categorySearchResult() =>
      _instance.completer.future;
}
