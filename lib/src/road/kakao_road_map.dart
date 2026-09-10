import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../basic/callbacks.dart';
import '../basic/custom_overlay.dart';
import '../basic/kakao_map_controller.dart';
import '../bridge/bridge_factory.dart';
import '../bridge/kakao_map_bridge.dart';
import '../bridge/platform_flags.dart';
import '../basic/marker.dart';
import '../constants/wrapper.dart';
import '../js/roadview/js_roadview_event.dart';
import '../js/roadview/js_roadview_init.dart';
import '../js/roadview/js_roadview_overlay.dart';
import '../model/lat_lng.dart';
import '../model/viewpoint.dart';
import '../repository/auth_repository.dart';
import 'kakao_roadview_controller.dart';

/// 카카오 로드뷰를 표시하는 위젯입니다.
///
/// [center] 좌표에서 가장 가까운 로드뷰를 찾아 표시합니다. [panoId]를 직접
/// 지정하면 해당 파노라마를 표시합니다.
///
/// 주변에 로드뷰가 없으면 [onRoadviewNotFound] 가 호출되며 화면은 비어 있습니다.
///
/// 예시:
/// ```dart
/// KakaoRoadMap(
///   center: LatLng(33.450701, 126.570667),
///   viewpoint: const Viewpoint(pan: 90),
///   onRoadviewCreated: (controller) async {
///     await controller.addMarker(markers: [
///       Marker(
///         markerId: 'm1',
///         latLng: LatLng(33.450701, 126.570667),
///         infoWindowContent: '<div style="padding:5px">여기</div>',
///         altitude: 3,
///         range: 100,
///       ),
///     ]);
///   },
///   onRoadviewNotFound: (latLng) {
///     debugPrint('이 위치에는 로드뷰가 없습니다: $latLng');
///   },
/// )
/// ```
class KakaoRoadMap extends StatefulWidget {
  /// 로드뷰가 생성된 뒤 호출되는 콜백입니다.
  ///
  /// 전달되는 [KakaoMapController]는 이 로드뷰의 WebView 를 감싸고 있으며,
  /// 로드뷰 페이지에는 지도용 JavaScript 함수가 없으므로 지도 전용 메서드
  /// (`setCenter`, `addPolyline` 등)는 동작하지 않습니다.
  ///
  /// 로드뷰를 제어하려면 [onRoadviewCreated] 를 사용하세요.
  final MapCreateCallback? onMapCreated;

  /// 로드뷰가 생성된 뒤 [KakaoRoadviewController]를 전달하는 콜백입니다.
  ///
  /// 시점 변경, 파노라마 이동, 오버레이 추가는 이 컨트롤러로 수행합니다.
  final RoadviewCreateCallback? onRoadviewCreated;

  /// 사용되지 않습니다.
  ///
  /// 로드뷰에는 지도의 확대 수준 개념이 없습니다. 하위호환을 위해 남겨둔
  /// 파라미터이며 값을 지정해도 표시에 영향을 주지 않습니다.
  final int currentLevel;

  /// 로드뷰를 찾을 기준 좌표입니다.
  ///
  /// 생략하면 제주 지역의 기본 좌표를 사용합니다.
  final LatLng? center;

  /// 표시할 파노라마 ID 입니다.
  ///
  /// 지정하면 [center] 주변 검색 대신 이 파노라마를 직접 표시합니다.
  final String? panoId;

  /// 로드뷰를 검색할 반경입니다. 단위는 미터이며 기본값은 50 입니다.
  final int radius;

  /// 로드뷰 초기 시점입니다.
  ///
  /// 지정하면 로드뷰가 준비된 직후 이 방향과 확대 수준으로 맞춥니다.
  final Viewpoint? viewpoint;

  /// 로드뷰 위에 표시할 마커 목록입니다.
  ///
  /// [Marker.altitude] 와 [Marker.range] 로 높이와 표시 거리를 지정할 수 있습니다.
  final List<Marker>? markers;

  /// 로드뷰 위에 표시할 커스텀 오버레이 목록입니다.
  final List<CustomOverlay>? customOverlays;

