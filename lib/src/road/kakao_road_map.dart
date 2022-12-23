part of kakao_map_plugin;

class KakaoRoadMap extends StatefulWidget {
  final MapCreateCallback? onMapCreated;
  final int currentLevel;
  final LatLng? center;
  final List<Marker>? markers;

  KakaoRoadMap({
    Key? key,
    this.onMapCreated,
    this.currentLevel = 3,
    this.center,
    this.markers,
  }) : super(key: key);

  @override
  State<KakaoRoadMap> createState() => _KakaoRoadMapState();
}

class _KakaoRoadMapState extends State<KakaoRoadMap> {
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
  var roadviewContainer = document.getElementById('map'); //로드뷰를 표시할 div
  var roadview = new kakao.maps.Roadview(roadviewContainer); //로드뷰 객체
  var roadviewClient = new kakao.maps.RoadviewClient(); //좌표로부터 로드뷰 파노ID를 가져올 로드뷰 helper객체

  var position = new kakao.maps.LatLng(33.450701, 126.570667);

  // 특정 위치의 좌표와 가까운 로드뷰의 panoId를 추출하여 로드뷰를 띄운다.
  roadviewClient.getNearestPanoId(position, 50, function (panoId) {
    roadview.setPanoId(panoId, position); //panoId와 중심좌표를 통해 로드뷰 실행
  });

</script>
</body>

</html>
''', mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();
  }
}
