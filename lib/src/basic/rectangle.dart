part of '../../kakao_map_plugin.dart';

/// 지도에 사각형을 그리는 클래스입니다.
///
/// 사각형은 남서쪽과 북동쪽 모서리 좌표로 정의된 경계 영역을 표시하는 데 사용됩니다.
/// 검색 영역, 관리 구역, 관심 지역 등을 시각적으로 표현할 때 유용합니다.
///
/// 예시:
/// ```dart
/// final rectangle = Rectangle(
///   rectangleId: 'area_1',
///   rectangleBounds: LatLngBounds(
///     sw: LatLng(37.566, 126.978),
///     ne: LatLng(37.570, 126.988),
///   ),
///   strokeWidth: 3,
///   strokeColor: Colors.red,
///   fillColor: Colors.red,
///   fillOpacity: 0.2,
/// );
/// ```
class Rectangle extends BaseDraw {
  /// 사각형의 고유 식별자입니다.
  ///
  /// 각 사각형은 고유한 ID를 가져야 하며, 이를 통해 사각형을 업데이트하거나 제거할 수 있습니다.
  final String rectangleId;

  /// 사각형의 경계 영역입니다.
  ///
  /// [LatLngBounds]로 정의되며, 남서쪽(sw)과 북동쪽(ne) 모서리 좌표를 포함합니다.
  /// 이 두 좌표로 정의되는 직사각형 영역이 지도에 표시됩니다.
  ///
  /// 예시:
  /// ```dart
  /// rectangleBounds: LatLngBounds(
  ///   sw: LatLng(37.566, 126.978), // 남서쪽 모서리
  ///   ne: LatLng(37.570, 126.988), // 북동쪽 모서리
  /// ),
  /// ```
  final LatLngBounds rectangleBounds;

  /// 사각형 인스턴스를 생성합니다.
  ///
  /// [rectangleId]와 [rectangleBounds]는 필수 파라미터입니다.
  /// 사각형의 스타일은 [BaseDraw]로부터 상속받은 속성들로 지정할 수 있습니다.
  ///
  /// 예시:
  /// ```dart
  /// final rectangle = Rectangle(
  ///   rectangleId: 'search_area',
  ///   rectangleBounds: LatLngBounds(
  ///     sw: LatLng(37.566, 126.978),
  ///     ne: LatLng(37.570, 126.988),
  ///   ),
  ///   strokeWidth: 2,
  ///   strokeColor: Colors.blue,
  ///   strokeOpacity: 1.0,
  ///   fillColor: Colors.blue,
  ///   fillOpacity: 0.3,
  ///   zIndex: 5,
  /// );
  /// ```
  Rectangle({
    required this.rectangleId,
    required this.rectangleBounds,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
    super.zIndex,
  });
}
