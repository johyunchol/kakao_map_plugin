/// 로드뷰 위 오버레이(마커, 커스텀 오버레이) 스크립트를 제공합니다.
class JsRoadviewOverlay {
  /// 로드뷰 오버레이 추가/제거 함수 스크립트를 반환합니다.
  static String getScript({
    required bool hasMarkerTapCallback,
    required bool hasCustomOverlayTapCallback,
  }) {
    return '''
    /**
     * 로드뷰 위에 마커를 추가합니다.
     *
     * 로드뷰의 마커는 지도와 달리 고도(altitude)와 표시 거리(range)를
     * 지정할 수 있습니다. altitude 는 지면으로부터의 높이(m), range 는
     * 이 거리(m) 안에서만 마커를 보이게 하는 값입니다.
     */
    function addRoadviewMarkers(payload) {
        const list = rvParse(payload) || [];
        rvForEachSafe(list, 'addRoadviewMarkers', function (m) {
            const existing = roadviewMarkerIndex.get(m.markerId);
            if (existing) {
                if (existing.__infoWindow) {
                    try { existing.__infoWindow.close(); } catch (e) {}
                    existing.__infoWindow = null;
                }
                existing.setMap(null);
                roadviewMarkerIndex.delete(m.markerId);
            }

            const position = new kakao.maps.LatLng(m.latLng.latitude, m.latLng.longitude);
            const marker = new kakao.maps.Marker({
                position: position,
                map: roadview
            });
            marker['id'] = m.markerId;

            const altitude = rvNv(m.altitude);
            if (altitude !== undefined && typeof marker.setAltitude === 'function') {
                marker.setAltitude(altitude);
            }
            const range = rvNv(m.range);
            if (range !== undefined && typeof marker.setRange === 'function') {
                marker.setRange(range);
            }

            roadviewMarkerIndex.set(m.markerId, marker);

            const content = rvNv(m.infoWindowContent);
            if (content !== undefined && content !== '') {
                const infoWindow = new kakao.maps.InfoWindow({ content: content });
                if (range !== undefined && typeof infoWindow.setRange === 'function') {
                    infoWindow.setRange(range);
                }
                marker.__infoWindow = infoWindow;
                if (m.infoWindowFirstShow !== false) {
                    infoWindow.open(roadview, marker);
                }
            }

            if ($hasMarkerTapCallback) {
                kakao.maps.event.addListener(marker, 'click', function () {
                    if (marker.__infoWindow) {
                        marker.__infoWindow.open(roadview, marker);
                    }
                    const p = marker.getPosition();
                    onRoadviewMarkerTap.postMessage(JSON.stringify({
                        markerId: marker.id,
                        latitude: p.getLat(),
                        longitude: p.getLng()
                    }));
                });
            }
        });
    }

    /** 로드뷰 위에 커스텀 오버레이를 추가합니다. */
    function addRoadviewCustomOverlays(payload) {
        const list = rvParse(payload) || [];
        rvForEachSafe(list, 'addRoadviewCustomOverlays', function (o) {
            const existing = roadviewOverlayIndex.get(o.customOverlayId);
            if (existing) {
                existing.setMap(null);
                roadviewOverlayIndex.delete(o.customOverlayId);
            }

            // 문자열 결합 대신 DOM API 로 구성해 ID 를 통한 인젝션을 막습니다.
            const el = document.createElement('div');
            el.id = o.customOverlayId;
            el.innerHTML = o.content;
            if ($hasCustomOverlayTapCallback) {
                el.addEventListener('click', function (e) {
                    e.stopPropagation();
                    onRoadviewCustomOverlayTap.postMessage(JSON.stringify({
                        customOverlayId: o.customOverlayId,
                        latitude: o.latLng.latitude,
                        longitude: o.latLng.longitude
                    }));
                });
            }

            const overlay = new kakao.maps.CustomOverlay({
                map: roadview,
                position: new kakao.maps.LatLng(o.latLng.latitude, o.latLng.longitude),
                content: el,
                xAnchor: rvNv(o.xAnchor),
                yAnchor: rvNv(o.yAnchor),
                zIndex: rvNv(o.zIndex)
            });
            overlay['id'] = o.customOverlayId;

            const altitude = rvNv(o.altitude);
            if (altitude !== undefined && typeof overlay.setAltitude === 'function') {
                overlay.setAltitude(altitude);
            }

            roadviewOverlayIndex.set(o.customOverlayId, overlay);
        });
    }

    /**
     * ids 에 포함된 마커만 남기고 나머지를 제거합니다.
     * ids 가 비어 있으면 전부 제거합니다.
     */
    function clearRoadviewMarker(ids) {
        let list = ids;
        try { list = rvParse(ids); } catch (e) { /* JSON 이 아니면 원문을 id 로 취급 */ }
        if (typeof list === 'string') list = [list];
        const keep = new Set(Array.isArray(list) ? list : []);
        for (const [id, marker] of Array.from(roadviewMarkerIndex.entries())) {
            if (keep.has(id)) continue;
            if (marker.__infoWindow) {
                try { marker.__infoWindow.close(); } catch (e) {}
                marker.__infoWindow = null;
            }
            marker.setMap(null);
            roadviewMarkerIndex.delete(id);
        }
    }

    /** ids 에 포함된 커스텀 오버레이만 남기고 나머지를 제거합니다. */
    function clearRoadviewCustomOverlay(ids) {
        let list = ids;
        try { list = rvParse(ids); } catch (e) { /* JSON 이 아니면 원문을 id 로 취급 */ }
        if (typeof list === 'string') list = [list];
        const keep = new Set(Array.isArray(list) ? list : []);
        for (const [id, overlay] of Array.from(roadviewOverlayIndex.entries())) {
            if (keep.has(id)) continue;
            overlay.setMap(null);
            roadviewOverlayIndex.delete(id);
        }
    }

    /** 로드뷰 위의 모든 오버레이를 제거합니다. */
    function clearRoadview() {
        clearRoadviewMarker([]);
        clearRoadviewCustomOverlay([]);
    }
    ''';
  }
}
