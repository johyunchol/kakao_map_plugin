import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// Model imports
import '../model/lat_lng.dart';
import '../model/lat_lng_bounds.dart';

// Callback imports
import 'callbacks.dart';

// Constants and enums imports
import 'constants/control_position.dart';
import 'constants/kakao_map_library.dart';
import 'constants/drag_type.dart';
import 'constants/drawing_overlay_type.dart';
import 'constants/marker_drag_type.dart';
import 'constants/zoom_type.dart';

// Controller imports
import 'kakao_map_controller.dart';

// Clusterer imports
import 'clusterer.dart';

// Marker and overlay imports
import 'marker.dart';
import 'overlay_payload.dart';
import 'custom_overlay.dart';
import 'polyline.dart';
import 'circle.dart';
import 'rectangle.dart';
import 'polygon.dart';

// Repository imports
import '../repository/auth_repository.dart';

// Service imports
import '../service/keyword_search_service.dart';
import '../service/category_search_service.dart';
import '../service/address_search_service.dart';
import '../service/coord_2_address_service.dart';
import '../service/coord_2_region_code_service.dart';
import '../service/trans_coord_service.dart';

// Wrapper imports
import '../constants/wrapper.dart';

// JS Script imports
import '../js/js_global_variables.dart';
import '../js/js_map_init.dart';
import '../js/js_overlay_clear.dart';
import '../js/js_overlay_draw.dart';
import '../js/js_marker.dart';
import '../js/js_clusterer.dart';
import '../js/js_drawing.dart';
import '../js/js_custom_overlay.dart';
import '../js/js_map_control.dart';
import '../js/js_search.dart';
import '../js/js_utils.dart';

/// 카카오 지도 위젯입니다.
///
/// WebView 기반으로 카카오 맵 JavaScript API를 사용하여 지도를 표시합니다.
/// 다양한 오버레이(마커, 폴리라인, 원, 다각형 등)와 이벤트 콜백을 지원합니다.
///
/// 예시:
/// ```dart
/// KakaoMap(
///   onMapCreated: (controller) {
///     // 지도 생성 완료 후 컨트롤러를 사용하여 지도 제어
///   },
///   center: LatLng(37.5665, 126.9780),
///   currentLevel: 3,
///   markers: [
///     Marker(
///       markerId: 'marker1',
///       latLng: LatLng(37.5665, 126.9780),
///     ),
///   ],
///   onMarkerTap: (markerId, latLng, zoomLevel) {
///     print('마커 클릭: $markerId');
///   },
/// )
/// ```
class KakaoMap extends StatefulWidget {
  /// 지도 생성이 완료되었을 때 호출되는 콜백입니다.
  ///
  /// [KakaoMapController]를 통해 지도를 제어할 수 있습니다.
  final MapCreateCallback? onMapCreated;

  /// 지도를 클릭했을 때 호출되는 콜백입니다.
  ///
  /// 클릭한 위치의 [LatLng] 좌표를 반환합니다.
  final OnMapTap? onMapTap;

  /// 마커를 클릭했을 때 호출되는 콜백입니다.
  ///
  /// 마커 ID, 마커 위치, 현재 줌 레벨을 반환합니다.
  final OnMarkerTap? onMarkerTap;

  /// 마커 클러스터를 클릭했을 때 호출되는 콜백입니다.
  ///
  /// 클러스터의 중심 좌표, 줌 레벨, 클러스터에 포함된 마커 목록을 반환합니다.
  final OnMarkerClustererTap? onMarkerClustererTap;

  /// 지도를 더블 클릭했을 때 호출되는 콜백입니다.
  ///
  /// 클릭한 위치의 [LatLng] 좌표를 반환합니다.
  final OnMapDoubleTap? onMapDoubleTap;

  /// 커스텀 오버레이를 클릭했을 때 호출되는 콜백입니다.
  ///
  /// 오버레이 ID와 위치를 반환합니다.
  final OnCustomOverlayTap? onCustomOverlayTap;

  /// 지도의 중심 좌표나 레벨 이동이 끝났을 때 호출되는 콜백입니다.
  ///
  /// idle 이벤트 발생 시 현재 중심 좌표와 줌 레벨을 반환합니다.
  final OnCameraIdle? onCameraIdle;

  /// 지도 드래그 이벤트 콜백입니다.
  ///
  /// 드래그 시작(start), 드래그 중(move), 드래그 종료(end) 시점에 호출됩니다.
  final OnDragChangeCallback? onDragChangeCallback;

  /// 마커 드래그 이벤트 콜백입니다.
  ///
  /// 드래그 가능한 마커의 드래그 시작과 종료 시점에 호출됩니다.
  final OnMarkerDragChangeCallback? onMarkerDragChangeCallback;

  /// 줌 레벨 변경 이벤트 콜백입니다.
  ///
  /// 줌 시작(start)과 줌 종료(end) 시점에 호출됩니다.
  final OnZoomChangeCallback? onZoomChangeCallback;

  /// 지도 중심 좌표 변경 이벤트 콜백입니다.
  ///
  /// 중심 좌표가 변경될 때마다 호출됩니다.
  final OnCenterChangeCallback? onCenterChangeCallback;

