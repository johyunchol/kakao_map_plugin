/// JavaScript 오버레이 그리기 스크립트를 제공합니다.
class JsOverlayDraw {
  /// 오버레이 그리기 함수들의 스크립트를 반환합니다.
  static String getScript() {
    return '''
    function addPolyline(polylineId, points, color, opacity, width, stroke, endArrow, zIndex) {
        // polyline에 동일한 ID가 있는지 확인
        if (polylines.some(existingPolyline => existingPolyline.id === polylineId)) {
            return;
        }

        let list = JSON.parse(points);
        let paths = [];
        for (let i = 0; i < list.length; i++) {
            paths.push(new kakao.maps.LatLng(list[i].latitude, list[i].longitude));
        }

        opacity = Number(opacity)
        width = Number(width)
        endArrow = endArrow === 'true'

        // 지도에 표시할 선을 생성합니다
        let polyline = new kakao.maps.Polyline({
            path: paths,
            strokeWeight: width,
            strokeColor: color,
            strokeOpacity: opacity,
            strokeStyle: stroke,
            endArrow: endArrow,
            zIndex: zIndex,
        });

        polylines.push(polyline);

        // 지도에 선을 표시합니다
        polyline.setMap(map);
    }

    function addCircle(circleId, center, radius, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // circle에 동일한 ID가 있는지 확인
        if (circles.some(existingCircle => existingCircle.id === circleId)) {
            return;
        }

        center = JSON.parse(center);

        // 지도에 표시할 원을 생성합니다
        let circle = new kakao.maps.Circle({
            center: new kakao.maps.LatLng(center.latitude, center.longitude),  // 원의 중심좌표 입니다
            radius: radius, // 미터 단위의 원의 반지름입니다
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: strokeColor, // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: strokeStyle, // 선의 스타일 입니다
            fillColor: fillColor, // 채우기 색깔입니다
            fillOpacity: fillOpacity,  // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        circles.push(circle);

        // 지도에 원을 표시합니다
        circle.setMap(map);
    }

    function addRectangle(rectangleId, rectangleBounds, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // rectangle에 동일한 ID가 있는지 확인
        if (rectangles.some(existingRectangle => existingRectangle.id === rectangleId)) {
            return;
        }

        rectangleBounds = JSON.parse(rectangleBounds);

        // 지도에 표시할 원을 생성합니다
        let rectangle = new kakao.maps.Rectangle({
            bounds: new kakao.maps.LatLngBounds(
                new kakao.maps.LatLng(rectangleBounds['sw'].latitude, rectangleBounds['sw'].longitude),
                new kakao.maps.LatLng(rectangleBounds['ne'].latitude, rectangleBounds['ne'].longitude)
            ),
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: strokeColor, // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            strokeStyle: strokeStyle, // 선의 스타일 입니다
            fillColor: fillColor, // 채우기 색깔입니다
            fillOpacity: fillOpacity, // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        rectangles.push(rectangle);

        // 지도에 원을 표시합니다
        rectangle.setMap(map);
    }

    function addPolygon(polygonId, points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // polygon에 동일한 ID가 있는지 확인
        if (polygons.some(existingPolygon => existingPolygon.id === polygonId)) {
            return;
        }

        points = JSON.parse(points);
        let paths = [];
        for (let i = 0; i < points.length; i++) {
            paths.push(new kakao.maps.LatLng(points[i].latitude, points[i].longitude));
        }

        holes = JSON.parse(holes);
        if (!empty(holes)) {
            let holePaths = [];

            for (let i = 0; i < holes.length; i++) {
                let array = [];
                for (let j = 0; j < holes[i].length; j++) {
                    array.push(new kakao.maps.LatLng(holes[i][j].latitude, holes[i][j].longitude));
                }
                holePaths.push(array);
            }

            return addPolygonWithHole(polygonId, paths, holePaths, strokeWeight, strokeColor, strokeOpacity, strokeStyle, fillColor, fillOpacity, zIndex);
        }

        return addPolygonWithoutHole(polygonId, paths, strokeWeight, strokeColor, strokeOpacity, strokeStyle, fillColor, fillOpacity, zIndex);
    }

    function addPolygonWithoutHole(polygonId, points, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
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

        polygons.push(polygon);

        // 지도에 다각형을 표시합니다
        polygon.setMap(map);
    }

    function addPolygonWithHole(polygonId, points, holes, strokeWeight, strokeColor, strokeOpacity = 1, strokeStyle = 'solid', fillColor = '#FFFFFF', fillOpacity = 0, zIndex) {
        // 다각형을 생성하고 지도에 표시합니다
        let polygon = new kakao.maps.Polygon({
            map: map,
            path: [points, ...holes], // 좌표 배열의 배열로 하나의 다각형을 표시할 수 있습니다
            strokeWeight: strokeWeight, // 선의 두께입니다
            strokeColor: strokeColor, // 선의 색깔입니다
            strokeOpacity: strokeOpacity, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
            fillColor: fillColor, // 채우기 색깔입니다
            fillOpacity: fillOpacity, // 채우기 불투명도 입니다
            zIndex: zIndex,
        });

        polygons.push(polygon);
    }
    ''';
  }
}
