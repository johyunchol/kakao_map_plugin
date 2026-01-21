/// JavaScript 클러스터러 관련 스크립트를 제공합니다.
class JsClusterer {
  /// 클러스터러 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasCustomOverlayTapCallback,
    required bool hasMarkerClustererTapCallback,
  }) {
    return '''
    function addMarkerClusterer(markerList, gridSize = 60, averageCenter = true, disableClickZoom = true, minLevel = 10, minClusterSize = 2, texts, calculator, styles) {
        markerList = JSON.parse(markerList);

        // Clear existing clusterer custom overlays
        clustererCustomOverlays.forEach(function(overlay) {
            overlay.setMap(null);
        });
        clustererCustomOverlays = [];

        markerList.map(function (marker) {
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
                JSON.stringify(marker.latLng),
                marker?.draggable,
                marker?.width,
                marker?.height,
                marker?.offsetX,
                marker?.offsetY,
                imageSrc,
                marker?.infoWindowContent,
                marker?.infoWindowRemovable,
                marker?.infoWindowFirstShow,
                marker?.zIndex,
                imageType,
            )

            // If marker has custom overlay content, create and store it
            if (marker.customOverlayContent && marker.customOverlayContent !== 'null' && marker.customOverlayContent !== '') {
                let position = new kakao.maps.LatLng(marker.latLng.latitude, marker.latLng.longitude);

                let content = '<div id="clusterer_overlay_' + marker.markerId + '">' + marker.customOverlayContent + '</div>';
                if ($hasCustomOverlayTapCallback) {
                    content =
                        '<div id="clusterer_overlay_' + marker.markerId +
                        '" onclick="addCustomOverlayListener(\`clusterer_overlay_' + marker.markerId +
                        '\`, \`' + marker.latLng.latitude +
                        '\`, \`' + marker.latLng.longitude +
                        '\`)">' + marker.customOverlayContent + '</div>';
                }

                let customOverlay = new kakao.maps.CustomOverlay({
                    content: content,
                    position: position,
                    xAnchor: marker.customOverlayXAnchor || 0.5,
                    yAnchor: marker.customOverlayYAnchor || 1.0,
                    zIndex: marker.zIndex || 0,
                });

                customOverlay['markerId'] = marker.markerId;
                clustererCustomOverlays.push(customOverlay);
            }
        })

        clusterer = new kakao.maps.MarkerClusterer({
            map: map,
            gridSize: gridSize,
            averageCenter: averageCenter,
            minLevel: minLevel,
            disableClickZoom: true,
        });

        clusterer.setMinClusterSize(minClusterSize);

        texts = JSON.parse(texts)
        if (texts) {
            clusterer.setTexts(texts)
        }

        calculator = JSON.parse(calculator)
        if (calculator) {
            clusterer.setCalculator(calculator)
        }

        styles = JSON.parse(styles)
        if (styles) {
            styles = styles.map(function (style) {
                return {...style, background: hexToRgba(style.background), color: hexToRgba(style.color)}
            })

            clusterer.setStyles(styles)
        }

        clusterer.addMarkers(markers);

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

            // Find the corresponding marker
            let correspondingMarker = markers.find(m => m.id === markerId);

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

    function getMarkerClustererStyles(styles) {
        styles = JSON.parse(styles)

        styles = styles?.map(function (style) {
            return removeUndefinedValue(style)
        })

        return styles
    }

    function removeUndefinedValue(obj) {
        const newObj = {}; // 빈객체를 만들어놓고

        Object.keys(obj).forEach(key => {
            if (obj[key]) {
                newObj[key] = obj[key]
            }
        });

        return newObj;
    }
    ''';
  }
}
