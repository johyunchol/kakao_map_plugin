/// JavaScript 오버레이 제거 스크립트를 제공합니다.
///
/// 각 `clearXxx(ids)` 함수는 **ids 에 포함된 오버레이만 남기고** 나머지를 제거합니다.
/// ids 가 비어 있으면 전부 제거합니다.
class JsOverlayClear {
  /// 오버레이 제거 함수들의 스크립트를 반환합니다.
  static String getScript() {
    return '''
    function clearPolyline(ids) {
        retainIndexed(polylineIndex, ids);
        syncOverlayArrays();
    }

    function clearCircle(ids) {
        retainIndexed(circleIndex, ids);
        syncOverlayArrays();
    }

    function clearRectangle(ids) {
        retainIndexed(rectangleIndex, ids);
        syncOverlayArrays();
    }

    function clearPolygon(ids) {
        retainIndexed(polygonIndex, ids);
        syncOverlayArrays();
    }

    /**
     * 일반 마커를 정리합니다. 클러스터러가 관리하는 마커는 대상에서 제외되며
     * clearMarkerClusterer() 로 정리합니다.
     */
    function clearMarker(ids) {
        retainIndexed(markerIndex, ids, clustererMarkerIds);
        syncOverlayArrays();
    }

    function clearMarkerClusterer() {
        if (clusterer) {
            clusterer.clear();
            clusterer = null;
        }

        // Clear clusterer custom overlays
        clustererCustomOverlays.forEach(function(overlay) {
            overlay.setMap(null);
        });
        clustererCustomOverlays = [];

        // 클러스터러가 관리하던 마커를 전역 인덱스에서 제거합니다
        for (const id of clustererMarkerIds) {
            const marker = markerIndex.get(id);
            if (marker) {
                detachOverlay(marker);
                markerIndex.delete(id);
            }
        }
        clustererMarkerIds = new Set();
        syncOverlayArrays();
    }

    function clearCustomOverlay(ids) {
        retainIndexed(customOverlayIndex, ids);
        syncOverlayArrays();
    }

    function clear() {
        runBatch(() => {
            clearPolyline();
            clearCircle();
            clearRectangle();
            clearPolygon();
            clearMarkerClusterer();
            clearMarker();
            clearCustomOverlay();
        });
    }

    function dispose() {
        clear();
        releaseImageCaches();
        map = null;
    }
    ''';
  }
}
