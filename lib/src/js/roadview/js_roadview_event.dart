/// 로드뷰 이벤트 리스너 등록 스크립트를 제공합니다.
class JsRoadviewEvent {
  /// 로드뷰 이벤트 리스너를 등록하는 스크립트를 반환합니다.
  ///
  /// Flutter 쪽에 콜백이 등록되지 않은 이벤트는 리스너 자체를 달지 않아
  /// 불필요한 브릿지 메시지가 발생하지 않도록 합니다.
  static String getScript({
    required bool hasPanoIdChange,
    required bool hasViewpointChange,
    required bool hasPositionChange,
  }) {
    return '''
    function registerRoadviewEvents() {
        // init 은 항상 등록합니다. 로드뷰 준비 완료를 Flutter 에 알리고
        // 이 시점에 초기 시점과 오버레이를 적용해야 정상적으로 표시됩니다.
        kakao.maps.event.addListener(roadview, 'init', function () {
            try { applyInitialViewpoint(); } catch (e) {
                window.__kakaoRoadviewErrors.push('applyInitialViewpoint: ' + String(e));
            }
            onRoadviewInit.postMessage(JSON.stringify({ ready: true }));
        });

        if ($hasPanoIdChange) {
            // 도로를 따라 이동해 다른 파노라마로 넘어가면 발생한다.
            kakao.maps.event.addListener(roadview, 'panoid_changed', function () {
                onRoadviewPanoIdChange.postMessage(JSON.stringify({
                    panoId: String(roadview.getPanoId())
                }));
            });
        }

        if ($hasViewpointChange) {
            // 화면을 돌리거나 확대/축소하면 발생한다.
            kakao.maps.event.addListener(roadview, 'viewpoint_changed', function () {
                const v = roadview.getViewpoint();
                onRoadviewViewpointChange.postMessage(JSON.stringify({
                    pan: v.pan, tilt: v.tilt, zoom: v.zoom
                }));
            });
        }

        if ($hasPositionChange) {
            // 표시 중인 파노라마의 좌표가 바뀌면 발생한다.
            kakao.maps.event.addListener(roadview, 'position_changed', function () {
                const p = roadview.getPosition();
                onRoadviewPositionChange.postMessage(JSON.stringify({
                    latitude: p.getLat(), longitude: p.getLng()
                }));
            });
        }
    }
    ''';
  }
}
