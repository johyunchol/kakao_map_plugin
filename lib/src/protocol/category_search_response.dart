part of '../../kakao_map_plugin.dart';

/// 카테고리 검색 응답 클래스입니다.
///
/// 카카오 로컬 API의 카테고리 검색 결과를 담는 응답 객체입니다.
/// 특정 카테고리에 속하는 장소 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.categorySearch(request);
/// for (var place in response.list) {
///   print('장소명: ${place.placeName}');
///   print('카테고리: ${place.categoryName}');
///   print('거리: ${place.distance}m');
/// }
/// ```
class CategorySearchResponse {
  /// 검색된 장소 정보 목록입니다.
  ///
  /// 각 항목은 [KeywordAddress] 타입으로, 장소명, 카테고리, 주소, 좌표 등의
  /// 상세 정보를 포함합니다.
  List<KeywordAddress> list = [];

  /// CategorySearchResponse 생성자입니다.
  ///
  /// [list] 검색 결과 목록을 초기화합니다.
  CategorySearchResponse({
    required this.list,
  });

  /// JSON 배열로부터 CategorySearchResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [KeywordAddress] 목록으로 변환합니다.
  CategorySearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => KeywordAddress.fromJson(e)).toList();
  }

  /// CategorySearchResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'CategorySearchResponse{list: $list}';
  }
}
