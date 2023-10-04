part of kakao_map_plugin;

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
  });

  @override
  String toString() {
    return '{markerId: $markerId, latLng: $latLng, draggable: $draggable, width: $width, height: $height, offsetX: $offsetX, offsetY: $offsetY, markerImageSrc: $markerImageSrc, infoWindowContent: $infoWindowContent, infoWindowRemovable: $infoWindowRemovable, infoWindowFirstShow: $infoWindowFirstShow}';
  }
}
