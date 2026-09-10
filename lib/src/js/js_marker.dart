/// JavaScript 마커 관련 스크립트를 제공합니다.
class JsMarker {
  /// 마커 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasMarkerDragCallback,
    required bool hasMarkerTapCallback,
  }) {
    return '''
    /**
     * 마커를 추가합니다.
     * 동일한 ID의 마커가 이미 있고 hash 가 같으면 아무 것도 하지 않습니다.
     * hash 가 다르거나(또는 hash 가 없으면) 기존 마커를 제거하고 새로 만듭니다.
     * latLng 는 JSON 문자열 또는 {latitude, longitude} 객체 모두 허용합니다.
     */
    function addMarker(markerId, latLng, draggable, width = 24, height = 30, offsetX = null, offsetY = null, imageSrc = '', infoWindowText = '', infoWindowRemovable = true, infoWindowFirstShow, zIndex, imageType, hash) {
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

        if (zIndex) {
            marker.setZIndex(zIndex);
        }

        // 마커가 지도 위에 표시되도록 설정합니다
        marker.setMap(map);

        if (!empty(imageSrc)) {
            const markerImage = getMarkerImage(imageSrc, imageType, width, height, offsetX, offsetY);
            if (markerImage) {
                marker.setImage(markerImage);
            }
        }

        markerIndex.set(markerId, marker);
        syncOverlayArrays();

        let infoWindow = null
        if (!empty(infoWindowText)) {
            // 인포윈도우를 생성하고 지도에 표시합니다
            infoWindow = new kakao.maps.InfoWindow({
                position: markerPosition,
                content: infoWindowText,
                removable: infoWindowRemovable
            });
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
            );
        });
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
