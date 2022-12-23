part of kakao_map_plugin;

class Circle extends BaseDraw {
  final String circleId;
  final LatLng center;
  double? radius;

  Circle({
    required this.circleId,
    required this.center,
    this.radius,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
  });
}
