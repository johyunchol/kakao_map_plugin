part of '../../kakao_map_plugin.dart';

/// 지도에 선을 그리는 폴리라인을 나타내는 클래스입니다.
///
/// 폴리라인은 지도 위에 여러 점을 연결하여 경로나 선을 그리는 데 사용됩니다.
/// 선의 두께, 색상, 스타일 등을 커스터마이징할 수 있습니다.
///
/// 예시:
/// ```dart
/// final polyline = Polyline(
///   polylineId: 'path_1',
///   points: [
///     LatLng(37.5665, 126.9780),
///     LatLng(37.5651, 126.9895),
///     LatLng(37.5640, 126.9900),
///   ],
///   strokeWidth: 5,
///   strokeColor: Colors.blue,
///   strokeOpacity: 0.8,
///   endArrow: true,
/// );
/// ```
class Polyline extends BaseDraw {
  /// 폴리라인의 고유 식별자입니다.
  ///
  /// 각 폴리라인은 고유한 ID를 가져야 하며, 이를 통해 폴리라인을 업데이트하거나 제거할 수 있습니다.
  final String polylineId;

  /// 폴리라인을 구성하는 좌표 점들의 리스트입니다.
  ///
  /// 최소 2개 이상의 좌표가 필요하며, 리스트 순서대로 연결되어 선이 그려집니다.
  /// null인 경우 폴리라인이 표시되지 않습니다.
  ///
  /// 예시:
  /// ```dart
  /// points: [
  ///   LatLng(37.5665, 126.9780),
  ///   LatLng(37.5651, 126.9895),
  ///   LatLng(37.5640, 126.9900),
  /// ],
  /// ```
  final List<LatLng>? points;

  /// 폴리라인의 끝점에 화살표를 표시할지 여부입니다.
  ///
  /// true로 설정하면 폴리라인의 마지막 점에 진행 방향을 나타내는 화살표가 표시됩니다.
  /// 경로나 방향을 표시할 때 유용합니다.
  /// 기본값은 false입니다.
  bool? endArrow = false;

  /// 폴리라인 인스턴스를 생성합니다.
  ///
  /// [polylineId]는 필수 파라미터입니다.
  /// 선의 스타일은 [BaseDraw]로부터 상속받은 속성들로 지정할 수 있습니다.
  ///
  /// 예시:
  /// ```dart
  /// final polyline = Polyline(
  ///   polylineId: 'path_1',
  ///   points: [LatLng(37.5665, 126.9780), LatLng(37.5651, 126.9895)],
  ///   strokeWidth: 5,
  ///   strokeColor: Colors.blue,
  ///   strokeOpacity: 0.8,
  ///   strokeStyle: StrokeStyle.solid,
  ///   endArrow: true,
  ///   zIndex: 10,
  /// );
  /// ```
  Polyline({
    required this.polylineId,
    this.points,
    super.strokeWidth = 8,
    super.strokeColor,
    super.strokeOpacity = 1,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
    super.zIndex,
    this.endArrow = false,
  });
}
