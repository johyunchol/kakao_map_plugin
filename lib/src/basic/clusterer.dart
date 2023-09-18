part of kakao_map_plugin;

class Clusterer {
  /// marker cluster list
  final List<Marker> markers;

  /// cluster gridSize
  int? gridSize;

  /// cluster average center
  bool? averageCenter;

  /// minimum zoom level
  int? minLevel;

  /// minimum cluster size
  int? minClusterSize;

  /// cluster styles
  List<ClustererStyle>? styles;

  Clusterer({
    required this.markers,
    this.gridSize = 60,
    this.averageCenter = false,
    this.minLevel = 10,
    this.minClusterSize = 2,
    this.styles,
  });

  Map<String, dynamic> toJson() {
    return {
      'markers': markers.map((marker) => marker.toJson()).toList(),
      'gridSize': gridSize,
      'averageCenter': averageCenter,
      'minLevel': minLevel,
      'minClusterSize': minClusterSize,
      'styles': styles,
    };
  }
}
