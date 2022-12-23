part of kakao_map_plugin;

typedef MapCreateCallback = void Function(KakaoMapController controller);

typedef OnMapTap = void Function(LatLng latLng);

typedef OnMapDoubleTap = void Function(LatLng latLng);

typedef OnMarkerClick = void Function(String markerId, LatLng latLng, int zoomLevel);

typedef OnCameraIdle = void Function(LatLng latLng, int zoomLevel);

typedef OnDragChangeCallback = void Function(LatLng latLng, int zoomLevel, DragType dragType);

typedef OnZoomChangeCallback = void Function(int zoomLevel, ZoomType zoomType);

typedef OnCenterChangeCallback = void Function(LatLng latlng, int zoomLevel);

typedef OnBoundsChangeCallback = void Function(LatLngBounds latLngBounds);

typedef OnTilesLoadedCallback = void Function(LatLng latLng, int zoomLevel);
