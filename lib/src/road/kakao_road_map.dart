import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../basic/callbacks.dart';
import '../basic/kakao_map_controller.dart';
import '../basic/marker.dart';
import '../constants/wrapper.dart';
import '../model/lat_lng.dart';
import '../repository/auth_repository.dart';

/// 카카오 로드뷰를 표시하는 위젯입니다.
///
/// [center] 좌표에서 가장 가까운 로드뷰를 찾아 표시합니다.
/// 해당 위치에 로드뷰가 없으면 아무것도 표시되지 않습니다.
///
/// 예시:
/// ```dart
/// KakaoRoadMap(
///   center: LatLng(33.450701, 126.570667),
///   markers: [
///     Marker(
///       markerId: 'm1',
///       latLng: LatLng(33.450701, 126.570667),
///       infoWindowContent: '<div>여기</div>',
///     ),
///   ],
/// )
/// ```
class KakaoRoadMap extends StatefulWidget {
  /// 로드뷰가 생성된 뒤 호출되는 콜백입니다.
  ///
  /// 전달되는 [KakaoMapController]는 이 로드뷰의 WebView 를 감싸고 있으며,
  /// 로드뷰 페이지에는 지도용 JavaScript 함수가 없으므로 지도 전용 메서드
  /// (`setCenter`, `addPolyline` 등)는 동작하지 않습니다. `relayout()` 처럼
  /// 로드뷰에도 정의된 메서드만 사용하세요.
  final MapCreateCallback? onMapCreated;

  /// 사용되지 않습니다.
  ///
  /// 로드뷰에는 지도의 확대 수준 개념이 없습니다. 하위호환을 위해 남겨둔
  /// 파라미터이며 값을 지정해도 표시에 영향을 주지 않습니다.
  final int currentLevel;

  /// 로드뷰를 찾을 기준 좌표입니다.
  ///
  /// 생략하면 제주 지역의 기본 좌표를 사용합니다.
  final LatLng? center;

  /// 로드뷰 위에 표시할 마커 목록입니다.
  ///
  /// 각 마커의 [Marker.latLng] 위치에 마커가 놓이며,
  /// [Marker.infoWindowContent] 가 있으면 인포윈도우가 함께 열립니다.
  final List<Marker>? markers;

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
  });

  @override
  State<KakaoRoadMap> createState() => _KakaoRoadMapState();
}

class _KakaoRoadMapState extends State<KakaoRoadMap> with WidgetsBindingObserver {
  late WebViewController _webViewController;
  KakaoMapController? _controller;
  Timer? _relayoutTimer;
  bool _isInitialized = false;

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
        if (mounted && _isInitialized) {
          _webViewController.runJavaScript('relayout();').catchError((_) {});
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

    _controller = KakaoMapController(controller);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('onRoadviewCreated',
          onMessageReceived: (JavaScriptMessage message) {
        if (!mounted) return;
        widget.onMapCreated?.call(_controller!);
      })
      ..loadHtmlString(_loadMap(), baseUrl: AuthRepository.instance.baseUrl);

    if (controller.platform is AndroidWebViewController) {
      if (kDebugMode) {
        AndroidWebViewController.enableDebugging(true);
      }
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Set permission handler for Android (Flutter 3.27+ fix)
      // 주의: 로드뷰 표시에 필요하지 않은 권한 요청까지 무조건 승인합니다.
      // 카메라/마이크 등 민감한 권한이 필요한 페이지를 로드하지 않는 한도 내에서만 사용하세요.
      androidController
          .setOnPlatformPermissionRequest((PlatformWebViewPermissionRequest request) async {
        await request.grant();
      });
    }

    _webViewController = controller;
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _webViewController,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  /// 마커 목록을 로드뷰 스크립트에 넘길 JSON 으로 직렬화합니다.
  ///
  /// 매 build 마다 리스트에 누적되던 문제를 피하기 위해 호출할 때마다
  /// 새 리스트를 만듭니다.
  String _markersJson() {
    final markers = widget.markers;
    if (markers == null || markers.isEmpty) return '[]';

    return jsonEncode(markers
        .map((item) => {
              'markerId': item.markerId,
              'latitude': item.latLng.latitude,
              'longitude': item.latLng.longitude,
              'text': item.infoWindowContent,
            })
        .toList(growable: false));
  }

  String _loadMap() {
    // 좌표는 숫자 리터럴로, 마커 목록은 JSON 문자열 리터럴로 안전하게 전달합니다.
    final latitude = widget.center?.latitude ?? 33.450701;
    final longitude = widget.center?.longitude ?? 126.570667;
    final markersLiteral = jsonEncode(_markersJson());

    return htmlWrapper('''<script>
  let roadview = null;
  let roadviewClient = null;
  let roadviewMarkers = [];

  window.onload = function () {
    // Kakao Maps SDK가 완전히 로드된 후 로드뷰를 초기화합니다
    kakao.maps.load(function() {
      initializeRoadview();
    });
  }

  /// 로드뷰 컨테이너 크기가 바뀌었을 때 다시 그립니다.
  function relayout() {
    if (roadview) roadview.relayout();
  }

  function addRoadviewMarkers() {
    const list = JSON.parse($markersLiteral);
    for (let i = 0; i < list.length; i++) {
      const item = list[i];
      const marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(item.latitude, item.longitude),
        map: roadview
      });
      marker['id'] = item.markerId;
      roadviewMarkers.push(marker);

      if (item.text && item.text !== '') {
        const infoWindow = new kakao.maps.InfoWindow({ content: item.text });
        infoWindow.open(roadview, marker);
      }
    }
  }

  function initializeRoadview() {
    const container = document.getElementById('map'); //로드뷰를 표시할 div
    roadview = new kakao.maps.Roadview(container); //로드뷰 객체
    roadviewClient = new kakao.maps.RoadviewClient(); //좌표로부터 로드뷰 파노ID를 가져올 로드뷰 helper객체

    let position = new kakao.maps.LatLng($latitude, $longitude);

    // 로드뷰 초기화가 끝난 뒤에 마커를 올려야 정상적으로 표시됩니다.
    kakao.maps.event.addListener(roadview, 'init', function () {
      addRoadviewMarkers();
      onRoadviewCreated.postMessage(JSON.stringify({ ready: true }));
    });

    // 특정 위치의 좌표와 가까운 로드뷰의 panoId를 추출하여 로드뷰를 띄운다.
    roadviewClient.getNearestPanoId(position, 50, function (panoId) {
      // 로드뷰가 없는 지역이면 panoId 가 null 이므로 호출하지 않는다.
      if (panoId === null) {
        onRoadviewCreated.postMessage(JSON.stringify({ ready: false }));
        return;
      }
      roadview.setPanoId(panoId, position); //panoId와 중심좌표를 통해 로드뷰 실행
    });
  }
</script>''');
  }
}
