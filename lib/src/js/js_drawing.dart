/// Drawing Library 관련 스크립트를 제공합니다.
///
/// 카카오 SDK 는 `kakao.maps.drawing` 과 `kakao.maps.Drawing` 두 표기를 모두
/// 제공하는데(실기기 확인 완료, 같은 객체의 별칭), 여기서는 문서에 쓰이는
/// 소문자 표기를 우선 사용하고 대문자를 대안으로 둡니다.
class JsDrawing {
  /// Drawing 관련 함수들의 스크립트를 반환합니다.
  static String getScript({
    required bool hasDrawEndCallback,
    required bool hasDrawRemoveCallback,
    required bool hasDrawStateChangeCallback,
    required bool isIOS,
  }) {
    return '''
    let drawingManager = null;
    let drawingToolbox = null;

    /** Drawing 네임스페이스를 반환합니다. 라이브러리를 불러오지 않았으면 null 입니다. */
    function drawingNamespace() {
        if (typeof kakao === 'undefined' || !kakao.maps) return null;
        return kakao.maps.drawing || kakao.maps.Drawing || null;
    }

    /**
     * Drawing 사용 가능 여부를 확인합니다.
     * drawing 라이브러리를 제외하고 로드한 경우 false 를 반환합니다.
     */
    function requireDrawing() {
        const ns = drawingNamespace();
        if (ns && ns.DrawingManager) return true;
        if (window.__kakaoMapErrors && window.__kakaoMapErrors.length < 50) {
            window.__kakaoMapErrors.push(
                'DRAWING_LIBRARY_NOT_LOADED: KakaoMapLibrary.drawing 을 포함해 지도를 만들어야 합니다.');
        }
        return false;
    }

    function drawingResult(value) {
        return $isIOS ? JSON.stringify(value) : value;
    }

    /** DrawingManager 를 만듭니다. 이미 있으면 정리한 뒤 새로 만듭니다. */
    function createDrawingManager(optionsPayload) {
        if (!requireDrawing()) return;
        const ns = drawingNamespace();
        const raw = parseIfString(optionsPayload) || {};

        removeDrawingToolbox();
        drawingManager = null;

        const options = { map: map };

        // drawingMode 는 문자열 배열로 오므로 SDK 의 OverlayType 값으로 맞춥니다.
        if (Array.isArray(raw.drawingMode) && raw.drawingMode.length > 0) {
            options.drawingMode = raw.drawingMode;
        }
        if (Array.isArray(raw.guideTooltip)) {
            options.guideTooltip = raw.guideTooltip;
        }
        ['markerOptions', 'polylineOptions', 'rectangleOptions', 'circleOptions',
         'ellipseOptions', 'polygonOptions', 'arrowOptions'].forEach(function (key) {
            if (raw[key]) options[key] = raw[key];
        });

        drawingManager = new ns.DrawingManager(options);
        registerDrawingEvents();
    }

    function registerDrawingEvents() {
        if (!drawingManager) return;

        if ($hasDrawEndCallback) {
            kakao.maps.event.addListener(drawingManager, 'drawend', function (data) {
                onDrawingEnd.postMessage(JSON.stringify({
                    type: (data && data.overlayType) ? String(data.overlayType) : ''
                }));
            });
        }

        if ($hasDrawRemoveCallback) {
            kakao.maps.event.addListener(drawingManager, 'remove', function () {
                onDrawingRemove.postMessage(JSON.stringify({ removed: true }));
            });
        }

        if ($hasDrawStateChangeCallback) {
            kakao.maps.event.addListener(drawingManager, 'state_changed', function () {
                // undo/redo 가능 여부는 Toolbox UI 상태와 함께 바뀝니다.
                onDrawingStateChange.postMessage(JSON.stringify({ changed: true }));
            });
        }
    }

    /** 그릴 도형 종류를 선택합니다. */
    function selectDrawingMode(overlayType) {
        if (!drawingManager) return;
        drawingManager.select(overlayType);
    }

    /** 그리는 중이던 작업을 취소합니다. */
    function cancelDrawing() {
        if (!drawingManager) return;
        drawingManager.cancel();
    }

    function undoDrawing() {
        if (!drawingManager) return;
        drawingManager.undo();
    }

    function redoDrawing() {
        if (!drawingManager) return;
        drawingManager.redo();
    }

    /** 선택된 도형을 지웁니다. */
    function removeDrawingShape() {
        if (!drawingManager) return;
        drawingManager.remove();
    }

    /** 그려진 도형 데이터를 반환합니다. */
    function getDrawingData() {
        if (!drawingManager) return drawingResult({});
        return drawingResult(drawingManager.getData());
    }

    /** Toolbox UI 를 지도 위에 표시합니다. */
    function showDrawingToolbox() {
        if (!requireDrawing() || !drawingManager) return;
        const ns = drawingNamespace();
        if (typeof ns.Toolbox !== 'function') return;
        if (drawingToolbox) return;

        drawingToolbox = new ns.Toolbox({ drawingManager: drawingManager });
        map.addControl(drawingToolbox.getElement(), kakao.maps.ControlPosition.TOP);
    }

    /** Toolbox UI 를 제거합니다. */
    function removeDrawingToolbox() {
        if (!drawingToolbox) return;
        try {
            map.removeControl(drawingToolbox.getElement());
        } catch (e) { /* 이미 제거되었으면 무시합니다 */ }
        drawingToolbox = null;
    }
    ''';
  }
}
