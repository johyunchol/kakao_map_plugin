part of kakao_map_plugin;

class KakaoMapController {
  final WebViewController _webViewController;

  WebViewController get webViewController => _webViewController;

  KakaoMapController(this._webViewController);

  addPolyline({List<Polyline>? polylines}) async {
    if (polylines != null) {
      clearPolyline();
      for (var polyline in polylines) {
        await _webViewController.runJavaScriptReturningResult(
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

        await _webViewController.runJavaScript(circleString);
      }
    }
  }

  addRectangle({List<Rectangle>? rectangles}) async {
    if (rectangles != null) {
      clearCircle();
      for (var rectangle in rectangles) {
        final rectangleString =
            "addRectangle('${rectangle.rectangleId}', '${jsonEncode(rectangle.rectangleBounds)}', '${rectangle.strokeWidth}', '${rectangle.strokeColor?.toHexColor()}', '${rectangle.strokeOpacity}', '${rectangle.strokeStyle?.name}', '${rectangle.fillColor?.toHexColor()}', '${rectangle.fillOpacity}');";

        await _webViewController.runJavaScript(rectangleString);
      }
    }
  }

  addPolygon({List<Polygon>? polygons}) async {
    if (polygons != null) {
      clearPolygon();
      for (var polygon in polygons) {
        await _webViewController.runJavaScript(
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
        await _webViewController.runJavaScript(markerString);
      }
    }
  }

  setMarkerDraggable(String markerId, bool draggable) async {
    await _webViewController.runJavaScript("setMarkerDraggable('$markerId', $draggable);");
  }

  addCustomOverlay({List<CustomOverlay>? customOverlays}) async {
    if (customOverlays != null) {
      clearCustomOverlay();

      for (var customOverlay in customOverlays) {
        await _webViewController.runJavaScript(
            "addCustomOverlay('${customOverlay.customOverlayId}', '${jsonEncode(customOverlay.latLng)}', '${customOverlay.content}')");
      }
    }
  }

  clear() {
    _webViewController.runJavaScript('clear();');
  }

  clearPolyline() {
    _webViewController.runJavaScript('clearPolyline();');
  }

  clearCircle() {
    _webViewController.runJavaScript('clearCircle();');
  }

  clearPolygon() {
    _webViewController.runJavaScript('clearPolygon();');
  }

  clearMarker() {
    _webViewController.runJavaScript('clearMarker();');
  }

  clearCustomOverlay() {
    _webViewController.runJavaScript('clearCustomOverlay();');
  }

  panTo(LatLng latLng) {
    _webViewController.runJavaScript("panTo('${latLng.latitude}', '${latLng.longitude}');");
  }

  fitBounds(List<LatLng> points) async {
    await _webViewController.runJavaScript("fitBounds('${jsonEncode(points)}');");
  }

  setCenter(LatLng latLng) {
    _webViewController.runJavaScript("setCenter('${latLng.latitude}', '${latLng.longitude}');");
  }

  Future<LatLng> getCenter() async {
    final center = await _webViewController.runJavaScriptReturningResult("getCenter();") as String;
    return LatLng.fromJson(jsonDecode(center));
  }

  setLevel(level) {
    _webViewController.runJavaScript("setLevel('$level');");
  }

  Future<int> getLevel() async {
    final level = await _webViewController.runJavaScriptReturningResult("getLevel();") as String;
    return int.parse(level);
  }

  setMapTypeId(MapType mapType) {
    _webViewController.runJavaScript("setMapTypeId('${mapType.id}');");
  }

  Future<MapType> getMapTypeId() async {
    final mapTypeId = await _webViewController.runJavaScriptReturningResult("getMapTypeId();") as String;
    return MapType.getById(int.parse(mapTypeId));
  }

  setBounds() {
    _webViewController.runJavaScript("setBounds();");
  }

  setStyle(int width, int height) {}

  relayout() {
    _webViewController.runJavaScript("relayout();");
  }

  Future<LatLngBounds> getBounds() async {
    final bounds = await _webViewController.runJavaScriptReturningResult("getBounds()") as String;
    final latLngBounds = jsonDecode(bounds);

    final sw = latLngBounds['sw'];
    final ne = latLngBounds['ne'];
    return LatLngBounds(LatLng(sw['latitude'], sw['longitude']), LatLng(ne['latitude'], ne['longitude']));
  }

  addOverlayMapTypeId(MapType mapType) {
    _webViewController.runJavaScript("addOverlayMapTypeId('${mapType.id}');");
  }

  removeOverlayMapTypeId(MapType mapType) {
    _webViewController.runJavaScript("removeOverlayMapTypeId('${mapType.id}');");
  }

  setDraggable(bool draggable) {
    _webViewController.runJavaScript("setDraggable($draggable);");
  }

  getDraggable() async {
    final draggable = await _webViewController.runJavaScript("getDraggable();");

    return draggable;
  }

  setZoomable(bool zoomable) {
    _webViewController.runJavaScript("setZoomable($zoomable);");
  }

  getZoomable() async {
    final zoomable = await _webViewController.runJavaScript("getZoomable();");
    return zoomable;
  }

  keywordSearch() async {
    await _webViewController.runJavaScriptReturningResult("keywordSearch();");
  }

  addressSearch() async {
    await _webViewController.runJavaScriptReturningResult("addressSearch();");
  }

  coord2Address() async {
    await _webViewController.runJavaScriptReturningResult("coord2Address(37.56496830314491, 126.93990862062978);");
  }
}
