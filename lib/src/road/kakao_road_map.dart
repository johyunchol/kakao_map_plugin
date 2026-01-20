part of '../../kakao_map_plugin.dart';

class KakaoRoadMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
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
  String json = '';
  List<Map<String, dynamic>> mapList = [];
  late WebViewController _webViewController;
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes to fix WebView rendering issues
    // when returning from background (Flutter 3.27+ issue)
    if (state == AppLifecycleState.resumed && _isInitialized) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _webViewController.reload();
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
      ..loadHtmlString(_loadMap(), baseUrl: AuthRepository.instance.baseUrl);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Set permission handler for Android (Flutter 3.27+ fix)
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
    getMarkers();
    return WebViewWidget(
      controller: _webViewController,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  void getMarkers() {
    int length = widget.markers?.length ?? 0;

    for (int i = 0; i < length; i++) {
      final item = widget.markers![i];
      Map<String, dynamic> marker = {
        "markerId": item.markerId,
        "latitude": item.latLng.latitude,
        "longitude": item.latLng.longitude,
        "text": item.infoWindowContent,
      };

      mapList.add(marker);
    }

    json = jsonEncode(mapList);
  }

  String _loadMap() {
    return _htmlWrapper('''<script>
  let roadview = null;
  let roadviewClient = null;

  window.onload = function () {
    // Kakao Maps SDK가 완전히 로드된 후 로드뷰를 초기화합니다
    kakao.maps.load(function() {
      initializeRoadview();
    });
  }

  function initializeRoadview() {
    const container = document.getElementById('map'); //로드뷰를 표시할 div
    roadview = new kakao.maps.Roadview(container); //로드뷰 객체
    roadviewClient = new kakao.maps.RoadviewClient(); //좌표로부터 로드뷰 파노ID를 가져올 로드뷰 helper객체

    let position = new kakao.maps.LatLng(${widget.center?.latitude ?? 33.450701}, ${widget.center?.longitude ?? 126.570667});

    // 특정 위치의 좌표와 가까운 로드뷰의 panoId를 추출하여 로드뷰를 띄운다.
    roadviewClient.getNearestPanoId(position, 50, function (panoId) {
      roadview.setPanoId(panoId, position); //panoId와 중심좌표를 통해 로드뷰 실행
    });
  }
</script>''');
  }
}
