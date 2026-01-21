import '../model/search_address.dart';

/// 주소 검색 응답 클래스입니다.
///
/// 카카오 로컬 API의 주소 검색 결과를 담는 응답 객체입니다.
/// 검색된 주소 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.addressSearch(request);
/// for (var address in response.list) {
///   print('주소명: ${address.addressName}');
///   print('지번 주소: ${address.address?.addressName}');
///   print('도로명 주소: ${address.roadAddress?.addressName}');
///   print('좌표: (${address.x}, ${address.y})');
/// }
/// ```
class AddressSearchResponse {
  /// 검색된 주소 정보 목록입니다.
  ///
  /// 각 항목은 [SearchAddress] 타입으로, 주소명, 지번 주소, 도로명 주소,
  /// 좌표 등의 상세 정보를 포함합니다.
  List<SearchAddress> list = [];

  /// AddressSearchResponse 생성자입니다.
  ///
  /// [list] 검색 결과 목록을 초기화합니다.
  AddressSearchResponse({
    required this.list,
  });

  /// JSON 배열로부터 AddressSearchResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [SearchAddress] 목록으로 변환합니다.
  AddressSearchResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => SearchAddress.fromJson(e)).toList();
  }

  /// AddressSearchResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'AddressSearchResponse{list: $list}';
  }
}
