/// 위도(latitude)와 경도(longitude)를 나타내는 좌표 클래스입니다.
///
/// 카카오 지도 API에서 지도의 위치나 마커의 위치를 지정할 때 사용됩니다.
///
/// 예시:
/// ```dart
/// // 서울 시청의 좌표
/// final seoul = LatLng(37.5665, 126.9780);
/// print('위도: ${seoul.latitude}, 경도: ${seoul.longitude}');
///
/// // JSON으로 변환
/// final json = seoul.toJson();
/// // {"latitude": 37.5665, "longitude": 126.9780}
/// ```
class LatLng {
  /// 위도 값입니다.
  ///
  /// 범위: -90 ~ 90
  /// - 양수: 북반구
  /// - 음수: 남반구
  double latitude;

  /// 경도 값입니다.
  ///
  /// 범위: -180 ~ 180
  /// - 양수: 동반구
  /// - 음수: 서반구
  double longitude;

  /// [latitude]와 [longitude]를 받아 LatLng 객체를 생성합니다.
  ///
  /// 예시:
  /// ```dart
  /// final position = LatLng(37.5665, 126.9780);
  /// ```
  LatLng(this.latitude, this.longitude);

  /// JSON Map으로부터 LatLng 객체를 생성합니다.
  ///
  /// [json]은 'latitude'와 'longitude' 키를 포함해야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// final json = {'latitude': 37.5665, 'longitude': 126.9780};
  /// final position = LatLng.fromJson(json);
  /// ```
  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);

  /// LatLng 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 'latitude'와 'longitude' 키를 포함합니다.
  ///
  /// 예시:
  /// ```dart
  /// final position = LatLng(37.5665, 126.9780);
  /// final json = position.toJson();
  /// // {"latitude": 37.5665, "longitude": 126.9780}
  /// ```
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  /// LatLng 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }
}

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      json['latitude'] as double,
      json['longitude'] as double,
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
