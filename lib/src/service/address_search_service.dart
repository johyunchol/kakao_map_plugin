part of '../../kakao_map_plugin.dart';

/// 주소로 좌표를 검색하는 서비스입니다.
///
/// 카카오 로컬 API의 주소 검색 기능을 제공합니다.
/// 지번 주소 또는 도로명 주소를 입력하면 해당 위치의 좌표 정보를 반환합니다.
/// 싱글톤 패턴으로 구현되어 있으며, [Completer] 기반의 비동기 처리를 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final response = await controller.addressSearch(
///   AddressSearchRequest(
///     query: '전북 삼성동 100',
///   ),
/// );
/// ```
class AddressSearchService extends BaseService<AddressSearchResponse> {
  static final AddressSearchService _instance =
      AddressSearchService._internal();

  /// [AddressSearchService]의 싱글톤 인스턴스를 반환합니다.
  factory AddressSearchService() => _instance;

  /// private 생성자로 싱글톤 패턴을 구현합니다.
  AddressSearchService._internal() : super();

  /// 네이티브 플랫폼에서 주소 검색 결과를 받아 처리하는 콜백입니다.
  ///
  /// [message]는 네이티브 플랫폼에서 전달한 JSON 문자열입니다.
  /// 이 메서드는 네이티브 코드에서 직접 호출됩니다.
  static Future<void> addressSearchCallback(String message) async {
    final resultData = jsonDecode(message);
    _instance._completer.complete(AddressSearchResponse.fromJson(resultData));
  }

  /// 주소 검색 결과를 비동기로 반환합니다.
  ///
  /// 네이티브 플랫폼에서 검색이 완료되면 [AddressSearchResponse]를 반환합니다.
  /// 이 Future는 [addressSearchCallback]이 호출될 때 완료됩니다.
  static Future<AddressSearchResponse> addressSearchResult() {
    return _instance.completer.future;
  }
}
