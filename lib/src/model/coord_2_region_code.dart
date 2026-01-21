/// 좌표를 행정구역 코드로 변환한 결과 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 좌표-행정구역 변환 API 응답 데이터를 담습니다.
/// 행정동, 법정동 등의 구역 정보와 행정코드를 제공합니다.
///
/// 예시:
/// ```dart
/// final regionCode = Coord2RegionCode(
///   regionType: 'H',
///   addressName: '서울특별시 중구 태평로1가',
///   region1DepthName: '서울특별시',
///   region2DepthName: '중구',
///   region3DepthName: '태평로1가',
///   region4DepthName: '',
///   code: '1114051500',
///   x: 126.978275,
///   y: 37.566535,
/// );
/// ```
class Coord2RegionCode {
  /// 행정구역 타입입니다.
  ///
  /// - "H": 행정동
  /// - "B": 법정동
  final String? regionType;

  /// 전체 주소명입니다.
  ///
  /// 예시: "서울특별시 중구 태평로1가"
  final String? addressName;

  /// 지역 1 Depth (시도 단위) 명칭입니다.
  ///
  /// 예시: "서울특별시", "경기도", "부산광역시"
  final String? region1DepthName;

  /// 지역 2 Depth (구 단위) 명칭입니다.
  ///
  /// 예시: "중구", "강남구", "해운대구"
  final String? region2DepthName;

  /// 지역 3 Depth (동 단위) 명칭입니다.
  ///
  /// 예시: "태평로1가", "역삼동", "우동"
  final String? region3DepthName;

  /// 지역 4 Depth 명칭입니다.
  ///
  /// 법정동의 리 영역명 또는 산 이름입니다.
  /// 행정동인 경우 빈 문자열입니다.
  final String? region4DepthName;

  /// 행정구역 코드입니다.
  ///
  /// B(법정동) 코드는 10자리이며, H(행정동) 코드는 뒤 2자리가 "00"으로 끝납니다.
  /// 예시: "1114051500", "4113511000"
  final String? code;

  /// X 좌표 값 (경도, Longitude)입니다.
  ///
  /// 해당 행정구역의 중심 좌표입니다.
  final double? x;

  /// Y 좌표 값 (위도, Latitude)입니다.
  ///
  /// 해당 행정구역의 중심 좌표입니다.
  final double? y;

  /// Coord2RegionCode 객체를 생성합니다.
  ///
  /// 모든 필드는 선택사항입니다.
  const Coord2RegionCode({
    required this.regionType,
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.region4DepthName,
    required this.code,
    required this.x,
    required this.y,
  });

  /// JSON Map으로부터 Coord2RegionCode 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'region_type': 'H',
  ///   'address_name': '서울특별시 중구 태평로1가',
  ///   'region_1depth_name': '서울특별시',
  ///   'region_2depth_name': '중구',
  ///   'region_3depth_name': '태평로1가',
  ///   'region_4depth_name': '',
  ///   'code': '1114051500',
  ///   'x': 126.978275,
  ///   'y': 37.566535,
  /// };
  /// final regionCode = Coord2RegionCode.fromJson(json);
  /// ```
  factory Coord2RegionCode.fromJson(Map<String, dynamic> json) =>
      Coord2RegionCode(
        regionType: json['region_type'] as String?,
        addressName: json['address_name'] as String?,
        region1DepthName: json['region_1depth_name'] as String?,
        region2DepthName: json['region_2depth_name'] as String?,
        region3DepthName: json['region_3depth_name'] as String?,
        region4DepthName: json['region_4depth_name'] as String?,
        code: json['code'] as String?,
        x: json['x'] as double?,
        y: json['y'] as double?,
      );

  /// Coord2RegionCode 객체를 JSON Map으로 변환합니다.
  ///
  /// 모든 필드가 포함된 JSON Map을 반환합니다.
  Map<String, dynamic> toJson() => {
        'region_type': regionType,
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'region_4depth_name': region4DepthName,
        'code': code,
        'x': x,
        'y': y,
      };

  /// Coord2RegionCode 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'Coord2RegionCode{regionType: $regionType, addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, region4DepthName: $region4DepthName, code: $code, x: $x, y: $y}';
  }
}
