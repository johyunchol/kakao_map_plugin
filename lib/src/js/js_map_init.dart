import '../model/lat_lng.dart';
import '../basic/constants/control_position.dart';

/// JavaScript 지도 초기화 스크립트를 제공합니다.
class JsMapInit {
  /// 지도 초기화 및 이벤트 리스너 설정 스크립트를 반환합니다.
  static String getScript({
    required LatLng? center,
    required int currentLevel,
    required bool? mapTypeControl,
    required ControlPosition mapTypeControlPosition,
    required bool? zoomControl,
    required ControlPosition zoomControlPosition,
    required int minLevel,
    required int maxLevel,
    required bool hasOnCenterChangeCallback,
    required bool hasOnZoomChangeCallback,
    required bool hasOnBoundsChangeCallback,
    required bool hasOnMapTap,
    required bool hasOnDragChangeCallback,
    required bool hasOnCameraIdle,
    required bool hasOnTilesLoadedCallback,
    required bool isIOS,
    required bool hasOnMapDoubleTap,
    bool hasOnMapTypeChanged = false,
    bool hasOnMapLongPress = false,
    int? initialMapTypeId,
    bool? disableDoubleClick,
    bool? disableDoubleClickZoom,
    bool? scrollwheel,
    bool? keyboardShortcuts,
    String copyrightPosition = 'BOTTOMRIGHT',
    bool copyrightReversed = false,
  }) {
    // 지정한 생성 옵션만 넣어 SDK 기본값을 유지합니다.
    final extraOptions = StringBuffer();
    if (initialMapTypeId != null) {
      extraOptions.write(',\n            mapTypeId: $initialMapTypeId');
    }
    if (disableDoubleClick != null) {
      extraOptions.write(',\n            disableDoubleClick: $disableDoubleClick');
    }
    if (disableDoubleClickZoom != null) {
      extraOptions.write(',\n            disableDoubleClickZoom: $disableDoubleClickZoom');
    }
    if (scrollwheel != null) {
      extraOptions.write(',\n            scrollwheel: $scrollwheel');
    }
    if (keyboardShortcuts != null) {
      extraOptions.write(',\n            keyboardShortcuts: $keyboardShortcuts');
    }
    return '''
    window.onload = function () {
        // Kakao Maps SDK가 완전히 로드된 후 지도를 초기화합니다
        kakao.maps.load(function() {
            initializeMap();
        });
    }

    /**
     * 검색 서비스 객체(geocoder, places)를 준비합니다.
     * services 라이브러리가 로드되지 않았으면 false 를 반환합니다.
     */
    function ensureServices() {
        if (typeof kakao === 'undefined' || !kakao.maps || !kakao.maps.services) {
            return false;
        }
        if (!geocoder) geocoder = new kakao.maps.services.Geocoder();
        // map 을 넘겨야 useMapCenter / useMapBounds 검색 옵션이 동작합니다.
        if (!places) places = map ? new kakao.maps.services.Places(map) : new kakao.maps.services.Places();
        return true;
    }

    function initializeMap() {
        defaultCenter = new kakao.maps.LatLng(33.450701, 126.570667);
        const container = document.getElementById('map');
        let center = defaultCenter;
        if (${center != null}) {
            center = new kakao.maps.LatLng(${center?.latitude}, ${center?.longitude});
        }

        const options = {
            center: center,
            level: $currentLevel$extraOptions
        };

        map = new kakao.maps.Map(container, options);
        // services 라이브러리를 제외하고 로드한 경우에도 지도 생성이 실패하지 않도록
        // 존재할 때만 생성합니다. (검색 API 사용 시 ensureServices() 가 재확인합니다)
        ensureServices();

        if ($mapTypeControl) {
            const mapTypeControl = new kakao.maps.MapTypeControl();
            map.addControl(mapTypeControl, ${mapTypeControlPosition.id});
        }

        if ($zoomControl) {
            const zoomControl = new kakao.maps.ZoomControl()
            map.addControl(zoomControl, ${zoomControlPosition.id});
        }

        map.setMinLevel($minLevel);

        map.setMaxLevel($maxLevel);

        if ($hasOnCenterChangeCallback) {
            // 중심 좌표가 변경되면 발생한다.
            kakao.maps.event.addListener(map, 'center_changed', function () {
                const latLng = map.getCenter();

                const data = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                centerChanged.postMessage(JSON.stringify(data));
            });
        }

        if ($hasOnZoomChangeCallback) {
            // 확대 수준이 변경되기 직전 발생한다.
            kakao.maps.event.addListener(map, 'zoom_start', function () {
                const level = map.getLevel();
                zoomStart.postMessage(JSON.stringify({zoomLevel: level}));
            });

            // 확대 수준이 변경되면 발생한다.
            kakao.maps.event.addListener(map, 'zoom_changed', function () {
                const level = map.getLevel();
                zoomChanged.postMessage(JSON.stringify({zoomLevel: level}));
            });
        }

        if ($hasOnBoundsChangeCallback) {
            // 지도 영역이 변경되면 발생한다.
            kakao.maps.event.addListener(map, 'bounds_changed', function () {
                const bounds = getBounds();

                if ($isIOS) {
                    boundsChanged.postMessage(bounds);
                } else {
                    boundsChanged.postMessage(JSON.stringify(bounds));
                }
            });
        }

        if ($hasOnMapTap) {
            // 지도를 클릭하면 발생한다.
            kakao.maps.event.addListener(map, 'click', function (mouseEvent) {
                // 클릭한 위도, 경도 정보를 가져옵니다
                const latLng = mouseEvent.latLng;

                const clickLatLng = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                onMapTap.postMessage(JSON.stringify(clickLatLng));
            });
        }

        if ($hasOnMapDoubleTap) {
            // 지도를 더블클릭하면 발생한다.
            kakao.maps.event.addListener(map, 'dblclick', function (mouseEvent) {
                const latLng = mouseEvent.latLng;

                const clickLatLng = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                onMapDoubleTap.postMessage(JSON.stringify(clickLatLng));
            });
        }

        if ($hasOnDragChangeCallback) {
            // 마우스 드래그로 지도 이동이 완료되었을 때 마지막 파라미터로 넘어온 함수를 호출하도록 이벤트를 등록합니다
            kakao.maps.event.addListener(map, 'dragstart', function () {
                const latLng = map.getCenter();

                const result = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                dragStart.postMessage(JSON.stringify(result));
            });

            kakao.maps.event.addListener(map, 'drag', function () {
                const latLng = map.getCenter();

                const result = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                drag.postMessage(JSON.stringify(result));
            });

            kakao.maps.event.addListener(map, 'dragend', function () {
                const latLng = map.getCenter();

                const result = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                dragEnd.postMessage(JSON.stringify(result));
            });
        }

        if ($hasOnCameraIdle) {
            // 마우스 드래그로 지도 이동이 완료되었을 때 마지막 파라미터로 넘어온 함수를 호출하도록 이벤트를 등록합니다
            kakao.maps.event.addListener(map, 'idle', function () {
                const latLng = map.getCenter();

                const idleLatLng = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                cameraIdle.postMessage(JSON.stringify(idleLatLng));
            });
        }

        if ($hasOnTilesLoadedCallback) {
            // 확대수준이 변경되거나 지도가 이동했을때 타일 이미지 로드가 모두 완료되면 발생한다.
            // 지도이동이 미세하기 일어나 타일 이미지 로드가 일어나지 않은경우 발생하지 않는다.
            kakao.maps.event.addListener(map, 'tilesloaded', function () {
                const latLng = map.getCenter();

                const result = {
                    latitude: latLng.getLat(),
                    longitude: latLng.getLng(),
                    zoomLevel: map.getLevel(),
                }

                tilesLoaded.postMessage(JSON.stringify(result));
            });
        }

        if ($hasOnMapLongPress) {
            // 길게 누르기: 포인터를 0.5초 이상 거의 움직이지 않고 누르고 있으면 발생합니다.
            // (SDK 에는 터치용 롱프레스 이벤트가 없어 컨테이너의 pointer 이벤트로 판정합니다)
            const LONG_PRESS_MS = 500, MOVE_TOLERANCE = 10;
            let lpTimer = null, lpStart = null;
            const cancelLongPress = function () { if (lpTimer) { clearTimeout(lpTimer); lpTimer = null; } lpStart = null; };
            const postLongPress = function (clientX, clientY) {
                const rect = container.getBoundingClientRect();
                const point = new kakao.maps.Point(clientX - rect.left, clientY - rect.top);
                const latLng = map.getProjection().coordsFromContainerPoint(point);
                onMapLongPress.postMessage(JSON.stringify({ latitude: latLng.getLat(), longitude: latLng.getLng() }));
            };
            container.addEventListener('pointerdown', function (e) {
                if (e.button !== 0 && e.pointerType === 'mouse') return;
                cancelLongPress();
                lpStart = { x: e.clientX, y: e.clientY };
                lpTimer = setTimeout(function () {
                    lpTimer = null;
                    if (lpStart) postLongPress(lpStart.x, lpStart.y);
                    lpStart = null;
                }, LONG_PRESS_MS);
            }, true);
            container.addEventListener('pointermove', function (e) {
                if (lpStart && (Math.abs(e.clientX - lpStart.x) > MOVE_TOLERANCE || Math.abs(e.clientY - lpStart.y) > MOVE_TOLERANCE)) cancelLongPress();
            }, true);
            ['pointerup', 'pointercancel', 'pointerleave'].forEach(function (type) {
                container.addEventListener(type, cancelLongPress, true);
            });
            // 마우스 환경의 우클릭도 같은 콜백으로 보냅니다.
            kakao.maps.event.addListener(map, 'rightclick', function (mouseEvent) {
                cancelLongPress();
                const latLng = mouseEvent.latLng;
                onMapLongPress.postMessage(JSON.stringify({ latitude: latLng.getLat(), longitude: latLng.getLng() }));
            });
        }

        if ($hasOnMapTypeChanged) {
            // 지도 타입이 바뀌면 발생한다. (지도타입 컨트롤, setMapTypeId 모두)
            kakao.maps.event.addListener(map, 'maptypeid_changed', function () {
                mapTypeChanged.postMessage(JSON.stringify({ mapTypeId: map.getMapTypeId() }));
            });
        }

        map.setCopyrightPosition(kakao.maps.CopyrightPosition.$copyrightPosition, $copyrightReversed);

        onMapCreated.postMessage(JSON.stringify({ ready: true }));
    }
    ''';
  }
}
