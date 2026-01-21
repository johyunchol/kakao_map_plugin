import 'lat_lng.dart';

/// 지도의 영역을 나타내는 사각형 경계(Bounds) 클래스입니다.
///
/// 남서쪽(SouthWest) 좌표와 북동쪽(NorthEast) 좌표로 사각형 영역을 정의합니다.
/// 지도의 표시 영역을 제한하거나 특정 영역 내의 마커를 표시할 때 사용됩니다.
///
/// 예시:
/// ```dart
/// // 서울 지역의 경계 설정
/// final seoulBounds = LatLngBounds(
///   LatLng(37.4133, 126.7342),  // 남서쪽 (강서구)
///   LatLng(37.7015, 127.1839),  // 북동쪽 (노원구)
/// );
///
/// // 경계 좌표 가져오기
/// final sw = seoulBounds.getSouthWest();
/// final ne = seoulBounds.getNorthEast();
/// ```
class LatLngBounds {
  /// 경계의 남서쪽(SouthWest) 좌표입니다.
  ///
  /// 사각형 영역의 왼쪽 아래 모서리를 나타냅니다.
  LatLng sw;

  /// 경계의 북동쪽(NorthEast) 좌표입니다.
  ///
  /// 사각형 영역의 오른쪽 위 모서리를 나타냅니다.
  LatLng ne;

  /// [sw](남서쪽)와 [ne](북동쪽) 좌표를 받아 LatLngBounds 객체를 생성합니다.
  ///
  /// 예시:
  /// ```dart
  /// final bounds = LatLngBounds(
  ///   LatLng(37.4133, 126.7342),  // 남서쪽
  ///   LatLng(37.7015, 127.1839),  // 북동쪽
  /// );
  /// ```
  LatLngBounds(this.sw, this.ne);

  /// JSON Map으로부터 LatLngBounds 객체를 생성합니다.
  ///
  /// [json]은 'sw'와 'ne' 키를 포함해야 합니다.
  factory LatLngBounds.fromJson(Map<String, dynamic> json) =>
      _$LatLngBoundsFromJson(json);

  /// LatLngBounds 객체를 JSON Map으로 변환합니다.
  ///
  /// 반환값은 'sw'와 'ne' 키를 포함합니다.
  Map<String, dynamic> toJson() => _$LatLngBoundsToJson(this);

  /// 경계의 남서쪽(SouthWest) 좌표를 반환합니다.
  ///
  /// 사각형 영역의 왼쪽 아래 모서리 좌표입니다.
  ///
  /// 예시:
  /// ```dart
  /// final bounds = LatLngBounds(
  ///   LatLng(37.4133, 126.7342),
  ///   LatLng(37.7015, 127.1839),
  /// );
  /// final southWest = bounds.getSouthWest();
  /// print('남서쪽: ${southWest.latitude}, ${southWest.longitude}');
  /// ```
  LatLng getSouthWest() => sw;

  /// 경계의 북동쪽(NorthEast) 좌표를 반환합니다.
  ///
  /// 사각형 영역의 오른쪽 위 모서리 좌표입니다.
  ///
  /// 예시:
  /// ```dart
  /// final bounds = LatLngBounds(
  ///   LatLng(37.4133, 126.7342),
  ///   LatLng(37.7015, 127.1839),
  /// );
  /// final northEast = bounds.getNorthEast();
  /// print('북동쪽: ${northEast.latitude}, ${northEast.longitude}');
  /// ```
  LatLng getNorthEast() => ne;

  /// LatLngBounds 객체의 문자열 표현을 반환합니다.
  ///
  /// 디버깅 및 로깅 용도로 사용됩니다.
  @override
  String toString() {
    return 'LatLngBounds{sw: $sw, ne: $ne}';
  }
}

LatLngBounds _$LatLngBoundsFromJson(Map<String, dynamic> json) => LatLngBounds(
      json['sw'] as LatLng,
      json['ne'] as LatLng,
    );

Map<String, dynamic> _$LatLngBoundsToJson(LatLngBounds instance) =>
    <String, dynamic>{
      'sw': instance.sw,
      'ne': instance.ne,
    };
