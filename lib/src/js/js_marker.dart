/// JavaScript 마커 관련 스크립트를 제공합니다.
class JsMarker {
  /// 마커 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasMarkerDragCallback,
    required bool hasMarkerTapCallback,
    bool hasMarkerHoverCallback = false,
    String? defaultInfoWindowStyleJson,
  }) {
    final defaultStyle = defaultInfoWindowStyleJson ?? 'null';
    return '''
    // 지도 테마의 기본 인포윈도우 스타일. null 이면 SDK 기본 InfoWindow 를 씁니다.
    const __defaultInfoWindowStyle = $defaultStyle;

    function __resolveInfoWindowStyle(style) {
        const parsed = parseIfString(style);
        return parsed || __defaultInfoWindowStyle || null;
    }

    /** 지도 밖에 열리면 SDK InfoWindow 처럼 보이도록 살짝 이동합니다. */
    function __autoPanTo(targetMap, position) {
        try {
            if (!targetMap.getBounds().contain(position)) targetMap.panTo(position);
        } catch (e) { /* 지도 준비 전이면 무시 */ }
    }

    /**
     * 앱 스타일 인포윈도우. SDK InfoWindow 와 같은 open/close 인터페이스를 가진
     * CustomOverlay 래퍼라서 기존 마커 코드가 구분 없이 사용합니다.
     * anchorHeight 는 마커 아이콘의 높이(px)로, 말풍선을 그 위에 띄웁니다.
     */
    function __createStyledInfoWindow(position, contentHtml, removable, style, anchorHeight) {
        const bg = style.backgroundColor || '#ffffff';
        const arrow = style.showArrow === false ? 0 : (style.arrowSize || 8);
        const gap = style.gap === undefined ? 6 : style.gap;

        const wrap = document.createElement('div');
        wrap.style.cssText = 'position:relative;width:0;height:0;';

        const card = document.createElement('div');
        card.className = 'kmp-iw';
        card.style.cssText = 'position:absolute;left:0;bottom:' + (anchorHeight + gap + arrow) + 'px;'
            + 'transform:translateX(-50%);box-sizing:border-box;'
            + 'background:' + bg + ';color:' + (style.textColor || '#191919') + ';'
            + 'border-radius:' + (style.borderRadius || 0) + 'px;'
            + 'padding:' + (style.padding || '10px 14px') + ';'
            + 'font-size:' + (style.fontSize || 14) + 'px;line-height:1.4;'
            + (style.maxWidth ? 'max-width:' + style.maxWidth + 'px;white-space:normal;' : 'white-space:nowrap;')
            + (style.borderColor ? 'border:1px solid ' + style.borderColor + ';' : '')
            + (style.shadow === false ? '' : 'box-shadow:0 2px 8px rgba(0,0,0,.18);');
        if (removable) card.style.paddingRight = 'calc(' + (style.padding || '10px 14px').split(' ')[1] + ' + 22px)';

        const body = document.createElement('div');
        body.className = 'kmp-iw-body';
        body.innerHTML = contentHtml;
        card.appendChild(body);

        if (arrow > 0) {
            const tail = document.createElement('div');
            tail.className = 'kmp-iw-arrow';
            tail.style.cssText = 'position:absolute;left:50%;bottom:-' + arrow + 'px;margin-left:-' + arrow + 'px;'
                + 'width:0;height:0;border-left:' + arrow + 'px solid transparent;border-right:' + arrow + 'px solid transparent;'
                + 'border-top:' + arrow + 'px solid ' + (style.borderColor || bg) + ';';
            card.appendChild(tail);
            if (style.borderColor) {
                const inner = document.createElement('div');
                inner.style.cssText = 'position:absolute;left:50%;bottom:-' + (arrow - 1.5) + 'px;margin-left:-' + (arrow - 1) + 'px;'
                    + 'width:0;height:0;border-left:' + (arrow - 1) + 'px solid transparent;border-right:' + (arrow - 1) + 'px solid transparent;'
                    + 'border-top:' + (arrow - 1) + 'px solid ' + bg + ';';
                card.appendChild(inner);
            }
        }
        wrap.appendChild(card);

        const overlay = new kakao.maps.CustomOverlay({
            position: position, content: wrap, xAnchor: 0, yAnchor: 0, zIndex: 10, clickable: true
        });

        if (removable) {
            const btn = document.createElement('div');
            btn.className = 'kmp-iw-close';
            btn.textContent = '\u00D7';
            btn.style.cssText = 'position:absolute;top:4px;right:6px;width:22px;height:22px;line-height:22px;'
                + 'text-align:center;font-size:18px;cursor:pointer;opacity:.6;color:' + (style.textColor || '#191919') + ';';
            const close = function (e) { e.stopPropagation(); e.preventDefault(); overlay.setMap(null); };
            btn.addEventListener('click', close);
            btn.addEventListener('touchend', close);
            card.appendChild(btn);
        }

        return {
            open: function (targetMap, marker) {
                const pos = marker ? marker.getPosition() : position;
                overlay.setPosition(pos);
                overlay.setMap(targetMap);
                __autoPanTo(targetMap, pos);
            },
            close: function () { overlay.setMap(null); },
            getMap: function () { return overlay.getMap(); }
        };
    }

    /**
     * 마커를 추가합니다.
     * 동일한 ID의 마커가 이미 있고 hash 가 같으면 아무 것도 하지 않습니다.
     * hash 가 다르거나(또는 hash 가 없으면) 기존 마커를 제거하고 새로 만듭니다.
     * latLng 는 JSON 문자열 또는 {latitude, longitude} 객체 모두 허용합니다.
     */
    function addMarker(markerId, latLng, draggable, width = 24, height = 30, offsetX = null, offsetY = null, imageSrc = '', infoWindowText = '', infoWindowRemovable = true, infoWindowFirstShow, zIndex, imageType, hash, infoWindowStyle, extra) {
        const existing = markerIndex.get(markerId);
        if (existing) {
            if (hash !== undefined && hash !== null && existing.__hash === hash) {
                return;
            }
            if (clusterer && clustererMarkerIds.has(markerId)) {
                try { clusterer.removeMarker(existing); } catch (e) {}
            }
            detachOverlay(existing);
            markerIndex.delete(markerId);
            clustererMarkerIds.delete(markerId);
        }

        latLng = parseIfString(latLng);
        let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다

        // 마커를 생성합니다
        let marker = new kakao.maps.Marker({
            position: markerPosition,
        });

        marker['id'] = markerId;
        marker.__hash = hash;

        marker.setDraggable(draggable === true || draggable === 'true');

        // 추가 옵션: opacity / visible / clickable / title
        const opts = parseIfString(extra) || {};
        if (opts.opacity !== undefined && opts.opacity !== null) marker.setOpacity(Number(opts.opacity));
        if (opts.clickable !== undefined && opts.clickable !== null) marker.setClickable(!!opts.clickable);
        if (opts.title) marker.setTitle(String(opts.title));

        if (zIndex) {
            marker.setZIndex(zIndex);
        }

        // 마커가 지도 위에 표시되도록 설정합니다 (visible: false 면 만들어만 둡니다)
        marker.setMap(map);
        if (opts.visible === false) marker.setVisible(false);

        if (!empty(imageSrc)) {
            const markerImage = getMarkerImage(imageSrc, imageType, width, height, offsetX, offsetY, opts.spriteOrigin, opts.spriteSize);
            if (markerImage) {
                marker.setImage(markerImage);
            }
        }

        markerIndex.set(markerId, marker);
        syncOverlayArrays();

        let infoWindow = null
        if (!empty(infoWindowText)) {
            const iwStyle = __resolveInfoWindowStyle(infoWindowStyle);
            if (iwStyle) {
                // 앱 스타일: 마커 아이콘 높이(커스텀 이미지는 anchor 기준, 기본 마커는 SDK 이미지 높이) 위에 띄웁니다.
                const anchorHeight = !empty(imageSrc)
                    ? ((offsetY !== null && offsetY !== undefined) ? Number(offsetY) : Number(height))
                    : 36;
                infoWindow = __createStyledInfoWindow(markerPosition, infoWindowText, infoWindowRemovable, iwStyle, anchorHeight);
            } else {
                // SDK 기본 인포윈도우
                infoWindow = new kakao.maps.InfoWindow({
                    position: markerPosition,
                    content: infoWindowText,
                    removable: infoWindowRemovable
                });
            }
            marker.__infoWindow = infoWindow;
        }

        if (infoWindowFirstShow) {
            if (infoWindow != null) {
                infoWindow.open(map, marker);
            }
        }

        if (draggable && $hasMarkerDragCallback) {

            kakao.maps.event.addListener(marker, 'dragstart', function () {
                let latLng = marker.getPosition();

                const resultLatLng = {
                    markerId: marker.id,
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                    drag: 'dragstart'
                }

                onMarkerDragChangeCallback.postMessage(JSON.stringify(resultLatLng));
            })

            kakao.maps.event.addListener(marker, 'dragend', function () {
                let latLng = marker.getPosition();

                const resultLatLng = {
                    markerId: marker.id,
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                    drag: 'dragend'
                }

                onMarkerDragChangeCallback.postMessage(JSON.stringify(resultLatLng));
            })
        }

        if ($hasMarkerHoverCallback) {
            // 마우스 환경 전용. 터치 기기에서는 발생하지 않습니다.
            const hoverPayload = function () {
                const pos = marker.getPosition();
                return JSON.stringify({ markerId: marker.id, latitude: pos.getLat(), longitude: pos.getLng(), zoomLevel: map.getLevel() });
            };
            kakao.maps.event.addListener(marker, 'mouseover', function () { onMarkerMouseOver.postMessage(hoverPayload()); });
            kakao.maps.event.addListener(marker, 'mouseout', function () { onMarkerMouseOut.postMessage(hoverPayload()); });
        }

        if ($hasMarkerTapCallback) {
            kakao.maps.event.addListener(marker, 'click', function () {
                if (infoWindow != null) {
                    infoWindow.open(map, marker);
                }

                // 클릭한 위도, 경도 정보를 가져옵니다
                let latLng = marker.getPosition();

                const clickLatLng = {
                    markerId: marker.id,
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                onMarkerTap.postMessage(JSON.stringify(clickLatLng));

            });
        }
    }

    /**
     * 마커 여러 개를 한 번의 브릿지 호출로 추가합니다.
     * payload: JSON 문자열 또는 배열. 각 항목은 Dart 쪽 OverlayPayload.marker() 형태입니다.
     */
    function addMarkers(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addMarkers', function (m) {
            addMarker(
                m.markerId,
                m.latLng,
                nv(m.draggable),
                nv(m.width),
                nv(m.height),
                nv(m.offsetX),
                nv(m.offsetY),
                nv(m.imageSrc),
                nv(m.infoWindowContent),
                nv(m.infoWindowRemovable),
                nv(m.infoWindowFirstShow),
                nv(m.zIndex),
                nv(m.imageType),
                nv(m.hash),
                nv(m.infoWindowStyle),
                m.extra,
            );
        });
    }

    /** 마커 위치만 옮깁니다. 열려 있는 인포윈도우도 함께 따라갑니다. */
    function setMarkerPosition(markerId, latitude, longitude) {
        const marker = markerIndex.get(markerId);
        if (!marker) return;
        const position = new kakao.maps.LatLng(latitude, longitude);
        marker.setPosition(position);
        const iw = marker.__infoWindow;
        if (iw && iw.getMap && iw.getMap()) {
            if (typeof iw.setPosition === 'function') iw.setPosition(position);
            else iw.open(map, marker);
        }
    }

    function setMarkerVisible(markerId, visible) {
        const marker = markerIndex.get(markerId);
        if (marker) marker.setVisible(!!visible);
    }

    /** 마커의 인포윈도우를 엽니다. 인포윈도우 내용이 없는 마커면 아무 일도 하지 않습니다. */
    function showInfoWindow(markerId) {
        const marker = markerIndex.get(markerId);
        if (marker && marker.__infoWindow) marker.__infoWindow.open(map, marker);
    }

    function hideInfoWindow(markerId) {
        const marker = markerIndex.get(markerId);
        if (marker && marker.__infoWindow) marker.__infoWindow.close();
    }

    function setMarkerDraggable(markerId, draggable) {
        const marker = markerIndex.get(markerId);
        if (marker) {
            marker.setDraggable(draggable);
        }
    }
    ''';
  }
}
