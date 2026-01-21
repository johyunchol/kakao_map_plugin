part of '../../kakao_map_plugin.dart';

/// JSON 문자열로부터 SearchAddress 객체를 생성합니다.
///
/// 카카오 로컬 API의 응답 문자열을 파싱할 때 사용됩니다.
///
/// 예시:
/// ```dart
/// final jsonString = '{"id":"123","address_name":"서울 중구 태평로1가 31",...}';
/// final searchAddress = searchAddressFromJson(jsonString);
/// ```
SearchAddress searchAddressFromJson(String str) =>
    SearchAddress.fromJson(json.decode(str));

/// SearchAddress 객체를 JSON 문자열로 변환합니다.
///
/// 예시:
/// ```dart
/// final searchAddress = SearchAddress(...);
/// final jsonString = searchAddressToJson(searchAddress);
/// ```
String searchAddressToJson(SearchAddress data) => json.encode(data.toJson());

/// 주소 검색 결과 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 주소 검색 API 응답 데이터를 담습니다.
/// 도로명 주소와 지번 주소 정보를 모두 포함할 수 있으며,
/// 좌표 정보와 주소 유형 등의 메타데이터도 제공합니다.
///
/// 예시:
/// ```dart
/// final searchAddress = SearchAddress(
///   id: '12345',
///   addressName: '서울 중구 태평로1가 31',
///   addressType: 'REGION',
///   x: '126.978275',
///   y: '37.566535',
///   roadAddress: RoadAddress(...),
///   address: Address(...),
/// );
/// ```
class SearchAddress {
  /// 장소 ID입니다.
  ///
  /// 주소 검색 결과의 고유 식별자입니다.
  final String? id;

  /// 전체 주소명입니다.
  ///
  /// 도로명 주소 또는 지번 주소 중 대표 주소가 표시됩니다.
  /// 예시: "서울 중구 태평로1가 31"
  final String? addressName;

  /// 주소 유형입니다.
  ///
  /// - "REGION": 지명
  /// - "ROAD": 도로명
  /// - "REGION_ADDR": 지번
  /// - "ROAD_ADDR": 도로명 주소
  final String? addressType;

  /// X 좌표 값 (경도, Longitude)입니다.
  ///
  /// WGS84 좌표계를 사용하며, 문자열 형태로 제공됩니다.
  /// 예시: "126.978275"
  final String? x;

  /// Y 좌표 값 (위도, Latitude)입니다.
  ///
  /// WGS84 좌표계를 사용하며, 문자열 형태로 제공됩니다.
  /// 예시: "37.566535"
  final String? y;

  /// 도로명 주소 정보입니다.
  ///
  /// 도로명 주소가 없는 경우 null입니다.
  final RoadAddress? roadAddress;

  /// 지번 주소 정보입니다.
  ///
  /// 지번 주소가 없는 경우 null입니다.
  final Address? address;

  /// SearchAddress 객체를 생성합니다.
  ///
  /// 모든 필드는 선택사항입니다.
  const SearchAddress({
    required this.id,
    required this.addressName,
    required this.addressType,
    required this.x,
    required this.y,
    required this.roadAddress,
    required this.address,
  });

  /// JSON Map으로부터 SearchAddress 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'id': '12345',
  ///   'address_name': '서울 중구 태평로1가 31',
  ///   'address_type': 'REGION',
  ///   'x': '126.978275',
  ///   'y': '37.566535',
  ///   'road_address': {...},
  ///   'address': {...},
  /// };
  /// final searchAddress = SearchAddress.fromJson(json);
  /// ```
  factory SearchAddress.fromJson(Map<String, dynamic> json) => SearchAddress(
        id: json['id'],
        addressName: json['address_name'],
        addressType: json['address_type'],
        x: json['x'],
        y: json['y'],
        roadAddress: json['road_address'] == null
            ? null
            : RoadAddress.fromJson(json['road_address']),
        address:
            json['address'] == null ? null : Address.fromJson(json['address']),
      );

  /// SearchAddress 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 null이 아닌 필드만 포함합니다.
  Map<String, dynamic> toJson() => {
        'id': id,
        'address_name': addressName,
        'address_type': addressType,
        'x': x,
        'y': y,
        'road_address': roadAddress?.toJson(),
        'address': address?.toJson(),
      };

  /// SearchAddress 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'SearchAddress{id: $id, addressName: $addressName, addressType: $addressType, x: $x, y: $y, roadAddress: $roadAddress, address: $address}';
  }
}
