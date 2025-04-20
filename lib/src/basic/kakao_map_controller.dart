part of '../../kakao_map_plugin.dart';

class KakaoMapController {
  final WebViewController _webViewController;

  WebViewController get webViewController => _webViewController;

  KakaoMapController(this._webViewController);

  /// draw polylines
  addPolyline({List<Polyline>? polylines}) async {
    if (polylines == null) {
      return;
    }

    clearPolyline(polylineIds: polylines.map((e) => e.polylineId).toList());
    for (var polyline in polylines) {
      await _webViewController.runJavaScript(
          "addPolyline('${polyline.polylineId}', '${jsonEncode(polyline.points)}', '${polyline.strokeColor?.toHexColor()}', '${polyline.strokeOpacity}', '${polyline.strokeWidth}', '${polyline.strokeStyle?.name}', '${polyline.endArrow}', ${polyline.zIndex});");
    }
  }

  /// draw circles
  addCircle({List<Circle>? circles}) async {
    if (circles == null) {
      return;
    }

    clearCircle(circleIds: circles.map((e) => e.circleId).toList());
    for (var circle in circles) {
      final circleString =
          "addCircle('${circle.circleId}', '${jsonEncode(circle.center)}', '${circle.radius}', '${circle.strokeWidth}', '${circle.strokeColor?.toHexColor()}', '${circle.strokeOpacity}', '${circle.strokeStyle?.name}', '${circle.fillColor?.toHexColor()}', '${circle.fillOpacity}', ${circle.zIndex});";

      await _webViewController.runJavaScript(circleString);
    }
  }

  /// draw rectangles
  addRectangle({List<Rectangle>? rectangles}) async {
    if (rectangles == null) {
      return;
    }

    clearRectangle(rectangleIds: rectangles.map((e) => e.rectangleId).toList());
    for (var rectangle in rectangles) {
      final rectangleString =
          "addRectangle('${rectangle.rectangleId}', '${jsonEncode(rectangle.rectangleBounds)}', '${rectangle.strokeWidth}', '${rectangle.strokeColor?.toHexColor()}', '${rectangle.strokeOpacity}', '${rectangle.strokeStyle?.name}', '${rectangle.fillColor?.toHexColor()}', '${rectangle.fillOpacity}', ${rectangle.zIndex});";

      await _webViewController.runJavaScript(rectangleString);
    }
  }

  /// draw polygons
  addPolygon({List<Polygon>? polygons}) async {
    if (polygons == null) {
      return;
    }

    clearPolygon(polygonIds: polygons.map((e) => e.polygonId).toList());
    for (var polygon in polygons) {
      await _webViewController.runJavaScript(
          "addPolygon('${polygon.polygonId}', '${jsonEncode(polygon.points)}', '${jsonEncode(polygon.holes)}', '${polygon.strokeWidth}', '${polygon.strokeColor?.toHexColor()}', '${polygon.strokeOpacity}', '${polygon.strokeStyle?.name}', '${polygon.fillColor?.toHexColor()}', '${polygon.fillOpacity}', ${polygon.zIndex});");
    }
  }

  /// draw markers
  addMarker({List<Marker>? markers}) async {
    if (markers == null || markers.isEmpty) {
      return;
    }

    clearMarker(markerIds: markers.map((e) => e.markerId).toList());
    for (var marker in markers) {
      final imageSrc = marker.icon?.imageSrc ?? marker.markerImageSrc;
      final markerString =
          "addMarker('${marker.markerId}', '${jsonEncode(marker.latLng)}', ${marker.draggable}, '${marker.width}', '${marker.height}', '${marker.offsetX}', '${marker.offsetY}', '$imageSrc', '${marker.infoWindowContent}', ${marker.infoWindowRemovable}, ${marker.infoWindowFirstShow}, ${marker.zIndex}, '${marker.icon?.imageType?.name}')";
      await _webViewController.runJavaScript(markerString);
    }
  }

