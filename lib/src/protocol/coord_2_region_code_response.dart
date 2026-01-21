import '../model/coord_2_region_code.dart';

/// 좌표를 행정구역 코드로 변환한 응답 클래스입니다.
///
/// 카카오 로컬 API의 좌표 → 행정구역 정보 변환 결과를 담는 응답 객체입니다.
/// 지정한 좌표에 해당하는 행정구역 정보 목록을 포함합니다.
///
/// 예시:
/// ```dart
/// final response = await kakaoMapService.coord2RegionCode(request);
/// for (var region in response.list) {
///   print('지역명: ${region.regionName}');
///   print('행정구역 코드: ${region.code}');
///   print('지역 타입: ${region.regionType}'); // H(행정동), B(법정동)
/// }
/// ```
class Coord2RegionCodeResponse {
  /// 변환된 행정구역 정보 목록입니다.
  ///
  /// 각 항목은 [Coord2RegionCode] 타입으로, 행정구역 코드, 지역명,
  /// 지역 타입(행정동/법정동) 등의 정보를 포함합니다.
  /// 일반적으로 하나의 좌표에 대해 여러 지역 정보가 반환됩니다.
  List<Coord2RegionCode> list = [];

  /// Coord2RegionCodeResponse 생성자입니다.
  ///
  /// [list] 변환 결과 목록을 초기화합니다.
  Coord2RegionCodeResponse({
    required this.list,
  });

  /// JSON 배열로부터 Coord2RegionCodeResponse 인스턴스를 생성합니다.
  ///
  /// API 응답의 documents 배열을 파싱하여 [Coord2RegionCode] 목록으로 변환합니다.
  Coord2RegionCodeResponse.fromJson(List<dynamic> json) {
    list = json.map((e) => Coord2RegionCode.fromJson(e)).toList();
  }

  /// Coord2RegionCodeResponse 인스턴스를 JSON 객체로 변환합니다.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['list'] = list.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'Coord2RegionCodeResponse{list: $list}';
  }
}