  /// 지도 영역(bounds) 변경 이벤트 콜백입니다.
  ///
  /// 지도 영역이 변경될 때마다 호출됩니다.
  final OnBoundsChangeCallback? onBoundsChangeCallback;

  /// 타일 이미지 로드 완료 이벤트 콜백입니다.
  ///
  /// 지도 이동이나 줌 레벨 변경 후 타일 이미지 로드가 완료되면 호출됩니다.
  final OnTilesLoadedCallback? onTilesLoadedCallback;

  /// 지도 타입 컨트롤(일반지도/스카이뷰) 표시 여부입니다.
  ///
  /// 기본값은 false입니다.
  final bool? mapTypeControl;

  /// 지도 타입 컨트롤의 위치입니다.
  ///
  /// 기본값은 [ControlPosition.topRight]입니다.
  final ControlPosition mapTypeControlPosition;

  /// 줌 컨트롤 표시 여부입니다.
  ///
  /// 기본값은 false입니다.
  final bool? zoomControl;

  /// 줌 컨트롤의 위치입니다.
  ///
  /// 기본값은 [ControlPosition.right]입니다.
  final ControlPosition zoomControlPosition;

  /// 지도의 최소 줌 레벨입니다.
  ///
  /// 기본값은 0입니다. 값이 클수록 확대된 상태입니다.
  final int minLevel;

  /// 지도의 초기 줌 레벨입니다.
  ///
  /// 기본값은 3입니다. 값이 클수록 확대된 상태입니다.
  final int currentLevel;

  /// 지도의 최대 줌 레벨입니다.
  ///
  /// 기본값은 25입니다. 값이 클수록 확대된 상태입니다.
  final int maxLevel;

  /// 지도의 초기 중심 좌표입니다.
  ///
  /// 설정하지 않으면 제주도(33.450701, 126.570667)로 설정됩니다.
  final LatLng? center;

  /// 지도에 표시할 폴리라인 목록입니다.
  ///
  /// 선을 그려서 경로나 영역을 표시할 때 사용합니다.
  final List<Polyline>? polylines;

  /// 지도에 표시할 원 목록입니다.
  ///
  /// 반경을 가진 원형 영역을 표시할 때 사용합니다.
  final List<Circle>? circles;

  /// 지도에 표시할 사각형 목록입니다.
  ///
  /// 사각형 영역을 표시할 때 사용합니다.
  final List<Rectangle>? rectangles;

  /// 지도에 표시할 다각형 목록입니다.
  ///
  /// 임의의 다각형 영역을 표시할 때 사용합니다.
  final List<Polygon>? polygons;

  /// 지도에 표시할 마커 목록입니다.
  ///
  /// 특정 위치를 표시할 때 사용합니다.
  final List<Marker>? markers;

  /// 지도에 표시할 커스텀 오버레이 목록입니다.
  ///
  /// HTML 기반의 커스텀 UI를 지도에 표시할 때 사용합니다.
  final List<CustomOverlay>? customOverlays;

  /// 마커 클러스터러 설정입니다.
  ///
  /// 많은 마커를 그룹화하여 표시할 때 사용합니다.
  final Clusterer? clusterer;

  /// 도형 하나를 다 그렸을 때 호출되는 콜백입니다.
  ///
  /// Drawing 기능은 `KakaoMapController.createDrawingManager()` 로 시작합니다.
  final OnDrawingEnd? onDrawingEnd;

  /// 그려진 도형이 제거되었을 때 호출되는 콜백입니다.
  final OnDrawingRemove? onDrawingRemove;

  /// 그리기 상태(되돌리기 가능 여부 등)가 바뀌었을 때 호출되는 콜백입니다.
  final OnDrawingStateChange? onDrawingStateChange;

  /// 커스텀 오버레이의 닫기 버튼을 눌러 제거되었을 때 호출되는 콜백입니다.
  ///
  /// [CustomOverlay.removable] 이 true 인 오버레이에서만 발생합니다.
  final OnCustomOverlayRemove? onCustomOverlayRemove;

  /// 커스텀 오버레이를 드래그해 놓았을 때 호출되는 콜백입니다.
  ///
  /// [CustomOverlay.draggable] 이 true 인 오버레이에서만 발생합니다.
  final OnCustomOverlayDragEnd? onCustomOverlayDragEnd;

  /// 다각형을 탭했을 때 호출되는 콜백입니다.
  ///
  /// 다각형 ID, 탭한 좌표, 현재 줌 레벨을 반환합니다.
  final OnPolygonTap? onPolygonTap;

  /// 지도와 함께 불러올 카카오 SDK 확장 라이브러리입니다.
  ///
  /// 생략하면 [AuthRepository.libraries](기본값: 전체)를 사용하므로 기존과 동일하게
  /// 동작합니다. 사용하지 않는 라이브러리를 제외하면 지도 생성 시 다운로드/파싱
  /// 비용이 줄어듭니다.
  ///
  /// [clusterer]를 지정하면 [KakaoMapLibrary.clusterer]가 자동으로 포함됩니다.
  ///
  /// 예시:
  /// ```dart
  /// KakaoMap(libraries: {KakaoMapLibrary.services})
  /// ```
  final Set<KakaoMapLibrary>? libraries;

