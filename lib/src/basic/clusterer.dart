part of '../../kakao_map_plugin.dart';

class Clusterer {
  /// marker cluster list
  final List<Marker> markers;

  /// cluster gridSize
  int? gridSize;

  /// cluster average center
  bool? averageCenter;

  /// cluster average center
  bool? disableClickZoom;

  /// minimum zoom level
  int? minLevel;

  /// minimum cluster size
  int? minClusterSize;

  /// cluster
  /// 클러스터 크기를 구분하는 값을 가진 배열 또는 구분값 생성함수 (default : [10, 100, 1000, 10000])
  List<int>? calculator = [10, 100, 1000, 10000];

  /// cluster
  /// 클러스터 크기를 구분하는 값을 가진 배열 또는 구분값 생성함수 (default : [10, 100, 1000, 10000])
  List<String>? texts;

  /// cluster styles
  /// 클러스터의 스타일. 여러개를 선언하면 calculator 로 구분된 사이즈 구간마다 서로 다른 스타일을 적용시킬 수 있다
  List<ClustererStyle>? styles;

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
}
