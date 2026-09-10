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
import '../protocol/drawing_data.dart';
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
import '../bridge/kakao_map_bridge.dart';
import '../bridge/webview_bridge.dart';
import 'constants/drawing_overlay_type.dart';
import 'custom_overlay.dart';
import 'drawing_options.dart';
import 'tileset.dart';
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
  final KakaoMapBridge _bridge;

  /// 내부적으로 사용하는 WebView 컨트롤러입니다.
  ///
  /// WebView 를 쓰지 않는 플랫폼(web)에서는 [StateError] 를 던집니다.
  WebViewController get webViewController =>
      _bridge.webViewController ??
      (throw StateError('이 플랫폼에서는 WebView 컨트롤러를 제공하지 않습니다.'));

  /// [KakaoMapController]를 생성합니다.
  ///
  /// [webViewController]: 지도를 표시하는 WebView 컨트롤러
  KakaoMapController(WebViewController webViewController)
      : _bridge = WebViewBridge.fromController(webViewController);

  /// 라이브러리 내부용. 통신 계층을 직접 주입해 생성합니다.
  KakaoMapController.fromBridge(this._bridge);

  /// 지도 문서 안에서 임의의 JavaScript 를 실행합니다.
  ///
  /// 이 플러그인이 제공하지 않는 카카오 SDK 기능을 직접 호출할 때 쓰는
  /// 고급 진입점입니다. 지도 객체는 `map` 전역 변수로 접근할 수 있습니다.
  /// 모든 플랫폼(Android, iOS, web)에서 동작합니다.
  ///
  /// 외부에서 받은 문자열을 그대로 넣지 마세요. 문서 안에서 그대로 실행됩니다.
  Future<void> runJavaScript(String script) => _bridge.runJavaScript(script);

  /// 지도 문서 안에서 JavaScript 를 실행하고 결과를 돌려줍니다.
  ///
  /// 결과 형식은 플랫폼마다 다릅니다. Android 와 web 은 JSON 문자열, iOS 는
  /// 원시 값(문자열/숫자/불리언) 또는 문자열입니다. 플랫폼에 관계없이 같은
  /// 값을 얻으려면 JS 쪽에서 `JSON.stringify(...)` 로 감싸고 Dart 에서
  /// 문자열이면 `jsonDecode` 하세요(문자열이 한 번 더 감싸여 올 수 있습니다).
  Future<Object?> evaluateJavaScript(String script) =>
      _bridge.runJavaScriptReturningResult(script);

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
      await _bridge
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
      await _bridge.runJavaScript('$jsFunction(${_jsStr(chunk)});');
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
    await _bridge.runJavaScript(clustererString);
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
    await _bridge.runJavaScript("dispose()");
  }

  /// 지도에 표시된 모든 오버레이를 제거합니다.
  ///
  /// 폴리라인, 원, 사각형, 다각형, 마커, 커스텀 오버레이를 모두 제거합니다.
  Future<void> clear() async {
    await _bridge.runJavaScript('clear();');
  }

  /// 지도에 표시된 폴리라인을 제거합니다.
  ///
  /// [polylineIds]: **남길** 폴리라인 ID 목록입니다. 목록에 포함되지 않은 폴리라인이(가) 제거되며,
  /// null이거나 비어 있으면 모든 폴리라인을(를) 제거합니다.
  Future<void> clearPolyline({List<String>? polylineIds}) async {
    await _bridge.runJavaScript(
        'clearPolyline(${_jsJson(polylineIds ?? const <String>[])});');
  }

  /// 지도에 표시된 원을 제거합니다.
  ///
  /// [circleIds]: **남길** 원 ID 목록입니다. 목록에 포함되지 않은 원이(가) 제거되며,
  /// null이거나 비어 있으면 모든 원을(를) 제거합니다.
  Future<void> clearCircle({List<String>? circleIds}) async {
    await _bridge.runJavaScript(
        'clearCircle(${_jsJson(circleIds ?? const <String>[])});');
  }

  /// 지도에 표시된 사각형을 제거합니다.
  ///
  /// [rectangleIds]: **남길** 사각형 ID 목록입니다. 목록에 포함되지 않은 사각형이(가) 제거되며,
  /// null이거나 비어 있으면 모든 사각형을(를) 제거합니다.
  Future<void> clearRectangle({List<String>? rectangleIds}) async {
    await _bridge.runJavaScript(
        'clearRectangle(${_jsJson(rectangleIds ?? const <String>[])});');
  }

  /// 지도에 표시된 다각형을 제거합니다.
  ///
  /// [polygonIds]: **남길** 다각형 ID 목록입니다. 목록에 포함되지 않은 다각형이(가) 제거되며,
  /// null이거나 비어 있으면 모든 다각형을(를) 제거합니다.
  Future<void> clearPolygon({List<String>? polygonIds}) async {
    await _bridge.runJavaScript(
        'clearPolygon(${_jsJson(polygonIds ?? const <String>[])});');
  }

  /// 지도에 표시된 마커를 제거합니다.
  ///
  /// [markerIds]: **남길** 마커 ID 목록입니다. 목록에 포함되지 않은 마커이(가) 제거되며,
  /// null이거나 비어 있으면 모든 마커을(를) 제거합니다.
  Future<void> clearMarker({List<String>? markerIds}) async {
    await _bridge.runJavaScript(
        'clearMarker(${_jsJson(markerIds ?? const <String>[])});');
  }

  /// 지도에 표시된 마커 클러스터러를 제거합니다.
  ///
  /// 클러스터러와 함께 클러스터러에 속한 모든 마커를 제거합니다.
  Future<void> clearMarkerClusterer() async {
    await _bridge.runJavaScript('clearMarkerClusterer();');
  }

  /// 지도에 표시된 커스텀 오버레이를 제거합니다.
  ///
  /// [overlayIds]: **남길** 커스텀 오버레이 ID 목록입니다. 목록에 포함되지 않은 오버레이가 제거되며,
  /// null이거나 비어 있으면 모든 커스텀 오버레이를 제거합니다.
  Future<void> clearCustomOverlay({List<String>? overlayIds}) async {
    await _bridge.runJavaScript(
        'clearCustomOverlay(${_jsJson(overlayIds ?? const <String>[])});');
  }

  /// 지도 중심을 지정한 좌표로 부드럽게 이동합니다.
  ///
  /// [latLng]: 이동할 중심 좌표입니다.
  ///
  /// 이동 거리가 화면 크기보다 크면 애니메이션 없이 즉시 이동합니다.
  Future<void> panTo(LatLng latLng) async {
    await _bridge.runJavaScript(
        "panTo(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
  }

  /// 주어진 좌표들이 모두 보이도록 지도 영역을 조정합니다.
  ///
  /// [points]: 화면에 표시할 좌표 목록입니다.
  ///
  /// 모든 좌표가 화면에 보이도록 줌 레벨과 중심 좌표를 자동으로 조정합니다.
  ///
  /// [padding] 을 주면 영역 바깥에 그만큼(px)의 상하좌우 여백을 확보합니다.
  /// 지정하지 않으면 SDK 기본값(32px)을 사용합니다.
  Future<void> fitBounds(List<LatLng> points, {int? padding}) async {
    await _bridge.runJavaScript(padding == null
        ? "fitBounds(${_jsJson(points)});"
        : "fitBounds(${_jsJson(points)}, ${_jsPrimitive(padding)});");
  }

  /// 영역이 화면에 들어오도록 지도를 부드럽게 이동합니다.
  ///
  /// [padding] 은 영역 바깥에 확보할 상하좌우 여백(px)입니다. 이동 거리가 화면보다
  /// 크면 애니메이션 없이 이동합니다.
  Future<void> panToBounds(LatLngBounds bounds, {int padding = 32}) async {
    await _bridge.runJavaScript('panToBounds('
        '${_jsPrimitive(bounds.sw.latitude)}, ${_jsPrimitive(bounds.sw.longitude)}, '
        '${_jsPrimitive(bounds.ne.latitude)}, ${_jsPrimitive(bounds.ne.longitude)}, '
        '${_jsPrimitive(padding)});');
  }

  /// 중심을 지정한 픽셀만큼 부드럽게 이동합니다.
  ///
  /// 바텀시트가 열릴 때 지도 중심을 위로 밀어 올리는 등에 씁니다.
  Future<void> panBy(int dx, int dy) async {
    await _bridge.runJavaScript('panBy(${_jsPrimitive(dx)}, ${_jsPrimitive(dy)});');
  }

  /// 중심 좌표와 확대 레벨을 한 번에 바꿉니다.
  ///
  /// [animate] 가 true 면 이동을 애니메이션으로 보여 주고, [duration] 으로 시간을
  /// 지정할 수 있습니다(지정하지 않으면 SDK 기본값). 이동 거리가 화면보다 크면
  /// 애니메이션 없이 이동합니다.
  Future<void> jump(
    LatLng center,
    int level, {
    bool animate = false,
    Duration? duration,
  }) async {
    final Object option = !animate
        ? false
        : duration == null
            ? true
            : {'duration': duration.inMilliseconds};
    await _bridge.runJavaScript('jump('
        '${_jsPrimitive(center.latitude)}, ${_jsPrimitive(center.longitude)}, '
        '${_jsPrimitive(level)}, ${_jsJson(option)});');
  }

  /// 지도의 최소 확대 레벨을 바꿉니다. 이 레벨보다 더 확대할 수 없습니다.
  Future<void> setMinLevel(int level) async {
    await _bridge.runJavaScript('setMinLevel(${_jsPrimitive(level)});');
  }

  /// 지도의 최대 확대 레벨을 바꿉니다. 이 레벨보다 더 축소할 수 없습니다.
  Future<void> setMaxLevel(int level) async {
    await _bridge.runJavaScript('setMaxLevel(${_jsPrimitive(level)});');
  }

  /// 폴리라인의 총 길이를 미터 단위로 반환합니다. SDK 가 계산한 값입니다.
  ///
  /// 해당 ID 의 폴리라인이 없으면 [StateError] 를 던집니다.
  Future<double> getPolylineLength(String polylineId) async => _decodeMeasure(
        await _bridge.runJavaScriptReturningResult(
            'getPolylineLength(${_jsStr(polylineId)});'),
        '폴리라인 $polylineId',
      );

  /// 다각형의 면적을 제곱미터 단위로 반환합니다. SDK 가 계산한 값입니다.
  ///
  /// 해당 ID 의 다각형이 없으면 [StateError] 를 던집니다.
  Future<double> getPolygonArea(String polygonId) async => _decodeMeasure(
        await _bridge.runJavaScriptReturningResult(
            'getPolygonArea(${_jsStr(polygonId)});'),
        '다각형 $polygonId',
      );

  /// 다각형의 둘레 길이를 미터 단위로 반환합니다. SDK 가 계산한 값입니다.
  ///
  /// 해당 ID 의 다각형이 없으면 [StateError] 를 던집니다.
  Future<double> getPolygonLength(String polygonId) async => _decodeMeasure(
        await _bridge.runJavaScriptReturningResult(
            'getPolygonLength(${_jsStr(polygonId)});'),
        '다각형 $polygonId',
      );

  /// 측정 결과(숫자 또는 null)를 플랫폼 표기 차이에 관계없이 double 로 되돌립니다.
  double _decodeMeasure(Object? raw, String label) {
    dynamic value = raw;
    if (value is String) {
      final text = value.trim().replaceAll('"', '');
      value = text.isEmpty || text == 'null' ? null : num.tryParse(text);
    }
    if (value is! num) {
      throw StateError('$label 을(를) 찾을 수 없습니다. 지도에 추가된 뒤 호출하세요.');
    }
    return value.toDouble();
  }

  /// 특정 마커의 드래그 가능 여부를 변경합니다.
  ///
  /// [markerId]: 대상 마커의 ID입니다.
  /// [draggable]: true이면 드래그 가능, false이면 불가능합니다.
  Future<void> setMarkerDraggable(String markerId, bool draggable) async {
    await _bridge
        .runJavaScript("setMarkerDraggable(${_jsStr(markerId)}, $draggable);");
  }

  /// 지도의 중심 좌표를 설정합니다.
  ///
  /// [latLng]: 새로운 중심 좌표입니다.
  ///
  /// 애니메이션 없이 즉시 중심이 이동합니다.
  Future<void> setCenter(LatLng latLng) async {
    await _bridge.runJavaScript(
        "setCenter(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
  }

  /// 현재 지도의 중심 좌표를 반환합니다.
  ///
  /// Returns: 현재 중심 좌표 [LatLng]
  Future<LatLng> getCenter() async {
    final center = await _bridge
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
      await _bridge.runJavaScript("setLevel('$level');");
    } else {
      await _bridge
          .runJavaScript("setLevel('$level', ${_jsJson(options)});");
    }
  }

  /// 현재 지도의 줌 레벨을 반환합니다.
  ///
  /// Returns: 현재 줌 레벨
  Future<int> getLevel() async {
    final result = await _bridge
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
    await _bridge.runJavaScript("setMapTypeId('${mapType.id}');");
  }

  /// 현재 지도 타입을 반환합니다.
  ///
  /// [setTileset] 으로 커스텀 타일셋을 기본 지도로 쓰고 있으면
  /// [MapType.normal] 을 반환합니다. 타일셋 ID 는 [getActiveTilesetId] 로 확인하세요.
  ///
  /// Returns: 현재 지도 타입 [MapType]
  Future<MapType> getMapTypeId() async {
    final result = await _bridge
        .runJavaScriptReturningResult("getMapTypeId();") as String;

    final mapTypeId = jsonDecode(result)['mapTypeId'];
    // 커스텀 타일셋이 기본 지도 타입이면 숫자가 아닌 값이 온다. 이때는
    // [MapType.normal] 로 돌려주고, 실제 ID 는 [getActiveTilesetId] 로 확인한다.
    if (mapTypeId is! num) return MapType.normal;

    return MapType.getById(mapTypeId.toInt());
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
      await _bridge.runJavaScript("setBounds();");
      return;
    }

    await _bridge.runJavaScript(
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
    await _bridge.runJavaScript(
        "setMapStyle(${_jsPrimitive(width)}, ${_jsPrimitive(height)});");
  }

  /// 지도를 다시 그립니다.
  ///
  /// 지도 컨테이너의 크기가 변경되었거나 숨겨진 상태에서 다시 표시될 때 호출합니다.
  /// IndexedStack 등에서 탭 전환 시 유용합니다.
  Future<void> relayout() async {
    await _bridge.runJavaScript("relayout();");
  }

  /// 현재 지도 화면의 영역 좌표를 반환합니다.
  ///
  /// Returns: 지도 영역의 남서(SW)와 북동(NE) 좌표를 포함하는 [LatLngBounds]
  Future<LatLngBounds> getBounds() async {
    final bounds = await _bridge
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
    await _bridge.runJavaScript("addOverlayMapTypeId('${mapType.id}');");
  }

  /// 지도에서 오버레이 타입의 타일 레이어를 제거합니다.
  ///
  /// [mapType]: 제거할 오버레이 타입입니다.
  Future<void> removeOverlayMapTypeId(MapType mapType) async {
    await _bridge
        .runJavaScript("removeOverlayMapTypeId('${mapType.id}');");
  }

  /// 지도 드래그 가능 여부를 설정합니다.
  ///
  /// [draggable]: true이면 드래그 가능, false이면 불가능합니다.
  Future<void> setDraggable(bool draggable) async {
    await _bridge.runJavaScript("setDraggable($draggable);");
  }

  /// 현재 지도의 드래그 가능 여부를 반환합니다.
  ///
  /// Returns: 드래그 가능 여부
  @Deprecated('플랫폼별 반환 타입이 달라 신뢰할 수 없습니다. isDraggable() 을 사용하세요.')
  Future<Object?> getDraggable() async {
    final draggable =
        await _bridge.runJavaScriptReturningResult("getDraggable();");

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
        await _bridge.runJavaScriptReturningResult("getDraggable();");
    return draggable == true || draggable == 'true' || draggable == 1;
  }

  /// 지도 줌 가능 여부를 설정합니다.
  ///
  /// [zoomable]: true이면 줌 가능, false이면 불가능합니다.
  Future<void> setZoomable(bool zoomable) async {
    await _bridge.runJavaScript("setZoomable($zoomable);");
  }

  /// 현재 지도의 줌 가능 여부를 반환합니다.
  ///
  /// Returns: 줌 가능 여부
  @Deprecated('플랫폼별 반환 타입이 달라 신뢰할 수 없습니다. isZoomable() 을 사용하세요.')
  Future<Object?> getZoomable() async {
    final zoomable =
        await _bridge.runJavaScriptReturningResult("getZoomable();");
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
        await _bridge.runJavaScriptReturningResult("getZoomable();");
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
      await _bridge
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
    final result = await _bridge.runJavaScriptReturningResult(
        "coordToPixel(${_jsPrimitive(latLng.latitude)}, ${_jsPrimitive(latLng.longitude)});");
    return Point.fromJson(_decodeMapResult(result, 'coordToPixel'));
  }

  /// 화면 픽셀 좌표를 지도 좌표(LatLng)로 변환합니다.
  ///
  /// [point]: 변환할 화면 픽셀 좌표입니다.
  ///
  /// Returns: 지도 좌표 [LatLng]
  Future<LatLng> pixelToCoord(Point point) async {
    final result = await _bridge.runJavaScriptReturningResult(
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
  // ---------------------------------------------------------------------------
  // Drawing Library
  // ---------------------------------------------------------------------------

  /// 도형 그리기 관리자를 생성합니다.
  ///
  /// Drawing 기능을 쓰기 전에 한 번 호출해야 합니다. 이미 만들어져 있으면
  /// 기존 관리자를 정리하고 새로 만듭니다.
  ///
  /// [options]로 그릴 수 있는 도형 종류와 도형별 스타일을 지정합니다.
  ///
  /// [KakaoMapLibrary.drawing] 을 제외하고 지도를 만든 경우에는 아무 일도
  /// 일어나지 않습니다.
  ///
  /// 예시:
  /// ```dart
  /// await controller.createDrawingManager(
  ///   options: const DrawingOptions(
  ///     drawingMode: [DrawingOverlayType.polyline, DrawingOverlayType.polygon],
  ///   ),
  /// );
  /// ```
  Future<void> createDrawingManager({DrawingOptions? options}) async {
    final payload = (options ?? const DrawingOptions()).toJson();
    await _bridge
        .runJavaScript('createDrawingManager(${_jsJson(payload)});');
  }

  /// 그릴 도형의 종류를 선택합니다.
  ///
  /// 선택 후 사용자가 지도를 조작하면 해당 도형이 그려집니다.
  Future<void> selectDrawingMode(DrawingOverlayType type) async {
    await _bridge
        .runJavaScript('selectDrawingMode(${_jsStr(type.value)});');
  }

  /// 그리는 중이던 작업을 취소합니다.
  Future<void> cancelDrawing() async {
    await _bridge.runJavaScript('cancelDrawing();');
  }

  /// 마지막 그리기 작업을 되돌립니다.
  Future<void> undoDrawing() async {
    await _bridge.runJavaScript('undoDrawing();');
  }

  /// 되돌린 작업을 다시 실행합니다.
  Future<void> redoDrawing() async {
    await _bridge.runJavaScript('redoDrawing();');
  }

  /// 선택된 도형을 지웁니다.
  Future<void> removeDrawingShape() async {
    await _bridge.runJavaScript('removeDrawingShape();');
  }

  /// 지금까지 그린 도형 데이터를 가져옵니다.
  ///
  /// 관리자를 만들지 않았거나 그린 도형이 없으면 빈 [DrawingData]를 반환합니다.
  Future<DrawingData> getDrawingData() async {
    final raw =
        await _bridge.runJavaScriptReturningResult('getDrawingData();');
    dynamic value = raw;
    if (value is String) {
      value = jsonDecode(value);
      if (value is String) value = jsonDecode(value);
    }
    if (value is! Map) return const DrawingData([]);
    return DrawingData.fromJson(Map<String, dynamic>.from(value));
  }

  /// 도형 그리기 도구 상자(Toolbox)를 지도 위에 표시합니다.
  ///
  /// [createDrawingManager] 를 먼저 호출해야 합니다.
  Future<void> showDrawingToolbox() async {
    await _bridge.runJavaScript('showDrawingToolbox();');
  }

  /// 도형 그리기 도구 상자를 제거합니다.
  Future<void> removeDrawingToolbox() async {
    await _bridge.runJavaScript('removeDrawingToolbox();');
  }
  // ---------------------------------------------------------------------------
  // Tileset
  // ---------------------------------------------------------------------------

  /// 커스텀 타일셋을 등록합니다.
  ///
  /// 등록만 하고 화면에는 아직 반영하지 않습니다. 기본 지도로 쓰려면
  /// [setTileset], 기존 지도 위에 겹치려면 [addOverlayTileset] 을 호출하세요.
  ///
  /// 예시:
  /// ```dart
  /// await controller.addTileset(const Tileset(
  ///   id: 'MY_TILES',
  ///   urlTemplate: 'https://tiles.example.com/{z}/{y}/{x}.png',
  /// ));
  /// await controller.setTileset('MY_TILES');
  /// ```
  ///
  /// [Tileset.id] 가 영문자·숫자·밑줄 규칙에 맞지 않으면 [ArgumentError] 를 던집니다.
  Future<void> addTileset(Tileset tileset) async {
    if (!_tilesetIdPattern.hasMatch(tileset.id)) {
      throw ArgumentError.value(
        tileset.id,
        'tileset.id',
        '영문자, 숫자, 밑줄만 쓸 수 있고 숫자로 시작할 수 없습니다.',
      );
    }
    await _bridge
        .runJavaScript('addTileset(${_jsJson(tileset.toJson())});');
  }

  static final RegExp _tilesetIdPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  /// 등록한 타일셋을 기본 지도 타입으로 사용합니다.
  ///
  /// 일반 지도로 되돌리려면 `setMapTypeId(MapType.normal)` 을 호출하세요.
  /// 등록하지 않은 [tilesetId] 는 무시됩니다.
  Future<void> setTileset(String tilesetId) async {
    await _bridge
        .runJavaScript('setTileset(${_jsStr(tilesetId)});');
  }

  /// 등록한 타일셋을 현재 지도 위에 겹쳐 올립니다.
  ///
  /// [removeOverlayTileset] 으로 내릴 수 있습니다.
  Future<void> addOverlayTileset(String tilesetId) async {
    await _bridge
        .runJavaScript('addOverlayTileset(${_jsStr(tilesetId)});');
  }

  /// [addOverlayTileset] 으로 올린 타일셋을 내립니다.
  Future<void> removeOverlayTileset(String tilesetId) async {
    await _bridge
        .runJavaScript('removeOverlayTileset(${_jsStr(tilesetId)});');
  }

  /// 기본 지도 타입으로 쓰고 있는 커스텀 타일셋의 ID 를 반환합니다.
  ///
  /// 일반 지도 타입([MapType])을 쓰고 있으면 null 을 반환합니다.
  Future<String?> getActiveTilesetId() async {
    final raw = await _bridge
        .runJavaScriptReturningResult('getActiveTilesetId();');
    final result = _decodeMapResult(raw, 'getActiveTilesetId');
    return result['tilesetId']?.toString();
  }
}
