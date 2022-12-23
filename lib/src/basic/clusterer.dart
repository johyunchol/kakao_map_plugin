part of kakao_map_plugin;

class Clusterer {
  final List<Marker> markers;
  int? gridSize = 60;
  bool? averageCenter = false;
  int? minLevel = 0;
  int? minClusterSize = 2;
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
