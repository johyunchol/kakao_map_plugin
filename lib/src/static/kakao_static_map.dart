part of kakao_map_plugin;

class KakaoStaticMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
  final List<Marker>? markers;

  const KakaoStaticMap({
    Key? key,
    this.onMapCreated,
    this.currentLevel = 3,
    this.center,
    this.markers,
  }) : super(key: key);

  @override
  State<KakaoStaticMap> createState() => _KakaoStaticMapState();
}

class _KakaoStaticMapState extends State<KakaoStaticMap> {
  String json = '';
  List<Map<String, dynamic>> mapList = [];
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    initMarkers();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_loadMap());

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
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
