import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'constants/drag_type.dart';
import 'constants/marker_drag_type.dart';
import 'constants/zoom_type.dart';

// Controller imports
import 'kakao_map_controller.dart';

// Clusterer imports
import 'clusterer.dart';

// Marker and overlay imports
import 'marker.dart';
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
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> with WidgetsBindingObserver {
  late final KakaoMapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // Add observer to handle app lifecycle changes (for iOS WebView touch event issues)
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes to fix WebView rendering issues
    // when returning from background (Flutter 3.27+ issue)
    if (state == AppLifecycleState.resumed && _isMapReady) {
      // Trigger relayout to fix potential rendering issues
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));
    addJavaScriptChannels(controller);
    controller.loadHtmlString(_loadMap(),
        baseUrl: AuthRepository.instance.baseUrl);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Set display mode to ensure proper rendering on Android (Flutter 3.27+ fix)
      androidController
          .setOnPlatformPermissionRequest((PlatformWebViewPermissionRequest request) async {
        await request.grant();
      });
    }

    _mapController = KakaoMapController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _mapController.webViewController,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  String _loadMap() {
    return htmlWrapper('''<script>
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
      isIOS: Platform.isIOS,
    )}
    ${JsOverlayClear.getScript()}
    ${JsOverlayDraw.getScript()}
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
    )}
    ${JsMapControl.getScript(isIOS: Platform.isIOS)}
    ${JsUtils.getScript(isIOS: Platform.isIOS)}
    ${JsSearch.getScript()}
</script>
    ''');
  }

  @override
  void didUpdateWidget(KakaoMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 중심 좌표 변경 감지 및 적용
    if (widget.center != oldWidget.center && widget.center != null) {
      _mapController.setCenter(widget.center!);
    }

    // 줌 레벨 변경 감지 및 적용
    if (widget.currentLevel != oldWidget.currentLevel) {
      _mapController.setLevel(widget.currentLevel);
    }

    // 가시성 복구 시 지도 크기 재계산 (IndexedStack 등에서 필요)
    _mapController.relayout();

    // 오버레이 업데이트
    _mapController.addPolyline(polylines: widget.polylines);
    _mapController.addCircle(circles: widget.circles);
    _mapController.addRectangle(rectangles: widget.rectangles);
    _mapController.addPolygon(polygons: widget.polygons);
    _mapController.addMarker(markers: widget.markers);
    _mapController.addMarkerClusterer(clusterer: widget.clusterer);
    _mapController.addCustomOverlay(customOverlays: widget.customOverlays);
  }

  void addJavaScriptChannels(WebViewController controller) {
    controller
      ..addJavaScriptChannel('onMapCreated',
          onMessageReceived: (JavaScriptMessage result) {
        _isMapReady = true;
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(_mapController);
        }
      })
      ..addJavaScriptChannel('onMapTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMapTap != null) {
          final data = _MapTapEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onMapTap!(data.toLatLng());
        }
      })
      ..addJavaScriptChannel('onMapDoubleTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMapDoubleTap != null) {
          final data = _MapTapEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onMapDoubleTap!(data.toLatLng());
        }
      })
      ..addJavaScriptChannel('onMarkerTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerTap != null) {
          final data = _MarkerTapEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onMarkerTap!(
            data.markerId,
            data.toLatLng(),
            data.zoomLevel,
          );
        }
      })
      ..addJavaScriptChannel('onMarkerClustererTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerClustererTap != null) {
          final data = _ClusterTapEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onMarkerClustererTap!(
            data.toLatLng(),
            data.zoomLevel,
            widget.clusterer?.getMarkersByIds(data.markerIds) ?? [],
          );
        }
      })
      ..addJavaScriptChannel('onCustomOverlayTap',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCustomOverlayTap != null) {
          final data = _CustomOverlayTapEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onCustomOverlayTap!(
            data.customOverlayId,
            data.toLatLng(),
          );
        }
      })
      ..addJavaScriptChannel('onMarkerDragChangeCallback',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onMarkerDragChangeCallback != null) {
          final data = _MarkerDragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onMarkerDragChangeCallback!(
            data.markerId,
            data.toLatLng(),
            data.zoomLevel,
            data.dragType,
          );
        }
      })
      ..addJavaScriptChannel('zoomStart',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onZoomChangeCallback != null) {
          final data = _ZoomEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onZoomChangeCallback!(data.zoomLevel, ZoomType.start);
        }
      })
      ..addJavaScriptChannel('zoomChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onZoomChangeCallback != null) {
          final data = _ZoomEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onZoomChangeCallback!(data.zoomLevel, ZoomType.end);
        }
      })
      ..addJavaScriptChannel('centerChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCenterChangeCallback != null) {
          final data = _CenterChangeEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onCenterChangeCallback!(data.toLatLng(), data.zoomLevel);
        }
      })
      ..addJavaScriptChannel('boundsChanged',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onBoundsChangeCallback != null) {
          final data = _BoundsChangeEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onBoundsChangeCallback!(data.toLatLngBounds());
        }
      })
      ..addJavaScriptChannel('dragStart',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          final data = _DragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onDragChangeCallback!(
            data.toLatLng(),
            data.zoomLevel,
            DragType.start,
          );
        }
      })
      ..addJavaScriptChannel('drag',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          final data = _DragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onDragChangeCallback!(
            data.toLatLng(),
            data.zoomLevel,
            DragType.move,
          );
        }
      })
      ..addJavaScriptChannel('dragEnd',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onDragChangeCallback != null) {
          final data = _DragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onDragChangeCallback!(
            data.toLatLng(),
            data.zoomLevel,
            DragType.end,
          );
        }
      })
      ..addJavaScriptChannel('cameraIdle',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onCameraIdle != null) {
          final data = _DragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onCameraIdle!(data.toLatLng(), data.zoomLevel);
        }
      })
      ..addJavaScriptChannel('tilesLoaded',
          onMessageReceived: (JavaScriptMessage result) {
        if (widget.onTilesLoadedCallback != null) {
          final data = _DragEventData.fromJson(
            jsonDecode(result.message) as Map<String, dynamic>,
          );
          widget.onTilesLoadedCallback!(data.toLatLng(), data.zoomLevel);
        }
      })
      ..addJavaScriptChannel("keywordSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        KeywordSearchService.keywordSearchCallback(result.message);
      })
      ..addJavaScriptChannel("categorySearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        CategorySearchService.categorySearchCallback(result.message);
      })
      ..addJavaScriptChannel("addressSearchCallback",
          onMessageReceived: (JavaScriptMessage result) {
        AddressSearchService.addressSearchCallback(result.message);
      })
      ..addJavaScriptChannel("coord2AddressCallback",
          onMessageReceived: (JavaScriptMessage result) {
        Coord2AddressService.coord2AddressCallback(result.message);
      })
      ..addJavaScriptChannel("coord2RegionCodeCallback",
          onMessageReceived: (JavaScriptMessage result) {
        Coord2RegionCodeService.coord2RegionCodeCallback(result.message);
      })
      ..addJavaScriptChannel("transCoordCallback",
          onMessageReceived: (JavaScriptMessage result) {
        TransCoordService.transCodeCallback(result.message);
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
