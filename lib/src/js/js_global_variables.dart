/// JavaScript 전역 변수 스크립트를 제공합니다.
class JsGlobalVariables {
  /// JavaScript 전역 변수 선언 스크립트를 반환합니다.
  static String getScript() {
    return '''
    let map = null;
    let geocoder = null;
    let places = null;
    let polylines = [];
    let circles = [];
    let rectangles = [];
    let polygons = [];
    let markers = [];
    let customOverlays = [];
    let clusterer = null;
    let clustererCustomOverlays = [];
    let defaultCenter = null;

    // id -> overlay 인덱스. 배열(polylines, markers 등)은 인덱스로부터 파생됩니다.
    let polylineIndex = new Map();
    let circleIndex = new Map();
    let rectangleIndex = new Map();
    let polygonIndex = new Map();
    let markerIndex = new Map();
    let customOverlayIndex = new Map();

    // 클러스터러가 관리하는 마커 ID 집합 (clearMarker 대상에서 제외)
    let clustererMarkerIds = new Set();

    // 배치 처리 중에는 파생 배열 재계산을 지연합니다.
    let __batchDepth = 0;

    // 진단용: 페이지 로드 이후 발생한 JS 오류를 수집합니다. (최대 50개)
    window.__kakaoMapErrors = [];
    window.addEventListener('error', function (e) {
        if (window.__kakaoMapErrors.length < 50) {
            window.__kakaoMapErrors.push(String(e.message) + ' @' + e.lineno + ':' + e.colno);
        }
    });
    window.addEventListener('unhandledrejection', function (e) {
        if (window.__kakaoMapErrors.length < 50) {
            window.__kakaoMapErrors.push('unhandledrejection: ' + String(e.reason));
        }
    });
    ''';
  }
}
