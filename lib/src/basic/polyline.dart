part of '../../kakao_map_plugin.dart';

class Polyline extends BaseDraw {
  /// polyline unique id
  final String polylineId;

  /// polyline paths
  final List<LatLng>? points;

  /// end arrow
  bool? endArrow = false;

  Polyline({
    required this.polylineId,
    this.points,
    super.strokeWidth = 8,
    super.strokeColor,
    super.strokeOpacity = 1,
    super.strokeStyle,
    super.fillColor,
    super.fillOpacity,
    super.zIndex,
    this.endArrow = false,
  });
}
