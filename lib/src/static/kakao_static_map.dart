part of '../../kakao_map_plugin.dart';

class KakaoStaticMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
  final List<Marker>? markers;

  const KakaoStaticMap({
    super.key,
    this.onMapCreated,
    this.currentLevel = 3,
    this.center,
    this.markers,
  });

  @override
  State<KakaoStaticMap> createState() => _KakaoStaticMapState();
}

class _KakaoStaticMapState extends State<KakaoStaticMap> with WidgetsBindingObserver {
  String json = '';
  List<Map<String, dynamic>> mapList = [];
  late WebViewController _webViewController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initMarkers();
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
    return WebViewWidget(
      controller: _webViewController,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory(() => EagerGestureRecognizer()),
      },
    );
  }

  initMarkers() {
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
    return _htmlWrapper("""<script>
  let map = null;

  window.onload = function () {
    // Kakao Maps SDK가 완전히 로드된 후 지도를 초기화합니다
    kakao.maps.load(function() {
      initializeStaticMap();
    });
  }

  function initializeStaticMap() {
    const staticMapContainer = document.getElementById('map');

    let center = new kakao.maps.LatLng(33.450701, 126.570667);
    if (${widget.center != null}) {
      center = new kakao.maps.LatLng(${widget.center?.latitude}, ${widget.center?.longitude});
    }

    const staticMapOption = {
      center: center,
      level: ${widget.currentLevel},
      marker: getMarkers(),
    };

    map = new kakao.maps.StaticMap(staticMapContainer, staticMapOption);
  }

  function getMarkers() {

    let markers = [];
    const list = $json;

    for (let i = 0; i < list.length; i++) {
      const item = list[i];
      const obj = {
        'position': new kakao.maps.LatLng(item.latitude, item.longitude),
      }

      if (item.text !== null && item.text !== '') {
        obj['text'] = item.text;
      }

      markers.push(obj);
    }

    return markers;
  }
</script>""");
  }
}
