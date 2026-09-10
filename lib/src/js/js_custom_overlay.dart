/// JavaScript 커스텀 오버레이 관련 스크립트를 제공합니다.
class JsCustomOverlay {
  /// 커스텀 오버레이 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasCustomOverlayTapCallback,
    bool hasCustomOverlayRemoveCallback = false,
    bool hasCustomOverlayDragEndCallback = false,
  }) {
    return '''
    // Debounce tracking for iOS touch events to prevent duplicate triggers
    let lastOverlayTapTime = new Map();
    const OVERLAY_TAP_DEBOUNCE_MS = 300;

    function addCustomOverlay(customOverlayId, latLng, content, xAnchor, yAnchor, zIndex, hash, removable, draggable) {
        const existing = customOverlayIndex.get(customOverlayId);
        if (existing) {
            if (hash !== undefined && hash !== null && existing.__hash === hash) {
                return;
            }
            detachOverlay(existing);
            customOverlayIndex.delete(customOverlayId);
        }

        latLng = parseIfString(latLng);
        let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude);

        // DOM API 로 안전하게 요소를 구성합니다 (id 를 통한 HTML 인젝션 방지)
        const el = document.createElement('div');
        el.id = customOverlayId;

        if (removable) {
            // 닫기 버튼을 겹쳐 놓기 위해 본문을 감싸고 상대 위치를 지정합니다.
            el.style.position = 'relative';
            el.style.display = 'inline-block';
            const body = document.createElement('div');
            body.innerHTML = content;
            el.appendChild(body);
            el.appendChild(__buildCloseButton(customOverlayId));
        } else {
            el.innerHTML = content;
        }

        if ($hasCustomOverlayTapCallback) {
            // Use both click and touchend for better iOS compatibility
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

        if (draggable) {
            __attachOverlayDrag(el, customOverlay, customOverlayId);
        }
    }

    /** 커스텀 오버레이의 닫기 버튼을 만듭니다. */
    function __buildCloseButton(customOverlayId) {
        const btn = document.createElement('div');
        btn.textContent = '\u00D7';
        btn.style.cssText = 'position:absolute;top:-10px;right:-10px;'
            + 'width:22px;height:22px;line-height:20px;text-align:center;'
            + 'background:#fff;border:1px solid #999;border-radius:50%;'
            + 'cursor:pointer;font-size:15px;color:#333;'
            + 'box-shadow:0 1px 3px rgba(0,0,0,0.3);';
        const remove = function (e) {
            e.stopPropagation();
            e.preventDefault();
            const overlay = customOverlayIndex.get(customOverlayId);
            if (overlay) {
                detachOverlay(overlay);
                customOverlayIndex.delete(customOverlayId);
                syncOverlayArrays();
            }
            if ($hasCustomOverlayRemoveCallback) {
                onCustomOverlayRemove.postMessage(JSON.stringify({
                    customOverlayId: customOverlayId
                }));
            }
        };
        btn.addEventListener('click', remove);
        btn.addEventListener('touchend', remove);
        return btn;
    }

    /**
     * 커스텀 오버레이를 드래그로 옮길 수 있게 합니다.
     *
     * 드래그 중에는 지도 이동을 잠그고, 문서 레벨 리스너는 드래그가 끝나면
     * 곧바로 제거해 오버레이 수만큼 리스너가 쌓이지 않도록 합니다.
     */
    function __attachOverlayDrag(el, overlay, customOverlayId) {
        el.style.cursor = 'move';

        function containerPoint(e) {
            const t = (e.touches && e.touches.length) ? e.touches[0] : e;
            const rect = document.getElementById('map').getBoundingClientRect();
            return new kakao.maps.Point(t.clientX - rect.left, t.clientY - rect.top);
        }

        function onMove(e) {
            e.preventDefault();
            e.stopPropagation();
            const projection = map.getProjection();
            overlay.setPosition(projection.coordsFromContainerPoint(containerPoint(e)));
        }

        function onEnd(e) {
            document.removeEventListener('mousemove', onMove, true);
            document.removeEventListener('touchmove', onMove, true);
            document.removeEventListener('mouseup', onEnd, true);
            document.removeEventListener('touchend', onEnd, true);
            map.setDraggable(true);

            const position = overlay.getPosition();
            if ($hasCustomOverlayDragEndCallback) {
                onCustomOverlayDragEnd.postMessage(JSON.stringify({
                    customOverlayId: customOverlayId,
                    latitude: position.getLat(),
                    longitude: position.getLng()
                }));
            }
        }

        function onStart(e) {
            e.stopPropagation();
            map.setDraggable(false);
            document.addEventListener('mousemove', onMove, true);
            document.addEventListener('touchmove', onMove, { passive: false, capture: true });
            document.addEventListener('mouseup', onEnd, true);
            document.addEventListener('touchend', onEnd, true);
        }

        el.addEventListener('mousedown', onStart);
        el.addEventListener('touchstart', onStart, { passive: true });
    }

    /** 커스텀 오버레이 여러 개를 한 번의 브릿지 호출로 추가합니다. */
    function addCustomOverlays(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addCustomOverlays', function (o) {
            addCustomOverlay(o.customOverlayId, o.latLng, o.content, nv(o.xAnchor), nv(o.yAnchor), nv(o.zIndex), nv(o.hash), nv(o.removable), nv(o.draggable));
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