  /// draw markers
  addMarkerClusterer({Clusterer? clusterer}) async {
    if (clusterer == null) {
      return null;
    }

    clearMarkerClusterer();
    final clustererString =
        "addMarkerClusterer('${jsonEncode(clusterer.markers)}', ${clusterer.gridSize}, ${clusterer.averageCenter}, ${clusterer.disableClickZoom}, ${clusterer.minLevel}, ${clusterer.minClusterSize}, '${jsonEncode(clusterer.texts)}', '${jsonEncode(clusterer.calculator)}', '${jsonEncode(clusterer.styles)}')";
    await _webViewController.runJavaScript(clustererString);
  }

  /// draw custom overlay
  addCustomOverlay({List<CustomOverlay>? customOverlays}) async {
    if (customOverlays == null) {
      return;
    }

    clearCustomOverlay(
        overlayIds: customOverlays.map((e) => e.customOverlayId).toList());
    for (var customOverlay in customOverlays) {
      await _webViewController.runJavaScript(
          "addCustomOverlay('${customOverlay.customOverlayId}', '${jsonEncode(customOverlay.latLng)}', '${customOverlay.content}', '${customOverlay.xAnchor}', '${customOverlay.yAnchor}', '${customOverlay.zIndex}')");
    }
  }

  dispose() {
    _webViewController.runJavaScript("dispose()");
  }

  /// clear overlays
  clear() {
    _webViewController.runJavaScript('clear();');
  }

  /// clear polylines
  clearPolyline({List<String>? polylineIds}) {
    String newPolylineIds = '';
    if (polylineIds != null) {
      newPolylineIds = jsonEncode(polylineIds);
    }

    _webViewController.runJavaScript('clearPolyline($newPolylineIds);');
  }

  /// clear circles
  clearCircle({List<String>? circleIds}) {
    String newCircleIds = '';
    if (circleIds != null) {
      newCircleIds = jsonEncode(circleIds);
    }

    _webViewController.runJavaScript('clearCircle($newCircleIds);');
  }

  /// clear rectagles
  clearRectangle({List<String>? rectangleIds}) {
    String newRectangleIds = '';
    if (rectangleIds != null) {
      newRectangleIds = jsonEncode(rectangleIds);
    }

    _webViewController.runJavaScript('clearRectangle($newRectangleIds);');
  }

  /// clear polygon
  clearPolygon({List<String>? polygonIds}) {
    String newPolygonIds = '';
    if (polygonIds != null) {
      newPolygonIds = jsonEncode(polygonIds);
    }

    _webViewController.runJavaScript('clearPolygon($newPolygonIds);');
  }

  /// clear markers
  clearMarker({List<String>? markerIds}) {
    String newMarkerIds = '';
    if (markerIds != null) {
      newMarkerIds = jsonEncode(markerIds);
    }

    _webViewController.runJavaScript('clearMarker($newMarkerIds);');
  }

  clearMarkerClusterer() {
    _webViewController.runJavaScript('clearMarkerClusterer();');
  }

  /// clear custom overlay
  clearCustomOverlay({List<String>? overlayIds}) {
    String newOverlayIds = '';
    if (overlayIds != null) {
      newOverlayIds = jsonEncode(overlayIds);
    }
    _webViewController.runJavaScript('clearCustomOverlay($newOverlayIds);');
  }

  /// move to center
  panTo(LatLng latLng) {
    _webViewController
        .runJavaScript("panTo('${latLng.latitude}', '${latLng.longitude}');");
  }

  /// fit bounds
  fitBounds(List<LatLng> points) async {
    await _webViewController
        .runJavaScript("fitBounds('${jsonEncode(points)}');");
  }

  /// change marker draggable
  setMarkerDraggable(String markerId, bool draggable) async {
    await _webViewController
        .runJavaScript("setMarkerDraggable('$markerId', $draggable);");
  }

  /// set center latitude, longitude
  setCenter(LatLng latLng) {
    _webViewController.runJavaScript(
        "setCenter('${latLng.latitude}', '${latLng.longitude}');");
  }

  /// get center latitude, longitude
  Future<LatLng> getCenter() async {
    final center = await _webViewController
        .runJavaScriptReturningResult("getCenter();") as String;
    return LatLng.fromJson(jsonDecode(center));
  }

  /// set zoom level
  setLevel(int level, {LevelOptions? options}) {
    if (options == null) {
      _webViewController.runJavaScript("setLevel('$level');");
    } else {
      _webViewController
          .runJavaScript("setLevel('$level', '${jsonEncode(options)}');");
    }
  }

