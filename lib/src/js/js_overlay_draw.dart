/// JavaScript 오버레이 그리기 스크립트를 제공합니다.
class JsOverlayDraw {
  /// 오버레이 그리기 함수들의 스크립트를 반환합니다.
  ///
  /// [hasPolygonTapCallback] 이 false 면 다각형 탭 리스너를 등록하지 않아
  /// 불필요한 브릿지 메시지가 발생하지 않습니다.
  static String getScript({
    bool hasPolygonTapCallback = false,
    bool hasPolylineTapCallback = false,
    bool hasCircleTapCallback = false,
    bool hasRectangleTapCallback = false,
    bool hasPolygonHoverCallback = false,
  }) {
    return '''
    /** 다각형 hover(mouseover / mousemove / mouseout)를 채널로 보냅니다. mousemove 는 프레임당 1회로 제한합니다. */
    function __attachPolygonHover(polygon) {
        const post = function (channel, mouseEvent) {
            const latLng = mouseEvent.latLng;
            channel.postMessage(JSON.stringify({
                polygonId: polygon.id, latitude: latLng.getLat(), longitude: latLng.getLng(), zoomLevel: map.getLevel()
            }));
        };
        kakao.maps.event.addListener(polygon, 'mouseover', function (e) { post(onPolygonMouseOver, e); });
        kakao.maps.event.addListener(polygon, 'mouseout', function (e) { post(onPolygonMouseOut, e); });
        let pending = null;
        kakao.maps.event.addListener(polygon, 'mousemove', function (e) {
            pending = e;
            if (pending.__scheduled) return;
            pending.__scheduled = true;
            requestAnimationFrame(function () {
                const ev = pending; pending = null;
                if (ev) post(onPolygonMouseMove, ev);
            });
        });
    }

    /** 도형 탭 이벤트를 채널로 보냅니다. idKey 는 payload 의 ID 필드 이름입니다. */
    function __attachShapeTap(shape, channel, idKey) {
        kakao.maps.event.addListener(shape, 'click', function (mouseEvent) {
            const latLng = mouseEvent.latLng;
            const payload = { latitude: latLng.getLat(), longitude: latLng.getLng(), zoomLevel: map.getLevel() };
            payload[idKey] = shape.id;
            channel.postMessage(JSON.stringify(payload));
        });
    }

    /**
     * 동일 ID 오버레이가 있을 때 재사용 여부를 결정합니다.
     * hash 가 같으면 true(건너뜀), 다르거나 없으면 기존 것을 제거하고 false 를 반환합니다.
     */
    function __reuseOrRemove(index, id, hash) {
        const existing = index.get(id);
        if (!existing) return false;
        if (hash !== undefined && hash !== null && existing.__hash === hash) return true;
        detachOverlay(existing);
        index.delete(id);
        return false;
    }

    function __toLatLngPath(points) {
        const list = parseIfString(points) || [];
        const paths = [];
        for (let i = 0; i < list.length; i++) {
            paths.push(new kakao.maps.LatLng(list[i].latitude, list[i].longitude));
        }
        return paths;
    }

    function addPolyline(polylineId, points, color, opacity = 1, width = 8, stroke = 'solid', endArrow = false, zIndex, hash) {
        if (__reuseOrRemove(polylineIndex, polylineId, hash)) return;

        const paths = __toLatLngPath(points);

        opacity = Number(opacity)
        width = Number(width)
        endArrow = endArrow === true || endArrow === 'true'

        // 지도에 표시할 선을 생성합니다
        let polyline = new kakao.maps.Polyline({
            path: paths,
            strokeWeight: width,
            strokeColor: nv(color),
            strokeOpacity: opacity,
            strokeStyle: nv(stroke),
            endArrow: endArrow,
            zIndex: zIndex,
        });

        polyline['id'] = polylineId;
        if ($hasPolylineTapCallback) __attachShapeTap(polyline, onPolylineTap, 'polylineId');
        polyline.__hash = hash;
        polylineIndex.set(polylineId, polyline);
        syncOverlayArrays();

        // 지도에 선을 표시합니다
        polyline.setMap(map);
    }

    function addPolylines(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addPolylines', function (p) {
            addPolyline(p.polylineId, p.points, nv(p.strokeColor), nv(p.strokeOpacity), nv(p.strokeWidth), nv(p.strokeStyle), nv(p.endArrow), nv(p.zIndex), nv(p.hash));
        });
    }

    function addCircle(circleId, center, radius, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex, hash) {
        if (__reuseOrRemove(circleIndex, circleId, hash)) return;

        center = parseIfString(center);

        // 지도에 표시할 원을 생성합니다
        let circle = new kakao.maps.Circle({
            center: new kakao.maps.LatLng(center.latitude, center.longitude),  // 원의 중심좌표 입니다
            radius: radius, // 미터 단위의 원의 반지름입니다
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: nv(strokeColor), // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: nv(strokeStyle), // 선의 스타일 입니다
            fillColor: nv(fillColor), // 채우기 색깔입니다
            fillOpacity: fillOpacity,  // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        circle['id'] = circleId;
        if ($hasCircleTapCallback) __attachShapeTap(circle, onCircleTap, 'circleId');
        circle.__hash = hash;
        circleIndex.set(circleId, circle);
        syncOverlayArrays();

        // 지도에 원을 표시합니다
        circle.setMap(map);
    }

    function addCircles(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addCircles', function (c) {
            addCircle(c.circleId, c.center, nv(c.radius), nv(c.strokeWidth), nv(c.strokeColor), nv(c.strokeOpacity), nv(c.strokeStyle), nv(c.fillColor), nv(c.fillOpacity), nv(c.zIndex), nv(c.hash));
        });
    }

    function addRectangle(rectangleId, rectangleBounds, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex, hash) {
        if (__reuseOrRemove(rectangleIndex, rectangleId, hash)) return;

        rectangleBounds = parseIfString(rectangleBounds);

        // 지도에 표시할 사각형을 생성합니다
        let rectangle = new kakao.maps.Rectangle({
            bounds: new kakao.maps.LatLngBounds(
                new kakao.maps.LatLng(rectangleBounds['sw'].latitude, rectangleBounds['sw'].longitude),
                new kakao.maps.LatLng(rectangleBounds['ne'].latitude, rectangleBounds['ne'].longitude)
            ),
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: nv(strokeColor), // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: nv(strokeStyle), // 선의 스타일 입니다
            fillColor: nv(fillColor), // 채우기 색깔입니다
            fillOpacity: fillOpacity, // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        rectangle['id'] = rectangleId;
        if ($hasRectangleTapCallback) __attachShapeTap(rectangle, onRectangleTap, 'rectangleId');
        rectangle.__hash = hash;
        rectangleIndex.set(rectangleId, rectangle);
        syncOverlayArrays();

        // 지도에 사각형을 표시합니다
        rectangle.setMap(map);
    }

    function addRectangles(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addRectangles', function (r) {
            addRectangle(r.rectangleId, r.bounds, nv(r.strokeWidth), nv(r.strokeColor), nv(r.strokeOpacity), nv(r.strokeStyle), nv(r.fillColor), nv(r.fillOpacity), nv(r.zIndex), nv(r.hash));
        });
    }

    function addPolygon(polygonId, points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex, hash) {
        if (__reuseOrRemove(polygonIndex, polygonId, hash)) return;

        const paths = __toLatLngPath(points);

        holes = parseIfString(holes);
        let polygon;
        if (!empty(holes)) {
            let holePaths = [];

            for (let i = 0; i < holes.length; i++) {
                let array = [];
                for (let j = 0; j < holes[i].length; j++) {
                    array.push(new kakao.maps.LatLng(holes[i][j].latitude, holes[i][j].longitude));
                }
                holePaths.push(array);
            }

            polygon = addPolygonWithHole(paths, holePaths, strokeWeight, nv(strokeColor), strokeOpacity, nv(strokeStyle), nv(fillColor), fillOpacity, zIndex);
        } else {
            polygon = addPolygonWithoutHole(paths, strokeWeight, nv(strokeColor), strokeOpacity, nv(strokeStyle), nv(fillColor), fillOpacity, zIndex);
        }

        polygon['id'] = polygonId;
        polygon.__hash = hash;
        polygonIndex.set(polygonId, polygon);
        syncOverlayArrays();

        if ($hasPolygonHoverCallback) __attachPolygonHover(polygon);

        if ($hasPolygonTapCallback) {
            kakao.maps.event.addListener(polygon, 'click', function (mouseEvent) {
                const latLng = mouseEvent.latLng;
                onPolygonTap.postMessage(JSON.stringify({
                    polygonId: polygon.id,
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel()
                }));
            });
        }
    }

    function addPolygons(payload) {
        const list = parseIfString(payload);
        forEachSafe(list, 'addPolygons', function (p) {
            addPolygon(p.polygonId, p.points, p.holes, nv(p.strokeWidth), nv(p.strokeColor), nv(p.strokeOpacity), nv(p.strokeStyle), nv(p.fillColor), nv(p.fillOpacity), nv(p.zIndex), nv(p.hash));
        });
    }

    function addPolygonWithoutHole(points, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // 지도에 표시할 다각형을 생성합니다
        let polygon = new kakao.maps.Polygon({
            path: points, // 그려질 다각형의 좌표 배열입니다
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: strokeColor, // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: strokeStyle, // 선의 스타일입니다
            fillColor: fillColor, // 채우기 색깔입니다
            fillOpacity: fillOpacity, // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        // 지도에 다각형을 표시합니다
        polygon.setMap(map);
        return polygon;
    }

    function addPolygonWithHole(points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // 다각형을 생성하고 지도에 표시합니다
        let polygon = new kakao.maps.Polygon({
            map: map,
            path: [points, ...holes], // 좌표 배열의 배열로 하나의 다각형을 표시할 수 있습니다
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: strokeColor, // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: strokeStyle, // 선의 스타일입니다
            fillColor: fillColor, // 채우기 색깔입니다
            fillOpacity: fillOpacity, // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        return polygon;
    }
    ''';
  }
}
