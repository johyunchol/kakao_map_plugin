part of kakao_map_plugin;

class CustomOverlay {
  final String customOverlayId;
  final LatLng latLng;
  final String content;

  CustomOverlay({
    required this.customOverlayId,
    required this.latLng,
    required this.content,
  });
}
