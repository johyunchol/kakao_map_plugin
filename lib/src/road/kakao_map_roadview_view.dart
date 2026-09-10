import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../basic/callbacks.dart';
import '../basic/js_literal.dart';
import '../bridge/bridge_factory.dart';
import '../bridge/kakao_map_bridge.dart';
import '../bridge/platform_flags.dart';
import '../bridge/webview_bridge.dart';
import '../constants/wrapper.dart';
import '../js/roadview/js_roadview_link.dart';
import '../model/lat_lng.dart';
import '../model/viewpoint.dart';
import '../repository/auth_repository.dart';

/// 지도와 로드뷰의 표시 방식을 나타냅니다.
enum RoadviewViewMode {
  /// 지도만 표시합니다.
  map('map'),

  /// 로드뷰만 표시합니다.
  roadview('roadview'),

  /// 지도와 로드뷰를 위아래로 나누어 표시합니다.
  split('split');

  /// JavaScript 로 전달되는 값입니다.
  final String value;

  const RoadviewViewMode(this.value);
}

/// [KakaoMapRoadviewView]를 제어하는 컨트롤러입니다.
///
/// 지도와 로드뷰가 하나의 WebView 안에 함께 있으므로, 두 대상을 모두
/// 이 컨트롤러로 제어합니다.
class KakaoMapRoadviewController {
  final KakaoMapBridge _bridge;

  /// 내부적으로 사용하는 WebView 컨트롤러입니다.
  ///
  /// WebView 를 쓰지 않는 플랫폼(web)에서는 [StateError] 를 던집니다.
  WebViewController get webViewController =>
      _bridge.webViewController ??
      (throw StateError('이 플랫폼에서는 WebView 컨트롤러를 제공하지 않습니다.'));

  /// [KakaoMapRoadviewController]를 생성합니다.
  KakaoMapRoadviewController(WebViewController webViewController)
      : _bridge = WebViewBridge.fromController(webViewController);

  /// 라이브러리 내부용. 통신 계층을 직접 주입해 생성합니다.
  KakaoMapRoadviewController.fromBridge(this._bridge);

  Future<void> _run(String script) => _bridge.runJavaScript(script);

  Map<String, dynamic> _decode(Object? raw) {
    dynamic value = jsonDecode(raw is String ? raw : raw.toString());
    if (value is String) value = jsonDecode(value);
    return Map<String, dynamic>.from(value as Map);
  }

  /// 표시 모드를 변경합니다.
  ///
  /// [splitRatio]는 [RoadviewViewMode.split] 일 때 지도가 차지할 비율(%)이며
  /// 기본값은 50 입니다.
  Future<void> setViewMode(RoadviewViewMode mode, {int splitRatio = 50}) async {
    await _run('setViewMode(${jsStringLiteral(mode.value)}, '
        '${jsPrimitiveLiteral(splitRatio)});');
  }

  /// 지정한 좌표의 로드뷰로 이동합니다.
  ///
  /// 해당 위치에 로드뷰가 없으면 [KakaoMapRoadviewView.onRoadviewNotFound]
  /// 콜백이 호출되고 화면은 바뀌지 않습니다.
  Future<void> moveRoadview(LatLng position) async {
    await _run('moveRoadview(${position.latitude}, ${position.longitude});');
  }

  /// 로드뷰로 이동하면서 표시 모드를 분할로 전환합니다.
  Future<void> toggleRoadview(LatLng position) async {
    await _run('toggleRoadview(${position.latitude}, ${position.longitude});');
  }

  /// 지도의 중심 좌표를 변경합니다.
  Future<void> setMapCenter(LatLng position) async {
    await _run('setMapCenter(${position.latitude}, ${position.longitude});');
  }

  /// 지도의 확대 수준을 변경합니다.
  Future<void> setMapLevel(int level) async {
    await _run('setMapLevel(${jsPrimitiveLiteral(level)});');
  }

  /// 로드뷰의 시점을 변경합니다.
  Future<void> setViewpoint(Viewpoint viewpoint) async {
    await _run('setViewpoint(${viewpoint.pan}, ${viewpoint.tilt}, '
        '${viewpoint.zoom});');
  }

  /// 로드뷰의 현재 시점을 반환합니다.
  Future<Viewpoint> getViewpoint() async {
    final raw =
        await _bridge.runJavaScriptReturningResult('getViewpoint();');
    return Viewpoint.fromJson(_decode(raw));
  }

  /// 로드뷰의 현재 좌표를 반환합니다.
  Future<LatLng> getPosition() async {
    final raw =
        await _bridge.runJavaScriptReturningResult('getPosition();');
    return LatLng.fromJson(_decode(raw));
  }

  /// 지도와 로드뷰를 다시 그립니다.
  Future<void> relayout() async {
    await _run('relayout();');
  }
}

/// 지도와 로드뷰를 함께 표시하는 위젯입니다.
///
/// 지도를 탭하면 그 위치의 로드뷰로 이동하며, 동동이(MapWalker)로 현재
/// 로드뷰 위치와 바라보는 방향을 지도 위에 표시할 수 있습니다.
///
/// 지도와 로드뷰가 서로를 참조해야 하므로 하나의 WebView 안에서 동작합니다.
///
/// 예시:
/// ```dart
/// KakaoMapRoadviewView(
///   center: LatLng(33.450701, 126.570667),
///   useMapWalker: true,
///   showRoadviewOverlay: true,
///   onCreated: (controller) async {
///     await controller.setViewMode(RoadviewViewMode.split);
///   },
/// )
/// ```
class KakaoMapRoadviewView extends StatefulWidget {
  /// 지도와 로드뷰가 준비되면 호출되는 콜백입니다.
  final void Function(KakaoMapRoadviewController controller)? onCreated;

