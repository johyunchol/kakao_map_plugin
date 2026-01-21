/// JavaScript 지도 제어 스크립트를 제공합니다.
class JsMapControl {
  /// 지도 제어 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool isIOS,
  }) {
    return '''
    /**
     * 지도의 중심 좌표를 설정한다.
     * @param latitude Number
     * @param longitude Number
     */
    function setCenter(latitude, longitude) {
        map.setCenter(new kakao.maps.LatLng(latitude, longitude));
    }

    /**
     * 지도의 중심 좌표를 반환한다.
     */
    function getCenter() {
        const center = map.getCenter();

        let result = {
            latitude: center.getLat(),
            longitude: center.getLng(),
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }

    /**
     * 지도의 확대 수준을 설정한다.
     * MapTypeId 의 종류에 따라 설정 범위가 다르다.
     * SKYVIEW, HYBRID 일 경우 0 ~ 14, ROADMAP 일 경우 1 ~ 14.
     * @param level
     * @param options
     */
    function setLevel(level, options) {
        if (!options) {
            return map.setLevel(level);
        }

        let levelOption = {}

        options = JSON.parse(options);

        if (options?.animate) {
            levelOption['animate'] = options.animate;
        }

        if (options?.anchor) {
            levelOption['anchor'] = new kakao.maps.LatLng(options?.anchor?.latitude, options?.anchor?.longitude);
        }

        map.setLevel(level, levelOption);
    }

    /**
     * 지도의 확대 수준을 반환한다.
     */
    function getLevel() {
        let result = {
            level: map.getLevel()
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }

    /**
     * 지도의 타입을 설정한다.
     * 베이스타입 : ROADMAP, SKYVIEW, HYBRID
     */
    function setMapTypeId(mapTypeId) {
        map.setMapTypeId(mapTypeId);
    }

    function getMapTypeId() {
        let result = {
            mapTypeId: map.getMapTypeId()
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }

    /**
     * 지도에 로드뷰, 교통정보 등의 오버레이 타입의 타일 이미지를 올린다.
     * 로드뷰 타일 이미지를 추가할 경우 RoadviewOverlay 와 동일한 기능을 수행한다.
     * 오버레이타입: OVERLAY, TERRAIN, TRAFFIC, BICYCLE, bicycleHybrid, USE_DISTRICT
     */
    function addOverlayMapTypeId(mapTypeId) {
        map.addOverlayMapTypeId(mapTypeId);
    }

    /**
     * 지도에 로드뷰, 교통정보 등의 오버레이 타입의 타일 이미지를 삭제한다.
     */
    function removeOverlayMapTypeId(mapTypeId) {
        map.removeOverlayMapTypeId(mapTypeId);
    }

    function setDraggable(draggable) {
        map.setDraggable(draggable);
    }

    function getDraggable() {
        return map.getDraggable();
    }

    function setZoomable(zoomable) {
        map.setZoomable(zoomable);
    }

    function getZoomable() {
        return map.getZoomable();
    }

    function setBounds(bounds, paddingTop = 0, paddingRight = 0, paddingBottom = 0, paddingLeft = 0) {
        map.setBounds(bounds, paddingTop, paddingRight, paddingBottom, paddingLeft);
    }

    function getBounds() {
        let bounds = map.getBounds();
        const sw = {
            latitude: bounds.getSouthWest().getLat(),
            longitude: bounds.getSouthWest().getLng(),
        };

        const ne = {
            latitude: bounds.getNorthEast().getLat(),
            longitude: bounds.getNorthEast().getLng(),
        };

        let result = {
            sw: sw,
            ne: ne
        };

        if ($isIOS) {
            result = JSON.stringify(result);
        }

        return result;
    }

    function setMinLevel(minLevel) {
        map.setMinLevel(minLevel);
    }

    function setMaxLevel(maxLevel) {
        map.setMaxLevel(maxLevel);
    }

    /**
     * 중심 좌표를 지정한 픽셀 만큼 부드럽게 이동한다.
     * 만약 이동할 거리가 지도 화면의 크기보다 클 경우 애니메이션 없이 이동한다.
     * @param dx Number
     * @param dy Number
     */
    function panBy(dx, dy) {
        map.panBy(dx, dy);
    }

    /**
     * 중심 좌표를 지정한 좌표 또는 영역으로 부드럽게 이동한다. 필요하면 확대 또는 축소도 수행한다.
     * 만약 이동할 거리가 지도 화면의 크기보다 클 경우 애니메이션 없이 이동한다.
     * 첫 번째 매개변수로 좌표나 영역을 지정할 수 있으며,
     * 영역(bounds)을 지정한 경우에만 padding 옵션이 유효하다.
     * padding 값을 지정하면 그 값만큼의 상하좌우 픽셀이 확보된 영역으로 계산되어 이동한다.
     * padding의 기본값은 32.
     * @param latitude
     * @param longitude
     * @param padding Number
     */
    function panTo(latitude, longitude, padding = 32) {
        // 이동할 위도 경도 위치를 생성합니다
        let moveLatLon = new kakao.maps.LatLng(latitude, longitude);

        // 지도 중심을 부드럽게 이동시킵니다
        // 만약 이동할 거리가 지도 화면보다 크면 부드러운 효과 없이 이동합니다
        map.panTo(moveLatLon);
    }

    function fitBounds(points) {
        let list = JSON.parse(points);

        let bounds = new kakao.maps.LatLngBounds();
        for (let i = 0; i < list.length; i++) {
            // LatLngBounds 객체에 좌표를 추가합니다
            bounds.extend(new kakao.maps.LatLng(list[i].latitude, list[i].longitude));
        }

        map.setBounds(bounds);
    }

    /**
     * 지도에 컨트롤을 추가한다.
     * @param isShowZoomControl boolean
     */
    function setZoomControl(isShowZoomControl) {
        if (!isShowZoomControl) return;

        const zoomControl = new kakao.maps.ZoomControl();
        map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);
    }

    function relayout() {
        map.relayout();
    }
    ''';
  }
}
