import 'clusterer_style.dart';
import 'marker.dart';

/// 지도의 마커들을 클러스터링하여 표시하는 클래스입니다.
///
/// 클러스터러는 많은 수의 마커를 효율적으로 표시하기 위해 가까이 있는 마커들을
/// 하나의 클러스터로 묶어서 표시합니다. 줌 레벨에 따라 자동으로 클러스터가
/// 분리되거나 병합됩니다.
///
/// 예시:
/// ```dart
/// final clusterer = Clusterer(
///   markers: [marker1, marker2, marker3, ...],
///   gridSize: 60,
///   minClusterSize: 2,
///   calculator: [10, 100, 1000],
///   styles: [
///     ClustererStyle(width: 40, height: 40, background: Colors.blue),
///     ClustererStyle(width: 50, height: 50, background: Colors.green),
///     ClustererStyle(width: 60, height: 60, background: Colors.red),
///   ],
/// );
/// ```
class Clusterer {
  /// 클러스터링할 마커 리스트입니다.
  ///
  /// 이 마커들이 지도상의 거리와 줌 레벨에 따라 자동으로 클러스터링됩니다.
  final List<Marker> markers;

  /// 클러스터링 그리드의 크기입니다 (픽셀 단위).
  ///
  /// 이 값은 클러스터링의 민감도를 결정합니다.
  /// 값이 클수록 더 넓은 영역의 마커들이 하나의 클러스터로 묶입니다.
  /// 기본값은 60픽셀입니다.
  int? gridSize;

  /// 클러스터의 중심을 포함된 마커들의 평균 위치로 계산할지 여부입니다.
  ///
  /// true로 설정하면 클러스터의 위치가 포함된 모든 마커의 평균 좌표로 계산됩니다.
  /// false로 설정하면 첫 번째 마커의 위치를 사용합니다.
  /// 기본값은 false입니다.
  bool? averageCenter;

  /// 클러스터 클릭 시 줌 동작을 비활성화할지 여부입니다.
  ///
  /// false로 설정하면 클러스터를 클릭할 때 자동으로 확대되어 클러스터가 분리됩니다.
  /// true로 설정하면 클릭 시 줌 동작이 발생하지 않습니다.
  /// 기본값은 true입니다.
  bool? disableClickZoom;

  /// 클러스터링이 적용되는 최소 줌 레벨입니다.
  ///
  /// 이 레벨보다 높은 줌에서는 클러스터링이 해제되고 개별 마커가 표시됩니다.
  /// 기본값은 10입니다.
  int? minLevel;

  /// 클러스터를 형성하는 최소 마커 개수입니다.
  ///
  /// 이 개수보다 적은 마커는 클러스터로 묶이지 않고 개별 마커로 표시됩니다.
  /// 기본값은 2개입니다.
  int? minClusterSize;

  /// 클러스터 크기 구간을 구분하는 기준값 배열입니다.
  ///
  /// 클러스터에 포함된 마커 개수에 따라 다른 스타일을 적용하기 위한 기준값입니다.
  /// 예를 들어 [10, 100, 1000]으로 설정하면:
  /// - 10개 미만: 첫 번째 스타일
  /// - 10~99개: 두 번째 스타일
  /// - 100~999개: 세 번째 스타일
  /// - 1000개 이상: 네 번째 스타일
  ///
  /// 기본값은 [10, 100, 1000, 10000]입니다.
  List<int>? calculator = [10, 100, 1000, 10000];

  /// 클러스터에 표시할 텍스트 배열입니다.
  ///
  /// [calculator]로 구분된 각 크기 구간에 표시할 커스텀 텍스트를 지정할 수 있습니다.
  /// null인 경우 마커 개수가 표시됩니다.
  ///
  /// 예시:
  /// ```dart
  /// texts: ['10+', '100+', '1000+'],
  /// ```
  List<String>? texts;

  /// 클러스터의 스타일 배열입니다.
  ///
  /// [calculator]로 구분된 각 크기 구간에 적용할 스타일을 지정합니다.
  /// 스타일 개수는 calculator 구간 개수 + 1 이어야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// styles: [
  ///   ClustererStyle(width: 40, height: 40, background: Colors.blue),
  ///   ClustererStyle(width: 50, height: 50, background: Colors.green),
  ///   ClustererStyle(width: 60, height: 60, background: Colors.red),
  /// ],
  /// ```
  List<ClustererStyle>? styles;

  /// 클러스터러 인스턴스를 생성합니다.
  ///
  /// [markers]는 필수 파라미터입니다.
  ///
  /// 예시:
  /// ```dart
  /// final clusterer = Clusterer(
  ///   markers: allMarkers,
  ///   gridSize: 80,
  ///   averageCenter: true,
  ///   disableClickZoom: false,
  ///   minLevel: 10,
  ///   minClusterSize: 3,
  ///   calculator: [10, 50, 100],
  ///   texts: ['소', '중', '대', '특대'],
  ///   styles: [
  ///     ClustererStyle(width: 40, height: 40, background: Colors.blue),
  ///     ClustererStyle(width: 50, height: 50, background: Colors.green),
  ///     ClustererStyle(width: 60, height: 60, background: Colors.orange),
  ///     ClustererStyle(width: 70, height: 70, background: Colors.red),
  ///   ],
  /// );
  /// ```
  Clusterer({
    required this.markers,
    this.gridSize = 60,
    this.averageCenter = false,
    this.disableClickZoom = true,
    this.minLevel = 10,
    this.minClusterSize = 2,
    this.texts,
    this.calculator,
    this.styles,
  });

  /// 클러스터러 정보를 JSON 형식으로 변환합니다.
  ///
  /// 플랫폼 채널을 통해 네이티브 코드로 클러스터러 정보를 전달할 때 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'markers': markers.map((marker) => marker.toJson()).toList(),
      'gridSize': gridSize,
      'averageCenter': averageCenter,
      'disableClickZoom': disableClickZoom,
      'minLevel': minLevel,
      'minClusterSize': minClusterSize,
      'texts': texts,
      'calculator': calculator,
      'styles': styles?.map((style) => style.toJson()).toList(),
    };
  }

  /// 마커 ID 리스트에 해당하는 마커들을 반환합니다.
  ///
  /// 클러스터 클릭 이벤트 등에서 특정 마커들을 조회할 때 사용됩니다.
  ///
  /// [markerIdList]: 조회할 마커 ID 리스트
  ///
  /// Returns: 해당 ID를 가진 마커 리스트
  List<Marker> getMarkersByIds(List<String> markerIdList) {
    return markers
        .where((marker) => markerIdList.contains(marker.markerId))
        .toList();
  }
}