  /// 로드뷰 초기화가 끝났을 때 호출됩니다.
  final OnRoadviewInit? onRoadviewInit;

  /// 표시 중인 파노라마가 바뀌었을 때 호출됩니다.
  final OnRoadviewPanoIdChange? onPanoIdChange;

  /// 시점이 바뀌었을 때 호출됩니다.
  final OnRoadviewViewpointChange? onViewpointChange;

  /// 파노라마 좌표가 바뀌었을 때 호출됩니다.
  final OnRoadviewPositionChange? onPositionChange;

  /// 주변에 로드뷰가 없어 표시하지 못했을 때 호출됩니다.
  final OnRoadviewNotFound? onRoadviewNotFound;

  /// 문서 안의 링크를 탭했을 때 호출되는 콜백입니다. 지정하지 않으면 링크 탭은 무시됩니다.
  ///
  /// 플러그인은 지도가 사라지지 않도록 링크 이동을 항상 가로챕니다.
  final OnLinkTap? onLinkTap;

  /// 로드뷰 위 마커를 탭했을 때 호출됩니다.
  final OnCustomOverlayTap? onMarkerTap;

  /// 로드뷰 위 커스텀 오버레이를 탭했을 때 호출됩니다.
  final OnCustomOverlayTap? onCustomOverlayTap;

  /// Specifies which gestures should be consumed by the map.
  ///
  /// When this set is empty (default), the map will only handle pointer events
  /// for gestures that were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const KakaoRoadMap({
    super.key,
    this.onMapCreated,
    this.currentLevel = 3,
    this.center,
    this.markers,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.onRoadviewCreated,
    this.panoId,
    this.radius = 50,
    this.viewpoint,
    this.customOverlays,
    this.onRoadviewInit,
    this.onPanoIdChange,
    this.onViewpointChange,
    this.onPositionChange,
    this.onRoadviewNotFound,
    this.onLinkTap,
    this.onMarkerTap,
    this.onCustomOverlayTap,
  });

  @override
  State<KakaoRoadMap> createState() => _KakaoRoadMapState();
}

