part of kakao_map_plugin;

class Marker {
  final String markerId;
  LatLng latLng;
  int width = 24;
  int height = 30;
  int offsetX = 0;
  int offsetY = 0;
  String markerImageSrc = '';
  String infoWindowContent = '';
  bool draggable;
  bool infoWindowRemovable;
  bool infoWindowFirstShow;

  Marker({
    required this.markerId,
    required this.latLng,
    this.width = 24,
    this.height = 30,
    this.offsetX = 0,
    this.offsetY = 0,
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
