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
    ''';
  }
}
