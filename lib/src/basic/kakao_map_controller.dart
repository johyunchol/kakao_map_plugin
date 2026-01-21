import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

import '../model/lat_lng.dart';
import '../model/lat_lng_bounds.dart';
import '../model/level_options.dart';
import '../model/point.dart';
import '../protocol/address_search_request.dart';
import '../protocol/address_search_response.dart';
import '../protocol/category_search_request.dart';
import '../protocol/category_search_response.dart';
import '../protocol/coord_2_address_request.dart';
import '../protocol/coord_2_address_response.dart';
import '../protocol/coord_2_region_code_request.dart';
import '../protocol/coord_2_region_code_response.dart';
import '../protocol/keyword_search_request.dart';
import '../protocol/keyword_search_response.dart';
import '../protocol/trans_coord_request.dart';
import '../protocol/trans_coord_response.dart';
import '../service/address_search_service.dart';
import '../service/category_search_service.dart';
import '../service/coord_2_address_service.dart';
import '../service/coord_2_region_code_service.dart';
import '../service/keyword_search_service.dart';
import '../service/trans_coord_service.dart';
import 'circle.dart';
import 'clusterer.dart';
import 'constants/map_type.dart';
import 'custom_overlay.dart';
import 'hex_color.dart';
import 'marker.dart';
import 'polygon.dart';
import 'polyline.dart';
import 'rectangle.dart';

/// 카카오 지도를 제어하는 컨트롤러 클래스입니다.
///
/// [KakaoMap] 위젯 생성 완료 후 [onMapCreated] 콜백을 통해 제공됩니다.
/// 이 컨트롤러를 사용하여 지도의 중심 이동, 줌 레벨 변경, 오버레이 추가/제거 등의
/// 작업을 수행할 수 있습니다.
///
/// 예시:
/// ```dart
/// late KakaoMapController _controller;
///
/// KakaoMap(
///   onMapCreated: (controller) {
///     _controller = controller;
///   },
/// )
///
/// // 지도 중심 이동
/// await _controller.setCenter(LatLng(37.5665, 126.9780));
///
/// // 마커 추가
/// await _controller.addMarker(
///   markers: [
///     Marker(
///       markerId: 'marker1',
///       latLng: LatLng(37.5665, 126.9780),
///     ),
///   ],
/// );
/// ```
class KakaoMapController {
  final WebViewController _webViewController;

  /// 내부적으로 사용하는 WebView 컨트롤러입니다.
  WebViewController get webViewController => _webViewController;

  /// [KakaoMapController]를 생성합니다.
  ///
  /// [_webViewController]: 지도를 표시하는 WebView 컨트롤러
  KakaoMapController(this._webViewController);

