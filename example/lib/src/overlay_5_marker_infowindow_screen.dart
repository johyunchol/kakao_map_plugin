import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:kakao_map_plugin_example/src/home_screen.dart';

/// 마커에 인포윈도우 표시하기
/// https://apis.map.kakao.com/web/sample/markerWithInfoWindow/
class Overlay5MarkerInfoWindowScreen extends StatefulWidget {
  const Overlay5MarkerInfoWindowScreen({Key? key, this.title})
      : super(key: key);

  final String? title;

  @override
  State<Overlay5MarkerInfoWindowScreen> createState() =>
      _Overlay5MarkerInfoWindowScreenState();
}

class _Overlay5MarkerInfoWindowScreenState
    extends State<Overlay5MarkerInfoWindowScreen> {
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
            infoWindowContent:
                '<div style="padding:15px;">Hello World! <br><a href="https://map.kakao.com/link/map/Hello World!,33.450701,126.570667" style="color:blue" target="_blank">큰지도보기</a> <a href="https://map.kakao.com/link/to/Hello World!,33.450701,126.570667" style="color:blue" target="_blank">길찾기</a></div>',
            infoWindowRemovable: true,
            infoWindowFirstShow: true,
          ));

          setState(() {});
        }),
        markers: markers.toList(),
        center: LatLng(37.3608681, 126.9306506),
        onMarkerTap: ((markerId, latLng, zoomLevel) {}),
      ),
    );
  }
}
