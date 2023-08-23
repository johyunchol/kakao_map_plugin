import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 선의 거리 계산하기
/// https://apis.map.kakao.com/web/sample/calculatePolylineDistance/
class Overlay16LineDistanceScreen extends StatefulWidget {
  const Overlay16LineDistanceScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay16LineDistanceScreen> createState() =>
      _Overlay16LineDistanceScreenState();
}

class _Overlay16LineDistanceScreenState
    extends State<Overlay16LineDistanceScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};
  List<Polyline> polylines = [];
  List<CustomOverlay> customOverlays = [];

  bool drawingFlag = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? selectedTitle),
      ),
      body: KakaoMap(
        onMapCreated: ((controller) async {
          mapController = controller;

          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: await mapController.getCenter(),
            width: 30,
            height: 44,
            offsetX: 15,
            offsetY: 44,
            markerImageSrc:
                'https://w7.pngwing.com/pngs/96/889/png-transparent-marker-map-interesting-places-the-location-on-the-map-the-location-of-the-thumbnail.png',
          ));

          setState(() {});
        }),
        onMapTap: (latLng) {
          if (!drawingFlag) {
            polylines.clear();

            polylines.add(
              Polyline(
                polylineId: 'clickLine',
                points: [latLng],
                strokeWidth: 3,
                strokeColor: const Color(0xffdb4040),
                strokeOpacity: 1,
                strokeStyle: StrokeStyle.solid,
              ),
            );

            polylines.add(
              Polyline(
                polylineId: 'moveLine',
                strokeWidth: 3,
                strokeColor: const Color(0xffdb4040),
                strokeOpacity: 0.5,
                strokeStyle: StrokeStyle.solid,
              ),
            );
          } else {
            // 선이 그려지고 있는 상태이면

            // // 그려지고 있는 선의 좌표 배열을 얻어옵니다
            // var path = clickLine.getPath();
            //
            // // 좌표 배열에 클릭한 위치를 추가합니다
            // path.push(clickPosition);
            //
            // // 다시 선에 좌표 배열을 설정하여 클릭 위치까지 선을 그리도록 설정합니다
            // clickLine.setPath(path);
            //
            // var distance = Math.round(clickLine.getLength());
            // displayCircleDot(clickPosition, distance);
          }

          setState(() {});
        },
        markers: markers.toList(),
        polylines: polylines,
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
