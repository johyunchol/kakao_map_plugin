import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 이미지 마커와 커스텀 오버레이
/// https://apis.map.kakao.com/web/sample/markerWithCustomOverlay/
class Overlay24ImageMarkerCustomOverlayScreen extends StatefulWidget {
  const Overlay24ImageMarkerCustomOverlayScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay24ImageMarkerCustomOverlayScreen> createState() =>
      _Overlay24ImageMarkerCustomOverlayScreenState();
}

class _Overlay24ImageMarkerCustomOverlayScreenState
    extends State<Overlay24ImageMarkerCustomOverlayScreen> {
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
        center: LatLng(37.3608681, 126.9306506),
      ),
    );
  }
}
