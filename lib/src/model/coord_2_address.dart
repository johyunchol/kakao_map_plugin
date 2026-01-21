import 'dart:convert';

import 'address.dart';
import 'road_address.dart';

/// 좌표를 주소로 변환한 결과 정보를 나타내는 클래스입니다.
///
/// 카카오 로컬 API의 좌표-주소 변환 API 응답 데이터를 담습니다.
/// 도로명 주소와 지번 주소 정보를 모두 포함할 수 있습니다.
///
/// 예시:
/// ```dart
/// final coord2Address = Coord2Address(
///   roadAddress: RoadAddress(...),
///   address: Address(...),
/// );
/// ```
class Coord2Address {
  /// 도로명 주소 정보입니다.
  ///
  /// 해당 좌표의 도로명 주소가 없는 경우 null입니다.
  final RoadAddress? roadAddress;

  /// 지번 주소 정보입니다.
  ///
  /// 해당 좌표의 지번 주소가 없는 경우 null입니다.
  final Address? address;

  /// Coord2Address 객체를 생성합니다.
  ///
  /// [roadAddress]와 [address] 모두 선택사항입니다.
  const Coord2Address({
    required this.roadAddress,
    required this.address,
  });

  /// JSON Map으로부터 Coord2Address 객체를 생성합니다.
  ///
  /// 카카오 로컬 API의 응답 데이터를 파싱할 때 사용됩니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {
  ///   'road_address': {...},
  ///   'address': {...},
  /// };
  /// final coord2Address = Coord2Address.fromJson(json);
  /// ```
  factory Coord2Address.fromJson(Map<String, dynamic> json) => Coord2Address(
        roadAddress: json['road_address'] == null
            ? null
            : RoadAddress.fromJson(json['road_address']),
        address:
            json['address'] == null ? null : Address.fromJson(json['address']),
      );

  /// Coord2Address 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 null이 아닌 필드만 포함합니다.
  Map<String, dynamic> toJson() => {
        'road_address': roadAddress?.toJson(),
        'address': address?.toJson(),
      };

  /// Coord2Address 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'Coord2Address{roadAddress: $roadAddress, address: $address}';
  }
}

/// JSON 문자열로부터 Coord2Address 객체를 생성합니다.
///
/// 카카오 로컬 API의 응답 문자열을 파싱할 때 사용됩니다.
///
/// 예시:
/// ```dart
/// final jsonString = '{"road_address":{...},"address":{...}}';
/// final coord2Address = coord2AddressFromJson(jsonString);
/// ```
Coord2Address coord2AddressFromJson(String str) =>
    Coord2Address.fromJson(json.decode(str));

/// Coord2Address 객체를 JSON 문자열로 변환합니다.
///
/// 예시:
/// ```dart
/// final coord2Address = Coord2Address(...);
/// final jsonString = coord2AddressToJson(coord2Address);
/// ```
String coord2AddressToJson(Coord2Address data) => json.encode(data.toJson());
