/// JavaScript 클러스터러 관련 스크립트를 제공합니다.
class JsClusterer {
  /// 클러스터러 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasCustomOverlayTapCallback,
    required bool hasMarkerClustererTapCallback,
  }) {
    return '''
    function addMarkerClusterer(markerList, gridSize = 60, averageCenter = true, disableClickZoom = true, minLevel = 10, minClusterSize = 2, texts, calculator, styles) {
        markerList = parseIfString(markerList) || [];

        // 이전 클러스터러와 그에 속한 마커/오버레이를 정리합니다
        clearMarkerClusterer();

        const ownMarkers = [];
        const seenIds = new Set();

        forEachSafe(markerList, 'addMarkerClusterer', function (marker) {
            // icon 객체에서 imageSrc와 imageType 추출, 없으면 markerImageSrc 사용
            let imageSrc = '';
            let imageType = null;
            if (marker?.icon && marker.icon.imageSrc) {
                imageSrc = marker.icon.imageSrc;
                imageType = marker.icon.imageType;
            } else if (marker?.markerImageSrc) {
                imageSrc = marker.markerImageSrc;
                imageType = 'url';
            }

            addMarker(
                marker.markerId,
                marker.latLng,
                nv(marker?.draggable),
                nv(marker?.width),
                nv(marker?.height),
                nv(marker?.offsetX),
                nv(marker?.offsetY),
                imageSrc,
                nv(marker?.infoWindowContent),
                nv(marker?.infoWindowRemovable),
                nv(marker?.infoWindowFirstShow),
                nv(marker?.zIndex),
                imageType,
            )

            const created = markerIndex.get(marker.markerId);
            if (created && !seenIds.has(marker.markerId)) {
                seenIds.add(marker.markerId);
                clustererMarkerIds.add(marker.markerId);
                ownMarkers.push(created);
            }

            // If marker has custom overlay content, create and store it
            if (!empty(marker.customOverlayContent)) {
                let position = new kakao.maps.LatLng(marker.latLng.latitude, marker.latLng.longitude);

                // DOM API 로 안전하게 요소를 구성합니다 (markerId 를 통한 HTML 인젝션 방지)
                const el = document.createElement('div');
                el.id = 'clusterer_overlay_' + marker.markerId;
                el.innerHTML = marker.customOverlayContent;
                if ($hasCustomOverlayTapCallback) {
                    el.addEventListener('click', function (e) { addCustomOverlayListener(el.id, marker.latLng.latitude, marker.latLng.longitude); });
                    el.addEventListener('touchend', function (e) { addCustomOverlayListener(el.id, marker.latLng.latitude, marker.latLng.longitude); });
                }

                let customOverlay = new kakao.maps.CustomOverlay({
                    content: el,
                    position: position,
                    xAnchor: marker.customOverlayXAnchor || 0.5,
                    yAnchor: marker.customOverlayYAnchor || 1.0,
                    zIndex: marker.zIndex || 0,
                });

                customOverlay['markerId'] = marker.markerId;
                clustererCustomOverlays.push(customOverlay);
            }
        });

        clusterer = new kakao.maps.MarkerClusterer({
            map: map,
            gridSize: gridSize,
            averageCenter: averageCenter,
            minLevel: minLevel,
            disableClickZoom: disableClickZoom,
        });

        clusterer.setMinClusterSize(minClusterSize);

        texts = parseIfString(texts)
        if (texts) {
            clusterer.setTexts(texts)
        }

        calculator = parseIfString(calculator)
        if (calculator) {
            clusterer.setCalculator(calculator)
        }

        styles = parseIfString(styles)
        if (styles) {
            styles = styles.map(function (style) {
                const converted = {...style};
                if (style.background) converted.background = hexToRgba(style.background);
                else delete converted.background;
                if (style.color) converted.color = hexToRgba(style.color);
                else delete converted.color;
                return converted;
            })

            clusterer.setStyles(styles)
        }

        // 클러스터러에는 이 클러스터러가 만든 마커만 등록합니다 (일반 마커는 제외)
        clusterer.addMarkers(ownMarkers);

        // Update custom overlay visibility based on clusterer state
        updateClustererCustomOverlays();

        // Add event listener for clustered event to update custom overlays
        kakao.maps.event.addListener(clusterer, 'clustered', function() {
            updateClustererCustomOverlays();
        });


        if ($hasMarkerClustererTapCallback) {
            kakao.maps.event.addListener(clusterer, 'clusterclick', function (cluster) {
                let markerIdList = [];
                cluster.getMarkers().map(function (marker) {
                    markerIdList.push(marker.id);
                })

                // 클릭한 위도, 경도 정보를 가져옵니다
                let latLng = cluster.getCenter();

                const clickLatLng = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                    markers: markerIdList,
                }

                onMarkerClustererTap.postMessage(JSON.stringify(clickLatLng))
            });
        }
    }

    function updateClustererCustomOverlays() {
        if (!clusterer || clustererCustomOverlays.length === 0) return;

        // Get all clusters
        let clusters = clusterer._clusters || [];
        let clusteredMarkerIds = new Set();

        // Collect marker IDs that are in clusters (more than 1 marker)
        clusters.forEach(function(cluster) {
            let clusterMarkers = cluster.getMarkers();
            if (clusterMarkers.length > 1) {
                clusterMarkers.forEach(function(marker) {
                    clusteredMarkerIds.add(marker.id);
                });
            }
        });

        // Show/hide custom overlays based on whether their marker is clustered
        clustererCustomOverlays.forEach(function(overlay) {
            let markerId = overlay.markerId;

            // Find the corresponding marker (O(1))
            let correspondingMarker = markerIndex.get(markerId);

            if (clusteredMarkerIds.has(markerId)) {
                // Marker is in a cluster, hide custom overlay and show default marker (which will be hidden by cluster)
                overlay.setMap(null);
                if (correspondingMarker) {
                    correspondingMarker.setVisible(true);
                }
            } else {
                // Marker is not clustered, show custom overlay and hide default marker
                overlay.setMap(map);
                if (correspondingMarker) {
                    correspondingMarker.setVisible(false);
                }
            }
        });
    }
    ''';
  }
}
