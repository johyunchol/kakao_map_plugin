part of kakao_map_plugin;

class KakaoMapController {
  final WebViewController _webViewController;

  WebViewController get webViewController => _webViewController;

  KakaoMapController(this._webViewController);

  addPolyline({List<Polyline>? polylines}) async {
    if (polylines != null) {
      clearPolyline();
      for (var polyline in polylines) {
        await _webViewController.runJavascriptReturningResult(
            "addPolyline('${polyline.polylineId}', '${jsonEncode(polyline.points)}', '${polyline.strokeColor?.toHexColor()}', '${polyline.strokeOpacity}', '${polyline.strokeWidth}');");
      }
    }
  }

  addCircle({List<Circle>? circles}) async {
    if (circles != null) {
      clearCircle();
      for (var circle in circles) {
        final circleString =
            "addCircle('${circle.circleId}', '${jsonEncode(circle.center)}', '${circle.radius}', '${circle.strokeWidth}', '${circle.strokeColor?.toHexColor()}', '${circle.strokeOpacity}', '${circle.strokeStyle?.name}', '${circle.fillColor?.toHexColor()}', '${circle.fillOpacity}');";

        await _webViewController.runJavascript(circleString);
      }
    }
  }

  addRectangle({List<Rectangle>? rectangles}) async {
    if (rectangles != null) {
      clearCircle();
      for (var rectangle in rectangles) {
        final rectangleString =
            "addRectangle('${rectangle.rectangleId}', '${jsonEncode(rectangle.rectangleBounds)}', '${rectangle.strokeWidth}', '${rectangle.strokeColor?.toHexColor()}', '${rectangle.strokeOpacity}', '${rectangle.strokeStyle?.name}', '${rectangle.fillColor?.toHexColor()}', '${rectangle.fillOpacity}');";

        await _webViewController.runJavascript(rectangleString);
      }
    }
  }

  addPolygon({List<Polygon>? polygons}) async {
    if (polygons != null) {
      clearPolygon();
      for (var polygon in polygons) {
        await _webViewController.runJavascript(
            "addPolygon('${polygon.polygonId}', '${jsonEncode(polygon.points)}', '${jsonEncode(polygon.holes)}', '${polygon.strokeWidth}', '${polygon.strokeColor?.toHexColor()}', '${polygon.strokeOpacity}', '${polygon.strokeStyle?.name}', '${polygon.fillColor?.toHexColor()}', '${polygon.fillOpacity}');");
      }
    }
  }

  addMarker({List<Marker>? markers}) async {
    if (markers != null) {
      clearMarker();

      for (var marker in markers) {
        final markerString =
            "addMarker('${marker.markerId}', '${jsonEncode(marker.latLng)}', ${marker.draggable}, '${marker.width}', '${marker.height}', '${marker.offsetX}', '${marker.offsetY}', '${marker.markerImageSrc}', '${marker.infoWindowContent}', ${marker.infoWindowRemovable}, ${marker.infoWindowFirstShow})";
        await _webViewController.runJavascript(markerString);
      }
    }
  }

  addClusterer({List<Clusterer>? clusterers}) async {
    if (clusterers != null) {
      // clearMarker();

      for (var clusterer in clusterers) {
        // final markerString =
        //     "addClusterer('${jsonEncode(clusterer.latLng)}', ${clusterer.draggable}, '${clusterer.width}', '${clusterer.height}', '${clusterer.offsetX}', '${clusterer.offsetY}', '${clusterer.clustererImageSrc ?? ''}', '${clusterer.infoWindowContent ?? ''}', ${clusterer.infoWindowRemovable}, ${clusterer.infoWindowFirstShow})";
        // await _webViewController.runJavascript(clustererString);
      }
    }
  }

  setMarkerDraggable(String markerId, bool draggable) async {
    await _webViewController.runJavascript("setMarkerDraggable('$markerId', $draggable);");
  }

  addCustomOverlay({List<CustomOverlay>? customOverlays}) async {
    if (customOverlays != null) {
      clearCustomOverlay();

      for (var customOverlay in customOverlays) {
        await _webViewController.runJavascript(
            "addCustomOverlay('${customOverlay.customOverlayId}', '${jsonEncode(customOverlay.latLng)}', '${customOverlay.content}')");
      }
    }
  }

  clear() {
    _webViewController.runJavascript('clear();');
  }

  clearPolyline() {
    _webViewController.runJavascript('clearPolyline();');
  }

  clearCircle() {
    _webViewController.runJavascript('clearCircle();');
  }

  clearPolygon() {
    _webViewController.runJavascript('clearPolygon();');
  }

  clearMarker() {
    _webViewController.runJavascript('clearMarker();');
  }

  clearCustomOverlay() {
    _webViewController.runJavascript('clearCustomOverlay();');
  }

  panTo(LatLng latLng) {
    _webViewController.runJavascript("panTo('${latLng.latitude}', '${latLng.longitude}');");
  }

  fitBounds(List<LatLng> points) async {
    await _webViewController.runJavascript("fitBounds('${jsonEncode(points)}');");
  }

  setCenter(LatLng latLng) {
    _webViewController.runJavascript("setCenter('${latLng.latitude}', '${latLng.longitude}');");
  }

  Future<LatLng> getCenter() async {
    final center = await _webViewController.runJavascriptReturningResult("getCenter();");
    return LatLng.fromJson(jsonDecode(center));
  }

  setLevel(level) {
    _webViewController.runJavascript("setLevel('$level');");
  }

  Future<int> getLevel() async {
    final level = await _webViewController.runJavascriptReturningResult("getLevel();");
    return int.parse(level);
  }

  setMapTypeId(MapType mapType) {
    _webViewController.runJavascript("setMapTypeId('${mapType.id}');");
  }

  Future<MapType> getMapTypeId() async {
    final mapTypeId = await _webViewController.runJavascriptReturningResult("getMapTypeId();");
    return MapType.getById(int.parse(mapTypeId));
  }

  setBounds() {
    _webViewController.runJavascript("setBounds();");
  }

  setStyle(int width, int height) {}

  relayout() {
    _webViewController.runJavascript("relayout();");
  }

  Future<LatLngBounds> getBounds() async {
    final bounds = await _webViewController.runJavascriptReturningResult("getBounds()");
    final latLngBounds = jsonDecode(bounds);

    final sw = latLngBounds['sw'];
    final ne = latLngBounds['ne'];
    return LatLngBounds(LatLng(sw['latitude'], sw['longitude']), LatLng(ne['latitude'], ne['longitude']));
  }

  addOverlayMapTypeId(MapType mapType) {
    _webViewController.runJavascript("addOverlayMapTypeId('${mapType.id}');");
  }

  removeOverlayMapTypeId(MapType mapType) {
    _webViewController.runJavascript("removeOverlayMapTypeId('${mapType.id}');");
  }

  setDraggable(bool draggable) {
    _webViewController.runJavascript("setDraggable($draggable);");
  }

  getDraggable() async {
    final draggable = await _webViewController.runJavascript("getDraggable();");

    return draggable;
  }

  setZoomable(bool zoomable) {
    _webViewController.runJavascript("setZoomable($zoomable);");
  }

  getZoomable() async {
    final zoomable = await _webViewController.runJavascript("getZoomable();");
    return zoomable;
  }

  keywordSearch() async {
    await _webViewController.runJavascriptReturningResult("keywordSearch();");
  }

  addressSearch() async {
    await _webViewController.runJavascriptReturningResult("addressSearch();");
  }

  coord2Address() async {
    await _webViewController.runJavascriptReturningResult("coord2Address(37.56496830314491, 126.93990862062978);");
  }
}
