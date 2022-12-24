part of kakao_map_plugin;

class Rectangle extends BaseDraw {
  final String rectangleId;
  final LatLngBounds rectangleBounds;

  Rectangle({
    required this.rectangleId,
    required this.rectangleBounds,
    super.strokeWidth,
    super.strokeColor,
    super.strokeOpacity,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
  });
}