class _KakaoRoadMapState extends State<KakaoRoadMap>
    with WidgetsBindingObserver {
  late final KakaoMapBridge _bridge;
  KakaoMapController? _mapController;
  KakaoRoadviewController? _roadviewController;
  Timer? _relayoutTimer;
  bool _isInitialized = false;
  bool _isRoadviewReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _relayoutTimer?.cancel();
    unawaited(_bridge.dispose().catchError((_) {}));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 백그라운드에서 돌아왔을 때의 렌더링 문제(Flutter 3.27+)를 완화합니다.
    //
    // 이전에는 reload() 를 호출했으나, iOS(WKWebView)는 loadHtmlString 으로
    // 로드한 문서를 reload 하면 HTML 을 다시 실행하지 않아 로드뷰가 빈 화면이
    // 됩니다. 크기만 다시 계산하는 relayout() 으로 대체합니다.
    if (state == AppLifecycleState.resumed && _isInitialized) {
      _relayoutTimer?.cancel();
      _relayoutTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted && _isRoadviewReady) {
          _roadviewController?.relayout().catchError((_) {});
        }
      });
    }
  }

  void _initializeWebView() {
    final bridge = createKakaoMapBridge();
    _bridge = bridge;

    // dispose 가 항상 초기화된 컨트롤러를 보도록 HTML 로드보다 먼저 대입합니다.
    _mapController = KakaoMapController.fromBridge(bridge);
    _roadviewController = KakaoRoadviewController.fromBridge(bridge);

    _addJavaScriptChannels(bridge);
    bridge.loadHtml(_loadRoadview(), baseUrl: AuthRepository.instance.baseUrl);
    _isInitialized = true;
  }

  /// 채널 메시지를 안전하게 파싱해 콜백으로 전달합니다.
  void _handleChannel(String raw, void Function(Map<String, dynamic>) emit) {
    if (!mounted) return;
    try {
      emit(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      assert(() {
        debugPrint('KakaoRoadMap 채널 메시지 처리 실패: $e\n$st');
        return true;
      }());
    }
  }

  void _addJavaScriptChannels(KakaoMapBridge bridge) {
    bridge
      ..addJavaScriptChannel('onLinkTap', (String message) {
        _handleChannel(message, (json) {
          final url = Uri.tryParse(json['url']?.toString() ?? '');
          if (url != null) widget.onLinkTap?.call(url);
        });
      })
      ..addJavaScriptChannel('onRoadviewInit', (String message) {
        if (!mounted) return;
        _isRoadviewReady = true;
        // 위젯 속성으로 넘긴 오버레이를 준비 시점에 그립니다.
        unawaited(_syncOverlays());
        widget.onRoadviewInit?.call();
        widget.onMapCreated?.call(_mapController!);
        widget.onRoadviewCreated?.call(_roadviewController!);
      })
      ..addJavaScriptChannel('onRoadviewNotFound', (String message) {
        _handleChannel(message, (json) {
          widget.onRoadviewNotFound?.call(LatLng(
            (json['latitude'] as num).toDouble(),
            (json['longitude'] as num).toDouble(),
          ));
        });
      })
      ..addJavaScriptChannel('onRoadviewPanoIdChange', (String message) {
        _handleChannel(message, (json) {
          widget.onPanoIdChange?.call(json['panoId'].toString());
        });
      })
      ..addJavaScriptChannel('onRoadviewViewpointChange', (String message) {
        _handleChannel(message, (json) {
          widget.onViewpointChange?.call(Viewpoint.fromJson(json));
        });
      })
      ..addJavaScriptChannel('onRoadviewPositionChange', (String message) {
        _handleChannel(message, (json) {
          widget.onPositionChange?.call(LatLng(
            (json['latitude'] as num).toDouble(),
            (json['longitude'] as num).toDouble(),
          ));
        });
      })
      ..addJavaScriptChannel('onRoadviewMarkerTap', (String message) {
        _handleChannel(message, (json) {
          widget.onMarkerTap?.call(
            json['markerId'].toString(),
            LatLng(
              (json['latitude'] as num).toDouble(),
              (json['longitude'] as num).toDouble(),
            ),
          );
        });
      })
      ..addJavaScriptChannel('onRoadviewCustomOverlayTap', (String message) {
        _handleChannel(message, (json) {
          widget.onCustomOverlayTap?.call(
            json['customOverlayId'].toString(),
            LatLng(
              (json['latitude'] as num).toDouble(),
              (json['longitude'] as num).toDouble(),
            ),
          );
        });
      });
  }

  Future<void> _syncOverlays() async {
    final controller = _roadviewController;
    if (controller == null || !_isRoadviewReady) return;
    try {
      await controller.addMarker(markers: widget.markers);
      await controller.addCustomOverlay(customOverlays: widget.customOverlays);
    } catch (e) {
      assert(() {
        debugPrint('KakaoRoadMap 오버레이 동기화 실패: $e');
        return true;
      }());
    }
  }

  @override
  void didUpdateWidget(KakaoRoadMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isRoadviewReady) return;
    if (!identical(widget.markers, oldWidget.markers) ||
        !identical(widget.customOverlays, oldWidget.customOverlays)) {
      unawaited(_syncOverlays());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _bridge.buildView(
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  String _loadRoadview() {
    final isIOS = isIOSWebView;

    return htmlWrapper('''<script>
    ${JsRoadviewInit.getScript(
      center: widget.center,
      panoId: widget.panoId,
      viewpoint: widget.viewpoint,
      radius: widget.radius,
      isIOS: isIOS,
    )}
    ${JsRoadviewEvent.getScript(
      hasPanoIdChange: widget.onPanoIdChange != null,
      hasViewpointChange: widget.onViewpointChange != null,
      hasPositionChange: widget.onPositionChange != null,
    )}
    ${JsRoadviewOverlay.getScript(
      hasMarkerTapCallback: widget.onMarkerTap != null,
      hasCustomOverlayTapCallback: widget.onCustomOverlayTap != null,
    )}
</script>''');
  }
}
