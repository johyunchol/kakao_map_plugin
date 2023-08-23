part of kakao_map_plugin;

class Polygon extends BaseDraw {
  /// polygon unique id
  final String polygonId;

  /// polygon paths
  final List<LatLng> points;

  /// polygon outline paths
  final List<List<LatLng>>? holes;

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
  });
}
