part of '../../kakao_map_plugin.dart';

/// 지도에 다각형을 그리는 클래스입니다.
///
/// 다각형은 여러 점을 연결하여 닫힌 영역을 만드는 데 사용됩니다.
/// 행정구역, 건물 부지, 관심 지역 등을 표현할 때 유용합니다.
/// 내부에 구멍(hole)을 만들어 복잡한 형태의 영역도 표현할 수 있습니다.
///
/// 예시:
/// ```dart
/// final polygon = Polygon(
///   polygonId: 'area_1',
///   points: [
///     LatLng(37.566, 126.978),
///     LatLng(37.566, 126.988),
///     LatLng(37.570, 126.988),
///     LatLng(37.570, 126.978),
///   ],
///   strokeWidth: 3,
///   strokeColor: Colors.green,
///   fillColor: Colors.green,
///   fillOpacity: 0.3,
/// );
/// ```
class Polygon extends BaseDraw {
  /// 다각형의 고유 식별자입니다.
  ///
  /// 각 다각형은 고유한 ID를 가져야 하며, 이를 통해 다각형을 업데이트하거나 제거할 수 있습니다.
  final String polygonId;

  /// 다각형을 구성하는 좌표 점들의 리스트입니다.
  ///
  /// 최소 3개 이상의 좌표가 필요하며, 리스트 순서대로 연결되어 닫힌 영역이 만들어집니다.
  /// 마지막 점과 첫 번째 점은 자동으로 연결됩니다.
  ///
  /// 예시:
  /// ```dart
  /// points: [
  ///   LatLng(37.566, 126.978),
  ///   LatLng(37.566, 126.988),
  ///   LatLng(37.570, 126.988),
  ///   LatLng(37.570, 126.978),
  /// ],
  /// ```
  final List<LatLng> points;

  /// 다각형 내부에 만들 구멍들의 좌표 리스트입니다.
  ///
  /// 각 구멍은 별도의 좌표 리스트로 정의되며, 다각형 내부에 채워지지 않은 영역을 만듭니다.
  /// 도넛 형태나 복잡한 행정구역 등을 표현할 때 유용합니다.
  /// null인 경우 구멍이 없는 일반 다각형이 됩니다.
  ///
  /// 예시:
  /// ```dart
  /// holes: [
  ///   [
  ///     LatLng(37.567, 126.980),
  ///     LatLng(37.567, 126.985),
  ///     LatLng(37.569, 126.985),
  ///     LatLng(37.569, 126.980),
  ///   ],
  /// ],
  /// ```
  final List<List<LatLng>>? holes;

  /// 다각형 인스턴스를 생성합니다.
  ///
  /// [polygonId]와 [points]는 필수 파라미터입니다.
  /// 다각형의 스타일은 [BaseDraw]로부터 상속받은 속성들로 지정할 수 있습니다.
  ///
  /// 예시:
  /// ```dart
  /// final polygon = Polygon(
  ///   polygonId: 'district_1',
  ///   points: [
  ///     LatLng(37.566, 126.978),
  ///     LatLng(37.566, 126.988),
  ///     LatLng(37.570, 126.988),
  ///   ],
  ///   holes: [
  ///     [LatLng(37.567, 126.980), LatLng(37.568, 126.985)],
  ///   ],
  ///   strokeWidth: 2,
  ///   strokeColor: Colors.blue,
  ///   fillColor: Colors.blue,
  ///   fillOpacity: 0.3,
  ///   zIndex: 5,
  /// );
  /// ```
  Polygon({
    required this.polygonId,
    required this.points,
    this.holes,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
    super.zIndex,
  });
}