  /// get zoom level
  Future<int> getLevel() async {
    final result = await _webViewController
        .runJavaScriptReturningResult("getLevel();") as String;
    final level = jsonDecode(result)['level'] as int;

    return level;
  }

  /// set map type id
  setMapTypeId(MapType mapType) {
    _webViewController.runJavaScript("setMapTypeId('${mapType.id}');");
  }

  /// get map type id
  Future<MapType> getMapTypeId() async {
    final result = await _webViewController
        .runJavaScriptReturningResult("getMapTypeId();") as String;

    final mapTypeId = jsonDecode(result)['mapTypeId'] as int;

    return MapType.getById(mapTypeId);
  }

  /// set bounds
  setBounds() {
    _webViewController.runJavaScript("setBounds();");
  }

  /// set styles
  setStyle(int width, int height) {}

  /// redraw layout
  relayout() {
    _webViewController.runJavaScript("relayout();");
  }

  /// get bounds from screen
  Future<LatLngBounds> getBounds() async {
    final bounds = await _webViewController
        .runJavaScriptReturningResult("getBounds()") as String;
    final latLngBounds = jsonDecode(bounds);

    final sw = latLngBounds['sw'];
    final ne = latLngBounds['ne'];
    return LatLngBounds(LatLng(sw['latitude'], sw['longitude']),
        LatLng(ne['latitude'], ne['longitude']));
  }

  /// add overlay map type id
  addOverlayMapTypeId(MapType mapType) {
    _webViewController.runJavaScript("addOverlayMapTypeId('${mapType.id}');");
  }

  /// remove overlay map type id
  removeOverlayMapTypeId(MapType mapType) {
    _webViewController
        .runJavaScript("removeOverlayMapTypeId('${mapType.id}');");
  }

  /// change draggable
  setDraggable(bool draggable) {
    _webViewController.runJavaScript("setDraggable($draggable);");
  }

  /// get current drag
  getDraggable() async {
    final draggable = await _webViewController.runJavaScript("getDraggable();");

    return draggable;
  }

  /// set available zoom
  setZoomable(bool zoomable) {
    _webViewController.runJavaScript("setZoomable($zoomable);");
  }

  /// get current available zoomable
  getZoomable() async {
    final zoomable = await _webViewController.runJavaScript("getZoomable();");
    return zoomable;
  }

  /// keyword search
  Future<KeywordSearchResponse> keywordSearch(
      KeywordSearchRequest request) async {
    KeywordSearchService().resetCompleter();

    await _webViewController
        .runJavaScript("keywordSearch('${jsonEncode(request)}');");

    return await KeywordSearchService.keywordSearchResult();
  }

  /// category search
  Future<CategorySearchResponse> categorySearch(
      CategorySearchRequest request) async {
    CategorySearchService().resetCompleter();

    await _webViewController
        .runJavaScript("categorySearch('${jsonEncode(request)}');");

    return await CategorySearchService.categorySearchResult();
  }

  /// address search
  Future<AddressSearchResponse> addressSearch(
      AddressSearchRequest request) async {
    AddressSearchService().resetCompleter();

    await _webViewController
        .runJavaScript("addressSearch('${jsonEncode(request)}')");

    return await AddressSearchService.addressSearchResult();
  }

  /// coord to address
  Future<Coord2AddressResponse> coord2Address(
      Coord2AddressRequest request) async {
    Coord2AddressService().resetCompleter();

    await _webViewController
        .runJavaScript("coord2Address('${jsonEncode(request)}')");

    return await Coord2AddressService.coord2AddressResult();
  }

  /// coord to region code
  Future<Coord2RegionCodeResponse> coord2RegionCode(
      Coord2RegionCodeRequest request) async {
    Coord2RegionCodeService().resetCompleter();

    await _webViewController
        .runJavaScript("coord2RegionCode('${jsonEncode(request)}')");

    return await Coord2RegionCodeService.coord2RegionCodeResult();
  }

  /// coord to region code
  Future<TransCoordResponse> transCoord(TransCoordRequest request) async {
    TransCoordService().resetCompleter();

    await _webViewController
        .runJavaScript("transCoord('${jsonEncode(request)}')");

    return await TransCoordService.transCodeResult();
  }
}
