/// JavaScript 커스텀 오버레이 관련 스크립트를 제공합니다.
class JsCustomOverlay {
  /// 커스텀 오버레이 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasCustomOverlayTapCallback,
  }) {
    return '''
    // Debounce tracking for iOS touch events to prevent duplicate triggers
    let lastOverlayTapTime = new Map();
    const OVERLAY_TAP_DEBOUNCE_MS = 300;

    function addCustomOverlay(customOverlayId, latLng, content, xAnchor, yAnchor, zIndex, hash) {
        const existing = customOverlayIndex.get(customOverlayId);
        if (existing) {
            if (hash !== undefined && hash !== null && existing.__hash === hash) {
                return;
            }
            detachOverlay(existing);
            customOverlayIndex.delete(customOverlayId);
        }

        latLng = parseIfString(latLng);
        let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다

        // DOM API 로 안전하게 요소를 구성합니다 (id 를 통한 HTML 인젝션 방지)
        const el = document.createElement('div');
        el.id = customOverlayId;
        el.innerHTML = content;
        if ($hasCustomOverlayTapCallback) {
            // Use both click and touchend for better iOS compatibility
            // The custom-overlay-clickable class provides iOS-specific touch optimizations
            el.className = 'custom-overlay-clickable';
            el.addEventListener('click', function (e) { handleOverlayTap(e, customOverlayId, latLng.latitude, latLng.longitude); });
            el.addEventListener('touchend', function (e) { handleOverlayTap(e, customOverlayId, latLng.latitude, latLng.longitude); });
        }

        let customOverlay = new kakao.maps.CustomOverlay({
            map: map,
            content: el,
            position: markerPosition,
            xAnchor: xAnchor,
            yAnchor: yAnchor,
            zIndex: zIndex,
        });

        customOverlay['id'] = customOverlayId;
        customOverlay.__hash = hash;

        customOverlayIndex.set(customOverlayId, customOverlay);
        syncOverlayArrays();
    }

    /** 커스텀 오버레이 여러 개를 한 번의 브릿지 호출로 추가합니다. */
    function addCustomOverlays(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addCustomOverlays', function (o) {
            addCustomOverlay(o.customOverlayId, o.latLng, o.content, nv(o.xAnchor), nv(o.yAnchor), nv(o.zIndex), nv(o.hash));
        });
    }

    // Unified tap handler that works for both click and touch events
    function handleOverlayTap(event, customOverlayId, latitude, longitude) {
        // Prevent event bubbling to avoid triggering map click
        if (event) {
            event.stopPropagation();
            // Prevent default to avoid any iOS-specific issues
            if (event.type === 'touchend') {
                event.preventDefault();
            }
        }

        // Debounce to prevent duplicate events (iOS may fire both touchend and click)
        const now = Date.now();
        const lastTap = lastOverlayTapTime.get(customOverlayId);
        if (lastTap && (now - lastTap) < OVERLAY_TAP_DEBOUNCE_MS) {
            return;
        }
        lastOverlayTapTime.set(customOverlayId, now);

        addCustomOverlayListener(customOverlayId, latitude, longitude);
    }

    function addCustomOverlayListener(customOverlayId, latitude, longitude) {
        // 클릭한 위도, 경도 정보를 가져옵니다
        let latLng = new kakao.maps.LatLng(latitude, longitude); // 마커가 표시될 위치입니다

        const clickLatLng = {
            customOverlayId: customOverlayId,
            latitude: latLng.getLat(),
            longitude: latLng.getLng(),
        }

        onCustomOverlayTap.postMessage(JSON.stringify(clickLatLng));
    }
    ''';
  }
}
