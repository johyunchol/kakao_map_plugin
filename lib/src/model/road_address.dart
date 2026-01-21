/// 도로명 주소 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 주소 검색 결과에 포함되는 도로명 주소 정보를 담습니다.
/// 행정구역, 도로명, 건물번호, 건물명 등의 정보를 포함합니다.
///
/// 예시:
/// ```dart
/// final roadAddress = RoadAddress(
///   addressName: '서울 중구 세종대로 110',
///   region1DepthName: '서울',
///   region2DepthName: '중구',
///   region3DepthName: '세종로',
///   roadName: '세종대로',
///   undergroundYn: 'N',
///   mainBuildingNo: '110',
///   subBuildingNo: '',
///   buildingName: '서울특별시청',
///   zoneNo: '04524',
/// );
/// ```
class RoadAddress {
  /// 전체 도로명 주소입니다.
  ///
  /// 예시: "서울 중구 세종대로 110"
  final String addressName;

  /// 지역 1 Depth (시도 단위) 명칭입니다.
  ///
  /// 예시: "서울", "경기", "부산"
  final String region1DepthName;

  /// 지역 2 Depth (구 단위) 명칭입니다.
  ///
  /// 예시: "중구", "강남구", "해운대구"
  final String region2DepthName;

  /// 지역 3 Depth (동 단위) 명칭입니다.
  ///
  /// 예시: "세종로", "역삼동", "우동"
  final String region3DepthName;

  /// 도로명입니다.
  ///
  /// 예시: "세종대로", "테헤란로", "해운대로"
  final String roadName;

  /// 지하 여부입니다.
  ///
  /// - "Y": 지하
  /// - "N": 지상
  final String undergroundYn;

  /// 건물 본번입니다.
  ///
  /// 예시: "110", "123", "1"
  final String mainBuildingNo;

  /// 건물 부번입니다.
  ///
  /// 부번이 없는 경우 빈 문자열입니다.
  /// 예시: "1", "23", ""
  final String subBuildingNo;

  /// 건물명입니다.
  ///
  /// 건물명이 없는 경우 빈 문자열입니다.
  /// 예시: "서울특별시청", "강남역센터", ""
  final String buildingName;

  /// 우편번호(5자리)입니다.
  ///
  /// 예시: "04524", "06234"
  final String zoneNo;

  /// RoadAddress 객체를 생성합니다.
  ///
  /// 모든 필드는 필수입니다.
  RoadAddress({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.roadName,
    required this.undergroundYn,
    required this.mainBuildingNo,
    required this.subBuildingNo,
    required this.buildingName,
    required this.zoneNo,
  });

  /// JSON Map으로부터 RoadAddress 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'address_name': '서울 중구 세종대로 110',
  ///   'region_1depth_name': '서울',
  ///   'region_2depth_name': '중구',
  ///   'region_3depth_name': '세종로',
  ///   'road_name': '세종대로',
  ///   'underground_yn': 'N',
  ///   'main_building_no': '110',
  ///   'sub_building_no': '',
  ///   'building_name': '서울특별시청',
  ///   'zone_no': '04524',
  /// };
  /// final roadAddress = RoadAddress.fromJson(json);
  /// ```
  factory RoadAddress.fromJson(Map<String, dynamic> json) => RoadAddress(
        addressName: json['address_name'],
        region1DepthName: json['region_1depth_name'],
        region2DepthName: json['region_2depth_name'],
        region3DepthName: json['region_3depth_name'],
        roadName: json['road_name'],
        undergroundYn: json['underground_yn'],
        mainBuildingNo: json['main_building_no'],
        subBuildingNo: json['sub_building_no'],
        buildingName: json['building_name'],
        zoneNo: json['zone_no'],
      );

  /// RoadAddress 객체를 JSON Map으로 변환합니다.
  ///
  /// 예시:
  /// ```dart
  /// final roadAddress = RoadAddress(
  ///   addressName: '서울 중구 세종대로 110',
  ///   region1DepthName: '서울',
  ///   region2DepthName: '중구',
  ///   region3DepthName: '세종로',
  ///   roadName: '세종대로',
  ///   undergroundYn: 'N',
  ///   mainBuildingNo: '110',
  ///   subBuildingNo: '',
  ///   buildingName: '서울특별시청',
  ///   zoneNo: '04524',
  /// );
  /// final json = roadAddress.toJson();
  /// ```
  Map<String, dynamic> toJson() => {
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'road_name': roadName,
        'underground_yn': undergroundYn,
        'main_building_no': mainBuildingNo,
        'sub_building_no': subBuildingNo,
        'building_name': buildingName,
        'zone_no': zoneNo,
      };

  /// RoadAddress 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'RoadAddress{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, roadName: $roadName, undergroundYn: $undergroundYn, mainBuildingNo: $mainBuildingNo, subBuildingNo: $subBuildingNo, buildingName: $buildingName, zoneNo: $zoneNo}';
  }
}
