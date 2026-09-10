import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

import '../basic/custom_overlay.dart';
import '../basic/js_literal.dart';
import '../basic/marker.dart';
import '../model/lat_lng.dart';
import '../model/viewpoint.dart';

/// 카카오 로드뷰를 제어하는 컨트롤러입니다.
///
/// [KakaoRoadMap] 위젯의 `onRoadviewCreated` 콜백을 통해 제공됩니다.
/// 시점 변경, 파노라마 이동, 로드뷰 위 오버레이 추가 등을 수행합니다.
///
/// 예시:
/// ```dart
/// late KakaoRoadviewController _controller;
///
/// KakaoRoadMap(
///   center: LatLng(33.450701, 126.570667),
///   onRoadviewCreated: (controller) {
///     _controller = controller;
///   },
/// )
///
/// // 북동쪽을 바라보게 시점 변경
/// await _controller.setViewpoint(const Viewpoint(pan: 45));
/// ```
class KakaoRoadviewController {
  final WebViewController _webViewController;

  /// 내부적으로 사용하는 WebView 컨트롤러입니다.
  WebViewController get webViewController => _webViewController;

  /// [KakaoRoadviewController]를 생성합니다.
  ///
  /// [_webViewController]: 로드뷰를 표시하는 WebView 컨트롤러
  KakaoRoadviewController(this._webViewController);

  /// 배치 전송 시 한 번의 JS 호출에 담을 최대 항목 수입니다.
  static const int _batchMaxItems = 200;

  Future<void> _run(String script) =>
      _webViewController.runJavaScript(script);

  Future<String> _runReturning(String script) async {
    final raw = await _webViewController.runJavaScriptReturningResult(script);
    return raw is String ? raw : raw.toString();
  }

  /// 플랫폼별 반환 형식(문자열 / 객체)을 흡수해 Map 으로 되돌립니다.
  Map<String, dynamic> _decode(String raw) {
    dynamic value = jsonDecode(raw);
    if (value is String) value = jsonDecode(value);
    return Map<String, dynamic>.from(value as Map);
  }

  // ---------------------------------------------------------------------------
  // 파노라마 / 시점
  // ---------------------------------------------------------------------------

  /// 파노라마 ID 를 지정해 로드뷰를 표시합니다.
  ///
  /// [panoId]: 표시할 파노라마의 ID
  /// [position]: 파노라마의 기준 좌표
  Future<void> setPanoId(String panoId, LatLng position) async {
    await _run('setPanoId(${jsStringLiteral(panoId)}, '
        '${position.latitude}, ${position.longitude});');
  }

  /// 좌표에서 가장 가까운 로드뷰를 찾아 표시합니다.
  ///
  /// [position]: 기준 좌표
  /// [radius]: 검색 반경(m). 기본값은 50 입니다.
  ///
  /// 반경 안에 로드뷰가 없으면 [KakaoRoadMap.onRoadviewNotFound] 콜백이
  /// 호출되고 화면은 변경되지 않습니다.
  Future<void> setPanoIdNear(LatLng position, {int radius = 50}) async {
    await _run('setPanoIdNear(${position.latitude}, ${position.longitude}, '
        '${jsPrimitiveLiteral(radius)});');
  }

  /// 현재 표시 중인 파노라마의 ID 를 반환합니다.
  Future<String> getPanoId() async {
    final result = _decode(await _runReturning('getPanoId();'));
    return result['panoId'].toString();
  }

  /// 로드뷰의 시점(방향과 확대 수준)을 변경합니다.
  Future<void> setViewpoint(Viewpoint viewpoint) async {
    await _run('setViewpoint(${viewpoint.pan}, ${viewpoint.tilt}, '
        '${viewpoint.zoom});');
  }

  /// 현재 로드뷰의 시점을 반환합니다.
  Future<Viewpoint> getViewpoint() async {
    return Viewpoint.fromJson(_decode(await _runReturning('getViewpoint();')));
  }

  /// 현재 표시 중인 파노라마의 좌표를 반환합니다.
  Future<LatLng> getPosition() async {
    return LatLng.fromJson(_decode(await _runReturning('getPosition();')));
  }

