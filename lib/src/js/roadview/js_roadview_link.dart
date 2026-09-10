import '../../model/lat_lng.dart';

/// 지도와 로드뷰를 한 문서 안에서 연동하는 스크립트를 제공합니다.
///
/// `#map` 과 `#roadview` 두 div 의 표시 모드를 바꾸고, 지도 클릭이나 동동이
/// 드래그로 로드뷰 위치를 옮기는 기능을 담당합니다.
class JsRoadviewLink {
  /// 지도-로드뷰 연동 스크립트를 반환합니다.
  static String getScript({
    required LatLng? center,
    required int currentLevel,
    required int radius,
    required bool showRoadviewOverlay,
    required bool useMapWalker,
    required bool isIOS,
  }) {
    final latitude = center?.latitude ?? 33.450701;
    final longitude = center?.longitude ?? 126.570667;

    return '''
    let map = null;
    let roadview = null;
    let roadviewClient = null;
    let mapWalker = null;

    // 'map' | 'roadview' | 'split'
    let viewMode = 'map';

    window.__kakaoRoadviewErrors = [];

    function rvParse(value) {
        return typeof value === 'string' ? JSON.parse(value) : value;
    }

    function rvResult(value) {
        return $isIOS ? JSON.stringify(value) : value;
    }

    window.onload = function () {
        kakao.maps.load(function () {
            initializeMapRoadview();
        });
    }

    function initializeMapRoadview() {
        const position = new kakao.maps.LatLng($latitude, $longitude);

        map = new kakao.maps.Map(document.getElementById('map'), {
            center: position,
            level: $currentLevel
        });

        roadview = new kakao.maps.Roadview(document.getElementById('roadview'));
        roadviewClient = new kakao.maps.RoadviewClient();

        if ($showRoadviewOverlay) {
            // 로드뷰가 있는 도로를 지도 위에 표시합니다.
            map.addOverlayMapTypeId(kakao.maps.MapTypeId.ROADVIEW);
        }

        if ($useMapWalker) {
            createMapWalker(position);
        }

        // 로드뷰 시점이 바뀌면 동동이가 바라보는 방향도 함께 돌립니다.
        kakao.maps.event.addListener(roadview, 'viewpoint_changed', function () {
            if (!mapWalker) return;
            const viewpoint = roadview.getViewpoint();
            mapWalker.setAngle(viewpoint.pan);
        });

        // 로드뷰 위치가 바뀌면 동동이와 지도 중심도 따라갑니다.
        kakao.maps.event.addListener(roadview, 'position_changed', function () {
            const position = roadview.getPosition();
            if (mapWalker) mapWalker.setPosition(position);
            map.setCenter(position);
            onRoadviewPositionChange.postMessage(JSON.stringify({
                latitude: position.getLat(),
                longitude: position.getLng()
            }));
        });

        kakao.maps.event.addListener(roadview, 'init', function () {
            onRoadviewInit.postMessage(JSON.stringify({ ready: true }));
        });

        // 지도를 클릭하면 그 위치의 로드뷰로 이동합니다.
        kakao.maps.event.addListener(map, 'click', function (mouseEvent) {
            toggleRoadview(mouseEvent.latLng.getLat(), mouseEvent.latLng.getLng());
        });

        onMapCreated.postMessage(JSON.stringify({ ready: true }));
    }

    /**
     * 동동이(MapWalker)를 만듭니다.
     * 지도 위에서 드래그해 로드뷰 위치를 옮길 수 있는 커스텀 오버레이입니다.
     */
    function createMapWalker(position) {
        const content = document.createElement('div');
        content.className = 'MapWalker m0';
        const figure = document.createElement('div');
        figure.className = 'figure';
        const face = document.createElement('div');
        face.className = 'face';
        content.appendChild(figure);
        content.appendChild(face);

        const walker = new kakao.maps.CustomOverlay({
            position: position,
            content: content,
            yAnchor: 1
        });
        walker.setMap(map);

        walker.setAngle = function (angle) {
            // pan(0~360)을 22.5도 단위 16분할로 바꿔 스프라이트를 교체합니다.
            const threshold = 22.5;
            let index = Math.floor((angle + threshold / 2) % 360 / threshold);
            if (index < 0) index += 16;
            content.className = 'MapWalker m' + index;
        };

        mapWalker = walker;
    }

    /** 표시 모드를 바꿉니다. mode: 'map' | 'roadview' | 'split' */
    function setViewMode(mode, splitRatio) {
        viewMode = mode;
        const mapWrapper = document.getElementById('mapWrapper');
        const rv = document.getElementById('roadview');
        const ratio = (splitRatio === undefined || splitRatio === null) ? 50 : splitRatio;

        if (mode === 'map') {
            mapWrapper.style.width = '100%';
            mapWrapper.style.height = '100%';
            mapWrapper.style.display = 'block';
            rv.style.display = 'none';
        } else if (mode === 'roadview') {
            mapWrapper.style.display = 'none';
            rv.style.display = 'block';
            rv.style.left = '0';
            rv.style.top = '0';
            rv.style.width = '100%';
            rv.style.height = '100%';
        } else {
            // 위아래로 분할합니다. 위가 지도, 아래가 로드뷰입니다.
            mapWrapper.style.display = 'block';
            mapWrapper.style.width = '100%';
            mapWrapper.style.height = ratio + '%';
            rv.style.display = 'block';
            rv.style.left = '0';
            rv.style.top = ratio + '%';
            rv.style.width = '100%';
            rv.style.height = (100 - ratio) + '%';
        }

        // 크기가 바뀌었으므로 두 객체 모두 다시 그립니다.
        if (map) map.relayout();
        if (roadview) roadview.relayout();
    }

    /** 좌표 위치의 로드뷰를 표시합니다. 없으면 안내만 보냅니다. */
    function moveRoadview(latitude, longitude) {
        const position = new kakao.maps.LatLng(latitude, longitude);
        roadviewClient.getNearestPanoId(position, $radius, function (panoId) {
            if (panoId === null || panoId === undefined) {
                onRoadviewNotFound.postMessage(JSON.stringify({
                    latitude: latitude, longitude: longitude
                }));
                return;
            }
            roadview.setPanoId(panoId, position);
            if (mapWalker) mapWalker.setPosition(position);
        });
    }

    /** 로드뷰로 이동하면서 표시 모드도 함께 전환합니다. */
    function toggleRoadview(latitude, longitude) {
        moveRoadview(latitude, longitude);
        if (viewMode === 'map') {
            setViewMode('split');
        }
    }

    function setMapCenter(latitude, longitude) {
        map.setCenter(new kakao.maps.LatLng(latitude, longitude));
    }

    function setMapLevel(level) {
        map.setLevel(level);
    }

    function getViewpoint() {
        const v = roadview.getViewpoint();
        return rvResult({ pan: v.pan, tilt: v.tilt, zoom: v.zoom });
    }

    function setViewpoint(pan, tilt, zoom) {
        roadview.setViewpoint({ pan: pan, tilt: tilt, zoom: zoom });
    }

    function getPosition() {
        const p = roadview.getPosition();
        return rvResult({ latitude: p.getLat(), longitude: p.getLng() });
    }

    function relayout() {
        if (map) map.relayout();
        if (roadview) roadview.relayout();
    }
    ''';
  }
}