  /// 지도의 초기 중심 좌표입니다.
  final LatLng? center;

  /// 지도의 초기 확대 수준입니다.
  final int currentLevel;

  /// 로드뷰를 검색할 반경입니다. 단위는 미터이며 기본값은 50 입니다.
  final int radius;

  /// 초기 표시 모드입니다. 기본값은 지도만 표시합니다.
  final RoadviewViewMode initialViewMode;

  /// [RoadviewViewMode.split] 일 때 지도가 차지할 비율(%)입니다.
  final int splitRatio;

  /// 지도 위에 로드뷰가 있는 도로를 표시할지 여부입니다.
  final bool showRoadviewOverlay;

  /// 동동이(MapWalker)를 표시할지 여부입니다.
  ///
  /// 현재 로드뷰 위치와 바라보는 방향을 지도 위에 아이콘으로 나타냅니다.
  final bool useMapWalker;

  /// 로드뷰 초기화가 끝났을 때 호출됩니다.
  final OnRoadviewInit? onRoadviewInit;

  /// 로드뷰 위치가 바뀌었을 때 호출됩니다.
  final OnRoadviewPositionChange? onPositionChange;

  /// 주변에 로드뷰가 없어 이동하지 못했을 때 호출됩니다.
  final OnRoadviewNotFound? onRoadviewNotFound;

  /// Specifies which gestures should be consumed by the view.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const KakaoMapRoadviewView({
    super.key,
    this.onCreated,
    this.center,
    this.currentLevel = 3,
    this.radius = 50,
    this.initialViewMode = RoadviewViewMode.map,
    this.splitRatio = 50,
    this.showRoadviewOverlay = true,
    this.useMapWalker = true,
    this.onRoadviewInit,
    this.onPositionChange,
    this.onRoadviewNotFound,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  @override
  State<KakaoMapRoadviewView> createState() => _KakaoMapRoadviewViewState();
}

class _KakaoMapRoadviewViewState extends State<KakaoMapRoadviewView>
    with WidgetsBindingObserver {
  late final KakaoMapBridge _bridge;
  KakaoMapRoadviewController? _controller;
  Timer? _relayoutTimer;
  bool _isReady = false;

  // 마지막으로 측정된 레이아웃 크기. 바뀌면 relayout 해 지도/로드뷰 크기를 맞춥니다.
  Size? _lastLayoutSize;

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
    if (state == AppLifecycleState.resumed && _isReady) {
      _relayoutTimer?.cancel();
      _relayoutTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted && _isReady) {
          _controller?.relayout().catchError((_) {});
        }
      });
    }
  }

  void _initializeWebView() {
    final bridge = createKakaoMapBridge();
    _bridge = bridge;
    _controller = KakaoMapRoadviewController.fromBridge(bridge);
    _addJavaScriptChannels(bridge);
    bridge.loadHtml(_loadHtml(), baseUrl: AuthRepository.instance.baseUrl);
  }

  void _handleChannel(String raw, void Function(Map<String, dynamic>) emit) {
    if (!mounted) return;
    try {
      emit(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      assert(() {
        debugPrint('KakaoMapRoadviewView 채널 메시지 처리 실패: $e\n$st');
        return true;
      }());
    }
  }

  void _addJavaScriptChannels(KakaoMapBridge bridge) {
    bridge
      ..addJavaScriptChannel('onMapCreated', (String message) {
        if (!mounted) return;
        _isReady = true;
        // 초기 표시 모드를 적용한 뒤 사용자 콜백을 호출합니다.
        unawaited(_controller!
            .setViewMode(widget.initialViewMode,
                splitRatio: widget.splitRatio)
            .then((_) {
          if (mounted) widget.onCreated?.call(_controller!);
        }).catchError((_) {}));
      })
      ..addJavaScriptChannel('onRoadviewInit', (String message) {
        if (!mounted) return;
        widget.onRoadviewInit?.call();
      })
      ..addJavaScriptChannel('onRoadviewPositionChange', (String message) {
        _handleChannel(message, (json) {
          widget.onPositionChange?.call(LatLng(
            (json['latitude'] as num).toDouble(),
            (json['longitude'] as num).toDouble(),
          ));
        });
      })
      ..addJavaScriptChannel('onRoadviewNotFound', (String message) {
        _handleChannel(message, (json) {
          widget.onRoadviewNotFound?.call(LatLng(
            (json['latitude'] as num).toDouble(),
            (json['longitude'] as num).toDouble(),
          ));
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (_lastLayoutSize != size) {
          final sizeChanged = _lastLayoutSize != null;
          _lastLayoutSize = size;
          // 위젯 크기가 바뀌면 WebView 안의 지도/로드뷰도 다시 배치합니다.
          if (sizeChanged && _isReady) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isReady) {
                _controller?.relayout().catchError((_) {});
              }
            });
          }
        }
        return _bridge.buildView(
          gestureRecognizers: widget.gestureRecognizers,
        );
      },
    );
  }

  String _loadHtml() {
    return htmlWrapperWithRoadview('''<script>
    ${JsRoadviewLink.getScript(
      center: widget.center,
      currentLevel: widget.currentLevel,
      radius: widget.radius,
      showRoadviewOverlay: widget.showRoadviewOverlay,
      useMapWalker: widget.useMapWalker,
      isIOS: isIOSWebView,
    )}
</script>''');
  }
}