  /// 특정 좌표를 바라보는 시점을 계산합니다.
  ///
  /// [position]: 바라볼 좌표
  /// [altitude]: 지면으로부터의 높이(m). 기본값은 0 입니다.
  ///
  /// 반환된 시점을 [setViewpoint] 에 넘기면 해당 지점을 정면으로 바라봅니다.
  Future<Viewpoint> viewpointFromCoords(
    LatLng position, {
    double altitude = 0,
  }) async {
    final raw = await _runReturning('viewpointFromCoords('
        '${position.latitude}, ${position.longitude}, $altitude);');
    return Viewpoint.fromJson(_decode(raw));
  }

  /// 로드뷰를 다시 그립니다.
  ///
  /// 컨테이너 크기가 바뀌었거나 숨겨진 상태에서 다시 표시될 때 호출합니다.
  Future<void> relayout() async {
    await _run('relayout();');
  }

  // ---------------------------------------------------------------------------
  // 오버레이
  // ---------------------------------------------------------------------------

  /// 로드뷰 위에 마커를 추가합니다.
  ///
  /// [markers]: 추가할 마커 목록입니다. null 이면 아무 작업도 하지 않고,
  /// 빈 목록이면 기존 마커를 모두 제거합니다.
  ///
  /// [Marker.altitude] 로 지면으로부터의 높이를, [Marker.range] 로 마커가
  /// 보이는 최대 거리를 지정할 수 있습니다.
  Future<void> addMarker({List<Marker>? markers}) async {
    if (markers == null) return;

    final safeMarkers = List<Marker>.from(markers);
    await clearMarker(markerIds: safeMarkers.map((e) => e.markerId).toList());

    final payloads = safeMarkers
        .map((m) => {
              'markerId': m.markerId,
              'latLng': {
                'latitude': m.latLng.latitude,
                'longitude': m.latLng.longitude,
              },
              'infoWindowContent': m.infoWindowContent,
              'infoWindowFirstShow': m.infoWindowFirstShow,
              'altitude': m.altitude,
              'range': m.range,
            })
        .toList();

    await _sendBatched('addRoadviewMarkers', payloads);
  }

  /// 로드뷰 위에 커스텀 오버레이를 추가합니다.
  ///
  /// [customOverlays]: 추가할 오버레이 목록입니다. null 이면 아무 작업도 하지
  /// 않고, 빈 목록이면 기존 오버레이를 모두 제거합니다.
  Future<void> addCustomOverlay({List<CustomOverlay>? customOverlays}) async {
    if (customOverlays == null) return;

    final overlays = List<CustomOverlay>.from(customOverlays);
    await clearCustomOverlay(
        overlayIds: overlays.map((e) => e.customOverlayId).toList());

    final payloads = overlays
        .map((o) => {
              'customOverlayId': o.customOverlayId,
              'latLng': {
                'latitude': o.latLng.latitude,
                'longitude': o.latLng.longitude,
              },
              'content': o.content,
              'xAnchor': o.xAnchor,
              'yAnchor': o.yAnchor,
              'zIndex': o.zIndex,
              'altitude': o.altitude,
            })
        .toList();

    await _sendBatched('addRoadviewCustomOverlays', payloads);
  }

  /// 로드뷰 위의 마커를 제거합니다.
  ///
  /// [markerIds]: **남길** 마커 ID 목록입니다. 목록에 포함되지 않은 마커가
  /// 제거되며, null 이거나 비어 있으면 모든 마커를 제거합니다.
  Future<void> clearMarker({List<String>? markerIds}) async {
    await _run('clearRoadviewMarker('
        '${jsJsonLiteral(markerIds ?? const <String>[])});');
  }

  /// 로드뷰 위의 커스텀 오버레이를 제거합니다.
  ///
  /// [overlayIds]: **남길** 오버레이 ID 목록입니다. 목록에 포함되지 않은
  /// 오버레이가 제거되며, null 이거나 비어 있으면 모두 제거합니다.
  Future<void> clearCustomOverlay({List<String>? overlayIds}) async {
    await _run('clearRoadviewCustomOverlay('
        '${jsJsonLiteral(overlayIds ?? const <String>[])});');
  }

  /// 로드뷰 위의 모든 오버레이를 제거합니다.
  Future<void> clear() async {
    await _run('clearRoadview();');
  }

  /// payload 목록을 나누어 `jsFunction(payload)` 를 호출합니다.
  Future<void> _sendBatched(
      String jsFunction, List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    for (var start = 0; start < items.length; start += _batchMaxItems) {
      final end = (start + _batchMaxItems).clamp(0, items.length);
      final chunk = items.sublist(start, end);
      await _run('$jsFunction(${jsJsonLiteral(chunk)});');
    }
  }
}
