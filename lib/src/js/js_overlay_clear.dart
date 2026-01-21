/// JavaScript 오버레이 제거 스크립트를 제공합니다.
class JsOverlayClear {
  /// 오버레이 제거 함수들의 스크립트를 반환합니다.
  static String getScript() {
    return '''
    function clearPolyline(ids) {
        if (empty(ids)) {
            ids = [];
        }

        polylines = polylines.filter(polyline => {
            if (!ids.includes(polyline.id)) {
                polyline.setMap(null);
                return false;
            }
            return true;
        });
    }

    function clearCircle(ids) {
        if (empty(ids)) {
            ids = [];
        }

        circles = circles.filter(circle => {
            if (!ids.includes(circle.id)) {
                circle.setMap(null);
                return false;
            }
            return true;
        });
    }

    function clearRectangle(ids) {
        if (empty(ids)) {
            ids = [];
        }

        rectangles = rectangles.filter(rectangle => {
            if (!ids.includes(rectangle.id)) {
                rectangle.setMap(null);
                return false;
            }
            return true;
        });

        for (let i = 0; i < rectangles.length; i++) {
            rectangles[i].setMap(null);
        }

        rectangles = [];
    }

    function clearPolygon(ids) {
        if (empty(ids)) {
            ids = [];
        }

        polygons = polygons.filter(polygon => {
            if (!ids.includes(polygon.id)) {
                polygon.setMap(null);
                return false;
            }
            return true;
        });
    }

    function clearMarker(ids) {
        if (empty(ids)) {
            ids = [];
        }

        markers = markers.filter(marker => {
            if (!ids.includes(marker.id)) {
                marker.setMap(null);
                return false;
            }
            return true;
        });
    }

    function clearMarkerClusterer() {
        if (!clusterer) return;

        clusterer.clear();

        // Clear clusterer custom overlays
        clustererCustomOverlays.forEach(function(overlay) {
            overlay.setMap(null);
        });
        clustererCustomOverlays = [];
    }

    function clearCustomOverlay(ids) {
        if (empty(ids)) {
            ids = [];
        }

        customOverlays = customOverlays.filter(overlay => {
            if (!ids.includes(overlay.id)) {
                overlay.setMap(null);
                return false;
            }
            return true;
        });
    }

    function clear() {
        clearPolyline();
        clearCircle();
        clearRectangle();
        clearPolygon();
        clearMarker();
        clearCustomOverlay();
    }

    function dispose() {
        clear();
        map = null;
    }
    ''';
  }
}
