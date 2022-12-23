part of kakao_map_plugin;

class Polyline extends BaseDraw {
  final String polylineId;
  final List<LatLng>? points;

  Polyline({
    required this.polylineId,
    this.points,
    super.strokeWidth = 8,
    super.strokeColor,
    super.strokeOpacity = 1,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
  });
}
