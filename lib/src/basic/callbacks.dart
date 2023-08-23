part of kakao_map_plugin;

/// kakao map created callback
typedef MapCreateCallback = void Function(KakaoMapController controller);

/// kakao map tap callback
typedef OnMapTap = void Function(LatLng latLng);

/// kakao map double tap callback
typedef OnMapDoubleTap = void Function(LatLng latLng);

/// kakao map marker tap callback
typedef OnCustomOverlayTap = void Function(
    String customOverlayId, LatLng latLng);

/// kakao map marker tap callback
typedef OnMarkerTap = void Function(
    String markerId, LatLng latLng, int zoomLevel);

/// kakao marker drag change callback
typedef OnMarkerDragChangeCallback = void Function(String markerId,
    LatLng latLng, int zoomLevel, MarkerDragType markerDragType);

/// kakao map move idle callback
typedef OnCameraIdle = void Function(LatLng latLng, int zoomLevel);

/// kakao map drag change callback
typedef OnDragChangeCallback = void Function(
    LatLng latLng, int zoomLevel, DragType dragType);

/// kakao map zoom change callback
typedef OnZoomChangeCallback = void Function(int zoomLevel, ZoomType zoomType);

/// kakao map center change callback
typedef OnCenterChangeCallback = void Function(LatLng latlng, int zoomLevel);

/// kakao map boundary change callback
typedef OnBoundsChangeCallback = void Function(LatLngBounds latLngBounds);

/// kakao map tile load cllback
typedef OnTilesLoadedCallback = void Function(LatLng latLng, int zoomLevel);
