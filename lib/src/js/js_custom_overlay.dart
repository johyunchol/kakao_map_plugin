/// JavaScript 커스텀 오버레이 관련 스크립트를 제공합니다.
class JsCustomOverlay {
  /// 커스텀 오버레이 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasCustomOverlayTapCallback,
  }) {
    return '''
    // Debounce tracking for iOS touch events to prevent duplicate triggers
    let lastOverlayTapTime = {};
    const OVERLAY_TAP_DEBOUNCE_MS = 300;

    function addCustomOverlay(customOverlayId, latLng, content, xAnchor, yAnchor, zIndex) {
        // customOverlays에 동일한 ID가 있는지 확인
        if (customOverlays.some(existingOverlay => existingOverlay.id === customOverlayId)) {
            return;
        }

        latLng = JSON.parse(latLng);
        let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다

        content = '<div id="' + customOverlayId + '">' + content + '</div>'
        if ($hasCustomOverlayTapCallback) {
            // Use both onclick and ontouchend for better iOS compatibility
            // The custom-overlay-clickable class provides iOS-specific touch optimizations
            content =
                '<div id="' + customOverlayId +
                '" class="custom-overlay-clickable"' +
                ' onclick="handleOverlayTap(event, `' + customOverlayId +
                '`, `' + latLng.latitude +
                '`, `' + latLng.longitude +
                '`)"' +
                ' ontouchend="handleOverlayTap(event, `' + customOverlayId +
                '`, `' + latLng.latitude +
                '`, `' + latLng.longitude +
                '`)">' + content + '</div>';
        }

        let customOverlay = new kakao.maps.CustomOverlay({
            map: map,
            content: content,
            position: markerPosition,
            xAnchor: xAnchor,
            yAnchor: yAnchor,
            zIndex: zIndex,
        });

        customOverlay['id'] = customOverlayId;

        customOverlays.push(customOverlay);

        customOverlay.setMap(map);
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
        if (lastOverlayTapTime[customOverlayId] && (now - lastOverlayTapTime[customOverlayId]) < OVERLAY_TAP_DEBOUNCE_MS) {
            return;
        }
        lastOverlayTapTime[customOverlayId] = now;

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


    function showInfoWindow(marker, latitude, longitude, contents = '', infoWindowRemovable) {
        let iwPosition = new kakao.maps.LatLng(latitude, longitude);

        // 인포윈도우를 생성하고 지도에 표시합니다
        let infoWindow = new kakao.maps.InfoWindow({
            map: map, // 인포윈도우가 표시될 지도
            position: iwPosition,
            content: contents,
            removable: infoWindowRemovable
        });

        infoWindow.open(map, marker);
    }
    ''';
  }
}
