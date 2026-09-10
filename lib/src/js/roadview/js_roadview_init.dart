import '../../model/lat_lng.dart';
import '../../model/viewpoint.dart';

/// 로드뷰 초기화 및 제어 스크립트를 제공합니다.
class JsRoadviewInit {
  /// 로드뷰 전역 변수와 초기화/제어 함수 스크립트를 반환합니다.
  ///
  /// [center]가 주어지면 그 좌표에서 가장 가까운 로드뷰를 찾아 표시하고,
  /// [panoId]가 주어지면 해당 파노라마를 직접 표시합니다. 둘 다 주어지면
  /// [panoId]가 우선합니다.
  static String getScript({
    required LatLng? center,
    required String? panoId,
    required Viewpoint? viewpoint,
    required int radius,
    required bool isIOS,
    bool disableZoomControl = false,
  }) {
    final latitude = center?.latitude ?? 33.450701;
    final longitude = center?.longitude ?? 126.570667;
    final panoIdLiteral = panoId == null ? 'null' : "'$panoId'";
    final viewpointLiteral = viewpoint == null
        ? 'null'
        : '{pan: ${viewpoint.pan}, tilt: ${viewpoint.tilt}, zoom: ${viewpoint.zoom}}';

    return '''
    let roadview = null;
    let roadviewClient = null;

    // id -> 오버레이 인덱스. 로드뷰 위에 올린 마커/커스텀 오버레이를 관리합니다.
    let roadviewMarkerIndex = new Map();
    let roadviewOverlayIndex = new Map();

    // 진단용: 로드뷰 스크립트에서 발생한 오류를 수집합니다. (최대 50개)
    window.__kakaoRoadviewErrors = [];

    /** 문자열이면 JSON.parse, 아니면 그대로 반환합니다. */
    function rvParse(value) {
        return typeof value === 'string' ? JSON.parse(value) : value;
    }

    /** null / 'null' / undefined 를 undefined 로 정규화합니다. */
    function rvNv(value) {
        return (value === null || value === undefined || value === 'null') ? undefined : value;
    }

    /** 항목 하나의 예외가 나머지를 막지 않도록 격리해 순회합니다. */
    function rvForEachSafe(list, label, fn) {
        for (let i = 0; i < list.length; i++) {
            try { fn(list[i], i); }
            catch (e) {
                if (window.__kakaoRoadviewErrors.length < 50) {
                    window.__kakaoRoadviewErrors.push(label + '[' + i + ']: ' + String(e));
                }
            }
        }
    }

    /** 반환값을 플랫폼에 맞게 감쌉니다. (iOS 는 문자열로 돌려줘야 합니다) */
    function rvResult(value) {
        return $isIOS ? JSON.stringify(value) : value;
    }

    window.onload = function () {
        // Kakao Maps SDK 가 완전히 로드된 후 로드뷰를 초기화합니다.
        kakao.maps.load(function () {
            initializeRoadview();
        });
    }

    function initializeRoadview() {
        const container = document.getElementById('map');
        roadview = new kakao.maps.Roadview(container, { disableZoomControl: $disableZoomControl });
        roadviewClient = new kakao.maps.RoadviewClient();

        registerRoadviewEvents();

        const initialPanoId = $panoIdLiteral;
        if (initialPanoId !== null) {
            setPanoId(initialPanoId, $latitude, $longitude);
        } else {
            setPanoIdNear($latitude, $longitude, $radius);
        }
    }

    /**
     * 좌표에서 가장 가까운 로드뷰를 찾아 표시합니다.
     * 주변에 로드뷰가 없으면 panoId 가 null 이므로 안내 콜백만 보냅니다.
     */
    function setPanoIdNear(latitude, longitude, radius) {
        const position = new kakao.maps.LatLng(latitude, longitude);
        roadviewClient.getNearestPanoId(position, radius, function (panoId) {
            if (panoId === null || panoId === undefined) {
                onRoadviewNotFound.postMessage(JSON.stringify({
                    latitude: latitude,
                    longitude: longitude
                }));
                return;
            }
            roadview.setPanoId(panoId, position);
        });
    }

    /** 파노라마 ID 를 직접 지정해 로드뷰를 표시합니다. */
    function setPanoId(panoId, latitude, longitude) {
        const position = new kakao.maps.LatLng(latitude, longitude);
        roadview.setPanoId(panoId, position);
    }

    /** 시점(방향, 확대 수준)을 변경합니다. */
    function setViewpoint(pan, tilt, zoom) {
        roadview.setViewpoint({ pan: pan, tilt: tilt, zoom: zoom });
    }

    function getViewpoint() {
        const v = roadview.getViewpoint();
        return rvResult({ pan: v.pan, tilt: v.tilt, zoom: v.zoom });
    }

    function getPosition() {
        const p = roadview.getPosition();
        return rvResult({ latitude: p.getLat(), longitude: p.getLng() });
    }

    function getPanoId() {
        return rvResult({ panoId: String(roadview.getPanoId()) });
    }

    /** 로드뷰 컨테이너 크기가 바뀌었을 때 다시 그립니다. */
    function relayout() {
        if (roadview) roadview.relayout();
    }

    /**
     * 좌표를 로드뷰 시점으로 변환합니다.
     * 로드뷰 위 특정 지점을 바라보게 할 때 사용합니다.
     */
    function viewpointFromCoords(latitude, longitude, altitude) {
        const projection = roadview.getProjection();
        const v = projection.viewpointFromCoords(
            new kakao.maps.LatLng(latitude, longitude), altitude);
        return rvResult({ pan: v.pan, tilt: v.tilt, zoom: v.zoom });
    }

    /** 초기 시점이 지정되어 있으면 init 시점에 적용합니다. */
    function applyInitialViewpoint() {
        const initial = $viewpointLiteral;
        if (initial !== null) {
            roadview.setViewpoint(initial);
        }
    }
    ''';
  }
}
