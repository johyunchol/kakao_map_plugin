import '../model/coord_2_address.dart';

/// 좌표를 주소로 변환한 응답 클래스입니다.
///
/// 카카오 로컬 API의 좌표 → 주소 변환 결과를 담는 응답 객체입니다.
/// 지정한 좌표에 해당하는 주소 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.coord2Address(request);
/// for (var address in response.list) {
///   if (address.roadAddress != null) {
///     print('도로명 주소: ${address.roadAddress?.addressName}');
///   }
///   if (address.address != null) {
///     print('지번 주소: ${address.address?.addressName}');
///   }
/// }
/// ```
class Coord2AddressResponse {
  /// 변환된 주소 정보 목록입니다.
  ///
  /// 각 항목은 [Coord2Address] 타입으로, 해당 좌표의 지번 주소와
  /// 도로명 주소 정보를 포함합니다.
  /// 일반적으로 하나의 좌표에 대해 여러 주소가 반환될 수 있습니다.
  List<Coord2Address> list = [];

  /// Coord2AddressResponse 생성자입니다.
  ///
  /// [list] 변환 결과 목록을 초기화합니다.
  Coord2AddressResponse({
    required this.list,
  });

  /// JSON 배열로부터 Coord2AddressResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [Coord2Address] 목록으로 변환합니다.
  Coord2AddressResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => Coord2Address.fromJson(e)).toList();
  }

  /// Coord2AddressResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'Coord2AddressResponse{list: $list}';
  }
}