  /// JavaScript 문자열에 안전하게 사용하기 위해 특수 문자를 이스케이프합니다.
  ///
  /// 따옴표, 백슬래시, 줄바꿈 등 JavaScript 구문을 깨뜨릴 수 있는 문자를 처리합니다.
  String _escapeForJs(String input) {
    return input
        .replaceAll(r'\', r'\\')    // Escape backslashes first
        .replaceAll("'", r"\'")     // Escape single quotes
        .replaceAll('"', r'\"')     // Escape double quotes
        .replaceAll('\n', r'\n')    // Escape newlines
        .replaceAll('\r', r'\r')    // Escape carriage returns
        .replaceAll('\t', r'\t');   // Escape tabs
  }

  /// 지도에 폴리라인(선)을 추가합니다.
  ///
  /// [polylines]: 추가할 폴리라인 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 폴리라인이 있으면 제거 후 새로 추가합니다.
  ///
  /// 예시:
  /// ```dart
  /// await controller.addPolyline(
  ///   polylines: [
  ///     Polyline(
  ///       polylineId: 'line1',
  ///       points: [
  ///         LatLng(37.5665, 126.9780),
  ///         LatLng(37.5655, 126.9790),
  ///       ],
  ///       strokeColor: Colors.red,
  ///       strokeWidth: 5,
  ///     ),
  ///   ],
  /// );
  /// ```
  Future<void> addPolyline({List<Polyline>? polylines}) async {
    if (polylines == null) return;

    final safePolylines = List<Polyline>.from(polylines);

    clearPolyline(
      polylineIds: safePolylines.map((e) => e.polylineId).toList(),
    );

    for (var polyline in safePolylines) {
      await _webViewController.runJavaScript(
          "addPolyline('${polyline.polylineId}', '${jsonEncode(polyline.points)}', '${polyline.strokeColor?.toHexColor()}', '${polyline.strokeOpacity}', '${polyline.strokeWidth}', '${polyline.strokeStyle?.name}', '${polyline.endArrow}', ${polyline.zIndex});"
      );
    }
  }

  /// 지도에 원을 추가합니다.
  ///
  /// [circles]: 추가할 원 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 원이 있으면 제거 후 새로 추가합니다.
  ///
  /// 예시:
  /// ```dart
  /// await controller.addCircle(
  ///   circles: [
  ///     Circle(
  ///       circleId: 'circle1',
  ///       center: LatLng(37.5665, 126.9780),
  ///       radius: 500, // 반경 500미터
  ///       strokeColor: Colors.blue,
  ///       fillColor: Colors.blue.withOpacity(0.3),
  ///     ),
  ///   ],
  /// );
  /// ```
  Future<void> addCircle({List<Circle>? circles}) async {
    if (circles == null) return;

    final safeCircles = List<Circle>.from(circles);

    clearCircle(
      circleIds: safeCircles.map((e) => e.circleId).toList(),
    );

    for (var circle in safeCircles) {
      final circleString =
          "addCircle('${circle.circleId}', '${jsonEncode(circle.center)}', '${circle.radius}', '${circle.strokeWidth}', '${circle.strokeColor?.toHexColor()}', '${circle.strokeOpacity}', '${circle.strokeStyle?.name}', '${circle.fillColor?.toHexColor()}', '${circle.fillOpacity}', ${circle.zIndex});";

      await _webViewController.runJavaScript(circleString);
    }
  }

  /// 지도에 사각형을 추가합니다.
  ///
  /// [rectangles]: 추가할 사각형 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 사각형이 있으면 제거 후 새로 추가합니다.
  Future<void> addRectangle({List<Rectangle>? rectangles}) async {
    if (rectangles == null) return;

    final safeRectangles = List<Rectangle>.from(rectangles);

    clearRectangle(
      rectangleIds: safeRectangles.map((e) => e.rectangleId).toList(),
    );

    for (var rectangle in safeRectangles) {
      final rectangleString =
          "addRectangle('${rectangle.rectangleId}', '${jsonEncode(rectangle.rectangleBounds)}', '${rectangle.strokeWidth}', '${rectangle.strokeColor?.toHexColor()}', '${rectangle.strokeOpacity}', '${rectangle.strokeStyle?.name}', '${rectangle.fillColor?.toHexColor()}', '${rectangle.fillOpacity}', ${rectangle.zIndex});";

      await _webViewController.runJavaScript(rectangleString);
    }
  }

  /// 지도에 다각형을 추가합니다.
  ///
  /// [polygons]: 추가할 다각형 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 다각형이 있으면 제거 후 새로 추가합니다.
  /// 다각형 내부에 구멍(hole)을 만들 수도 있습니다.
  Future<void> addPolygon({List<Polygon>? polygons}) async {
    if (polygons == null) return;

    final safePolygons = List<Polygon>.from(polygons);

    clearPolygon(
      polygonIds: safePolygons.map((e) => e.polygonId).toList(),
    );

    for (var polygon in safePolygons) {
      await _webViewController.runJavaScript(
          "addPolygon('${polygon.polygonId}', '${jsonEncode(polygon.points)}', '${jsonEncode(polygon.holes)}', '${polygon.strokeWidth}', '${polygon.strokeColor?.toHexColor()}', '${polygon.strokeOpacity}', '${polygon.strokeStyle?.name}', '${polygon.fillColor?.toHexColor()}', '${polygon.fillOpacity}', ${polygon.zIndex});"
      );
    }
  }

  /// 지도에 마커를 추가합니다.
  ///
  /// [markers]: 추가할 마커 목록입니다. null이거나 비어있으면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 마커가 있으면 제거 후 새로 추가합니다.
  /// 마커에 커스텀 이미지, 인포윈도우, 드래그 기능 등을 설정할 수 있습니다.
  ///
  /// 예시:
  /// ```dart
  /// await controller.addMarker(
  ///   markers: [
  ///     Marker(
  ///       markerId: 'marker1',
  ///       latLng: LatLng(37.5665, 126.9780),
  ///       width: 40,
  ///       height: 50,
  ///       draggable: true,
  ///     ),
  ///   ],
  /// );
  /// ```
  Future<void> addMarker({List<Marker>? markers}) async {
    if (markers == null || markers.isEmpty) {
      return;
    }

    final safeMarkers = List<Marker>.from(markers);

    clearMarker(markerIds: safeMarkers.map((e) => e.markerId).toList());
    for (var marker in safeMarkers) {
      final imageSrc = marker.icon?.imageSrc ?? marker.markerImageSrc;
      final escapedInfoWindowContent = _escapeForJs(marker.infoWindowContent);
      final markerString =
          "addMarker('${marker.markerId}', '${jsonEncode(marker.latLng)}', ${marker.draggable}, '${marker.width}', '${marker.height}', '${marker.offsetX}', '${marker.offsetY}', '$imageSrc', '$escapedInfoWindowContent', ${marker.infoWindowRemovable}, ${marker.infoWindowFirstShow}, ${marker.zIndex}, '${marker.icon?.imageType?.name}')";
      await _webViewController.runJavaScript(markerString);
    }
  }

  /// 지도에 마커 클러스터러를 추가합니다.
  ///
  /// [clusterer]: 마커 클러스터러 설정입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 많은 마커를 그룹화하여 성능을 개선하고 가독성을 높입니다.
  /// 기존 클러스터러가 있으면 제거 후 새로 추가합니다.
  Future<void> addMarkerClusterer({Clusterer? clusterer}) async {
    if (clusterer == null) {
      return;
    }

    clearMarkerClusterer();
    final clustererString =
        "addMarkerClusterer('${jsonEncode(clusterer.markers)}', ${clusterer.gridSize}, ${clusterer.averageCenter}, ${clusterer.disableClickZoom}, ${clusterer.minLevel}, ${clusterer.minClusterSize}, '${jsonEncode(clusterer.texts)}', '${jsonEncode(clusterer.calculator)}', '${jsonEncode(clusterer.styles)}')";
    await _webViewController.runJavaScript(clustererString);
  }

  /// 지도에 커스텀 오버레이를 추가합니다.
  ///
  /// [customOverlays]: 추가할 커스텀 오버레이 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// HTML 기반의 커스텀 UI를 지도 위에 표시할 수 있습니다.
  /// 기존에 동일한 ID의 오버레이가 있으면 제거 후 새로 추가합니다.
  Future<void> addCustomOverlay({List<CustomOverlay>? customOverlays}) async {
    if (customOverlays == null) {
      return;
    }

    final overlays = List<CustomOverlay>.from(customOverlays);

    clearCustomOverlay(
        overlayIds: overlays.map((e) => e.customOverlayId).toList());
    for (var customOverlay in overlays) {
      final escapedContent = _escapeForJs(customOverlay.content);
      await _webViewController.runJavaScript(
          "addCustomOverlay('${customOverlay.customOverlayId}', '${jsonEncode(customOverlay.latLng)}', '$escapedContent', '${customOverlay.xAnchor}', '${customOverlay.yAnchor}', '${customOverlay.zIndex}')");
    }
  }

  /// 컨트롤러를 정리하고 리소스를 해제합니다.
  ///
  /// 지도에 표시된 모든 오버레이를 제거하고 지도 객체를 초기화합니다.
  Future<void> dispose() async {
    await _webViewController.runJavaScript("dispose()");
  }

  /// 지도에 표시된 모든 오버레이를 제거합니다.
  ///
  /// 폴리라인, 원, 사각형, 다각형, 마커, 커스텀 오버레이를 모두 제거합니다.
  Future<void> clear() async {
    await _webViewController.runJavaScript('clear();');
  }

  /// 지도에 표시된 폴리라인을 제거합니다.
  ///
  /// [polylineIds]: 제거할 폴리라인 ID 목록입니다. null이면 모든 폴리라인을 제거합니다.
  Future<void> clearPolyline({List<String>? polylineIds}) async {
    String newPolylineIds = '';
    if (polylineIds != null) {
      newPolylineIds = jsonEncode(polylineIds);
    }

    await _webViewController.runJavaScript('clearPolyline($newPolylineIds);');
  }

  /// 지도에 표시된 원을 제거합니다.
  ///
  /// [circleIds]: 제거할 원 ID 목록입니다. null이면 모든 원을 제거합니다.
  Future<void> clearCircle({List<String>? circleIds}) async {
    String newCircleIds = '';
    if (circleIds != null) {
      newCircleIds = jsonEncode(circleIds);
    }

    await _webViewController.runJavaScript('clearCircle($newCircleIds);');
  }

  /// 지도에 표시된 사각형을 제거합니다.
  ///
  /// [rectangleIds]: 제거할 사각형 ID 목록입니다. null이면 모든 사각형을 제거합니다.
  Future<void> clearRectangle({List<String>? rectangleIds}) async {
    String newRectangleIds = '';
    if (rectangleIds != null) {
      newRectangleIds = jsonEncode(rectangleIds);
    }

    await _webViewController.runJavaScript('clearRectangle($newRectangleIds);');
  }

  /// 지도에 표시된 다각형을 제거합니다.
  ///
  /// [polygonIds]: 제거할 다각형 ID 목록입니다. null이면 모든 다각형을 제거합니다.
  Future<void> clearPolygon({List<String>? polygonIds}) async {
    String newPolygonIds = '';
    if (polygonIds != null) {
      newPolygonIds = jsonEncode(polygonIds);
    }

    await _webViewController.runJavaScript('clearPolygon($newPolygonIds);');
  }

  /// 지도에 표시된 마커를 제거합니다.
  ///
  /// [markerIds]: 제거할 마커 ID 목록입니다. null이면 모든 마커를 제거합니다.
  Future<void> clearMarker({List<String>? markerIds}) async {
    String newMarkerIds = '';
    if (markerIds != null) {
      newMarkerIds = jsonEncode(markerIds);
    }

    await _webViewController.runJavaScript('clearMarker($newMarkerIds);');
  }

  /// 지도에 표시된 마커 클러스터러를 제거합니다.
  ///
  /// 클러스터러와 함께 클러스터러에 속한 모든 마커를 제거합니다.
  Future<void> clearMarkerClusterer() async {
    await _webViewController.runJavaScript('clearMarkerClusterer();');
  }

  /// 지도에 표시된 커스텀 오버레이를 제거합니다.
  ///
  /// [overlayIds]: 제거할 오버레이 ID 목록입니다. null이면 모든 커스텀 오버레이를 제거합니다.
  Future<void> clearCustomOverlay({List<String>? overlayIds}) async {
    String newOverlayIds = '';
    if (overlayIds != null) {
      newOverlayIds = jsonEncode(overlayIds);
    }
    await _webViewController.runJavaScript('clearCustomOverlay($newOverlayIds);');
  }

  /// 지도 중심을 지정한 좌표로 부드럽게 이동합니다.
  ///
  /// [latLng]: 이동할 중심 좌표입니다.
  ///
  /// 이동 거리가 화면 크기보다 크면 애니메이션 없이 즉시 이동합니다.
  Future<void> panTo(LatLng latLng) async {
    await _webViewController
        .runJavaScript("panTo('${latLng.latitude}', '${latLng.longitude}');");
  }

  /// 주어진 좌표들이 모두 보이도록 지도 영역을 조정합니다.
  ///
  /// [points]: 화면에 표시할 좌표 목록입니다.
  ///
  /// 모든 좌표가 화면에 보이도록 줌 레벨과 중심 좌표를 자동으로 조정합니다.
  Future<void> fitBounds(List<LatLng> points) async {
    await _webViewController
        .runJavaScript("fitBounds('${jsonEncode(points)}');");
  }

  /// 특정 마커의 드래그 가능 여부를 변경합니다.
  ///
  /// [markerId]: 대상 마커의 ID입니다.
  /// [draggable]: true이면 드래그 가능, false이면 불가능합니다.
  Future<void> setMarkerDraggable(String markerId, bool draggable) async {
    await _webViewController
        .runJavaScript("setMarkerDraggable('$markerId', $draggable);");
  }

  /// 지도의 중심 좌표를 설정합니다.
  ///
  /// [latLng]: 새로운 중심 좌표입니다.
  ///
  /// 애니메이션 없이 즉시 중심이 이동합니다.
  Future<void> setCenter(LatLng latLng) async {
    await _webViewController.runJavaScript(
        "setCenter('${latLng.latitude}', '${latLng.longitude}');");
  }

  /// 현재 지도의 중심 좌표를 반환합니다.
  ///
  /// Returns: 현재 중심 좌표 [LatLng]
  Future<LatLng> getCenter() async {
    final center = await _webViewController
        .runJavaScriptReturningResult("getCenter();") as String;
    return LatLng.fromJson(jsonDecode(center));
  }

  /// 지도의 줌 레벨을 설정합니다.
  ///
  /// [level]: 설정할 줌 레벨입니다. 값이 작을수록 넓은 영역을 표시합니다.
  /// [options]: 줌 옵션입니다. 애니메이션 여부와 기준점을 설정할 수 있습니다.
  ///
  /// 지도 타입에 따라 설정 가능한 범위가 다릅니다:
  /// - ROADMAP: 1~14
  /// - SKYVIEW, HYBRID: 0~14
  Future<void> setLevel(int level, {LevelOptions? options}) async {
    if (options == null) {
      await _webViewController.runJavaScript("setLevel('$level');");
    } else {
      await _webViewController
          .runJavaScript("setLevel('$level', '${jsonEncode(options)}');");
    }
  }

  /// 현재 지도의 줌 레벨을 반환합니다.
  ///
  /// Returns: 현재 줌 레벨
  Future<int> getLevel() async {
    final result = await _webViewController
        .runJavaScriptReturningResult("getLevel();") as String;
    final level = jsonDecode(result)['level'] as int;

    return level;
  }

  /// 지도 타입을 설정합니다.
  ///
  /// [mapType]: 설정할 지도 타입입니다.
  ///
  /// 가능한 타입:
  /// - ROADMAP: 일반 지도
  /// - SKYVIEW: 스카이뷰 (위성 지도)
  /// - HYBRID: 하이브리드 (스카이뷰 + 라벨)
  Future<void> setMapTypeId(MapType mapType) async {
    await _webViewController.runJavaScript("setMapTypeId('${mapType.id}');");
  }

  /// 현재 지도 타입을 반환합니다.
  ///
  /// Returns: 현재 지도 타입 [MapType]
  Future<MapType> getMapTypeId() async {
    final result = await _webViewController
        .runJavaScriptReturningResult("getMapTypeId();") as String;

    final mapTypeId = jsonDecode(result)['mapTypeId'] as int;

    return MapType.getById(mapTypeId);
  }

  /// 지도 영역을 설정합니다.
  Future<void> setBounds() async {
    await _webViewController.runJavaScript("setBounds();");
  }

  /// 지도 스타일을 설정합니다.
  ///
  /// [width]: 지도 너비
  /// [height]: 지도 높이
  Future<void> setStyle(int width, int height) async {}

  /// 지도를 다시 그립니다.
  ///
  /// 지도 컨테이너의 크기가 변경되었거나 숨겨진 상태에서 다시 표시될 때 호출합니다.
  /// IndexedStack 등에서 탭 전환 시 유용합니다.
  Future<void> relayout() async {
    await _webViewController.runJavaScript("relayout();");
  }

  /// 현재 지도 화면의 영역 좌표를 반환합니다.
  ///
  /// Returns: 지도 영역의 남서(SW)와 북동(NE) 좌표를 포함하는 [LatLngBounds]
  Future<LatLngBounds> getBounds() async {
    final bounds = await _webViewController
        .runJavaScriptReturningResult("getBounds()") as String;
    final latLngBounds = jsonDecode(bounds);

    final sw = latLngBounds['sw'];
    final ne = latLngBounds['ne'];
    return LatLngBounds(LatLng(sw['latitude'], sw['longitude']),
        LatLng(ne['latitude'], ne['longitude']));
  }

  /// 지도에 오버레이 타입의 타일 레이어를 추가합니다.
  ///
  /// [mapType]: 추가할 오버레이 타입입니다.
  ///
  /// 가능한 타입:
  /// - TRAFFIC: 교통정보
  /// - TERRAIN: 지형도
  /// - BICYCLE: 자전거 도로
  /// - USE_DISTRICT: 지적편집도
  Future<void> addOverlayMapTypeId(MapType mapType) async {
    await _webViewController.runJavaScript("addOverlayMapTypeId('${mapType.id}');");
  }

  /// 지도에서 오버레이 타입의 타일 레이어를 제거합니다.
  ///
  /// [mapType]: 제거할 오버레이 타입입니다.
  Future<void> removeOverlayMapTypeId(MapType mapType) async {
    await _webViewController
        .runJavaScript("removeOverlayMapTypeId('${mapType.id}');");
  }

  /// 지도 드래그 가능 여부를 설정합니다.
  ///
  /// [draggable]: true이면 드래그 가능, false이면 불가능합니다.
  Future<void> setDraggable(bool draggable) async {
    await _webViewController.runJavaScript("setDraggable($draggable);");
  }

  /// 현재 지도의 드래그 가능 여부를 반환합니다.
  ///
  /// Returns: 드래그 가능 여부
  Future<Object?> getDraggable() async {
    final draggable =
        await _webViewController.runJavaScriptReturningResult("getDraggable();");

    return draggable;
  }

  /// 지도 줌 가능 여부를 설정합니다.
  ///
  /// [zoomable]: true이면 줌 가능, false이면 불가능합니다.
  Future<void> setZoomable(bool zoomable) async {
    await _webViewController.runJavaScript("setZoomable($zoomable);");
  }

  /// 현재 지도의 줌 가능 여부를 반환합니다.
  ///
  /// Returns: 줌 가능 여부
  Future<Object?> getZoomable() async {
    final zoomable =
        await _webViewController.runJavaScriptReturningResult("getZoomable();");
    return zoomable;
  }

  /// 키워드로 장소를 검색합니다.
  ///
  /// [request]: 검색 요청 정보입니다.
  ///
  /// Returns: 검색 결과 [KeywordSearchResponse]
  ///
  /// 예시:
  /// ```dart
  /// final result = await controller.keywordSearch(
  ///   KeywordSearchRequest(
  ///     keyword: '카페',
  ///     x: 126.9780,
  ///     y: 37.5665,
  ///     radius: 5000,
  ///   ),
  /// );
  /// ```
  Future<KeywordSearchResponse> keywordSearch(
      KeywordSearchRequest request) async {
    KeywordSearchService().resetCompleter();

    await _webViewController
        .runJavaScript("keywordSearch('${jsonEncode(request)}');");

    return await KeywordSearchService.keywordSearchResult();
  }

  /// 카테고리로 장소를 검색합니다.
  ///
  /// [request]: 검색 요청 정보입니다.
  ///
  /// Returns: 검색 결과 [CategorySearchResponse]
  Future<CategorySearchResponse> categorySearch(
      CategorySearchRequest request) async {
    CategorySearchService().resetCompleter();

    await _webViewController
        .runJavaScript("categorySearch('${jsonEncode(request)}');");

    return await CategorySearchService.categorySearchResult();
  }

  /// 주소로 좌표를 검색합니다.
  ///
  /// [request]: 검색 요청 정보입니다.
  ///
  /// Returns: 검색 결과 [AddressSearchResponse]
  Future<AddressSearchResponse> addressSearch(
      AddressSearchRequest request) async {
    AddressSearchService().resetCompleter();

    await _webViewController
        .runJavaScript("addressSearch('${jsonEncode(request)}')");

    return await AddressSearchService.addressSearchResult();
  }

  /// 좌표를 주소로 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [Coord2AddressResponse]
  Future<Coord2AddressResponse> coord2Address(
      Coord2AddressRequest request) async {
    Coord2AddressService().resetCompleter();

    await _webViewController
        .runJavaScript("coord2Address('${jsonEncode(request)}')");

    return await Coord2AddressService.coord2AddressResult();
  }

  /// 좌표를 행정구역 코드로 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [Coord2RegionCodeResponse]
  Future<Coord2RegionCodeResponse> coord2RegionCode(
      Coord2RegionCodeRequest request) async {
    Coord2RegionCodeService().resetCompleter();

    await _webViewController
        .runJavaScript("coord2RegionCode('${jsonEncode(request)}')");

    return await Coord2RegionCodeService.coord2RegionCodeResult();
  }

  /// 좌표계를 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [TransCoordResponse]
  Future<TransCoordResponse> transCoord(TransCoordRequest request) async {
    TransCoordService().resetCompleter();

    await _webViewController
        .runJavaScript("transCoord('${jsonEncode(request)}')");

    return await TransCoordService.transCodeResult();
  }

  /// 지도 좌표(LatLng)를 화면 픽셀 좌표로 변환합니다.
  ///
  /// [latLng]: 변환할 지도 좌표입니다.
  ///
  /// Returns: 화면 픽셀 좌표 [Point]
  Future<Point> coordToPixel(LatLng latLng) async {
    final result = await _webViewController.runJavaScriptReturningResult(
        "coordToPixel('${latLng.latitude}', '${latLng.longitude}');") as String;
    return Point.fromJson(jsonDecode(result));
  }

  /// 화면 픽셀 좌표를 지도 좌표(LatLng)로 변환합니다.
  ///
  /// [point]: 변환할 화면 픽셀 좌표입니다.
  ///
  /// Returns: 지도 좌표 [LatLng]
  Future<LatLng> pixelToCoord(Point point) async {
    final result = await _webViewController.runJavaScriptReturningResult(
        "pixelToCoord('${point.x}', '${point.y}');") as String;
    return LatLng.fromJson(jsonDecode(result));
  }
}
