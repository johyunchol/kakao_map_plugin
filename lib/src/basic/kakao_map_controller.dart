import 'dart:convert';
import 'dart:math' as math;

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
import '../service/base_service.dart';
import '../service/category_search_service.dart';
import '../service/coord_2_address_service.dart';
import '../service/coord_2_region_code_service.dart';
import '../service/keyword_search_service.dart';
import '../service/trans_coord_service.dart';
import 'circle.dart';
import 'clusterer.dart';
import 'constants/map_type.dart';
import 'custom_overlay.dart';
import 'marker.dart';
import 'overlay_payload.dart';
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

  /// 배치 전송 시 한 번의 JS 호출에 담을 최대 항목 수입니다.
  static const int _batchMaxItems = 200;

  /// 배치 전송 시 한 번의 JS 호출에 담을 payload 의 대략적인 최대 길이(문자 수)입니다.
  static const int _batchMaxChars = 512 * 1024;

  /// Dart 문자열을 JS 문자열 리터럴(큰따옴표 포함)로 안전하게 변환합니다.
  ///
  /// `jsonEncode` 가 따옴표, 백슬래시, 제어 문자를 모두 이스케이프하므로
  /// 임의의 사용자 입력(검색어, HTML 콘텐츠 등)이 JS 구문을 깨뜨리지 않습니다.
  /// JS 문자열 리터럴에서 줄바꿈으로 취급되는 U+2028/U+2029 도 추가로 이스케이프합니다.
  String _jsStr(String value) {
    return jsonEncode(value)
        .replaceAll('\u2028', r'\u2028')
        .replaceAll('\u2029', r'\u2029');
  }

  /// 임의의 값을 JSON 으로 직렬화한 뒤 JS 문자열 리터럴로 감쌉니다.
  ///
  /// JS 쪽에서 `JSON.parse` 또는 `parseIfString` 으로 되돌려 사용합니다.
  String _jsJson(Object? value) => _jsStr(jsonEncode(value));

  /// 숫자/불리언 등 원시값을 JS 리터럴로 변환합니다. null 은 `undefined` 가 되어
  /// JS 기본 파라미터가 적용됩니다.
  String _jsPrimitive(Object? value) {
    if (value == null) return 'undefined';
    if (value is num || value is bool) return value.toString();
    assert(false, '_jsPrimitive 는 숫자/불리언만 허용합니다. 문자열은 _jsStr 를 사용하세요.');
    return _jsStr(value.toString());
  }

  /// 이 컨트롤러의 WebView 에 이미 등록한 base64 이미지 키 집합입니다.
  final Set<String> _registeredImageKeys = {};

  /// WebView 페이지가 다시 로드되어 JS 측 상태가 초기화됐을 때 호출합니다.
  ///
  /// WebView 안에 등록해 둔 이미지 캐시 키 등 "JS 쪽에도 사본이 있다고 가정한" 상태를
  /// 비웁니다. 라이브러리 내부에서 사용하며, 일반적으로 직접 호출할 필요는 없습니다.
  void resetWebViewSideCaches() {
    _registeredImageKeys.clear();
  }

  /// base64(file 타입) 이미지에 대한 짧은 참조 키를 만듭니다.
  static String _imageKey(String base64) =>
      '${base64.length}:${base64.hashCode.toRadixString(36)}';

  /// payload 목록에서 file 타입 base64 이미지를 찾아 WebView 에 1회만 등록하고,
  /// payload 의 imageSrc 를 `@key` 참조로 치환합니다.
  ///
  /// 같은 아이콘을 쓰는 마커 N개가 base64 를 N번 전송하던 것을 1번으로 줄입니다.
  Future<void> _registerImagesAndRewrite(
      List<Map<String, dynamic>> payloads, {
      required String Function(Map<String, dynamic>) srcOf,
      required String? Function(Map<String, dynamic>) typeOf,
      required void Function(Map<String, dynamic>, String) rewrite,
  }) async {
    final pending = <String, String>{};
    for (final p in payloads) {
      if (typeOf(p) != 'file') continue;
      final src = srcOf(p);
      if (src.isEmpty || src.startsWith('@')) continue;
      final key = _imageKey(src);
      if (!_registeredImageKeys.contains(key)) pending[key] = src;
      rewrite(p, '@$key');
    }
    if (pending.isEmpty) return;

    // 이미지 1개가 매우 클 수 있으므로 크기 기준으로 나누어 전송합니다.
    var chunk = <String, String>{};
    var chars = 0;
    Future<void> flush() async {
      if (chunk.isEmpty) return;
      await _webViewController
          .runJavaScript('registerImages(${_jsJson(chunk)});');
      _registeredImageKeys.addAll(chunk.keys);
      chunk = <String, String>{};
      chars = 0;
    }

    for (final entry in pending.entries) {
      if (chunk.isNotEmpty && chars + entry.value.length > _batchMaxChars) {
        await flush();
      }
      chunk[entry.key] = entry.value;
      chars += entry.value.length;
    }
    await flush();
  }

  /// payload 목록을 크기 기준으로 나누어 `jsFunction(payload)` 를 호출합니다.
  ///
  /// 마커 N개를 N번 호출하던 방식 대신 한 번(또는 소수의) 브릿지 왕복으로 전송합니다.
  Future<void> _runBatched(
      String jsFunction, Iterable<Map<String, dynamic>> items) async {
    final encoded = items.map(jsonEncode).toList(growable: false);
    if (encoded.isEmpty) return;

    var start = 0;
    while (start < encoded.length) {
      var chars = 0;
      var end = start;
      while (end < encoded.length &&
          end - start < _batchMaxItems &&
          (end == start || chars + encoded[end].length <= _batchMaxChars)) {
        chars += encoded[end].length;
        end++;
      }
      end = math.max(end, start + 1);
      final chunk = '[${encoded.sublist(start, end).join(',')}]';
      await _webViewController.runJavaScript('$jsFunction(${_jsStr(chunk)});');
      start = end;
    }
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

    await clearPolyline(
      polylineIds: safePolylines.map((e) => e.polylineId).toList(),
    );
    await _runBatched('addPolylines', safePolylines.map(OverlayPayload.polyline));
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

    await clearCircle(
      circleIds: safeCircles.map((e) => e.circleId).toList(),
    );
    await _runBatched('addCircles', safeCircles.map(OverlayPayload.circle));
  }

  /// 지도에 사각형을 추가합니다.
  ///
  /// [rectangles]: 추가할 사각형 목록입니다. null이면 아무 작업도 수행하지 않습니다.
  ///
  /// 기존에 동일한 ID의 사각형이 있으면 제거 후 새로 추가합니다.
  Future<void> addRectangle({List<Rectangle>? rectangles}) async {
    if (rectangles == null) return;

    final safeRectangles = List<Rectangle>.from(rectangles);

    await clearRectangle(
      rectangleIds: safeRectangles.map((e) => e.rectangleId).toList(),
    );
    await _runBatched(
        'addRectangles', safeRectangles.map(OverlayPayload.rectangle));
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

    await clearPolygon(
      polygonIds: safePolygons.map((e) => e.polygonId).toList(),
    );
    await _runBatched('addPolygons', safePolygons.map(OverlayPayload.polygon));
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
    if (markers == null) {
      return;
    }

    final safeMarkers = List<Marker>.from(markers);

    await clearMarker(markerIds: safeMarkers.map((e) => e.markerId).toList());

    final payloads = safeMarkers.map(OverlayPayload.marker).toList();
    await _registerImagesAndRewrite(
      payloads,
      srcOf: (p) => (p['imageSrc'] as String?) ?? '',
      typeOf: (p) => p['imageType'] as String?,
      rewrite: (p, ref) => p['imageSrc'] = ref,
    );
    await _runBatched('addMarkers', payloads);
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

    final markerPayloads =
        clusterer.markers.map((m) => m.toJson()).toList();
    await _registerImagesAndRewrite(
      markerPayloads,
      srcOf: (p) => ((p['icon'] as Map?)?['imageSrc'] as String?) ?? '',
      typeOf: (p) => (p['icon'] as Map?)?['imageType'] as String?,
      rewrite: (p, ref) => (p['icon'] as Map)['imageSrc'] = ref,
    );

    // JS 쪽 addMarkerClusterer 가 이전 클러스터러를 정리한 뒤 새로 생성합니다.
    final clustererString = 'addMarkerClusterer('
        '${_jsJson(markerPayloads)}, '
        '${_jsPrimitive(clusterer.gridSize)}, '
        '${_jsPrimitive(clusterer.averageCenter)}, '
        '${_jsPrimitive(clusterer.disableClickZoom)}, '
        '${_jsPrimitive(clusterer.minLevel)}, '
        '${_jsPrimitive(clusterer.minClusterSize)}, '
        '${_jsJson(clusterer.texts)}, '
        '${_jsJson(clusterer.calculator)}, '
        '${_jsJson(clusterer.styles)});';
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

    await clearCustomOverlay(
        overlayIds: overlays.map((e) => e.customOverlayId).toList());
    await _runBatched(
        'addCustomOverlays', overlays.map(OverlayPayload.customOverlay));
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
  /// [polylineIds]: **남길** 폴리라인 ID 목록입니다. 목록에 포함되지 않은 폴리라인이(가) 제거되며,
  /// null이거나 비어 있으면 모든 폴리라인을(를) 제거합니다.
  Future<void> clearPolyline({List<String>? polylineIds}) async {
    await _webViewController.runJavaScript(
        'clearPolyline(${_jsJson(polylineIds ?? const <String>[])});');
  }

  /// 지도에 표시된 원을 제거합니다.
  ///
  /// [circleIds]: **남길** 원 ID 목록입니다. 목록에 포함되지 않은 원이(가) 제거되며,
  /// null이거나 비어 있으면 모든 원을(를) 제거합니다.
  Future<void> clearCircle({List<String>? circleIds}) async {
    await _webViewController.runJavaScript(
        'clearCircle(${_jsJson(circleIds ?? const <String>[])});');
  }

  /// 지도에 표시된 사각형을 제거합니다.
  ///
  /// [rectangleIds]: **남길** 사각형 ID 목록입니다. 목록에 포함되지 않은 사각형이(가) 제거되며,
  /// null이거나 비어 있으면 모든 사각형을(를) 제거합니다.
  Future<void> clearRectangle({List<String>? rectangleIds}) async {
    await _webViewController.runJavaScript(
        'clearRectangle(${_jsJson(rectangleIds ?? const <String>[])});');
  }

  /// 지도에 표시된 다각형을 제거합니다.
  ///
  /// [polygonIds]: **남길** 다각형 ID 목록입니다. 목록에 포함되지 않은 다각형이(가) 제거되며,
  /// null이거나 비어 있으면 모든 다각형을(를) 제거합니다.
  Future<void> clearPolygon({List<String>? polygonIds}) async {
    await _webViewController.runJavaScript(
        'clearPolygon(${_jsJson(polygonIds ?? const <String>[])});');
  }

  /// 지도에 표시된 마커를 제거합니다.
  ///
  /// [markerIds]: **남길** 마커 ID 목록입니다. 목록에 포함되지 않은 마커이(가) 제거되며,
  /// null이거나 비어 있으면 모든 마커을(를) 제거합니다.
  Future<void> clearMarker({List<String>? markerIds}) async {
    await _webViewController.runJavaScript(
        'clearMarker(${_jsJson(markerIds ?? const <String>[])});');
  }

  /// 지도에 표시된 마커 클러스터러를 제거합니다.
  ///
  /// 클러스터러와 함께 클러스터러에 속한 모든 마커를 제거합니다.
  Future<void> clearMarkerClusterer() async {
    await _webViewController.runJavaScript('clearMarkerClusterer();');
  }

  /// 지도에 표시된 커스텀 오버레이를 제거합니다.
  ///
  /// [overlayIds]: **남길** 커스텀 오버레이 ID 목록입니다. 목록에 포함되지 않은 오버레이가 제거되며,
  /// null이거나 비어 있으면 모든 커스텀 오버레이를 제거합니다.
  Future<void> clearCustomOverlay({List<String>? overlayIds}) async {
    await _webViewController.runJavaScript(
        'clearCustomOverlay(${_jsJson(overlayIds ?? const <String>[])});');
  }

  /// 지도 중심을 지정한 좌표로 부드럽게 이동합니다.
  ///
  /// [latLng]: 이동할 중심 좌표입니다.
  ///
  /// 이동 거리가 화면 크기보다 크면 애니메이션 없이 즉시 이동합니다.
  Future<void> panTo(LatLng latLng) async {
    await _webViewController.runJavaScript(
        "panTo(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
  }

  /// 주어진 좌표들이 모두 보이도록 지도 영역을 조정합니다.
  ///
  /// [points]: 화면에 표시할 좌표 목록입니다.
  ///
  /// 모든 좌표가 화면에 보이도록 줌 레벨과 중심 좌표를 자동으로 조정합니다.
  Future<void> fitBounds(List<LatLng> points) async {
    await _webViewController
        .runJavaScript("fitBounds(${_jsJson(points)});");
  }

  /// 특정 마커의 드래그 가능 여부를 변경합니다.
  ///
  /// [markerId]: 대상 마커의 ID입니다.
  /// [draggable]: true이면 드래그 가능, false이면 불가능합니다.
  Future<void> setMarkerDraggable(String markerId, bool draggable) async {
    await _webViewController
        .runJavaScript("setMarkerDraggable(${_jsStr(markerId)}, $draggable);");
  }

  /// 지도의 중심 좌표를 설정합니다.
  ///
  /// [latLng]: 새로운 중심 좌표입니다.
  ///
  /// 애니메이션 없이 즉시 중심이 이동합니다.
  Future<void> setCenter(LatLng latLng) async {
    await _webViewController.runJavaScript(
        "setCenter(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
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
          .runJavaScript("setLevel('$level', ${_jsJson(options)});");
    }
  }

  /// 현재 지도의 줌 레벨을 반환합니다.
  ///
  /// Returns: 현재 줌 레벨
  Future<int> getLevel() async {
    final result = await _webViewController
        .runJavaScriptReturningResult("getLevel();") as String;
    final level = (jsonDecode(result)['level'] as num).toInt();

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

    final mapTypeId = (jsonDecode(result)['mapTypeId'] as num).toInt();

    return MapType.getById(mapTypeId);
  }

  /// 지도가 표시할 영역을 설정합니다.
  ///
  /// [bounds]: 지도에 표시할 영역입니다. null이면 아무 작업도 수행하지 않고
  /// 조용히 반환합니다(하위호환: 기존에는 인자 없이 호출했습니다).
  /// [paddingTop], [paddingRight], [paddingBottom], [paddingLeft]: 영역 기준
  /// 상하좌우로 추가 확보할 픽셀 여백입니다.
  Future<void> setBounds([
    LatLngBounds? bounds,
    int paddingTop = 0,
    int paddingRight = 0,
    int paddingBottom = 0,
    int paddingLeft = 0,
  ]) async {
    if (bounds == null) {
      await _webViewController.runJavaScript("setBounds();");
      return;
    }

    await _webViewController.runJavaScript(
        "setBounds(${_jsJson(bounds)}, ${_jsPrimitive(paddingTop)}, "
        "${_jsPrimitive(paddingRight)}, ${_jsPrimitive(paddingBottom)}, "
        "${_jsPrimitive(paddingLeft)});");
  }

  /// 지도 스타일을 설정합니다.
  ///
  /// [width]: 지도 너비
  /// [height]: 지도 높이
  @Deprecated('컨테이너 크기는 Flutter 위젯으로 제어하세요. 지도 재계산은 relayout() 을 사용합니다.')
  Future<void> setStyle(int width, int height) async {
    await _webViewController.runJavaScript(
        "setMapStyle(${_jsPrimitive(width)}, ${_jsPrimitive(height)});");
  }

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
    return LatLngBounds.fromJson(jsonDecode(bounds));
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
  @Deprecated('플랫폼별 반환 타입이 달라 신뢰할 수 없습니다. isDraggable() 을 사용하세요.')
  Future<Object?> getDraggable() async {
    final draggable =
        await _webViewController.runJavaScriptReturningResult("getDraggable();");

    return draggable;
  }

  /// 현재 지도의 드래그 가능 여부를 반환합니다.
  ///
  /// Android 는 문자열(`"true"`), iOS 는 bool(`true`)을 반환하는 플랫폼 차이를
  /// 내부에서 정규화하여 항상 [bool] 로 반환합니다.
  ///
  /// Returns: 드래그 가능 여부
  Future<bool> isDraggable() async {
    final draggable =
        await _webViewController.runJavaScriptReturningResult("getDraggable();");
    return draggable == true || draggable == 'true' || draggable == 1;
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
  @Deprecated('플랫폼별 반환 타입이 달라 신뢰할 수 없습니다. isZoomable() 을 사용하세요.')
  Future<Object?> getZoomable() async {
    final zoomable =
        await _webViewController.runJavaScriptReturningResult("getZoomable();");
    return zoomable;
  }

  /// 현재 지도의 줌 가능 여부를 반환합니다.
  ///
  /// Android 는 문자열(`"true"`), iOS 는 bool(`true`)을 반환하는 플랫폼 차이를
  /// 내부에서 정규화하여 항상 [bool] 로 반환합니다.
  ///
  /// Returns: 줌 가능 여부
  Future<bool> isZoomable() async {
    final zoomable =
        await _webViewController.runJavaScriptReturningResult("getZoomable();");
    return zoomable == true || zoomable == 'true' || zoomable == 1;
  }

  /// 검색/변환 계열 서비스(keywordSearch, categorySearch, addressSearch,
  /// coord2Address, coord2RegionCode, transCoord)가 공유하는 요청 처리 로직입니다.
  ///
  /// [service]: 요청 상태를 관리하는 [BaseService] 인스턴스입니다.
  /// [jsFunction]: 호출할 WebView 측 JS 함수 이름입니다.
  /// [request]: JSON 으로 직렬화되어 JS 함수에 전달될 요청 객체입니다.
  Future<R> _runSearch<R>(
      BaseService<R> service, String jsFunction, Object request) async {
    // 레거시 정적 결과 경로(xxxResult())도 계속 동작하도록 이전과 동일하게 초기화합니다.
    service.resetCompleter();
    final requestId = service.createRequest();
    final result = service.requestFuture(requestId);

    try {
      await _webViewController
          .runJavaScript("$jsFunction(${_jsJson(request)}, $requestId);");
    } catch (e, st) {
      service.failRequest(requestId, e, st);
    }

    return result;
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
          KeywordSearchRequest request) =>
      _runSearch(KeywordSearchService(), 'keywordSearch', request);

  /// 카테고리로 장소를 검색합니다.
  ///
  /// [request]: 검색 요청 정보입니다.
  ///
  /// Returns: 검색 결과 [CategorySearchResponse]
  Future<CategorySearchResponse> categorySearch(
          CategorySearchRequest request) =>
      _runSearch(CategorySearchService(), 'categorySearch', request);

  /// 주소로 좌표를 검색합니다.
  ///
  /// [request]: 검색 요청 정보입니다.
  ///
  /// Returns: 검색 결과 [AddressSearchResponse]
  Future<AddressSearchResponse> addressSearch(
          AddressSearchRequest request) =>
      _runSearch(AddressSearchService(), 'addressSearch', request);

  /// 좌표를 주소로 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [Coord2AddressResponse]
  Future<Coord2AddressResponse> coord2Address(
          Coord2AddressRequest request) =>
      _runSearch(Coord2AddressService(), 'coord2Address', request);

  /// 좌표를 행정구역 코드로 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [Coord2RegionCodeResponse]
  Future<Coord2RegionCodeResponse> coord2RegionCode(
          Coord2RegionCodeRequest request) =>
      _runSearch(Coord2RegionCodeService(), 'coord2RegionCode', request);

  /// 좌표계를 변환합니다.
  ///
  /// [request]: 변환 요청 정보입니다.
  ///
  /// Returns: 변환 결과 [TransCoordResponse]
  Future<TransCoordResponse> transCoord(TransCoordRequest request) =>
      _runSearch(TransCoordService(), 'transCoord', request);

  /// 지도 좌표(LatLng)를 화면 픽셀 좌표로 변환합니다.
  ///
  /// [latLng]: 변환할 지도 좌표입니다.
  ///
  /// Returns: 화면 픽셀 좌표 [Point]
  Future<Point> coordToPixel(LatLng latLng) async {
    final result = await _webViewController.runJavaScriptReturningResult(
        "coordToPixel(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
    return Point.fromJson(_decodeMapResult(result, 'coordToPixel'));
  }

  /// 화면 픽셀 좌표를 지도 좌표(LatLng)로 변환합니다.
  ///
  /// [point]: 변환할 화면 픽셀 좌표입니다.
  ///
  /// Returns: 지도 좌표 [LatLng]
  Future<LatLng> pixelToCoord(Point point) async {
    final result = await _webViewController.runJavaScriptReturningResult(
        "pixelToCoord(${_jsPrimitive(point.x)}, ${_jsPrimitive(point.y)});");
    return LatLng.fromJson(_decodeMapResult(result, 'pixelToCoord'));
  }

  /// 좌표 변환 결과를 Map 으로 되돌립니다.
  ///
  /// 위젯이 이미 정리되어 지도가 없으면 JS 가 null 을 돌려주는데, 그대로
  /// 캐스트하면 원인을 알기 어려운 타입 오류가 납니다. 무엇이 잘못됐는지
  /// 알 수 있도록 [StateError] 로 바꿔 던집니다.
  Map<String, dynamic> _decodeMapResult(Object? raw, String label) {
    dynamic value = raw;
    if (value is String) {
      value = jsonDecode(value);
      if (value is String) value = jsonDecode(value);
    }
    if (value is! Map) {
      throw StateError(
        '$label 결과를 받지 못했습니다. 지도가 아직 준비되지 않았거나 '
        '이미 정리된 상태일 수 있습니다. 위젯이 화면에 있는 동안 호출하세요.',
      );
    }
    return Map<String, dynamic>.from(value);
  }
}
