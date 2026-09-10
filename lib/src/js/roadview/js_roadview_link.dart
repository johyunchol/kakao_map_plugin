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
    bool disableZoomControl = false,
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

    // 사용자가 의도한 지도 중심. relayout 뒤에 지도가 어긋나지 않도록 다시 맞추는 데 씁니다.
    // (컨테이너 크기가 바뀐 채 relayout 하면 SDK 는 좌상단을 기준으로 유지해 중심이 이동합니다)
    let mapCenter = null;
    // 로드뷰를 한 번이라도 요청했는지. 처음 로드뷰를 보여줄 때 지도 중심의 로드뷰를 불러오기 위한 플래그입니다.
    let roadviewRequested = false;

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
        mapCenter = position;

        map = new kakao.maps.Map(document.getElementById('map'), {
            center: position,
            level: $currentLevel
        });

        // 사용자가 지도를 움직이면 그 위치를 의도한 중심으로 기억합니다.
        kakao.maps.event.addListener(map, 'dragend', function () {
            mapCenter = map.getCenter();
        });
        kakao.maps.event.addListener(map, 'zoom_changed', function () {
            mapCenter = map.getCenter();
        });

        roadview = new kakao.maps.Roadview(document.getElementById('roadview'), { disableZoomControl: $disableZoomControl });
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
            if (mapWalker) {
                mapWalker.setPosition(position);
                mapWalker.setAngle(roadview.getViewpoint().pan);
            }
            mapCenter = position;
            map.setCenter(position);
            onRoadviewPositionChange.postMessage(JSON.stringify({
                latitude: position.getLat(),
                longitude: position.getLng()
            }));
        });

        kakao.maps.event.addListener(roadview, 'init', function () {
            // 첫 파노라마의 시점에 맞춰 동동이 방향을 바로 맞춥니다.
            if (mapWalker) mapWalker.setAngle(roadview.getViewpoint().pan);
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
        // 공식 샘플과 같은 구조: 시야각(angleBack) 위에 사람 아이콘(figure)을 올립니다.
        const content = document.createElement('div');
        content.className = 'MapWalker m0';
        const angleBack = document.createElement('div');
        angleBack.className = 'angleBack';
        const figure = document.createElement('div');
        figure.className = 'figure';
        content.appendChild(angleBack);
        content.appendChild(figure);

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
        relayout();

        // 로드뷰를 처음 보여줄 때는 지도 중심 위치의 로드뷰를 불러옵니다.
        // (공식 샘플처럼 시작과 동시에 로드뷰가 보이도록)
        if (mode !== 'map' && !roadviewRequested && mapCenter) {
            moveRoadview(mapCenter.getLat(), mapCenter.getLng());
        }
    }

    /** 좌표 위치의 로드뷰를 표시합니다. 없으면 안내만 보냅니다. */
    function moveRoadview(latitude, longitude) {
        const position = new kakao.maps.LatLng(latitude, longitude);
        roadviewRequested = true;
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
        mapCenter = new kakao.maps.LatLng(latitude, longitude);
        map.setCenter(mapCenter);
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
        if (map) {
            map.relayout();
            // relayout 은 좌상단 기준으로 크기를 다시 잡아 중심이 밀리므로 의도한 중심으로 되돌립니다.
            if (mapCenter && viewMode !== 'roadview') map.setCenter(mapCenter);
        }
        if (roadview) roadview.relayout();
    }
    ''';
  }
}
