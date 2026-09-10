/// Flutter 위젯 오버레이의 픽셀 좌표를 추적해 Dart 로 보내는 스크립트입니다.
class JsWidgetOverlay {
  /// 스크립트를 반환합니다.
  static String getScript() {
    return '''
    // id -> kakao.maps.LatLng. Flutter 위젯 오버레이가 붙을 좌표들입니다.
    const __widgetOverlayTargets = new Map();
    let __widgetOverlayScheduled = false;
    let __widgetOverlayListening = false;

    /** 추적할 좌표 목록을 통째로 바꿉니다. payload: [{id, latitude, longitude}] */
    function trackWidgetOverlays(payload) {
        const list = parseIfString(payload) || [];
        __widgetOverlayTargets.clear();
        list.forEach(function (item) {
            __widgetOverlayTargets.set(String(item.id), new kakao.maps.LatLng(item.latitude, item.longitude));
        });
        __ensureWidgetOverlayListeners();
        __postWidgetOverlayPositions();
    }

    /** 지도가 움직일 때마다(프레임당 최대 1회) 픽셀 좌표를 보냅니다. */
    function __scheduleWidgetOverlayPositions() {
        if (__widgetOverlayScheduled) return;
        __widgetOverlayScheduled = true;
        requestAnimationFrame(function () {
            __widgetOverlayScheduled = false;
            __postWidgetOverlayPositions();
        });
    }

    function __postWidgetOverlayPositions() {
        if (!map || typeof widgetOverlayPositions === 'undefined') return;
        const projection = map.getProjection();
        const positions = {};
        __widgetOverlayTargets.forEach(function (latLng, id) {
            const point = projection.containerPointFromCoords(latLng);
            positions[id] = [Math.round(point.x * 100) / 100, Math.round(point.y * 100) / 100];
        });
        widgetOverlayPositions.postMessage(JSON.stringify({ positions: positions }));
    }

    function __ensureWidgetOverlayListeners() {
        if (__widgetOverlayListening || !map) return;
        __widgetOverlayListening = true;
        ['center_changed', 'zoom_start', 'zoom_changed', 'drag', 'dragend', 'idle', 'bounds_changed'].forEach(function (type) {
            kakao.maps.event.addListener(map, type, __scheduleWidgetOverlayPositions);
        });
        window.addEventListener('resize', __scheduleWidgetOverlayPositions);
    }
    ''';
  }
}
