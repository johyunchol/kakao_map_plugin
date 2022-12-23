part of kakao_map_plugin;

class Polygon extends BaseDraw {
  final String polygonId;
  final List<LatLng> points;
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
