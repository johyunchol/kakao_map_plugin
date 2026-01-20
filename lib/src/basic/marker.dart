part of '../../kakao_map_plugin.dart';

class Marker {
  /// marker unique id
  final String markerId;

  /// marker latitude, longitude
  LatLng latLng;

  /// marker width
  int width = 24;

  /// marker height
  int height = 30;

  /// marker horizontal offset
  int? offsetX;

  /// marker vertical offset
  int? offsetY;

  /// marker image - MarkerIcon.fromAssets(...) or MarkerIcon.fromNetwork(...)
  MarkerIcon? icon;

  /// marker image - image url
  @Deprecated('use MarkerIcon instead')
  String markerImageSrc = '';

  /// marker info window
  String infoWindowContent = '';

  /// marker draggable
  bool draggable;

  /// marker info window close button
  bool infoWindowRemovable;

  /// marker info window first show flag
  bool infoWindowFirstShow;

  /// marker z-index
  int zIndex = 0;

  /// custom overlay content for clusterer
  /// When using with clusterer, this content will be displayed instead of default marker
  String? customOverlayContent;

  /// custom overlay x anchor (0.0 ~ 1.0)
  double customOverlayXAnchor;

  /// custom overlay y anchor (0.0 ~ 1.0)
  double customOverlayYAnchor;

  Marker({
    required this.markerId,
    required this.latLng,
    this.width = 24,
    this.height = 30,
    this.offsetX,
    this.offsetY,
    this.icon,
    this.markerImageSrc = '',
    this.infoWindowContent = '',
    this.draggable = false,
    this.infoWindowRemovable = true,
    this.infoWindowFirstShow = false,
    this.zIndex = 0,
    this.customOverlayContent,
    this.customOverlayXAnchor = 0.5,
    this.customOverlayYAnchor = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'markerId': markerId,
      'latLng': {
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
      },
      'width': width,
      'height': height,
      'offsetX': offsetX,
      'offsetY': offsetY,
      'icon': icon != null
          ? {
              'imageSrc': icon!.imageSrc,
              'imageType': icon!.imageType?.name,
            }
          : null,
      'markerImageSrc': markerImageSrc,
      'infoWindowContent': infoWindowContent,
      'draggable': draggable,
      'infoWindowRemovable': infoWindowRemovable,
      'infoWindowFirstShow': infoWindowFirstShow,
      'zIndex': zIndex,
      'customOverlayContent': customOverlayContent,
      'customOverlayXAnchor': customOverlayXAnchor,
      'customOverlayYAnchor': customOverlayYAnchor,
    };
  }

  @override
  String toString() {
    return 'Marker{markerId: $markerId, latLng: $latLng, width: $width, height: $height, offsetX: $offsetX, offsetY: $offsetY, icon: $icon, markerImageSrc: $markerImageSrc, infoWindowContent: $infoWindowContent, draggable: $draggable, infoWindowRemovable: $infoWindowRemovable, infoWindowFirstShow: $infoWindowFirstShow, zIndex: $zIndex}';
  }
}
