part of kakao_map_plugin;

class CustomOverlay {
  /// custom overlay unique id
  final String customOverlayId;

  /// custom overlay center latitude, longitude
  final LatLng latLng;

  /// custom overlay inner content
  final String content;

  final bool isClickable;

  CustomOverlay({
    required this.customOverlayId,
    required this.latLng,
    required this.content,
    this.isClickable = true,
  });
}