  /// Specifies which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map
  /// on pointer events, e.g. if the map is inside a [ListView] the [ListView]
  /// will want to handle vertical drags. The map will claim gestures that are
  /// recognized by any of the recognizers on this list.
  ///
  /// When this set is empty (default), the map will only handle pointer events
  /// for gestures that were not claimed by any other gesture recognizer.
  ///
  /// If you want the map to consume all gestures (previous behavior),
  /// set this to `{Factory(() => EagerGestureRecognizer())}`.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const KakaoMap({
    super.key,
    this.onMapCreated,
    this.onMapTap,
    this.onMarkerTap,
    this.onMarkerClustererTap,
    this.onMapDoubleTap,
    this.onCustomOverlayTap,
    this.onDragChangeCallback,
    this.onMarkerDragChangeCallback,
    this.onCameraIdle,
    this.onZoomChangeCallback,
    this.onCenterChangeCallback,
    this.onBoundsChangeCallback,
    this.onTilesLoadedCallback,
    this.mapTypeControl = false,
    this.mapTypeControlPosition = ControlPosition.topRight,
    this.zoomControl = false,
    this.zoomControlPosition = ControlPosition.right,
    this.minLevel = 0,
    this.currentLevel = 3,
    this.maxLevel = 25,
    this.center,
    this.polylines,
    this.circles,
    this.rectangles,
    this.polygons,
    this.markers,
    this.clusterer,
    this.customOverlays,
    this.onDrawingEnd,
    this.onDrawingRemove,
    this.onDrawingStateChange,
    this.onCustomOverlayRemove,
    this.onCustomOverlayDragEnd,
    this.onPolygonTap,
    this.libraries,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

/// `_syncOverlays()` 가 큐잉하는 오버레이 전송 작업 단위입니다.
///
/// [run] 은 실제 전송을 수행하고, [onFailure] 는 전송 실패 시 미리 갱신해 둔
/// 시그니처를 되돌려 다음 rebuild 에서 재시도되도록 합니다.
typedef _OverlaySyncTask = ({
  Future<void> Function() run,
  void Function() onFailure,
});

class _KakaoMapState extends State<KakaoMap> with WidgetsBindingObserver {
  late final KakaoMapController _mapController;
  bool _isMapReady = false;
  Timer? _relayoutTimer;

  // didUpdateWidget 경로의 relayout 요청을 트레일링 디바운스로 묶기 위한 타이머입니다.
  Timer? _relayoutDebounceTimer;

  // 마지막으로 측정된 레이아웃 제약 크기. 값이 바뀌면 즉시 relayout 합니다.
  Size? _lastLayoutSize;

  // 마지막으로 JS 에 적용된 카메라 상태. 지도 준비 전 변경도 준비 시점에 반영합니다.
  LatLng? _appliedCenter;
  late int _appliedLevel;

  // 오버레이 동기화를 직렬화하는 체인. 호출 순서를 보장하고 unhandled error 를 막습니다.
  Future<void> _syncChain = Future<void>.value();

  // 마지막으로 JS 에 전송한 오버레이 시그니처. 같은 내용이면 재전송하지 않습니다.
  int? _polylinesSig;
  int? _circlesSig;
  int? _rectanglesSig;
  int? _polygonsSig;
  int? _markersSig;
  int? _clustererSig;
  int? _customOverlaysSig;

