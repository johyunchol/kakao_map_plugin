part of kakao_map_plugin;

class Clusterer {
  /// marker cluster list
  final List<Marker> markers;

  /// cluster gridSize
  int? gridSize = 60;

  /// cluster average center
  bool? averageCenter = false;

  /// minimum zoom level
  int? minLevel = 0;

  /// minimum cluster size
  int? minClusterSize = 2;

  /// cluster styles
  List<ClustererStyle>? styles;

  Clusterer({
    required this.markers,
    this.gridSize,
    this.averageCenter,
    this.minLevel,
    this.minClusterSize,
    this.styles,
  });
}
