/// JavaScript 마커 관련 스크립트를 제공합니다.
class JsMarker {
  /// 마커 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasMarkerDragCallback,
    required bool hasMarkerTapCallback,
  }) {
    return '''
    function addMarker(markerId, latLng, draggable, width = 24, height = 30, offsetX = null, offsetY = null, imageSrc = '', infoWindowText = '', infoWindowRemovable = true, infoWindowFirstShow, zIndex, imageType) {
        // marker에 동일한 ID가 있는지 확인
        if (markers.some(existingMarker => existingMarker.id === markerId)) {
            return;
        }

        latLng = JSON.parse(latLng);
        let markerPosition = new kakao.maps.LatLng(latLng.latitude, latLng.longitude); // 마커가 표시될 위치입니다

        // 마커를 생성합니다
        let marker = new kakao.maps.Marker({
            position: markerPosition,
        });

        marker['id'] = markerId;

        marker.setDraggable(draggable);

        if (zIndex) {
            marker.setZIndex(zIndex);
        }

        // 마커가 지도 위에 표시되도록 설정합니다
        marker.setMap(map);

        if (imageSrc !== '' && imageSrc !== 'null') {
          if (imageType !== null && imageType === 'file') {
              // Convert base64 to Blob and create Object URL
              const byteCharacters = atob(imageSrc);
              const byteNumbers = Array.from(byteCharacters).map(char => char.charCodeAt(0));
              const byteArray = new Uint8Array(byteNumbers);
              const blob = new Blob([byteArray], { type: 'image/png' });
              imageSrc = URL.createObjectURL(blob);
          }

            let imageSize = new kakao.maps.Size(width, height); // 마커이미지의 크기입니다

            let offset;
            if (offsetX && offsetY) {
                offset = new kakao.maps.Point(offsetX, offsetY);
            }
            let imageOption = {offset: offset}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.

            let markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption);
            marker.setImage(markerImage);
        }

        markers.push(marker);

        let infoWindow = null
        if (infoWindowText !== '' && infoWindowText !== 'null') {

            // 인포윈도우를 생성하고 지도에 표시합니다
            infoWindow = new kakao.maps.InfoWindow({
                position: markerPosition,
                content: infoWindowText,
                removable: infoWindowRemovable
            });
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

    function setMarkerDraggable(markerId, draggable) {
        let marker = null;
        for (let i = 0; i < markers.length; i++) {
            if (markerId === markers[i].markerId) {
                marker = markers[i];
                break;
            }
        }

        if (marker != null) {
            marker.setDraggable(draggable);
        }
    }
    ''';
  }
}
