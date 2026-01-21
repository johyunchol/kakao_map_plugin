import '../model/keyword_address.dart';

/// 키워드 검색 응답 클래스입니다.
///
/// 카카오 로컬 API의 키워드 검색 결과를 담는 응답 객체입니다.
/// 검색된 장소 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.keywordSearch(request);
/// for (var place in response.list) {
///   print('장소명: ${place.placeName}');
///   print('주소: ${place.addressName}');
/// }
/// ```
class KeywordSearchResponse {
  /// 검색된 장소 정보 목록입니다.
  ///
  /// 각 항목은 [KeywordAddress] 타입으로, 장소명, 주소, 좌표 등의
  /// 상세 정보를 포함합니다.
  List<KeywordAddress> list = [];

  /// KeywordSearchResponse 생성자입니다.
  ///
  /// [list] 검색 결과 목록을 초기화합니다.
  KeywordSearchResponse({
    required this.list,
  });

  /// JSON 배열로부터 KeywordSearchResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [KeywordAddress] 목록으로 변환합니다.
  KeywordSearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => KeywordAddress.fromJson(e)).toList();
  }

  /// KeywordSearchResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'KeywordSearchResponse{list: $list}';
  }
}
