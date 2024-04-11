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

  /// marker image
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

  Marker({
    required this.markerId,
    required this.latLng,
    this.width = 24,
    this.height = 30,
    this.offsetX,
    this.offsetY,
    this.markerImageSrc = '',
    this.infoWindowContent = '',
    this.draggable = false,
    this.infoWindowRemovable = true,
    this.infoWindowFirstShow = false,
    this.zIndex = 0,
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
      'markerImageSrc': markerImageSrc,
      'infoWindowContent': infoWindowContent,
      'draggable': draggable,
      'infoWindowRemovable': infoWindowRemovable,
      'infoWindowFirstShow': infoWindowFirstShow,
      'zIndex': zIndex,
    };
  }

  @override
  String toString() {
    return 'Marker{markerId: $markerId, latLng: $latLng, width: $width, height: $height, offsetX: $offsetX, offsetY: $offsetY, markerImageSrc: $markerImageSrc, infoWindowContent: $infoWindowContent, draggable: $draggable, infoWindowRemovable: $infoWindowRemovable, infoWindowFirstShow: $infoWindowFirstShow, zIndex: $zIndex}';
  }
}
