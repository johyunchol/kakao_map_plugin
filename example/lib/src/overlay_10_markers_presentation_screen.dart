import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 여러개 마커 표시하기
/// https://apis.map.kakao.com/web/sample/multipleMarkerImage/
class Overlay10MarkersPresentationScreen extends StatefulWidget {
  const Overlay10MarkersPresentationScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay10MarkersPresentationScreen> createState() =>
      _Overlay10MarkersPresentationScreenState();
}

class _Overlay10MarkersPresentationScreenState
    extends State<Overlay10MarkersPresentationScreen> {
  late KakaoMapController mapController;

  Set<Marker> markers = {};

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
            latLng: LatLng(33.450705, 126.570677),
            width: 24,
            height: 35,
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
          ));

          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: LatLng(33.450936, 126.569477),
            width: 24,
            height: 35,
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
          ));

          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: LatLng(33.450879, 126.569940),
            width: 24,
            height: 35,
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
          ));

          markers.add(Marker(
            markerId: markers.length.toString(),
            latLng: LatLng(33.451393, 126.570738),
            width: 24,
            height: 35,
            markerImageSrc:
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
          ));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(33.450701, 126.570667),
      ),
    );
  }
}
