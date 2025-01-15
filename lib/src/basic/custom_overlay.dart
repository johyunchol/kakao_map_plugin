part of '../../kakao_map_plugin.dart';

class CustomOverlay {
  /// custom overlay unique id
  final String customOverlayId;

  /// custom overlay center latitude, longitude
  final LatLng latLng;

  /// custom overlay inner content
  final String content;

  /// custom overlay x anchor
  final double xAnchor;

  /// custom overlay y anchor
  final double yAnchor;

  /// custom overlay zIndex
  final int zIndex;

  CustomOverlay({
    required this.customOverlayId,
    required this.latLng,
    required this.content,
    this.xAnchor = 0.5,
    this.yAnchor = 1,
    this.zIndex = 3,
  });
}
