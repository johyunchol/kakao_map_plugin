part of '../../kakao_map_plugin.dart';

/// 지도에 원을 그리는 클래스입니다.
///
/// 원은 중심 좌표와 반지름을 기준으로 지도 위에 원형 영역을 표시하는 데 사용됩니다.
/// 검색 반경, 배달 가능 지역 등을 시각적으로 표현할 때 유용합니다.
///
/// 예시:
/// ```dart
/// final circle = Circle(
///   circleId: 'area_1',
///   center: LatLng(37.5665, 126.9780),
///   radius: 1000, // 미터 단위
///   strokeWidth: 3,
///   strokeColor: Colors.blue,
///   fillColor: Colors.blue.withOpacity(0.3),
///   fillOpacity: 0.3,
/// );
/// ```
class Circle extends BaseDraw {
  /// 원의 고유 식별자입니다.
  ///
  /// 각 원은 고유한 ID를 가져야 하며, 이를 통해 원을 업데이트하거나 제거할 수 있습니다.
  final String circleId;

  /// 원의 중심 좌표입니다.
  ///
  /// 이 좌표를 중심으로 [radius]에 지정된 반지름만큼 원이 그려집니다.
  final LatLng center;

  /// 원의 반지름입니다 (미터 단위).
  ///
  /// 중심점으로부터 이 거리만큼 떨어진 위치에 원의 둘레가 그려집니다.
  /// null인 경우 원이 표시되지 않습니다.
  ///
  /// 예시:
  /// ```dart
  /// radius: 1000, // 반경 1km
  /// radius: 500,  // 반경 500m
  /// ```
  double? radius;

  /// 원 인스턴스를 생성합니다.
  ///
  /// [circleId]와 [center]는 필수 파라미터입니다.
  /// 원의 스타일은 [BaseDraw]로부터 상속받은 속성들로 지정할 수 있습니다.
  ///
  /// 예시:
  /// ```dart
  /// final circle = Circle(
  ///   circleId: 'delivery_area',
  ///   center: LatLng(37.5665, 126.9780),
  ///   radius: 2000,
  ///   strokeWidth: 2,
  ///   strokeColor: Colors.red,
  ///   strokeOpacity: 1.0,
  ///   fillColor: Colors.red,
  ///   fillOpacity: 0.2,
  ///   zIndex: 5,
  /// );
  /// ```
  Circle({
    required this.circleId,
    required this.center,
    this.radius,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
    super.zIndex,
  });
}