  @override
  void initState() {
    super.initState();
    // Add observer to handle app lifecycle changes (for iOS WebView touch event issues)
    WidgetsBinding.instance.addObserver(this);
    _appliedCenter = widget.center;
    _appliedLevel = widget.currentLevel;
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _relayoutTimer?.cancel();
    _relayoutDebounceTimer?.cancel();
    // WebView 가 먼저 파괴된 경우 JS 실행이 실패할 수 있으므로 오류를 무시합니다.
    unawaited(_mapController.dispose().catchError((_) {}));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes to fix WebView rendering issues
    // when returning from background (Flutter 3.27+ issue)
    if (state == AppLifecycleState.resumed && _isMapReady) {
      // Trigger relayout to fix potential rendering issues
      _relayoutTimer?.cancel();
      _relayoutTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted && _isMapReady) {
          _mapController.relayout();
        }
      });
    }
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    // dispose() 가 항상 초기화된 컨트롤러를 보도록 HTML 로드보다 먼저 대입합니다.
    _mapController = KakaoMapController(controller);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
    addJavaScriptChannels(controller);
    controller.loadHtmlString(_loadMap(),
        baseUrl: AuthRepository.instance.baseUrl);

    if (controller.platform is AndroidWebViewController) {
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Set display mode to ensure proper rendering on Android (Flutter 3.27+ fix)
      androidController
          .setOnPlatformPermissionRequest((PlatformWebViewPermissionRequest request) async {
        await request.grant();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        if (_isMapReady &&
            _lastLayoutSize != null &&
            _lastLayoutSize != size) {
          // 제약이 실제로 바뀐 경우(회전, 부모 위젯 리사이즈 등)에는 디바운스 없이
          // 다음 프레임에 즉시 relayout 합니다.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isMapReady) {
              _mapController.relayout();
            }
          });
        }
        _lastLayoutSize = size;

        return WebViewWidget(
          controller: _mapController.webViewController,
          gestureRecognizers: widget.gestureRecognizers,
        );
      },
    );
  }

  /// 이 지도가 실제로 불러올 라이브러리 집합입니다.
  ///
  /// 위젯 지정값이 없으면 [AuthRepository.libraries]를 쓰고,
  /// [KakaoMap.clusterer]가 있으면 클러스터러를 자동으로 포함합니다.
  Set<KakaoMapLibrary> get _effectiveLibraries {
    final base = widget.libraries ?? AuthRepository.instance.libraries;
    if (widget.clusterer != null &&
        !base.contains(KakaoMapLibrary.clusterer)) {
      return {...base, KakaoMapLibrary.clusterer};
    }
    return base;
  }

  String _loadMap() {
    return htmlWrapper(libraries: _effectiveLibraries, '''<script>
    ${JsGlobalVariables.getScript()}
    ${JsMapInit.getScript(
      center: widget.center,
      currentLevel: widget.currentLevel,
      mapTypeControl: widget.mapTypeControl,
      mapTypeControlPosition: widget.mapTypeControlPosition,
      zoomControl: widget.zoomControl,
      zoomControlPosition: widget.zoomControlPosition,
      minLevel: widget.minLevel,
      maxLevel: widget.maxLevel,
      hasOnCenterChangeCallback: widget.onCenterChangeCallback != null,
      hasOnZoomChangeCallback: widget.onZoomChangeCallback != null,
      hasOnBoundsChangeCallback: widget.onBoundsChangeCallback != null,
      hasOnMapTap: widget.onMapTap != null,
      hasOnDragChangeCallback: widget.onDragChangeCallback != null,
      hasOnCameraIdle: widget.onCameraIdle != null,
      hasOnTilesLoadedCallback: widget.onTilesLoadedCallback != null,
      hasOnMapDoubleTap: widget.onMapDoubleTap != null,
      isIOS: defaultTargetPlatform == TargetPlatform.iOS,
    )}
    ${JsOverlayClear.getScript()}
    ${JsOverlayDraw.getScript(
      hasPolygonTapCallback: widget.onPolygonTap != null,
    )}
    ${JsMarker.getScript(
      hasMarkerDragCallback: widget.onMarkerDragChangeCallback != null,
      hasMarkerTapCallback: widget.onMarkerTap != null,
    )}
    ${JsClusterer.getScript(
      hasCustomOverlayTapCallback: widget.onCustomOverlayTap != null,
      hasMarkerClustererTapCallback: widget.onMarkerClustererTap != null,
    )}
    ${JsCustomOverlay.getScript(
      hasCustomOverlayTapCallback: widget.onCustomOverlayTap != null,
      hasCustomOverlayRemoveCallback: widget.onCustomOverlayRemove != null,
      hasCustomOverlayDragEndCallback: widget.onCustomOverlayDragEnd != null,
    )}
    ${JsMapControl.getScript(isIOS: defaultTargetPlatform == TargetPlatform.iOS)}
    ${JsUtils.getScript(isIOS: defaultTargetPlatform == TargetPlatform.iOS)}
    ${JsDrawing.getScript(
      hasDrawEndCallback: widget.onDrawingEnd != null,
      hasDrawRemoveCallback: widget.onDrawingRemove != null,
      hasDrawStateChangeCallback: widget.onDrawingStateChange != null,
      isIOS: defaultTargetPlatform == TargetPlatform.iOS,
    )}
    ${JsSearch.getScript()}
</script>
    ''');
  }

  @override
  void didUpdateWidget(KakaoMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isMapReady) {
      // 지도 준비 전에는 JS 함수가 없으므로 보류합니다. onMapCreated 시점에 동기화됩니다.
      return;
    }

    _syncCamera();

    // 가시성 복구 시 지도 크기 재계산 (IndexedStack 등에서 필요).
    // 제약이 실제로 바뀐 경우는 build() 에서 즉시 처리되므로, 여기서는 매
    // rebuild 마다 발생하는 relayout 비용을 줄이기 위해 150ms 트레일링
    // 디바운스로 코얼레싱합니다. (생략이 아니라 지연 후 1회 실행)
    _scheduleDebouncedRelayout();

    // 오버레이 업데이트 (내용이 바뀐 종류만 전송)
    _syncOverlays();
  }

  /// `didUpdateWidget` 에서의 relayout 요청을 150ms 트레일링 디바운스로 묶습니다.
  ///
  /// IndexedStack 탭 복귀처럼 레이아웃 제약이 바뀌지 않는 rebuild 에서도
  /// relayout 이 최소 한 번은 실행되어야 하므로, 요청을 "생략"하지 않고
  /// 마지막 요청으로부터 150ms 뒤에 한 번만 실행되도록 합니다.
  void _scheduleDebouncedRelayout() {
    _relayoutDebounceTimer?.cancel();
    _relayoutDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted && _isMapReady) {
        _mapController.relayout();
      }
    });
  }

  /// center / currentLevel 속성을 마지막 적용값과 비교해 바뀐 경우에만 JS 에 반영합니다.
  void _syncCamera() {
    if (!_isMapReady) return;

    final center = widget.center;
    if (center != null && !_sameLatLng(center, _appliedCenter)) {
      _appliedCenter = center;
      _mapController.setCenter(center);
    }

    if (widget.currentLevel != _appliedLevel) {
      _appliedLevel = widget.currentLevel;
      _mapController.setLevel(widget.currentLevel);
    }
  }

  static bool _sameLatLng(LatLng? a, LatLng? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }

  /// 위젯 속성의 오버레이들을 JS 와 동기화합니다.
  ///
  /// 각 오버레이 종류별로 내용 시그니처를 계산해 마지막 전송값과 다를 때만
  /// 컨트롤러 메서드를 호출합니다. 부모 위젯의 무관한 rebuild 로 인한
  /// 전량 재전송을 방지합니다.
  void _syncOverlays() {
    if (!_isMapReady) return;

    // 시그니처 비교와 "전송 중" 표시는 동기적으로 수행하고, 실제 전송만 체인에
    // 직렬로 붙입니다. 시그니처는 전송 성공 여부와 무관하게 먼저 갱신해 같은
    // 내용이 중복 전송되는 것을 막고, 전송이 실패하면 onFailure 에서 되돌려
    // 다음 rebuild 때 재시도되도록 합니다.
    final tasks = <_OverlaySyncTask>[];

    final polylinesSig = OverlayPayload.polylinesSignature(widget.polylines);
    if (polylinesSig != _polylinesSig) {
      final previousSig = _polylinesSig;
      _polylinesSig = polylinesSig;
      if (previousSig != null && polylinesSig == null) {
        // 리스트가 null 로 바뀐 전이: addPolyline(null) 은 무시되므로 직접 비웁니다.
        tasks.add((
          run: () => _mapController.clearPolyline(polylineIds: const []),
          onFailure: () {
            if (_polylinesSig == polylinesSig) _polylinesSig = null;
          },
        ));
      } else {
        final polylines = widget.polylines;
        tasks.add((
          run: () => _mapController.addPolyline(polylines: polylines),
          onFailure: () {
            if (_polylinesSig == polylinesSig) _polylinesSig = null;
          },
        ));
      }
    }

    final circlesSig = OverlayPayload.circlesSignature(widget.circles);
    if (circlesSig != _circlesSig) {
      final previousSig = _circlesSig;
      _circlesSig = circlesSig;
      if (previousSig != null && circlesSig == null) {
        tasks.add((
          run: () => _mapController.clearCircle(circleIds: const []),
          onFailure: () {
            if (_circlesSig == circlesSig) _circlesSig = null;
          },
        ));
      } else {
        final circles = widget.circles;
        tasks.add((
          run: () => _mapController.addCircle(circles: circles),
          onFailure: () {
            if (_circlesSig == circlesSig) _circlesSig = null;
          },
        ));
      }
    }

    final rectanglesSig =
        OverlayPayload.rectanglesSignature(widget.rectangles);
    if (rectanglesSig != _rectanglesSig) {
      final previousSig = _rectanglesSig;
      _rectanglesSig = rectanglesSig;
      if (previousSig != null && rectanglesSig == null) {
        tasks.add((
          run: () => _mapController.clearRectangle(rectangleIds: const []),
          onFailure: () {
            if (_rectanglesSig == rectanglesSig) _rectanglesSig = null;
          },
        ));
      } else {
        final rectangles = widget.rectangles;
        tasks.add((
          run: () => _mapController.addRectangle(rectangles: rectangles),
          onFailure: () {
            if (_rectanglesSig == rectanglesSig) _rectanglesSig = null;
          },
        ));
      }
    }

    final polygonsSig = OverlayPayload.polygonsSignature(widget.polygons);
    if (polygonsSig != _polygonsSig) {
      final previousSig = _polygonsSig;
      _polygonsSig = polygonsSig;
      if (previousSig != null && polygonsSig == null) {
        tasks.add((
          run: () => _mapController.clearPolygon(polygonIds: const []),
          onFailure: () {
            if (_polygonsSig == polygonsSig) _polygonsSig = null;
          },
        ));
      } else {
        final polygons = widget.polygons;
        tasks.add((
          run: () => _mapController.addPolygon(polygons: polygons),
          onFailure: () {
            if (_polygonsSig == polygonsSig) _polygonsSig = null;
          },
        ));
      }
    }

    final markersSig = OverlayPayload.markersSignature(widget.markers);
    if (markersSig != _markersSig) {
      final previousSig = _markersSig;
      _markersSig = markersSig;
      if (previousSig != null && markersSig == null) {
        tasks.add((
          run: () => _mapController.clearMarker(markerIds: const []),
          onFailure: () {
            if (_markersSig == markersSig) _markersSig = null;
          },
        ));
      } else {
        final markers = widget.markers;
        tasks.add((
          run: () => _mapController.addMarker(markers: markers),
          onFailure: () {
            if (_markersSig == markersSig) _markersSig = null;
          },
        ));
      }
    }

    final clustererSig = OverlayPayload.clustererSignature(widget.clusterer);
    if (clustererSig != _clustererSig) {
      final previousSig = _clustererSig;
      _clustererSig = clustererSig;
      if (previousSig != null && clustererSig == null) {
        tasks.add((
          run: () => _mapController.clearMarkerClusterer(),
          onFailure: () {
            if (_clustererSig == clustererSig) _clustererSig = null;
          },
        ));
      } else {
        final clusterer = widget.clusterer;
        tasks.add((
          run: () => _mapController.addMarkerClusterer(clusterer: clusterer),
          onFailure: () {
            if (_clustererSig == clustererSig) _clustererSig = null;
          },
        ));
      }
    }

    final customOverlaysSig =
        OverlayPayload.customOverlaysSignature(widget.customOverlays);
    if (customOverlaysSig != _customOverlaysSig) {
      final previousSig = _customOverlaysSig;
      _customOverlaysSig = customOverlaysSig;
      if (previousSig != null && customOverlaysSig == null) {
        tasks.add((
          run: () => _mapController.clearCustomOverlay(overlayIds: const []),
          onFailure: () {
            if (_customOverlaysSig == customOverlaysSig) {
              _customOverlaysSig = null;
            }
          },
        ));
      } else {
        final customOverlays = widget.customOverlays;
        tasks.add((
          run: () =>
              _mapController.addCustomOverlay(customOverlays: customOverlays),
          onFailure: () {
            if (_customOverlaysSig == customOverlaysSig) {
              _customOverlaysSig = null;
            }
          },
        ));
      }
    }

    if (tasks.isEmpty) return;

    _syncChain = _syncChain.then((_) async {
      for (final task in tasks) {
        if (!mounted) return;
        try {
          await task.run();
        } catch (e, st) {
          // WebView 가 파괴된 뒤 도착한 호출 등은 무시하고 나머지 동기화를 계속합니다.
          task.onFailure();
          assert(() {
            debugPrint('KakaoMap overlay sync failed: $e\n$st');
            return true;
          }());
        }
      }
    });
  }

  /// JavaScriptChannel 콜백 처리 공통 헬퍼입니다.
  ///
  /// WebView 콜백 컨텍스트에서 발생한 JSON 파싱/콜백 실행 예외가 앱 크래시로
  /// 이어지지 않도록 방어하고, 위젯이 이미 dispose 된 경우 무시합니다.
  void _handleChannel<T>(
    String raw,
    T Function(Map<String, dynamic>) parse,
    void Function(T data) emit,
  ) {
    if (!mounted) return;
    try {
      emit(parse(jsonDecode(raw) as Map<String, dynamic>));
    } catch (e, st) {
      assert(() {
        debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
        return true;
      }());
    }
  }

  void addJavaScriptChannels(WebViewController controller) {
    controller
      ..addJavaScriptChannel('onMapCreated',
          onMessageReceived: (JavaScriptMessage result) {
        // 이 채널은 아래 두 시나리오에서 발화합니다.
        // 1) 최초 지도 생성 완료
        // 2) WebView 재로드(사용자의 reload() 호출, Android 렌더러 프로세스
        //    복구 등)로 window.onload 가 다시 실행된 경우
        // 구조가 다른 채널들과 달라 _handleChannel 로 감싸지 않고 별도로
        // 처리하되, mounted 확인은 동일하게 유지합니다.
        if (!mounted) return;
        final wasAlreadyReady = _isMapReady;
        _isMapReady = true;
        if (wasAlreadyReady) {
          // 재로드로 JS 쪽 상태는 초기화됐지만 Dart 쪽 오버레이 시그니처
          // 캐시는 남아있어 _syncOverlays() 가 "변경 없음"으로 판단하고
          // 아무것도 다시 그리지 않을 수 있으므로 캐시를 모두 무효화합니다.
          _polylinesSig = null;
          _circlesSig = null;
          _rectanglesSig = null;
          _polygonsSig = null;
          _markersSig = null;
          _clustererSig = null;
          _customOverlaysSig = null;
          _appliedCenter = null;
          // WebView 안에 등록해 둔 이미지 키 등 JS 쪽 캐시도 함께 비웁니다.
          _mapController.resetWebViewSideCaches();
        }
        // WebView 가 실제 크기를 갖기 전에 지도가 만들어졌을 수 있으므로
        // 준비 직후 한 번은 반드시 크기를 재계산합니다. (이후 rebuild 는 코얼레싱)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isMapReady) {
            _mapController.relayout();
          }
        });
        // 지도 준비 전(혹은 재로드 전)에 바뀐 카메라/오버레이 속성을 반영합니다.
        _syncCamera();
        _syncOverlays();
        // 사용자 onMapCreated 콜백은 위젯 속성 기반 동기화(오버레이 전송)가
        // 끝난 뒤 실행되도록 체인 뒤에 붙입니다. 콜백 안에서
        // controller.addMarker() 등을 호출해도 위젯 동기화와 순서가 섞이지
        // 않습니다.
        _syncChain = _syncChain.then((_) {
          if (!mounted) return;
          if (widget.onMapCreated != null) {
            widget.onMapCreated!(_mapController);
          }
        });
      })
      ..addJavaScriptChannel('onMapTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_MapTapEventData>(
          result.message,
          _MapTapEventData.fromJson,
          (data) => widget.onMapTap?.call(data.toLatLng()),
        );
      })
      ..addJavaScriptChannel('onMapDoubleTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_MapTapEventData>(
          result.message,
          _MapTapEventData.fromJson,
          (data) => widget.onMapDoubleTap?.call(data.toLatLng()),
        );
      })
      ..addJavaScriptChannel('onMarkerTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_MarkerTapEventData>(
          result.message,
          _MarkerTapEventData.fromJson,
          (data) => widget.onMarkerTap?.call(
            data.markerId,
            data.toLatLng(),
            data.zoomLevel,
          ),
        );
      })
      ..addJavaScriptChannel('onMarkerClustererTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_ClusterTapEventData>(
          result.message,
          _ClusterTapEventData.fromJson,
          (data) => widget.onMarkerClustererTap?.call(
            data.toLatLng(),
            data.zoomLevel,
            widget.clusterer?.getMarkersByIds(data.markerIds) ?? [],
          ),
        );
      })
      ..addJavaScriptChannel('onCustomOverlayTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_CustomOverlayTapEventData>(
          result.message,
          _CustomOverlayTapEventData.fromJson,
          (data) => widget.onCustomOverlayTap?.call(
            data.customOverlayId,
            data.toLatLng(),
          ),
        );
      })
      ..addJavaScriptChannel('onDrawingEnd',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<DrawingOverlayType?>(
          result.message,
          (json) => DrawingOverlayType.fromValue(json['type']?.toString() ?? ''),
          (type) => widget.onDrawingEnd?.call(type),
        );
      })
      ..addJavaScriptChannel('onDrawingRemove',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<bool>(
          result.message,
          (json) => true,
          (_) => widget.onDrawingRemove?.call(),
        );
      })
      ..addJavaScriptChannel('onDrawingStateChange',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<bool>(
          result.message,
          (json) => true,
          (_) => widget.onDrawingStateChange?.call(),
        );
      })
      ..addJavaScriptChannel('onCustomOverlayRemove',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<String>(
          result.message,
          (json) => json['customOverlayId'] as String,
          (id) => widget.onCustomOverlayRemove?.call(id),
        );
      })
      ..addJavaScriptChannel('onCustomOverlayDragEnd',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_CustomOverlayTapEventData>(
          result.message,
          _CustomOverlayTapEventData.fromJson,
          (data) => widget.onCustomOverlayDragEnd?.call(
            data.customOverlayId,
            data.toLatLng(),
          ),
        );
      })
      ..addJavaScriptChannel('onPolygonTap',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_PolygonTapEventData>(
          result.message,
          _PolygonTapEventData.fromJson,
          (data) => widget.onPolygonTap?.call(
            data.polygonId,
            data.toLatLng(),
            data.zoomLevel,
          ),
        );
      })
      ..addJavaScriptChannel('onMarkerDragChangeCallback',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_MarkerDragEventData>(
          result.message,
          _MarkerDragEventData.fromJson,
          (data) => widget.onMarkerDragChangeCallback?.call(
            data.markerId,
            data.toLatLng(),
            data.zoomLevel,
            data.dragType,
          ),
        );
      })
      ..addJavaScriptChannel('zoomStart',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_ZoomEventData>(
          result.message,
          _ZoomEventData.fromJson,
          (data) =>
              widget.onZoomChangeCallback?.call(data.zoomLevel, ZoomType.start),
        );
      })
      ..addJavaScriptChannel('zoomChanged',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_ZoomEventData>(
          result.message,
          _ZoomEventData.fromJson,
          (data) =>
              widget.onZoomChangeCallback?.call(data.zoomLevel, ZoomType.end),
        );
      })
      ..addJavaScriptChannel('centerChanged',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_CenterChangeEventData>(
          result.message,
          _CenterChangeEventData.fromJson,
          (data) => widget.onCenterChangeCallback
              ?.call(data.toLatLng(), data.zoomLevel),
        );
      })
      ..addJavaScriptChannel('boundsChanged',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_BoundsChangeEventData>(
          result.message,
          _BoundsChangeEventData.fromJson,
          (data) => widget.onBoundsChangeCallback?.call(data.toLatLngBounds()),
        );
      })
      ..addJavaScriptChannel('dragStart',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_DragEventData>(
          result.message,
          _DragEventData.fromJson,
          (data) => widget.onDragChangeCallback?.call(
            data.toLatLng(),
            data.zoomLevel,
            DragType.start,
          ),
        );
      })
      ..addJavaScriptChannel('drag',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_DragEventData>(
          result.message,
          _DragEventData.fromJson,
          (data) => widget.onDragChangeCallback?.call(
            data.toLatLng(),
            data.zoomLevel,
            DragType.move,
          ),
        );
      })
      ..addJavaScriptChannel('dragEnd',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_DragEventData>(
          result.message,
          _DragEventData.fromJson,
          (data) => widget.onDragChangeCallback?.call(
            data.toLatLng(),
            data.zoomLevel,
            DragType.end,
          ),
        );
      })
      ..addJavaScriptChannel('cameraIdle',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_DragEventData>(
          result.message,
          _DragEventData.fromJson,
          (data) => widget.onCameraIdle?.call(data.toLatLng(), data.zoomLevel),
        );
      })
      ..addJavaScriptChannel('tilesLoaded',
          onMessageReceived: (JavaScriptMessage result) {
        _handleChannel<_DragEventData>(
          result.message,
          _DragEventData.fromJson,
          (data) =>
              widget.onTilesLoadedCallback?.call(data.toLatLng(), data.zoomLevel),
        );
      })
      ..addJavaScriptChannel("keywordSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          KeywordSearchService.keywordSearchCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      })
      ..addJavaScriptChannel("categorySearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          CategorySearchService.categorySearchCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      })
      ..addJavaScriptChannel("addressSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          AddressSearchService.addressSearchCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      })
      ..addJavaScriptChannel("coord2AddressCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          Coord2AddressService.coord2AddressCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      })
      ..addJavaScriptChannel("coord2RegionCodeCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          Coord2RegionCodeService.coord2RegionCodeCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      })
      ..addJavaScriptChannel("transCoordCallback",
          onMessageReceived: (JavaScriptMessage result) {
        if (!mounted) return;
        try {
          TransCoordService.transCodeCallback(result.message);
        } catch (e, st) {
          assert(() {
            debugPrint('KakaoMap 채널 메시지 처리 실패: $e\n$st');
            return true;
          }());
        }
      });
  }
}

// ========================================
// Internal Event Data Classes
// ========================================

/// 지도 탭 이벤트 내부 데이터 클래스입니다.
class _MapTapEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _MapTapEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _MapTapEventData.fromJson(Map<String, dynamic> json) {
    return _MapTapEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 탭 이벤트 내부 데이터 클래스입니다.
class _MarkerTapEventData {
  final String markerId;
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _MarkerTapEventData({
    required this.markerId,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _MarkerTapEventData.fromJson(Map<String, dynamic> json) {
    return _MarkerTapEventData(
      markerId: json['markerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 클러스터 탭 이벤트 내부 데이터 클래스입니다.
class _ClusterTapEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final List<String> markerIds;

  const _ClusterTapEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.markerIds,
  });

  factory _ClusterTapEventData.fromJson(Map<String, dynamic> json) {
    return _ClusterTapEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
      markerIds: (json['markers'] as List<dynamic>).cast<String>(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 커스텀 오버레이 탭 이벤트 내부 데이터 클래스입니다.
class _CustomOverlayTapEventData {
  final String customOverlayId;
  final double latitude;
  final double longitude;

  const _CustomOverlayTapEventData({
    required this.customOverlayId,
    required this.latitude,
    required this.longitude,
  });

  factory _CustomOverlayTapEventData.fromJson(Map<String, dynamic> json) {
    return _CustomOverlayTapEventData(
      customOverlayId: json['customOverlayId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 마커 드래그 이벤트 내부 데이터 클래스입니다.
class _MarkerDragEventData {
  final String markerId;
  final double latitude;
  final double longitude;
  final int zoomLevel;
  final MarkerDragType dragType;

  const _MarkerDragEventData({
    required this.markerId,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.dragType,
  });

  factory _MarkerDragEventData.fromJson(Map<String, dynamic> json) {
    return _MarkerDragEventData(
      markerId: json['markerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
      dragType: json['drag'] == 'dragstart'
          ? MarkerDragType.start
          : MarkerDragType.end,
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 드래그 이벤트 내부 데이터 클래스입니다.
class _DragEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _DragEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _DragEventData.fromJson(Map<String, dynamic> json) {
    return _DragEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 줌 이벤트 내부 데이터 클래스입니다.
class _ZoomEventData {
  final int zoomLevel;

  const _ZoomEventData({required this.zoomLevel});

  factory _ZoomEventData.fromJson(Map<String, dynamic> json) {
    return _ZoomEventData(
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }
}

/// 중심 변경 이벤트 내부 데이터 클래스입니다.
class _CenterChangeEventData {
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _CenterChangeEventData({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _CenterChangeEventData.fromJson(Map<String, dynamic> json) {
    return _CenterChangeEventData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// 경계 변경 이벤트 내부 데이터 클래스입니다.
class _BoundsChangeEventData {
  final double swLatitude;
  final double swLongitude;
  final double neLatitude;
  final double neLongitude;

  const _BoundsChangeEventData({
    required this.swLatitude,
    required this.swLongitude,
    required this.neLatitude,
    required this.neLongitude,
  });

  factory _BoundsChangeEventData.fromJson(Map<String, dynamic> json) {
    final sw = json['sw'] as Map<String, dynamic>;
    final ne = json['ne'] as Map<String, dynamic>;
    return _BoundsChangeEventData(
      swLatitude: (sw['latitude'] as num).toDouble(),
      swLongitude: (sw['longitude'] as num).toDouble(),
      neLatitude: (ne['latitude'] as num).toDouble(),
      neLongitude: (ne['longitude'] as num).toDouble(),
    );
  }

  LatLngBounds toLatLngBounds() => LatLngBounds(
        LatLng(swLatitude, swLongitude),
        LatLng(neLatitude, neLongitude),
      );
}

/// 다각형 탭 이벤트 내부 데이터 클래스입니다.
class _PolygonTapEventData {
  final String polygonId;
  final double latitude;
  final double longitude;
  final int zoomLevel;

  const _PolygonTapEventData({
    required this.polygonId,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });

  factory _PolygonTapEventData.fromJson(Map<String, dynamic> json) {
    return _PolygonTapEventData(
      polygonId: json['polygonId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toInt(),
    );
  }

  LatLng toLatLng() => LatLng(latitude, longitude);
}
