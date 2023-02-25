part of kakao_map_plugin;

class Circle extends BaseDraw {
  /// circle unique id
  final String circleId;

  /// circle center latitude, longitude
  final LatLng center;

  /// circle radius
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
