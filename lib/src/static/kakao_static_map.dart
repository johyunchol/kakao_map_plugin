part of kakao_map_plugin;

class KakaoStaticMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
  final List<Marker>? markers;

  KakaoStaticMap({
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

  @override
  Widget build(BuildContext context) {
    getMarkers();
    return WebView(
      initialUrl: _loadMap(),
      javascriptMode: JavascriptMode.unrestricted,
      debuggingEnabled: true,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory(() => EagerGestureRecognizer()),
      },
    );
  }

  getMarkers() {
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

  _loadMap() {
    return Uri.dataFromString('''<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
  <script type="text/javascript"
          src='https://dapi.kakao.com/v2/maps/sdk.js?autoload=true&appkey=${AuthRepository.instance.appKey}&libraries=services,clusterer,drawing'></script>
</head>

<body style="margin: 0;">
<div id="map" style="width: 100vw; height: 100vh;"></div>

<script>
  let map = null;

  getMarkers();

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
  
  for(let i = 0; i < list.length; i++) {
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

</script>
</body>

</html>
''', mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();
  }
}
