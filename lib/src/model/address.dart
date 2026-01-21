/// 지번 주소 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 주소 검색 결과에 포함되는 지번 주소 정보를 담습니다.
/// 행정구역 정보와 번지 정보를 포함합니다.
///
/// 예시:
/// ```dart
/// final address = Address(
///   addressName: '서울 중구 태평로1가 31',
///   region1DepthName: '서울',
///   region2DepthName: '중구',
///   region3DepthName: '태평로1가',
///   mountainYn: 'N',
///   mainAddressNo: '31',
///   subAddressNo: '',
///   zipCode: '04512',
/// );
/// ```
class Address {
  /// 전체 지번 주소입니다.
  ///
  /// 예시: "서울 중구 태평로1가 31"
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
  /// 예시: "태평로1가", "역삼동", "우동"
  final String region3DepthName;

  /// 산 여부입니다.
  ///
  /// - "Y": 산
  /// - "N": 일반 지번
  final String mountainYn;

  /// 지번 주번지입니다.
  ///
  /// 예시: "31", "123", "1"
  final String mainAddressNo;

  /// 지번 부번지입니다.
  ///
  /// 부번지가 없는 경우 빈 문자열입니다.
  /// 예시: "1", "23", ""
  final String subAddressNo;

  /// 우편번호(5자리)입니다.
  ///
  /// 우편번호 정보가 없는 경우 null입니다.
  /// 예시: "04512", "06234"
  final String? zipCode;

  /// Address 객체를 생성합니다.
  ///
  /// 모든 필드는 필수이며, [zipCode]만 선택사항입니다.
  Address({
    required this.addressName,
    required this.region1DepthName,
    required this.region2DepthName,
    required this.region3DepthName,
    required this.mountainYn,
    required this.mainAddressNo,
    required this.subAddressNo,
    required this.zipCode,
  });

  /// JSON Map으로부터 Address 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'address_name': '서울 중구 태평로1가 31',
  ///   'region_1depth_name': '서울',
  ///   'region_2depth_name': '중구',
  ///   'region_3depth_name': '태평로1가',
  ///   'mountain_yn': 'N',
  ///   'main_address_no': '31',
  ///   'sub_address_no': '',
  ///   'zip_code': '04512',
  /// };
  /// final address = Address.fromJson(json);
  /// ```
  factory Address.fromJson(Map<String, dynamic> json) => Address(
        addressName: json['address_name'],
        region1DepthName: json['region_1depth_name'],
        region2DepthName: json['region_2depth_name'],
        region3DepthName: json['region_3depth_name'],
        mountainYn: json['mountain_yn'],
        mainAddressNo: json['main_address_no'],
        subAddressNo: json['sub_address_no'],
        zipCode: json['zip_code'],
      );

  /// Address 객체를 JSON Map으로 변환합니다.
  ///
  /// 예시:
  /// ```dart
  /// final address = Address(
  ///   addressName: '서울 중구 태평로1가 31',
  ///   region1DepthName: '서울',
  ///   region2DepthName: '중구',
  ///   region3DepthName: '태평로1가',
  ///   mountainYn: 'N',
  ///   mainAddressNo: '31',
  ///   subAddressNo: '',
  ///   zipCode: '04512',
  /// );
  /// final json = address.toJson();
  /// ```
  Map<String, dynamic> toJson() => {
        'address_name': addressName,
        'region_1depth_name': region1DepthName,
        'region_2depth_name': region2DepthName,
        'region_3depth_name': region3DepthName,
        'mountain_yn': mountainYn,
        'main_address_no': mainAddressNo,
        'sub_address_no': subAddressNo,
        'zip_code': zipCode,
      };

  /// Address 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'Address{addressName: $addressName, region1DepthName: $region1DepthName, region2DepthName: $region2DepthName, region3DepthName: $region3DepthName, mountainYn: $mountainYn, mainAddressNo: $mainAddressNo, subAddressNo: $subAddressNo, zipCode: $zipCode}';
  }
}
