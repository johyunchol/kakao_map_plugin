import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커에 클릭 이벤트 등록하기
/// https://apis.map.kakao.com/web/sample/addMarkerClickEvent/
class Overlay6MarkerClickScreen extends StatefulWidget {
  const Overlay6MarkerClickScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<Overlay6MarkerClickScreen> createState() =>
      _Overlay6MarkerClickScreenState();
}

class _Overlay6MarkerClickScreenState extends State<Overlay6MarkerClickScreen> {
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
            markerId: UniqueKey().toString(),
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
        markers: markers.toList(),
        onMarkerTap: ((markerId, latLng, zoomLevel) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('marker click:\n\n$latLng')));
        }),
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
